#!/usr/bin/env python3
"""On-demand req→Radar adapter. Loopback only; bounded memory cache, no files/timer.

Replies are disabled unless --writer-user-id explicitly binds an authorized
personal Tailscale identity. Serve must strip/inject identity headers (no Funnel).
No task/reply text, login names or raw CLI errors are logged.
"""
import argparse
import base64
from concurrent.futures import ThreadPoolExecutor, TimeoutError as FutureTimeout
from datetime import datetime, timezone, timedelta
from email.header import decode_header, make_header
import hashlib
import hmac
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys
import time
import uuid
from radar_notifications import NotificationError

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


class LedgerCache:
    """Single-flight reads; 30s fresh, at most 5min old while revalidating.

    Only the serial HTTP handler mutates this state. The worker returns data, never
    touches authorization, reply receipts or cache state. No periodic refresh.
    """
    def __init__(self, loader=None, clock=time.monotonic):
        self.loader, self.clock = loader or read_ledger, clock
        self.executor = ThreadPoolExecutor(max_workers=1)
        self.snapshot = self.future = None
        self.loaded_at = self.retry_after = 0
        self.revision = self.read_revision = 0
        self.failed = False

    def _load(self):
        snapshot = self.loader()
        if len(json.dumps(snapshot, ensure_ascii=False, allow_nan=False).encode()) > MAX_BYTES:
            raise ValueError("ledger too large")
        return snapshot, self.clock()

    def _finish(self):
        if self.future is None or not self.future.done():
            return
        future, revision = self.future, self.read_revision
        self.future = None
        if revision != self.revision:
            return  # A reply invalidated this read; never resurrect its old result.
        try:
            self.snapshot, self.loaded_at = future.result()
            self.failed = False
            self.retry_after = 0
        except READ_ERRORS:
            self.failed = True
            self.retry_after = self.clock() + 30

    def get(self, wait_for_refresh=False):
        while True:
            self._finish()
            now = self.clock()
            age = now - self.loaded_at
            if (self.snapshot is None or age > 30) and self.future is None and now >= self.retry_after:
                self.read_revision = self.revision
                self.future = self.executor.submit(self._load)
            if self.snapshot is not None and age <= 300 and not (wait_for_refresh and self.future is not None):
                # Copy the envelope: per-request write authorization must not enter the cache.
                return dict(self.snapshot, source_refreshing=self.future is not None,
                            source_refresh_failed=self.failed)
            if self.future is None:
                raise RuntimeError("ledger unavailable")
            try:
                self.future.result(timeout=31)
            except FutureTimeout:
                raise RuntimeError("ledger unavailable") from None
            except READ_ERRORS:
                pass  # _finish records the failure; no stale-success date is synthesized.

    def invalidate(self):
        self.revision += 1
        self.snapshot = None
        self.failed = False
        self.retry_after = 0

    def close(self):
        self.executor.shutdown(wait=True, cancel_futures=True)


