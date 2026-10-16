"""Read-only Colab projection. No execution commands or client-supplied paths."""
import json
import math
import re
import time

MAX_BYTES = 2 * 1024 * 1024


def number(value, nullable=True):
    if value is None and nullable:
        return True
    try:
        return type(value) in (int, float) and math.isfinite(value) and value >= 0
    except OverflowError:
        return False


def text(value, maximum=120):
    return isinstance(value, str) and 0 < len(value) <= maximum and not any(ord(c) < 32 for c in value)


def validate_snapshot(data):
    """Reject unknown fields so provider paths, logs and identities never leak."""
    def keys(value, expected):
        return isinstance(value, dict) and set(value) == set(expected.split())

    if not keys(data, "version observed_at usage budget experiments executions") or type(data["version"]) is not int or data["version"] != 1:
        raise ValueError("invalid Colab snapshot")
    if not number(data["observed_at"], False) or data["observed_at"] > time.time() + 300:
        raise ValueError("invalid Colab observation")
    usage, budget = data["usage"], data["budget"]
    if (not keys(usage, "status balance rate assignments observed_at") or
            usage["status"] not in ("sampled", "unavailable", "not_requested") or
            usage["assignments"] is not None and (type(usage["assignments"]) is not int or usage["assignments"] < 0) or
            not all(number(usage[k]) for k in ("balance", "rate", "assignments", "observed_at")) or
            usage["observed_at"] is not None and usage["observed_at"] > data["observed_at"] + 300 or
            usage["status"] != "sampled" and any(usage[k] is not None for k in ("balance", "rate", "assignments", "observed_at")) or
            not keys(budget, "measured_cu unmeasured_runs") or not number(budget["measured_cu"], False) or
            type(budget["unmeasured_runs"]) is not int or budget["unmeasured_runs"] < 0):
        raise ValueError("invalid Colab usage")
    experiments, executions = data["experiments"], data["executions"]
    if not isinstance(experiments, list) or len(experiments) > 100 or not isinstance(executions, list) or len(executions) > 100:
        raise ValueError("oversized Colab snapshot")
    fingerprints, requests = set(), set()
    for item in experiments:
        if (not keys(item, "fingerprint status completed_queries total_queries completed_batches total_batches measured_cu release_confirmed baseline candidate") or
                not isinstance(item["fingerprint"], str) or not re.fullmatch("[0-9a-f]{64}", item["fingerprint"]) or
                item["fingerprint"] in fingerprints or item["status"] not in ("allocating", "running", "complete", "interrupted", "cleanup_unconfirmed", "recovered_cost_includes_interruption_interval", "unknown") or
                item["release_confirmed"] is not None and type(item["release_confirmed"]) is not bool or
                not number(item["measured_cu"])):
            raise ValueError("invalid Colab experiment")
        fingerprints.add(item["fingerprint"])
        for done, total in [("completed_queries", "total_queries"), ("completed_batches", "total_batches")]:
            if (any(item[k] is not None and (type(item[k]) is not int or item[k] < 0) for k in (done, total)) or
                    item[done] is not None and item[total] is not None and item[done] > item[total]):
                raise ValueError("invalid Colab progress")
        for arm in (item["baseline"], item["candidate"]):
            if arm is None:
                continue
            if (not keys(arm, "top1 top5 top10 false_same_rate negative_rejection_rate acceptance_status") or
                    not all(number(arm[k]) for k in ("top1", "top5", "top10", "false_same_rate", "negative_rejection_rate")) or
                    arm["acceptance_status"] is not None and not text(arm["acceptance_status"])):
                raise ValueError("invalid Colab evaluation")
    for item in executions:
        if (not keys(item, "request_id item_id operation fingerprint status") or
                not isinstance(item["request_id"], str) or not re.fullmatch("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", item["request_id"]) or
                item["request_id"] in requests or not text(item["item_id"]) or
                item["operation"] not in ("colab.run", "colab.resume", "colab.recover", "colab.calibrate") or
                not isinstance(item["fingerprint"], str) or not re.fullmatch("[0-9a-f]{64}", item["fingerprint"]) or item["status"] not in ("running", "complete", "failed", "uncertain")):
            raise ValueError("invalid Colab execution")
        requests.add(item["request_id"])
    return data


def read_projection(command, script, output, cwd, wrapper=None):
    args = ["python3", script, "snapshot", "--output", output]
    if wrapper:
        args += ["--live-usage", "--colab-wrap", wrapper]
    try:
        code, raw, _ = command(args, timeout=40, cwd=cwd, max_bytes=MAX_BYTES)
        if code or len(raw) > MAX_BYTES:
            raise ValueError("Colab unavailable")
        return {"colab": validate_snapshot(json.loads(raw)), "colab_unavailable": False}
    except (ValueError, TypeError, OSError, RuntimeError, AttributeError, KeyError):
        # Independent failure; never retain an old balance as a fresh measurement.
        return {"colab_unavailable": True}
