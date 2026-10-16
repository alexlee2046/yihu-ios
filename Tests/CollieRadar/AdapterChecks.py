"""Synthetic adapter/cache checks. No network, private ledger or credentials."""
import importlib.util
import copy
import hashlib
import io
import json
from pathlib import Path
import sys
import threading
import time
import unittest
from unittest.mock import Mock, patch

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "tools"))
spec = importlib.util.spec_from_file_location("radar_adapter", Path(sys.path[0]) / "serve-radar.py")
radar = importlib.util.module_from_spec(spec)
spec.loader.exec_module(radar)


def snapshot(title="Synthetic task"):
    return {"date_str": "2026-10-08 08:00", "tasks": [{"title": title}],
            "decisions": [], "active": [], "stale": [], "cold": []}


class CacheChecks(unittest.TestCase):
    def setUp(self):
        self.now = 1000
        self.calls = 0
        self.release = threading.Event()
        self.started = threading.Event()
        self.result = snapshot()
        self.error = None

        def load():
            self.calls += 1
            if self.calls > 1:
                self.started.set()
                if not self.release.wait(2):
                    raise RuntimeError("synthetic deadline")
            if self.error:
                raise self.error
            return self.result

        self.cache = radar.LedgerCache(load, lambda: self.now)
        self.cache.get()

    def tearDown(self):
        self.release.set()
        self.cache.close()

    def test_fresh_hits_and_request_authorization_are_not_cached(self):
        first = self.cache.get()
        first["reply_supported"] = True
        self.now += 30
        second = self.cache.get()
        self.assertNotIn("reply_supported", second)
        self.assertFalse(second["source_refreshing"])
        self.assertEqual(self.calls, 1)

    def test_stale_read_returns_immediately_and_coalesces(self):
        self.now += 31
        start = time.monotonic()
        stale = self.cache.get()
        elapsed = time.monotonic() - start
        self.assertTrue(stale["source_refreshing"])
        self.assertEqual(stale["date_str"], "2026-10-08 08:00")
        self.assertTrue(self.started.wait(1))
        for _ in range(20):
            self.assertTrue(self.cache.get()["source_refreshing"])
        self.assertEqual(self.calls, 2)
        self.result = snapshot("New task")
        self.release.set()
        fresh = self.cache.get(wait_for_refresh=True)
        self.assertEqual(fresh["tasks"][0]["title"], "New task")
        self.assertFalse(fresh["source_refreshing"])
        print("Synthetic warm response while source read is blocked: %.2f ms" % (elapsed * 1000))

    def test_failed_refresh_keeps_date_and_reports_failure_without_retry_storm(self):
        self.now += 31
        self.error = RuntimeError("synthetic source failure")
        self.cache.get()
        self.release.set()
        failed = self.cache.get(wait_for_refresh=True)
        self.assertTrue(failed["source_refresh_failed"])
        self.assertEqual(failed["date_str"], "2026-10-08 08:00")
        for _ in range(20):
            self.assertTrue(self.cache.get()["source_refresh_failed"])
        self.assertEqual(self.calls, 2)
        self.now += 30
        self.error = None
        self.assertFalse(self.cache.get(wait_for_refresh=True)["source_refresh_failed"])

    def test_over_age_failure_is_not_served_as_success(self):
        self.now += 301
        self.error = RuntimeError("synthetic source failure")
        self.release.set()
        with self.assertRaises(RuntimeError):
            self.cache.get()

    def test_submit_invalidation_does_not_resurrect_inflight_read(self):
        self.now += 31
        self.cache.get()
        self.assertTrue(self.started.wait(1))
        self.cache.invalidate()
        self.release.set()
        self.cache.future.result(timeout=2)
        self.result = snapshot("After reply")
        fresh = self.cache.get()
        self.assertEqual(fresh["tasks"][0]["title"], "After reply")
        self.assertEqual(self.calls, 3)

    def test_cold_failure_and_oversize_are_rejected(self):
        for loader in [lambda: (_ for _ in ()).throw(RuntimeError("source unavailable")),
                       lambda: snapshot("x" * radar.MAX_BYTES)]:
            cache = radar.LedgerCache(loader, lambda: self.now)
            try:
                with self.assertRaises(RuntimeError):
                    cache.get()
                self.assertIsNone(cache.snapshot)
            finally:
                cache.close()


