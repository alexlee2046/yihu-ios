"""Typed, content-bound requests in the existing private ledger, not execution tokens.

Only the existing identity-checked reply route records a confirmation. Executors
retain their own fingerprint, budget and signed-production gates. Nothing here
loads credentials, executes commands, or treats a free-text comment as approval.
"""
import hashlib
import json
import math
import re

MARKER = "```yihu-authorization\n"
OPERATIONS = {"colab.run", "colab.resume", "colab.recover", "colab.calibrate", "release.promote"}


def canonical(value):
    return json.dumps(value, sort_keys=True, ensure_ascii=False, separators=(",", ":"), allow_nan=False)


def parse_request(body):
    if not isinstance(body, str) or "```yihu-authorization" not in body:
        return None
    # A malformed/duplicate declaration is never downgraded to an ordinary reply.
    body = re.split(r"\n---\n\*\*备注 [^\n]+\*\*（req note）\n\n", body, maxsplit=1)[0]
    if "```yihu-authorization" not in body:
        return None
    if body.count("```yihu-authorization") != 1:
        raise ValueError("invalid authorization declaration")
    match = re.search(r"(?:\A|\n)```yihu-authorization\n([\s\S]{1,12000}?)\n```(?:\n|\Z)", body)
    if not match:
        raise ValueError("invalid authorization declaration")

    def unique(pairs):
        result = {}
        for key, value in pairs:
            if key in result:
                raise ValueError("duplicate authorization field")
            result[key] = value
        return result

    request = json.loads(match[1], object_pairs_hook=unique)
    required = {"version", "operation", "fingerprint", "subject", "scope", "expires_at", "budget"}
    if not isinstance(request, dict) or set(request) != required or type(request["version"]) is not int or request["version"] != 1:
        raise ValueError("invalid authorization schema")
    if not isinstance(request["operation"], str) or request["operation"] not in OPERATIONS:
        raise ValueError("unknown authorization operation")
    for field, maximum in [("subject", 200), ("scope", 2000)]:
        value = request[field]
        if not isinstance(value, str) or not value.strip() or len(value) > maximum or any(ord(c) < 32 and c != "\n" for c in value):
            raise ValueError("invalid authorization description")
    size = 40 if request["operation"] == "release.promote" else 64
    if not isinstance(request["fingerprint"], str) or not re.fullmatch("[0-9a-f]{%d}" % size, request["fingerprint"]):
        raise ValueError("invalid authorization fingerprint")
    if type(request["expires_at"]) is not int or not 0 < request["expires_at"] < 253402300800:
        raise ValueError("invalid authorization expiry")
    budget = request["budget"]
    if request["operation"] in {"colab.run", "colab.resume"}:
        if not isinstance(budget, dict) or set(budget) != {"session_cu", "total_cu", "minutes"}:
            raise ValueError("missing authorization budget")
        try:
            valid_budget = all(type(v) in (int, float) and math.isfinite(v) and v > 0
                               for v in budget.values())
        except OverflowError:
            valid_budget = False
        if not valid_budget:
            raise ValueError("invalid authorization budget")
        if budget["session_cu"] > budget["total_cu"]:
            raise ValueError("invalid authorization budget")
        # JSONEncoder emits integral Swift Doubles as integers. Bind the value,
        # not the producer's choice of 5 versus 5.0, across phone round trips.
        request["budget"] = {k: int(v) if isinstance(v, float) and v.is_integer() else v
                             for k, v in budget.items()}
    elif budget is not None:
        raise ValueError("unexpected authorization budget")
    result = dict(request)
    result["digest"] = hashlib.sha256(canonical(request).encode()).hexdigest()
    return result


def request_body(request):
    return MARKER + canonical({k: v for k, v in request.items() if k != "digest"}) + "\n```"


def confirmation_text(request, text):
    # Re-read exact values are written to the existing receipt, not just a title.
    return "Alex 手机确认（操作授权记录）：\n\n" + request_body(request) + "\n\n" + text
