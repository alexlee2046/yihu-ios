#!/usr/bin/env python3
"""On-demand req→Radar adapter. Loopback only; no data files, cache or timer.

Replies are disabled unless --writer-user-id explicitly binds an authorized
personal Tailscale identity. Serve must strip/inject identity headers (no Funnel).
No task/reply text, login names or raw CLI errors are logged.
"""
import argparse
from datetime import datetime, timezone, timedelta
from email.header import decode_header, make_header
import hashlib
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys
import uuid

MAX_BYTES = 2 * 1024 * 1024
WAITING = {"等你决策", "等你验收"}
READ_ERRORS = (ValueError, TypeError, OSError, RuntimeError, AttributeError, KeyError)


class ReplyError(Exception):
    def __init__(self, code, status=409, target=None):
        self.code, self.status, self.target = code, status, target


def command(args, timeout=18, input_data=None):
    process = subprocess.Popen(args, stdin=subprocess.PIPE if input_data is not None else subprocess.DEVNULL,
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True)
    try:
        output, error = process.communicate(input_data, timeout=timeout)
    except BaseException as exception:
        if process.poll() is None:
            os.killpg(process.pid, signal.SIGKILL)
        process.communicate()
        if isinstance(exception, subprocess.TimeoutExpired):
            raise RuntimeError("command timed out") from None
        raise
    return process.returncode, output, error


def graphql(query, variables):
    # stdin keeps GraphQL data out of process arguments; no provider error echo.
    process = subprocess.Popen(["gh", "api", "graphql", "--input", "-"], stdin=subprocess.PIPE,
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True)
    try:
        output, _ = process.communicate(json.dumps({"query": query, "variables": variables}).encode(), timeout=15)
    except BaseException as exception:
        if process.poll() is None:
            os.killpg(process.pid, signal.SIGKILL)
        process.communicate()
        if isinstance(exception, subprocess.TimeoutExpired):
            raise RuntimeError("provider timed out") from None
        raise
    if process.returncode or len(output) > MAX_BYTES * 4:
        raise RuntimeError("provider unavailable")
    result = json.loads(output)
    if result.get("errors") or not isinstance(result.get("data"), dict):
        raise RuntimeError("incomplete provider response")
    return result["data"]


def ledger_response(records):
    if not isinstance(records, list):
        raise ValueError("invalid ledger response")
    tasks, ids = [], set()
    for record in records:
        if not isinstance(record, dict) or type(record.get("archived")) is not bool:
            raise ValueError("invalid ledger record")
        ident = record.get("id")
        if not isinstance(ident, str) or not ident or ident in ids:
            raise ValueError("missing or duplicate ledger identity")
        ids.add(ident)
        if record["archived"]:
            continue
        title = record.get("title")
        if not isinstance(title, str) or not title.strip():
            raise ValueError("unavailable ledger title")
        action = {"id": ident, "project": record.get("project") or "未分类", "title": title}
        for field in ("status", "next", "url", "priority", "evidence", "session", "window_status"):
            value = record.get(field)
            if value is not None and not isinstance(value, str):
                raise ValueError("invalid ledger field")
            action[field] = value or ""
        if not isinstance(action["project"], str) or not action["project"].strip():
            raise ValueError("invalid project identity")
        updated = record.get("updated_at")
        if updated is not None:
            stamp = datetime.fromisoformat(updated.replace("Z", "+00:00"))
            if stamp.tzinfo is None or not 0 <= stamp.timestamp() <= 253402300799:
                raise ValueError("invalid ledger timestamp")
            action["timestamp"] = stamp.timestamp()
        tasks.append(action)
    tasks.sort(key=lambda item: (-item.get("timestamp", 0), item["id"]))
    return {"date_str": datetime.now(timezone(timedelta(hours=8))).strftime("%Y-%m-%d %H:%M"),
            "tasks": tasks, "decisions": [item for item in tasks if item["status"] in WAITING],
            "active": [], "stale": [], "cold": []}


