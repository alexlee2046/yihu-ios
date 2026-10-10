#!/usr/bin/env python3
"""Live, read-only req→Radar adapter, bound to loopback behind an existing HTTPS path.

Each GET queries the current ledger. No server-side cache, files, timer or writes.
Task text and raw CLI errors are never logged. Requires the existing req CLI.
"""
import argparse
from datetime import datetime, timezone, timedelta
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os
import signal
import subprocess

MAX_BYTES = 2 * 1024 * 1024
WAITING = {"等你决策", "等你验收"}
READ_ERRORS = (ValueError, TypeError, OSError, RuntimeError, AttributeError)


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


def read_ledger():
    process = subprocess.Popen(["req", "list", "--all", "--json"], stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE, start_new_session=True)
    try:
        output, _ = process.communicate(timeout=18)
    except BaseException as error:
        if process.poll() is None:
            os.killpg(process.pid, signal.SIGKILL)
        process.communicate()
        if isinstance(error, subprocess.TimeoutExpired):
            raise RuntimeError("ledger read timed out") from None
        raise
    if process.returncode:
        raise RuntimeError("ledger read failed")
    if len(output) > MAX_BYTES * 4:
        raise ValueError("oversized ledger response")
    data = json.dumps(ledger_response(json.loads(output)), ensure_ascii=False, allow_nan=False).encode()
    if len(data) > MAX_BYTES:
        raise ValueError("response exceeds 2 MiB")
    return data


def serve(port, tailnet_host):
    allowed_hosts = {f"127.0.0.1:{port}", f"localhost:{port}", tailnet_host,
                     tailnet_host.removesuffix(":443")}
    allowed_origins = {"https://" + tailnet_host, "https://" + tailnet_host.removesuffix(":443")}

    class Server(HTTPServer):
        def handle_error(self, request, client_address):
            pass  # Do not log addresses or private response details.

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, *args):
            pass

        def read(self, head=False):
            if self.headers.get("Host") not in allowed_hosts or (
                    self.headers.get("Origin") and self.headers["Origin"] not in allowed_origins):
                self.send_error(403)
                return
            if self.path not in {"/", "/pm-radar.json"}:
                self.send_error(404)
                return
            try:
                data = read_ledger()
            except READ_ERRORS:
                self.send_error(503, "Ledger unavailable")
                return
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(data)))
            self.send_header("Cache-Control", "no-store")
            self.send_header("X-Content-Type-Options", "nosniff")
            self.end_headers()
            if not head:
                self.wfile.write(data)

        def do_GET(self):
            self.read()

        def do_HEAD(self):
            self.read(head=True)

        def reject_write(self):
            self.send_error(405)

        do_POST = do_PUT = do_PATCH = do_DELETE = reject_write

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
    parser.add_argument("--tailnet-host", required=True, help="Existing HTTPS hostname and port")
    args = parser.parse_args()
    try:
        serve(args.port, args.tailnet_host)
    except READ_ERRORS:
        raise SystemExit("Radar adapter could not start (private details omitted)") from None