class HandlerChecks(unittest.TestCase):
    def run_handler_checks(self, check):
        # Exercise the real Handler without binding a socket or starting a service.
        class FakeServer:
            def __init__(self, address, handler):
                self.handler = handler
            def __enter__(self):
                return self
            def __exit__(self, *_):
                pass
            def serve_forever(self):
                handler = self.handler.__new__(self.handler)
                handler.path = "/pm-radar.json"
                handler.headers = {"Host": "localhost:1234"}
                handler.send_json = Mock()
                handler.send_error = Mock()
                check(handler)

        with patch.object(radar, "HTTPServer", FakeServer), patch.object(radar.signal, "signal"), \
             patch.object(radar, "read_ledger", return_value=snapshot()) as loader, \
             patch.object(radar, "private_proxy", return_value=True) as proxy, \
             patch.object(radar, "writer_allowed", side_effect=lambda headers, _: headers.get("Synthetic-Writer") == "yes"):
            radar.serve(1234, "synthetic.invalid:443", 1)
            return loader, proxy

    def test_guards_and_per_request_authorization_still_run_on_cache_hits(self):
        def check(handler):
            handler.do_GET()
            self.assertFalse(handler.send_json.call_args.args[0]["reply_supported"])
            handler.headers["Synthetic-Writer"] = "yes"
            handler.do_HEAD()
            self.assertTrue(handler.send_json.call_args.args[0]["reply_supported"])
            self.assertTrue(handler.send_json.call_args.kwargs["head"])
            handler.send_json.reset_mock()
            for header, value in [("Origin", "https://foreign.invalid"), ("Host", "foreign.invalid")]:
                original = dict(handler.headers)
                handler.headers[header] = value
                handler.do_GET()
                handler.send_error.assert_called_with(403)
                handler.headers = original
            with patch.object(radar, "private_proxy", return_value=False):
                handler.do_GET()
                handler.send_error.assert_called_with(403)
            handler.send_json.assert_not_called()
        loader, proxy = self.run_handler_checks(check)
        self.assertEqual(loader.call_count, 1)
        self.assertGreaterEqual(proxy.call_count, 3)

    def test_submit_invalidates_even_when_result_is_uncertain(self):
        def check(handler):
            handler.do_GET()
            handler.headers.update({"Synthetic-Writer": "yes", "X-Yihu-Reply": "1", "Content-Type": "application/json"})
            body = json.dumps({"operation": "submit"}).encode()
            handler.headers["Content-Length"] = str(len(body))
            handler.rfile = io.BytesIO(body)
            handler.connection = Mock()
            with patch.object(radar, "reply", side_effect=radar.ReplyError("result_unknown", 503)) as writer:
                handler.do_POST()
                writer.assert_called_once()
                self.assertEqual(handler.send_json.call_args.args[1], 503)
            handler.do_GET()
        loader, _ = self.run_handler_checks(check)
        self.assertEqual(loader.call_count, 2)