def notification_transition(previous, current):
    """Event contract only: confirmed private-ledger status entry, never polling.

    Caller supplies before/after records from an authorized write/readback.
    This function does not send APNs or grant subscription/write authority.
    """
    if not isinstance(previous, dict) or not isinstance(current, dict):
        raise ValueError("invalid transition")
    ident = current.get("id")
    if not isinstance(ident, str) or not re.fullmatch(r"PVTI_[A-Za-z0-9_-]{1,120}", ident) or previous.get("id") != ident:
        raise ValueError("invalid transition identity")
    if current.get("archived") is not False or previous.get("archived") is not False:
        return None
    if current.get("status") not in WAITING or previous.get("status") == current.get("status"):
        return None
    version = current.get("version")
    if not isinstance(version, str) or not re.fullmatch(r"[0-9a-f]{64}", version):
        raise ValueError("missing confirmed version")
    # Repeated delivery of the same confirmed item revision has one event key.
    key = hashlib.sha256(json.dumps([ident, version], separators=(",", ":")).encode()).hexdigest()
    return {"version": 1, "event_key": key, "item_id": ident, "item_version": version}


def read_ledger():
    code, output, _ = command(["req", "list", "--all", "--json"], timeout=28)
    if code or len(output) > MAX_BYTES * 4:
        raise RuntimeError("ledger unavailable")
    return ledger_response(json.loads(output))


TARGET_QUERY = """query($id:ID!) { node(id:$id) { ... on ProjectV2Item {
 id fullDatabaseId isArchived project { id public viewerCanUpdate }
 content { __typename ... on Issue { id title url repository { isPrivate viewerPermission } }
 ... on DraftIssue { id title body } }
 fieldValues(first:30) { nodes {
 ... on ProjectV2ItemFieldSingleSelectValue { name field { ... on ProjectV2FieldCommon { name } } }
 ... on ProjectV2ItemFieldTextValue { text field { ... on ProjectV2FieldCommon { name } } }
 } pageInfo { hasNextPage } }
} } }"""
COMMENTS_QUERY = """query($id:ID!, $after:String) { node(id:$id) { ... on Issue {
 comments(first:100,after:$after) { totalCount nodes { body } pageInfo { hasNextPage endCursor } }
} } }"""


def target_item(ident, epoch):
    executable = shutil.which("req")
    if not executable:
        raise RuntimeError("req unavailable")
    config_path = os.environ.get("REQ_CONFIG") or str(Path(executable).resolve().parent / "config.json")
    config = json.loads(Path(config_path).read_text())
    node = graphql(TARGET_QUERY, {"id": ident})["node"]
    if not node or node.get("project", {}).get("id") != config["project"]["id"]:
        raise ReplyError("target_unavailable", 404)
    if node["project"].get("public") is not False or node["project"].get("viewerCanUpdate") is not True:
        raise ReplyError("forbidden", 403)
    content = node.get("content") or {}
    kind = content.get("__typename")
    if kind not in {"Issue", "DraftIssue"} or not content.get("id"):
        raise ReplyError("forbidden", 403)
    if kind == "Issue" and (content.get("repository", {}).get("isPrivate") is not True or
                            content.get("repository", {}).get("viewerPermission") not in {"ADMIN", "MAINTAIN", "WRITE"}):
        raise ReplyError("forbidden", 403)
    values = node["fieldValues"]
    if values.get("pageInfo", {}).get("hasNextPage") is not False:
        raise RuntimeError("incomplete fields")
    fields = {v["field"]["name"]: v.get("name", v.get("text", "")) for v in values["nodes"] if v}
    url = content.get("url")
    if kind == "DraftIssue":
        if not node.get("fullDatabaseId"):
            raise ReplyError("target_unavailable", 404)
        url = config["project"]["url"] + "?pane=issue&itemId=" + str(node["fullDatabaseId"])
    if not content.get("title") or not url:
        raise ReplyError("target_unavailable", 404)
    target = {"id": ident, "epoch": epoch, "title": content["title"], "url": url,
              "status": fields.get("Status") or "", "next": fields.get("下一步") or ""}
    eligible = not node["isArchived"] and target["status"] in WAITING
    target["eligible"] = eligible
    revision = dict(target, archived=node["isArchived"], kind=kind, content_id=content["id"])
    target["version"] = hashlib.sha256(json.dumps(revision, sort_keys=True, ensure_ascii=False).encode()).hexdigest()
    return target, content, eligible