TARGET_QUERY = """query($id:ID!) { node(id:$id) { ... on ProjectV2Item {
 id fullDatabaseId isArchived updatedAt project { id public viewerCanUpdate }
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


def target_item(ident, epoch, notification=False, history=False):
    executable = shutil.which("req")
    if not executable:
        raise RuntimeError("req unavailable")
    config_path = os.environ.get("REQ_CONFIG") or str(Path(executable).resolve().parent / "config.json")
    config = json.loads(Path(config_path).read_text())
    node = graphql(TARGET_QUERY, {"id": ident})["node"]
    if not node or node.get("project", {}).get("id") != config["project"]["id"]:
        raise ReplyError("target_unavailable", 404)
    if node["project"].get("public") is not False or (not history and node["project"].get("viewerCanUpdate") is not True):
        raise ReplyError("forbidden", 403)
    content = node.get("content") or {}
    kind = content.get("__typename")
    if kind not in {"Issue", "DraftIssue"} or not content.get("id"):
        raise ReplyError("forbidden", 403)
    permissions = {"ADMIN", "MAINTAIN", "WRITE"}
    if history:
        permissions |= {"READ", "TRIAGE"}
    if kind == "Issue" and (content.get("repository", {}).get("isPrivate") is not True or
                            content.get("repository", {}).get("viewerPermission") not in permissions):
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
    writable = node["project"].get("viewerCanUpdate") is True and (
        kind == "DraftIssue" or content["repository"].get("viewerPermission") in {"ADMIN", "MAINTAIN", "WRITE"})
    eligible = writable and not node["isArchived"] and target["status"] in WAITING
    target["eligible"] = eligible
    revision = dict(target, archived=node["isArchived"], kind=kind, content_id=content["id"])
    target["version"] = hashlib.sha256(json.dumps(revision, sort_keys=True, ensure_ascii=False).encode()).hexdigest()
    if notification:
        content = dict(content, notification_revision=node.get("updatedAt"),
                       notification_source=hashlib.sha256(node["project"]["id"].encode()).hexdigest())
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


HISTORY_QUERY = """query($id:ID!, $before:String) { node(id:$id) { ... on Issue {
 id comments(last:5,before:$before) { totalCount nodes { id body url createdAt updatedAt }
 pageInfo { hasPreviousPage startCursor } }
} } }"""
HISTORY_BYTES = 128 * 1024
HISTORY_TEXT_BYTES = 20000
PHONE_NOTE = re.compile(r"Alex 手机确认（(?:决策回复|验收反馈)）：\n\n(.*?)\n\n<!-- yihu-reply:([0-9a-f-]{36}):([0-9a-f]{64}) -->", re.S)


def phone_note(body, owner, ident):
    match = PHONE_NOTE.match(body)
    if not match:
        return None
    text, request_id, digest = match.groups()
    try:
        if str(uuid.UUID(request_id)) != request_id or not text.strip() or len(text) > 4000:
            return None
    except ValueError:
        return None
    expected = hashlib.sha256(json.dumps([owner, ident, text], ensure_ascii=False).encode()).hexdigest()
    return (text, request_id) if hmac.compare_digest(expected, digest) else None


def history_timestamp(value):
    if not isinstance(value, str):
        raise RuntimeError("invalid history time")
    parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    if parsed.tzinfo is None or not 0 <= parsed.timestamp() <= time.time() + 300:
        raise RuntimeError("invalid history time")
    return parsed.timestamp()


def reply_history(payload, owner, epoch):
    """Read only, current private membership; completion does not revoke history.

    Five source records per page, no history cache/database. Cursor scope and
    page range are rechecked; a changed source requires an explicit first-page read.
    """
    ident = payload["id"]
    target, content, _ = target_item(ident, epoch, history=True)
    cursor = payload.get("before")
    previous = None
    if cursor is not None:
        try:
            if not isinstance(cursor, str) or not 0 < len(cursor) <= 2048:
                raise ValueError()
            previous = json.loads(base64.b64decode(cursor, altchars=b"-_", validate=True))
            if not isinstance(previous, dict) or set(previous) != {"item", "content", "version", "total", "loaded", "before", "revision"}:
                raise ValueError()
            if previous["item"] != ident or previous["content"] != content["id"] or previous["version"] != target["version"]:
                raise ReplyError("history_changed", 409)
            if type(previous["loaded"]) is not int or type(previous["total"]) is not int or not 0 < previous["loaded"] < previous["total"] <= 100000:
                raise ValueError()
        except (ValueError, TypeError, KeyError):
            raise ReplyError("invalid_request", 400) from None
    loaded = previous["loaded"] if previous else 0
    draft = content["__typename"] == "DraftIssue"
    if draft:
        body = content.get("body")
        if not isinstance(body, str) or len(body.encode()) > MAX_BYTES:
            raise RuntimeError("draft history unavailable")
        revision = hashlib.sha256(body.encode()).hexdigest()
        # Draft notes have no independent provider comment ID/time. Preserve that
        # distinction instead of treating the whole draft's update time as send time.
        blocks = re.split(r"(?:\A|\n)---\n\*\*备注 [^\n]+\*\*（req note）\n\n", body)
        blocks = [b for b in blocks if b.strip()]
        total = len(blocks)
        if previous and (previous["revision"] != revision or previous["before"] is not None):
            raise ReplyError("history_changed", 409)
        nodes = [{"id": "draft-" + revision + "-" + str(i), "body": blocks[i], "url": target["url"],
                  "createdAt": None, "updatedAt": None} for i in range(total - loaded - 1, max(-1, total - loaded - 6), -1)]
        more, before = loaded + len(nodes) < total, None
    else:
        before = previous["before"] if previous else None
        if previous and (previous["revision"] is not None or not isinstance(before, str) or not 0 < len(before) <= 1024):
            raise ReplyError("invalid_request", 400)
        node = graphql(HISTORY_QUERY, {"id": content["id"], "before": before})["node"]
        if not node or node.get("id") != content["id"]:
            raise RuntimeError("history target mismatch")
        page = node["comments"]
        total, nodes = page["totalCount"], page["nodes"]
        more, next_before = page["pageInfo"]["hasPreviousPage"], page["pageInfo"]["startCursor"]
        if not isinstance(nodes, list) or type(more) is not bool:
            raise RuntimeError("incomplete history page")
        if more and (not isinstance(next_before, str) or not 0 < len(next_before) <= 1024 or next_before == before):
            raise RuntimeError("invalid history cursor")
        nodes, before, revision = list(reversed(nodes)), next_before, None
    if type(total) is not int or not 0 <= total <= 100000 or (previous and previous["total"] != total):
        raise ReplyError("history_changed", 409)
    if len(nodes) != min(5, total - loaded) or more != (loaded + len(nodes) < total):
        raise RuntimeError("incomplete history range")
    entries, seen = [], set()
    for index, row in enumerate(nodes):
        body, key, url = row.get("body"), row.get("id"), row.get("url")
        if not isinstance(body, str) or not isinstance(key, str) or not key or key in seen or len(key) > 200:
            raise RuntimeError("invalid history entry")
        if not isinstance(url, str) or (url != target["url"] if draft else
                not re.fullmatch(re.escape(target["url"]) + r"#issuecomment-[0-9]+", url)):
            raise RuntimeError("history link mismatch")
        seen.add(key)
        verified = phone_note(body, owner, ident)
        text, request_id = verified if verified else (body, None)
        omitted = len(text.encode()) > HISTORY_TEXT_BYTES
        created = None if draft else history_timestamp(row["createdAt"])
        updated = None if draft else history_timestamp(row["updatedAt"])
        if created is not None and updated < created:
            raise RuntimeError("invalid history time order")
        entries.append({"id": key, "position": total - loaded - index, "kind": "reply" if verified else "update", "text": "" if omitted else text,
                        "request_id": request_id, "url": url, "created_at": created, "updated_at": updated,
                        "text_omitted": omitted})
    # Recheck after pagination too: permission/membership loss is not stale success.
    fresh, current, _ = target_item(ident, epoch, history=True)
    if fresh["version"] != target["version"] or current["id"] != content["id"] or (draft and current.get("body") != content["body"]):
        raise ReplyError("history_changed", 409)
    next_cursor = None
    if more:
        scope = {"item": ident, "content": content["id"], "version": fresh["version"], "total": total,
                 "loaded": loaded + len(nodes), "before": before, "revision": revision}
        next_cursor = base64.urlsafe_b64encode(json.dumps(scope, separators=(",", ":")).encode()).decode()
    result = {"outcome": "history", "history_version": 1, "target": fresh, "entries": entries,
              "total": total, "start": loaded + 1 if nodes else 0, "end": loaded + len(nodes),
              "before": next_cursor, "read_at": time.time(), "draft": draft}
    if len(json.dumps(result, ensure_ascii=False).encode()) > HISTORY_BYTES:
        raise ReplyError("history_too_large", 413)
    return result


def reply(payload, writer_user_id, epoch, attempts):
    operation, ident = payload.get("operation"), payload.get("id")
    if operation not in {"prepare", "submit", "check", "history"} or not isinstance(ident, str) or not re.fullmatch(r"PVTI_[A-Za-z0-9_-]{1,120}", ident):
        raise ReplyError("invalid_request", 400)
    if operation == "history":
        return reply_history(payload, writer_user_id, epoch)
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


def notification_scope():
    executable = shutil.which("req")
    if not executable:
        raise ReplyError("notifications_unavailable", 503)
    config_path = os.environ.get("REQ_CONFIG") or str(Path(executable).resolve().parent / "config.json")
    config = json.loads(Path(config_path).read_text())
    ident = config["project"]["id"]
    node = graphql("query($id:ID!){node(id:$id){... on ProjectV2{id public}}}", {"id": ident})["node"]
    if not node or node.get("id") != ident or node.get("public") is not False:
        raise ReplyError("forbidden", 403)
    return hashlib.sha256(ident.encode()).hexdigest()


def notification_operation(payload, registry, owner):
    if registry is None:
        raise ReplyError("notifications_unavailable", 503)
    operation = payload.get("operation")
    if operation == "notification_status":
        result = registry.status()
        return dict(result, sourceToken=notification_scope()) if result["available"] else result
    if operation == "notification_register":
        if payload.get("sourceToken") != notification_scope():
            raise ReplyError("forbidden", 403)
        return registry.register(owner, payload.get("installationId"), payload.get("sourceToken"), payload.get("deviceToken"))
    if operation == "notification_unregister":
        return registry.unregister(owner, payload.get("subscriptionId"))
    if operation == "notification_resolve":
        result = registry.resolve(owner, payload.get("subscriptionId"), payload.get("eventKey"))
        latest, content, eligible = target_item(result["itemId"], "notification", notification=True)
        revision = hashlib.sha256(json.dumps([latest["id"], latest["status"], content["notification_revision"]], separators=(",", ":")).encode()).hexdigest()
        if not eligible or content["notification_source"] != result["sourceToken"] or revision != result["itemVersion"]:
            raise ReplyError("event_unavailable", 410)
        # Resolution remains read-only and revalidates current private membership.
        return dict(result, target=latest)
    raise ReplyError("invalid_request", 400)


def ingest_notification(body, signature, registry, event_key):
    if registry is None or event_key is None or len(event_key) < 32:
        raise ReplyError("notifications_unavailable", 503)
    expected = hmac.new(event_key, body, hashlib.sha256).hexdigest()
    if not isinstance(signature, str) or not hmac.compare_digest(expected, signature):
        raise ReplyError("forbidden", 403)
    payload = json.loads(body)
    if not isinstance(payload, dict) or set(payload) != {"operation", "id", "previous_status", "status", "item_updated_at", "source", "timestamp"}:
        raise ReplyError("invalid_request", 400)
    stamp = payload["timestamp"]
    if payload["operation"] != "notification_event" or type(stamp) is not int or abs(time.time() - stamp) > 120:
        raise ReplyError("invalid_request", 400)
    ident = payload["id"]
    if not isinstance(ident, str) or not re.fullmatch(r"PVTI_[A-Za-z0-9_-]{1,120}", ident):
        raise ReplyError("invalid_request", 400)
    # Never trust a signed event as authority to leak public/foreign items.
    latest, content, eligible = target_item(ident, "notification", notification=True)
    scope, updated = content["notification_source"], content["notification_revision"]
    if not eligible or not updated or latest["status"] != payload["status"] or updated != payload["item_updated_at"] or payload["source"] != scope:
        raise ReplyError("event_unavailable", 410)
    revision = hashlib.sha256(json.dumps([ident, payload["status"], updated], separators=(",", ":")).encode()).hexdigest()
    event = notification_transition({"id": ident, "archived": False, "status": payload["previous_status"]},
                                    {"id": ident, "archived": False, "status": latest["status"], "version": revision})
    return registry.dispatch(event, scope) if event else {"outcome": "ignored"}


def serve(port, tailnet_host, writer_user_id, notifications=None, notification_user_id=None, event_key=None):
    epoch, attempts = str(uuid.uuid4()), {}
    ledger = LedgerCache()
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
                data = ledger.get(wait_for_refresh=self.headers.get("Cache-Control") == "no-cache")
                data["reply_supported"] = writer_allowed(self.headers, writer_user_id)
                self.send_json(data, head=head)
            except READ_ERRORS:
                self.send_error(503, "Ledger unavailable")

        def do_GET(self):
            self.read()

        def do_HEAD(self):
            self.read(head=True)

        def do_POST(self):
            # Notification identity/ingress is separate from business reply authority.
            event_signature = self.headers.get("X-Yihu-Event")
            notification_intent = self.headers.get("X-Yihu-Notification") == "1"
            if not self.valid_route() or self.headers.get("Origin") is not None or self.headers.get("Sec-Fetch-Site") is not None:
                self.send_json({"error": "forbidden"}, 403)
                return
            if event_signature is None and not (writer_allowed(self.headers, notification_user_id) if notification_intent else
                                               self.headers.get("X-Yihu-Reply") == "1" and writer_allowed(self.headers, writer_user_id)):
                self.send_json({"error": "forbidden"}, 403)
                return
            try:
                length = int(self.headers.get("Content-Length", "0"))
                if self.headers.get("Transfer-Encoding") or not 0 < length <= 20_000 or self.headers.get("Content-Type", "").split(";")[0].strip().lower() != "application/json":
                    raise ReplyError("invalid_request", 400)
                self.connection.settimeout(10)
                body = self.rfile.read(length)
                if len(body) != length:
                    raise ReplyError("invalid_request", 400)
                if event_signature is not None:
                    self.send_json(ingest_notification(body, event_signature, notifications, event_key))
                    return
                payload = json.loads(body)
                if not isinstance(payload, dict):
                    raise ReplyError("invalid_request", 400)
                if notification_intent:
                    self.send_json(notification_operation(payload, notifications, str(notification_user_id)))
                else:
                    try:
                        self.send_json(reply(payload, writer_user_id, epoch, attempts))
                    finally:
                        if payload.get("operation") == "submit":
                            ledger.invalidate()
            except ReplyError as error:
                data = {"error": error.code}
                if error.target:
                    data["target"] = error.target
                self.send_json(data, error.status)
            except NotificationError as error:
                self.send_json({"error": str(error)}, 409)
            except READ_ERRORS:
                self.send_json({"error": "unavailable"}, 503)

        def reject_write(self):
            self.send_error(405)

        do_PUT = do_PATCH = do_DELETE = reject_write

    def terminate(*_):
        raise KeyboardInterrupt

    signal.signal(signal.SIGTERM, terminate)
    try:
        with Server(("127.0.0.1", port), Handler) as server:
            try:
                server.serve_forever()
            except KeyboardInterrupt:
                pass
    finally:
        ledger.close()


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
