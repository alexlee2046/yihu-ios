"""Private notification metadata only; no ledger snapshots or task text.

Provider is injected explicitly. None means unavailable, never pretend delivered.
All methods are called serially by the existing loopback adapter.
"""
import hashlib
import json
import os
from pathlib import Path
import re
import sqlite3
import time
import uuid


class NotificationError(Exception):
    pass


class NotificationRegistry:
    def __init__(self, path, provider=None):
        self.provider = provider
        path = Path(path)
        path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
        if path.is_symlink() or path.parent.is_symlink():
            raise NotificationError("unsafe_state")
        fd = os.open(path, os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
        os.close(fd)
        os.chmod(path, 0o600)
        self.db = sqlite3.connect(path)
        self.db.execute("PRAGMA journal_mode=DELETE")
        self.db.executescript("""
          CREATE TABLE IF NOT EXISTS subscriptions (
            id TEXT PRIMARY KEY, owner TEXT NOT NULL, installation TEXT NOT NULL,
            source TEXT NOT NULL, token TEXT NOT NULL, expires REAL NOT NULL,
            UNIQUE(owner, installation, source));
          CREATE TABLE IF NOT EXISTS events (
            key TEXT PRIMARY KEY, item TEXT NOT NULL, revision TEXT NOT NULL,
            expires REAL NOT NULL);
          CREATE TABLE IF NOT EXISTS attempts (
            subscription TEXT NOT NULL, event TEXT NOT NULL, outcome TEXT NOT NULL,
            PRIMARY KEY(subscription, event));
        """)
        self.db.commit()

    def close(self):
        self.db.close()

    def prune(self):
        now = time.time()
        with self.db:
            self.db.execute("DELETE FROM subscriptions WHERE expires <= ?", (now,))
            self.db.execute("DELETE FROM events WHERE expires <= ?", (now,))
            self.db.execute("DELETE FROM attempts WHERE subscription NOT IN (SELECT id FROM subscriptions) OR event NOT IN (SELECT key FROM events)")

    def status(self):
        return {"available": self.provider is not None, "version": 1}

    def register(self, owner, installation, source, token):
        if self.provider is None:
            raise NotificationError("provider_unavailable")
        try:
            installation = str(uuid.UUID(installation))
        except (ValueError, TypeError, AttributeError):
            raise NotificationError("invalid_request") from None
        if not owner or not re.fullmatch(r"[0-9a-f]{64}", source or "") or not re.fullmatch(r"[0-9a-f]{64,200}", token or "") or len(token) % 2:
            raise NotificationError("invalid_request")
        self.prune()
        row = self.db.execute("SELECT id FROM subscriptions WHERE owner=? AND installation=? AND source=?", (owner, installation, source)).fetchone()
        if row is None:
            if self.db.execute("SELECT COUNT(*) FROM subscriptions").fetchone()[0] >= 32:
                raise NotificationError("capacity")
            ident = str(uuid.uuid4())
        else:
            ident = row[0]
        expiry = time.time() + 7 * 86400
        with self.db:
            self.db.execute("INSERT INTO subscriptions VALUES(?,?,?,?,?,?) ON CONFLICT(owner,installation,source) DO UPDATE SET token=excluded.token,expires=excluded.expires", (ident, owner, installation, source, token, expiry))
        return {"subscriptionId": ident, "expiresAt": expiry}

    def unregister(self, owner, ident):
        # Owner-scoped and idempotent. Never disclose another owner's binding.
        with self.db:
            self.db.execute("DELETE FROM subscriptions WHERE owner=? AND id=?", (owner, ident))
            self.db.execute("DELETE FROM attempts WHERE subscription NOT IN (SELECT id FROM subscriptions)")
        return {"outcome": "unregistered"}

    def resolve(self, owner, ident, event):
        self.prune()
        row = self.db.execute("SELECT s.source,e.item,e.revision FROM subscriptions s JOIN events e ON e.key=? WHERE s.id=? AND s.owner=? AND EXISTS (SELECT 1 FROM attempts a WHERE a.subscription=s.id AND a.event=e.key)", (event, ident, owner)).fetchone()
        if row is None:
            raise NotificationError("event_unavailable")
        return {"sourceToken": row[0], "itemId": row[1], "itemVersion": row[2]}

    def dispatch(self, event, source):
        if self.provider is None:
            raise NotificationError("provider_unavailable")
        if not isinstance(event, dict) or set(event) != {"version", "event_key", "item_id", "item_version"} or type(event["version"]) is not int or event["version"] != 1:
            raise NotificationError("invalid_event")
        key, item, revision = event["event_key"], event["item_id"], event["item_version"]
        if not re.fullmatch(r"[0-9a-f]{64}", revision or "") or not re.fullmatch(r"PVTI_[A-Za-z0-9_-]{1,120}", item or "") or not re.fullmatch(r"[0-9a-f]{64}", source or ""):
            raise NotificationError("invalid_event")
        expected = hashlib.sha256(json.dumps([item, revision], separators=(",", ":")).encode()).hexdigest()
        if key != expected:
            raise NotificationError("invalid_event")
        self.prune()
        expiry = time.time() + 600
        with self.db:
            if self.db.execute("SELECT COUNT(*) FROM events").fetchone()[0] >= 256 and not self.db.execute("SELECT 1 FROM events WHERE key=?", (key,)).fetchone():
                raise NotificationError("capacity")
            self.db.execute("INSERT OR IGNORE INTO events VALUES(?,?,?,?)", (key, item, revision, expiry))
        count = 0
        for ident, token in self.db.execute("SELECT id,token FROM subscriptions WHERE source=?", (source,)).fetchall():
            if self.db.execute("SELECT 1 FROM attempts WHERE subscription=? AND event=?", (ident, key)).fetchone():
                continue
            # Persist before the network boundary. Ambiguous APNs attempts do not
            # blindly resend after exceptions or process restart.
            with self.db:
                self.db.execute("INSERT INTO attempts VALUES(?,?,?)", (ident, key, "unknown"))
            payload = {"aps": {"alert": "一呼有待处理事项"}, "yihuRadar": {"version": 1, "subscriptionId": ident, "eventKey": key}}
            try:
                accepted = self.provider(token, payload, key, expiry)
            except Exception:
                continue
            with self.db:
                self.db.execute("UPDATE attempts SET outcome=? WHERE subscription=? AND event=?", ("accepted" if accepted is True else "rejected" if accepted is False else "unknown", ident, key))
            count += accepted is True
        return {"outcome": "processed", "accepted": count} # APNs acceptance != delivery.