def receipt(content, request_id, digest):
    prefix = "<!-- yihu-reply:" + request_id + ":"
    expected = prefix + digest + " -->"

    def match(body):
        if prefix not in body:
            return False
        if expected not in body:
            raise ReplyError("request_reused")
        return True

    if content["__typename"] == "DraftIssue":
        return match(content.get("body", ""))
    cursor, seen, count, total = None, set(), 0, None
    for _ in range(100):
        page = graphql(COMMENTS_QUERY, {"id": content["id"], "after": cursor})["node"]["comments"]
        if total is None:
            total = page["totalCount"]
        if page["totalCount"] != total or not isinstance(page["nodes"], list):
            raise RuntimeError("comments changed during receipt lookup")
        for row in page["nodes"]:
            if not isinstance(row, dict) or not isinstance(row.get("body"), str):
                raise RuntimeError("incomplete comments")
            if match(row["body"]):
                return True
        count += len(page["nodes"])
        info = page["pageInfo"]
        if info["hasNextPage"] is False:
            if count != total:
                raise RuntimeError("incomplete comments")
            return False
        cursor = info.get("endCursor")
        if not cursor or cursor in seen:
            raise RuntimeError("invalid comments pagination")
        seen.add(cursor)
    raise RuntimeError("receipt lookup limit reached")


def reply(payload, writer_user_id, epoch, attempts):
    operation, ident = payload.get("operation"), payload.get("id")
    if operation not in {"prepare", "submit", "check"} or not isinstance(ident, str) or not re.fullmatch(r"PVTI_[A-Za-z0-9_-]{1,120}", ident):
        raise ReplyError("invalid_request", 400)
    target, content, eligible = target_item(ident, epoch)
    if operation == "prepare":
        if not eligible:
            raise ReplyError("target_changed", target=target)
        return {"outcome": "prepared", "target": target}
    text, request_id = payload.get("text"), payload.get("request_id")
    if not isinstance(text, str) or not text.strip() or len(text) > 4000 or not isinstance(request_id, str):
        raise ReplyError("invalid_request", 400)
    try:
        request_id = str(uuid.UUID(request_id))
    except ValueError:
        raise ReplyError("invalid_request", 400) from None
    digest = hashlib.sha256(json.dumps([writer_user_id, ident, text], ensure_ascii=False).encode()).hexdigest()
    if receipt(content, request_id, digest):
        return {"outcome": "recorded", "target": target}
    key = (writer_user_id, ident, request_id)
    if payload.get("epoch") != epoch:
        # A restarted server cannot prove a prior ambiguous mutation did not run.
        raise ReplyError("result_unknown", 503)
    if key in attempts:
        if attempts[key] != digest:
            raise ReplyError("request_reused")
        raise ReplyError("result_unknown", 503)
    if operation == "check":
        # This process never began a mutation for this ID. Unlike a missing comment,
        # that is sufficient evidence to offer a safe retry with the same ID.
        return {"outcome": "absent", "target": target}
    if payload.get("confirmed") is not True:
        raise ReplyError("invalid_request", 400)
    # Receipt pagination can take time. Re-read immediately before mutation,
    # including private membership/permissions, instead of using the first read.
    target, _, eligible = target_item(ident, epoch)
    if not eligible or payload.get("version") != target["version"]:
        raise ReplyError("target_changed", target=target)
    label = "决策回复" if target["status"] == "等你决策" else "验收反馈"
    note = "Alex 手机确认（" + label + "）：\n\n" + text + "\n\n<!-- yihu-reply:" + request_id + ":" + digest + " -->"
    if len(attempts) >= 5000:
        raise ReplyError("write_rejected", 403)
    attempts[key] = digest  # IDs/digests only; never a ledger cache or stored reply body.
    try:
        # Execute the unchanged req CLI, including all its mutation/sensitive-text
        # guards, while keeping the reply out of OS process arguments and files.
        runner = "import json,os,runpy,shutil,sys; p=os.path.realpath(shutil.which('req')); d=json.load(sys.stdin); sys.argv=[p,'note',d['id'],d['note'],'--source-uuid',d['uuid']]; runpy.run_path(p,run_name='__main__')"
        code, _, error = command([sys.executable, "-c", runner], timeout=18,
                                  input_data=json.dumps({"id": ident, "note": note, "uuid": request_id}).encode())
    except READ_ERRORS:
        raise ReplyError("result_unknown", 503) from None
    # A nonzero transport/mutation result may still have written. Always read back.
    try:
        fresh, current, _ = target_item(ident, epoch)
        if receipt(current, request_id, digest):
            return {"outcome": "recorded", "target": fresh}
    except (ReplyError,) + READ_ERRORS:
        # Permission/membership loss after an attempted write is not proof of
        # rejection. Never let the client discard its durable pending ID.
        raise ReplyError("result_unknown", 503) from None
    if code and ("拒绝写入台账".encode() in error or "拒绝写评论".encode() in error):
        attempts.pop(key, None)  # Known req pre-mutation guards, not provider/network errors.
        raise ReplyError("write_rejected", 403)
    raise ReplyError("result_unknown", 503)