class HistoryChecks(unittest.TestCase):
    def setUp(self):
        self.ident, self.owner = "PVTI_synthetic", 7
        self.request_id = "11111111-2222-4333-8444-555555555555"
        self.url = "https://fixture.invalid/demo/repo/issues/1"
        self.comments = []
        self.node = {"id": self.ident, "fullDatabaseId": 1, "isArchived": False,
                     "project": {"id": "PVT_fixture", "public": False, "viewerCanUpdate": True},
                     "content": {"__typename": "Issue", "id": "I_fixture", "title": "Synthetic item",
                                 "url": self.url, "repository": {"isPrivate": True, "viewerPermission": "WRITE"}},
                     "fieldValues": {"nodes": [{"field": {"name": "Status"}, "name": "等你决策"}],
                                     "pageInfo": {"hasNextPage": False}}}
        self.config = {"project": {"id": "PVT_fixture", "url": "https://fixture.invalid/projects/1"}}
        self.patches = [patch.object(radar.shutil, "which", return_value="/fixture/req"),
                        patch.object(radar.Path, "read_text", return_value=json.dumps(self.config)),
                        patch.object(radar, "graphql", side_effect=self.query),
                        patch.object(radar, "command")]
        self.mocks = [p.start() for p in self.patches]
        for p in self.patches:
            self.addCleanup(p.stop)

    def query(self, query, variables):
        if query == radar.TARGET_QUERY:
            return {"node": copy.deepcopy(self.node)}
        if query == radar.HISTORY_QUERY:
            self.assertEqual(variables["id"], self.node["content"]["id"])
            end = int(variables["before"].removeprefix("cursor-")) if variables["before"] else len(self.comments)
            start = max(0, end - 5)
            return {"node": {"id": variables["id"], "comments": {
                "totalCount": len(self.comments), "nodes": copy.deepcopy(self.comments[start:end]),
                "pageInfo": {"hasPreviousPage": start > 0, "startCursor": "cursor-" + str(start)}}}}
        if query == radar.COMMENTS_QUERY:
            return {"node": {"comments": {"totalCount": len(self.comments), "nodes": copy.deepcopy(self.comments),
                                          "pageInfo": {"hasNextPage": False, "endCursor": None}}}}
        self.fail("Unexpected query")

    def note(self, text="Synthetic decision", owner=None, ident=None):
        digest = hashlib.sha256(json.dumps([self.owner if owner is None else owner,
                                            ident or self.ident, text], ensure_ascii=False).encode()).hexdigest()
        return "Alex 手机确认（决策回复）：\n\n" + text + "\n\n<!-- yihu-reply:" + self.request_id + ":" + digest + " -->"

    def append(self, body):
        index = len(self.comments) + 1
        self.comments.append({"id": "IC_" + str(index), "body": body,
                              "url": self.url + "#issuecomment-" + str(index),
                              "createdAt": "2026-10-01T00:00:00Z", "updatedAt": "2026-10-01T00:00:00Z"})

    def history(self, **kwargs):
        return radar.reply(dict(operation="history", id=self.ident, **kwargs), self.owner, "epoch", {})

    def test_readback_preserves_original_and_receipt_without_write(self):
        original = "  Synthetic decision\nwith unicode 示例  "
        self.append(self.note(original) + "\n\n<sub>Synthetic footer</sub>")
        result = self.history(text="Unconfirmed draft must be ignored", confirmed=True)
        entry = result["entries"][0]
        self.assertEqual((entry["text"], entry["request_id"], entry["kind"]), (original, self.request_id, "reply"))
        self.assertEqual(entry["url"], self.comments[0]["url"])
        self.assertEqual(entry["created_at"], radar.history_timestamp(self.comments[0]["createdAt"]))
        self.assertEqual((result["start"], result["end"], result["total"], result["before"]), (1, 1, 1, None))
        self.mocks[-1].assert_not_called()

    def test_read_is_separate_from_write_and_completion(self):
        self.append(self.note())
        self.node["fieldValues"]["nodes"][0]["name"] = "已完成"
        self.node["project"]["viewerCanUpdate"] = False
        self.node["content"]["repository"]["viewerPermission"] = "READ"
        self.assertFalse(self.history()["target"]["eligible"])
        with self.assertRaises(radar.ReplyError) as caught:
            radar.reply({"operation": "prepare", "id": self.ident}, self.owner, "epoch", {})
        self.assertEqual(caught.exception.code, "forbidden")
        self.node["project"]["viewerCanUpdate"] = True
        self.node["content"]["repository"]["viewerPermission"] = "WRITE"
        with self.assertRaises(radar.ReplyError) as caught:
            radar.reply({"operation": "prepare", "id": self.ident}, self.owner, "epoch", {})
        self.assertEqual(caught.exception.code, "target_changed")
        self.mocks[-1].assert_not_called()

    def test_foreign_public_or_invisible_targets_fail_closed(self):
        for location, key, value in [(self.node["project"], "id", "PVT_foreign"),
                                     (self.node["project"], "public", True),
                                     (self.node["content"]["repository"], "isPrivate", False),
                                     (self.node["content"]["repository"], "viewerPermission", None)]:
            old = location[key]
            location[key] = value
            with self.assertRaises(radar.ReplyError):
                self.history()
            location[key] = old
        self.mocks[-1].assert_not_called()

    def test_permission_is_rechecked_after_page_read(self):
        self.append(self.note())
        def lose_access(query, variables):
            result = self.query(query, variables)
            if query == radar.HISTORY_QUERY:
                self.node["content"]["repository"]["isPrivate"] = False
            return result
        self.mocks[2].side_effect = lose_access
        with self.assertRaises(radar.ReplyError) as caught:
            self.history()
        self.assertEqual(caught.exception.code, "forbidden")

    def test_pages_are_bounded_scoped_and_include_older_replies(self):
        self.append(self.note())
        for _ in range(7):
            self.append("Synthetic update")
        first = self.history()
        self.assertEqual((len(first["entries"]), first["start"], first["end"], first["total"]), (5, 1, 5, 8))
        second = self.history(before=first["before"])
        self.assertEqual((len(second["entries"]), second["start"], second["end"], second["before"]), (3, 6, 8, None))
        self.assertEqual(second["entries"][-1]["request_id"], self.request_id)
        self.assertEqual([e["position"] for e in first["entries"] + second["entries"]], list(range(8, 0, -1)))
        self.ident = "PVTI_another"
        with self.assertRaises(radar.ReplyError):
            self.history(before=first["before"])
        self.mocks[-1].assert_not_called()

    def test_changed_count_or_target_requires_fresh_first_page(self):
        for _ in range(6):
            self.append("Synthetic update")
        first = self.history()
        self.append("New update")
        with self.assertRaises(radar.ReplyError) as caught:
            self.history(before=first["before"])
        self.assertEqual(caught.exception.code, "history_changed")
        first = self.history()
        self.node["fieldValues"]["nodes"][0]["name"] = "已完成"
        with self.assertRaises(radar.ReplyError) as caught:
            self.history(before=first["before"])
        self.assertEqual(caught.exception.code, "history_changed")
        self.assertEqual(self.history()["total"], 7)

    def test_digest_binds_owner_target_and_exact_text(self):
        for body in [self.note(owner=8), self.note(ident="PVTI_other"), self.note().replace("Synthetic decision", "Edited")]:
            self.append(body)
        self.assertTrue(all(e["kind"] == "update" and e["request_id"] is None for e in self.history()["entries"]))

    def test_draft_notes_have_no_fabricated_comment_time_or_link(self):
        self.node["content"] = {"__typename": "DraftIssue", "id": "D_fixture", "title": "Synthetic draft",
                                "body": "Synthetic description\n\n---\n**备注 2026-10-01 08:00 +0800**（req note）\n\n" + self.note() + "\n"}
        result = self.history()
        self.assertTrue(result["draft"])
        entry = result["entries"][0]
        self.assertEqual(entry["kind"], "reply")
        self.assertIsNone(entry["created_at"])
        self.assertIsNone(entry["updated_at"])
        self.assertEqual(entry["url"], result["target"]["url"])
        self.mocks[-1].assert_not_called()

    def test_oversize_notes_are_explicit_and_provider_links_validated(self):
        self.append("x" * (radar.HISTORY_TEXT_BYTES + 1))
        entry = self.history()["entries"][0]
        self.assertTrue(entry["text_omitted"])
        self.assertEqual(entry["text"], "")
        self.comments[0]["url"] = "https://foreign.invalid/issues/1#issuecomment-1"
        with self.assertRaises(RuntimeError):
            self.history()

    def test_incomplete_pages_and_duplicate_entries_are_not_empty_success(self):
        for _ in range(6):
            self.append("Synthetic update")
        def partial(query, variables):
            data = self.query(query, variables)
            if query == radar.HISTORY_QUERY:
                data["node"]["comments"]["nodes"].pop()
            return data
        self.mocks[2].side_effect = partial
        with self.assertRaises(RuntimeError):
            self.history()
        self.mocks[2].side_effect = self.query
        self.comments[-1]["id"] = self.comments[-2]["id"]
        with self.assertRaises(RuntimeError):
            self.history()

    def test_feedback_requires_explicit_same_item_reference(self):
        self.append(self.note())
        self.append("Ordinary update, " + self.request_id)
        self.append("Explicit request_id: " + self.request_id)
        self.append("See [source](" + self.url + "#issuecomment-1).")
        result = self.history()
        by_id = {entry["id"]: entry for entry in result["entries"]}
        self.assertEqual(by_id["IC_2"]["references"], [])
        self.assertEqual(by_id["IC_3"]["references"], [self.request_id])
        self.assertEqual(by_id["IC_4"]["references"], [self.url + "#issuecomment-1"])
        self.assertEqual(by_id["IC_1"]["references"], [])
        self.assertEqual(result["target"]["status"], "等你决策")
        self.mocks[-1].assert_not_called()

    def test_reference_parser_does_not_bind_foreign_or_nested_links(self):
        original = self.url + "#issuecomment-1"
        for body in [self.request_id, "not_request_id: " + self.request_id,
                     "request_id: " + self.request_id + "-extra",
                     original.replace("/issues/1", "/issues/2"),
                     "https://foreign.invalid/?return=" + original]:
            self.assertEqual(radar.history_references(body, self.url, False), [])
        self.assertEqual(radar.history_references("request_id: `" + self.request_id + "`", self.url, True), [self.request_id])
        self.assertEqual(radar.history_references(original, self.url, True), [])
        self.assertEqual(radar.history_references("Source: " + original + "。", self.url, False), [original])

    def test_owner_projection_does_not_change_send_version(self):
        self.node["fieldValues"]["nodes"].append({"field": {"name": "负责会话"}, "text": "fixture-session"})
        history = self.history()
        prepared = radar.reply({"operation": "prepare", "id": self.ident}, self.owner, "epoch", {})
        self.assertEqual(history["target"]["owner_session"], "fixture-session")
        self.assertEqual(history["target"]["version"], prepared["target"]["version"])
        self.assertNotIn("owner_session", prepared["target"])

    def authorization(self, **changes):
        value = {"version": 1, "operation": "colab.run", "subject": "Synthetic experiment",
                 "fingerprint": "a" * 64, "scope": "Public synthetic images only; no delivery",
                 "expires_at": int(time.time()) + 3600,
                 "budget": {"session_cu": 5, "total_cu": 100, "minutes": 15}}
        value.update(changes)
        self.node["content"]["body"] = radar.request_body(value)
        return radar.parse_request(self.node["content"]["body"])

    def approval_payload(self):
        prepared = radar.reply({"operation": "prepare", "id": self.ident}, self.owner, "epoch", {})["target"]
        return {"operation": "submit", "id": self.ident, "text": "Synthetic approval note",
                "request_id": self.request_id, "epoch": "epoch", "confirmed": True,
                "version": prepared["version"], "authorization_confirmed": True,
                "authorization": prepared["authorization"],
                "authorization_digest": prepared["authorization"]["digest"]}

    def record_command(self, *args, input_data, **kwargs):
        payload = json.loads(input_data)
        self.append(payload["note"])
        return 0, b"", b""

    def test_typed_authorization_readback_and_restart_never_execute_or_repeat(self):
        request = self.authorization()
        payload = self.approval_payload()
        self.mocks[-1].side_effect = self.record_command
        self.assertEqual(radar.reply(payload, self.owner, "epoch", {})["outcome"], "recorded")
        self.mocks[-1].assert_called_once()
        note = self.comments[0]["body"]
        self.assertIn("操作授权记录", note)
        self.assertEqual(radar.parse_request(note)["digest"], request["digest"])
        self.assertEqual(self.history()["entries"][0]["kind"], "reply")
        self.authorization(scope="Changed after recording")
        payload["operation"] = "check"
        self.assertEqual(radar.reply(payload, self.owner, "restarted", {})["outcome"], "recorded")
        self.mocks[-1].assert_called_once()
        # The sole subprocess is the existing req note runner, never Colab/promote.
        self.assertEqual(self.mocks[-1].call_args.args[0][1], "-c")
        self.assertIn("'note'", self.mocks[-1].call_args.args[0][2])

    def test_authorization_changes_and_expiry_refuse_before_any_write(self):
        self.authorization()
        payload = self.approval_payload()
        self.authorization(scope="A different batch or destination")
        with self.assertRaises(radar.ReplyError) as changed:
            radar.reply(payload, self.owner, "epoch", {})
        self.assertEqual(changed.exception.code, "target_changed")
        self.authorization(expires_at=int(time.time()) - 1)
        payload = self.approval_payload()
        with self.assertRaises(radar.ReplyError) as expired:
            radar.reply(payload, self.owner, "epoch", {})
        self.assertEqual(expired.exception.code, "authorization_expired")
        self.mocks[-1].assert_not_called()

    def test_ordinary_agreement_is_not_typed_authorization(self):
        self.authorization()
        payload = self.approval_payload()
        for field in ["authorization", "authorization_digest", "authorization_confirmed"]:
            payload.pop(field)
        payload["text"] = "同意"
        self.mocks[-1].side_effect = self.record_command
        radar.reply(payload, self.owner, "epoch", {})
        self.assertNotIn("操作授权记录", self.comments[0]["body"])
        self.assertIn("决策回复", self.comments[0]["body"])

    def test_uncertain_authorization_keeps_the_same_receipt_identity(self):
        self.authorization()
        payload = self.approval_payload()
        self.mocks[-1].return_value = (1, b"", b"")
        attempts = {}
        for _ in range(2):
            with self.assertRaises(radar.ReplyError) as uncertain:
                radar.reply(payload, self.owner, "epoch", attempts)
            self.assertEqual(uncertain.exception.code, "result_unknown")
        self.mocks[-1].assert_called_once()

    def test_authorization_schema_is_strict_and_digest_binds_budget_and_operation(self):
        valid = self.authorization()
        self.assertNotEqual(self.authorization(budget={"session_cu": 6, "total_cu": 100, "minutes": 15})["digest"], valid["digest"])
        self.assertNotEqual(self.authorization(operation="colab.resume")["digest"], valid["digest"])
        for changes in [{"operation": "shell"}, {"operation": []}, {"fingerprint": "a" * 40},
                        {"expires_at": True}, {"extra": "unknown"}, {"budget": None},
                        {"budget": {"session_cu": float("inf"), "total_cu": 100, "minutes": 15}},
                        {"budget": {"session_cu": True, "total_cu": 100, "minutes": 15}}]:
            with self.assertRaises((ValueError, TypeError)):
                self.authorization(**changes)
        body = radar.request_body(valid)
        with self.assertRaises(ValueError):
            radar.parse_request(body + "\n" + body)
        with self.assertRaises(ValueError):
            radar.parse_request(body.replace('"version":1', '"version":1,"version":1'))
        self.assertEqual(radar.parse_request(body + "\n---\n**备注 synthetic**（req note）\n\n" + body)["digest"], valid["digest"])

    def test_existing_request_receipt_survives_restart_and_no_second_write(self):
        self.append(self.note())
        payload = {"operation": "submit", "id": self.ident, "text": "Synthetic decision",
                   "request_id": self.request_id, "confirmed": True, "epoch": "old epoch"}
        for epoch in ["epoch", "restarted"]:
            self.assertEqual(radar.reply(payload, self.owner, epoch, {})["outcome"], "recorded")
        self.mocks[-1].assert_not_called()


if __name__ == "__main__":
    unittest.main()
