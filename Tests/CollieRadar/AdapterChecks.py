"""Synthetic adapter/cache checks. No network, private ledger or credentials."""
import importlib.util
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


if __name__ == "__main__":
    unittest.main()