def writer_allowed(headers, writer_user_id):
    if writer_user_id is None:
        return False
    try:
        code, output, _ = command(["tailscale", "status", "--json"], timeout=3)
        if code:
            return False
        profile = json.loads(output).get("User", {}).get(str(writer_user_id), {})
        expected = profile.get("LoginName")
        actual = str(make_header(decode_header(headers.get("Tailscale-User-Login", ""))))
        return bool(expected) and not expected.startswith("tagged-") and actual == expected
    except READ_ERRORS:
        return False


def private_proxy(tailnet_host):
    try:
        code, output, _ = command(["tailscale", "serve", "status", "--json"], timeout=3)
        if code:
            return False
        status = json.loads(output)
        return tailnet_host in status.get("Web", {}) and not status.get("AllowFunnel", {}).get(tailnet_host)
    except READ_ERRORS:
        return False


def serve(port, tailnet_host, writer_user_id):
    epoch, attempts = str(uuid.uuid4()), {}
    allowed_hosts = {f"127.0.0.1:{port}", f"localhost:{port}", tailnet_host, tailnet_host.removesuffix(":443")}
    allowed_origins = {"https://" + tailnet_host, "https://" + tailnet_host.removesuffix(":443")}

    class Server(HTTPServer):
        def handle_error(self, request, client_address):
            pass

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, *args):
            pass

        def valid_route(self):
            return self.headers.get("Host") in allowed_hosts and self.path in {"/", "/pm-radar.json"} and private_proxy(tailnet_host)

        def send_json(self, payload, status=200, head=False):
            data = json.dumps(payload, ensure_ascii=False, allow_nan=False).encode()
            if len(data) > MAX_BYTES:
                self.send_error(503)
                return
            self.send_response(status)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(data)))
            self.send_header("Cache-Control", "no-store")
            self.send_header("X-Content-Type-Options", "nosniff")
            self.end_headers()
            if not head:
                self.wfile.write(data)

        def read(self, head=False):
            if not self.valid_route() or (self.headers.get("Origin") and self.headers["Origin"] not in allowed_origins):
                self.send_error(403)
                return
            try:
                data = read_ledger()
                data["reply_supported"] = writer_allowed(self.headers, writer_user_id)
                self.send_json(data, head=head)
            except READ_ERRORS:
                self.send_error(503, "Ledger unavailable")

        def do_GET(self):
            self.read()

        def do_HEAD(self):
            self.read(head=True)

        def do_POST(self):
            # Native-only. Browser Origin/Fetch headers are rejected even on the Collie origin.
            if not self.valid_route() or self.headers.get("Origin") is not None or self.headers.get("Sec-Fetch-Site") is not None or self.headers.get("X-Yihu-Reply") != "1" or not writer_allowed(self.headers, writer_user_id):
                self.send_json({"error": "forbidden"}, 403)
                return
            try:
                length = int(self.headers.get("Content-Length", "0"))
                if self.headers.get("Transfer-Encoding") or not 0 < length <= 20_000 or self.headers.get("Content-Type", "").split(";")[0].strip().lower() != "application/json":
                    raise ReplyError("invalid_request", 400)
                self.connection.settimeout(10)
                payload = json.loads(self.rfile.read(length))
                if not isinstance(payload, dict):
                    raise ReplyError("invalid_request", 400)
                self.send_json(reply(payload, writer_user_id, epoch, attempts))
            except ReplyError as error:
                data = {"error": error.code}
                if error.target:
                    data["target"] = error.target
                self.send_json(data, error.status)
            except READ_ERRORS:
                self.send_json({"error": "unavailable"}, 503)

        def reject_write(self):
            self.send_error(405)

        do_PUT = do_PATCH = do_DELETE = reject_write

    def terminate(*_):
        raise KeyboardInterrupt

    signal.signal(signal.SIGTERM, terminate)
    with Server(("127.0.0.1", port), Handler) as server:
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            pass


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", required=True, type=int, choices=range(1, 65536), metavar="PORT")
    parser.add_argument("--tailnet-host", required=True)
    parser.add_argument("--writer-user-id", type=int, help="Explicitly authorized personal Tailscale user ID; absent means read-only")
    args = parser.parse_args()
    try:
        serve(args.port, args.tailnet_host, args.writer_user_id)
    except READ_ERRORS:
        raise SystemExit("Radar adapter could not start (private details omitted)") from None
