#!/usr/bin/env python3
"""Runtime hooks: turn platform events into incident records.

    AIGOV_WEBHOOK_SECRET=... python3 hooks/receiver.py --port 8081 [--incidents incidents/]

Endpoints (POST, JSON):
    /hooks/aws-eventbridge     Amazon EventBridge envelope (API destination) — Bedrock Guardrails,
                               GuardDuty, CloudWatch alarm → EventBridge rule → this receiver
    /hooks/azure-eventgrid     Azure Event Grid (webhook subscription; validation handshake supported)
                               — Defender for AI alerts, Foundry/Content Safety via Event Grid
    /hooks/gcp-pubsub          Google Pub/Sub push subscription — Model Armor / Cloud Logging sinks
    /hooks/generic             {"system": "...", "event_type": "...", "severity": "...", "title": "...", "details": {...}}
                               for OpenAI, Anthropic, Mistral moderation gates, SIEM rules, LiteLLM, etc.
    /healthz                   GET liveness

Authentication: every POST must carry `X-AIGov-Signature: sha256=<hex HMAC of the raw body
with AIGOV_WEBHOOK_SECRET>` or `Authorization: Bearer <AIGOV_WEBHOOK_SECRET>` (for senders that
cannot sign, such as EventBridge API destinations with an API-key auth). Comparison is constant-time.

Each accepted event becomes incidents/INC-<date>-<hash>.yaml (see hooks/README.md for the record
shape and the mapping rules). Nothing is executed from the payload; only allow-listed keys are kept.
"""
from __future__ import annotations

import argparse
import base64
import datetime as dt
import hashlib
import hmac
import json
import os
import re
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
SYSTEM_RE = re.compile(r"^[a-z0-9][a-z0-9-]{1,62}$")
SEVERITIES = ("low", "medium", "high", "critical")
MAX_BODY = 1_000_000
KEEP_KEYS = {"action", "assessment", "category", "confidence", "detail-type", "eventType", "guardrailId", "guardrailVersion",
             "id", "message", "modelId", "operation", "outcome", "policy", "reason", "region", "resource", "severity",
             "source", "subject", "topic", "type", "verdict", "filter", "alertType", "compromisedEntity", "productName",
             "matchState", "sanitizationResult", "ruleName", "alarmName", "state", "value"}


def utcnow() -> str:
    return dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def prune(obj, depth: int = 0):
    """Keep only allow-listed keys at every depth, short strings, numbers and booleans."""
    if depth > 4:
        return None
    if isinstance(obj, dict):
        out = {}
        for k, v in obj.items():
            if k in KEEP_KEYS:
                pv = prune(v, depth + 1)
                if pv not in (None, {}, []):
                    out[str(k)[:64]] = pv
        return out
    if isinstance(obj, list):
        return [x for x in (prune(v, depth + 1) for v in obj[:20]) if x not in (None, {}, [])]
    if isinstance(obj, str):
        return obj[:500]
    if isinstance(obj, (int, float, bool)) or obj is None:
        return obj
    return str(obj)[:200]


def severity_for(event_type: str, hint: str | None) -> str:
    if hint and str(hint).lower() in SEVERITIES:
        return str(hint).lower()
    h = (hint or "").lower()
    if h in ("sev0", "sev1", "p1", "critical"):
        return "critical"
    if h in ("sev2", "p2", "high", "error", "alarm"):
        return "high"
    if h in ("sev3", "p3", "medium", "warning", "warn"):
        return "medium"
    if h in ("sev4", "p4", "low", "informational", "info"):
        return "low"
    return {"prompt_attack_detected": "high", "defender_alert": "high", "guardrail_intervened": "medium", "content_filtered": "medium",
            "moderation_flagged": "medium", "model_armor_match": "medium", "budget_alarm": "medium"}.get(event_type, "medium")


def find_system(*cands) -> str | None:
    for c in cands:
        if isinstance(c, str) and SYSTEM_RE.match(c):
            return c
    return None


# ── Adapters: raw payload → list of normalised events ───────────────────────────
def from_generic(body: dict, query_system: str | None) -> list[dict]:
    return [{
        "system": find_system(body.get("system"), query_system),
        "source": str(body.get("source", "generic"))[:40],
        "event_type": str(body.get("event_type", "manual"))[:40],
        "severity": severity_for(str(body.get("event_type", "")), body.get("severity")),
        "title": str(body.get("title", "Runtime event"))[:200],
        "occurred": str(body.get("time", utcnow()))[:40],
        "details": prune(body.get("details", {})),
    }]


def from_eventbridge(body: dict, query_system: str | None) -> list[dict]:
    detail = body.get("detail", {}) if isinstance(body.get("detail"), dict) else {}
    dtype = str(body.get("detail-type", ""))
    src = str(body.get("source", "aws"))
    tags = detail.get("tags", {}) if isinstance(detail.get("tags"), dict) else {}
    et = "guardrail_intervened" if "guardrail" in (dtype + json.dumps(detail)[:2000]).lower() else \
         "defender_alert" if src == "aws.guardduty" else "budget_alarm" if src == "aws.cloudwatch" else "platform_event"
    return [{
        "system": find_system(tags.get("aigov-system"), tags.get("workload"), detail.get("aigovSystem"), query_system),
        "source": "aws-bedrock" if "bedrock" in src else src[:40],
        "event_type": et,
        "severity": severity_for(et, detail.get("severity") or (detail.get("state", {}) or {}).get("value") if isinstance(detail.get("state"), dict) else detail.get("severity")),
        "title": (dtype or "EventBridge event")[:200],
        "occurred": str(body.get("time", utcnow()))[:40],
        "details": prune({"detail-type": dtype, "source": src, "region": body.get("region"), "resources": body.get("resources", [])[:5], **detail}),
    }]


def from_eventgrid(body, query_system: str | None) -> list[dict]:
    events = body if isinstance(body, list) else [body]
    out = []
    for e in events:
        if not isinstance(e, dict):
            continue
        etype = str(e.get("eventType") or e.get("type") or "")
        data = e.get("data", {}) if isinstance(e.get("data"), dict) else {}
        et = "defender_alert" if "Security" in etype or "alert" in etype.lower() else \
             "content_filtered" if "ContentSafety" in etype or "contentFilter" in json.dumps(data)[:2000] else "platform_event"
        out.append({
            "system": find_system(data.get("aigovSystem"), (data.get("tags") or {}).get("aigov-system") if isinstance(data.get("tags"), dict) else None, query_system),
            "source": "azure-foundry",
            "event_type": et,
            "severity": severity_for(et, data.get("severity")),
            "title": (etype or "Event Grid event")[:200],
            "occurred": str(e.get("eventTime") or e.get("time") or utcnow())[:40],
            "details": prune({"eventType": etype, "subject": e.get("subject"), **data}),
        })
    return out


def from_pubsub(body: dict, query_system: str | None) -> list[dict]:
    msg = body.get("message", {}) if isinstance(body.get("message"), dict) else {}
    attrs = msg.get("attributes", {}) if isinstance(msg.get("attributes"), dict) else {}
    try:
        data = json.loads(base64.b64decode(msg.get("data", "") or "e30=").decode("utf-8", "replace"))
    except (ValueError, json.JSONDecodeError):
        data = {}
    if not isinstance(data, dict):
        data = {"value": data}
    blob = json.dumps(data)[:2000].lower()
    et = "model_armor_match" if "modelarmor" in blob or "sanitization" in blob else "platform_event"
    return [{
        "system": find_system(attrs.get("aigov-system"), (data.get("labels") or {}).get("aigov-system") if isinstance(data.get("labels"), dict) else None, query_system),
        "source": "gcp-vertex",
        "event_type": et,
        "severity": severity_for(et, data.get("severity")),
        "title": str(attrs.get("title") or data.get("logName") or "Pub/Sub event")[:200],
        "occurred": str(msg.get("publishTime") or utcnow())[:40],
        "details": prune({**attrs, **data}),
    }]


ADAPTERS = {"aws-eventbridge": from_eventbridge, "azure-eventgrid": from_eventgrid, "gcp-pubsub": from_pubsub, "generic": from_generic}
EVENT_CONTROLS = {"guardrail_intervened": ["AIG-10", "AIG-16"], "content_filtered": ["AIG-10", "AIG-16"], "prompt_attack_detected": ["AIG-10", "AIG-13", "AIG-16"],
                  "moderation_flagged": ["AIG-10", "AIG-16"], "defender_alert": ["AIG-13", "AIG-16"], "model_armor_match": ["AIG-10", "AIG-16"],
                  "budget_alarm": ["AIG-22"], "platform_event": ["AIG-16"], "manual": ["AIG-16"]}


def write_incident(ev: dict, incidents_dir: Path, raw: bytes) -> Path:
    stamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%d")
    h = hashlib.sha256(raw).hexdigest()[:8]
    iid = f"INC-{stamp}-{h}"
    rec = {
        "apiVersion": "aigov/v1",
        "kind": "AIIncident",
        "id": iid,
        "system": ev["system"] or "unassigned",
        "source": ev["source"],
        "event_type": ev["event_type"],
        "severity": ev["severity"],
        "title": ev["title"],
        "occurred": ev["occurred"],
        "opened": utcnow(),
        "status": "open",
        "controls": EVENT_CONTROLS.get(ev["event_type"], ["AIG-16"]),
        "details": ev["details"],
        "notes": [],
    }
    incidents_dir.mkdir(parents=True, exist_ok=True)
    path = incidents_dir / f"{iid}.yaml"
    path.write_text(yaml.safe_dump(rec, sort_keys=False, allow_unicode=True), encoding="utf-8")
    return path


class Handler(BaseHTTPRequestHandler):
    secret: bytes = b""
    incidents_dir: Path = ROOT / "incidents"
    server_version = "aigov-hooks/1.0"

    def log_message(self, fmt, *args):  # quieter, no client payloads
        sys.stderr.write(f"{self.address_string()} {fmt % args}\n")

    def _send(self, code: int, obj: dict) -> None:
        data = json.dumps(obj).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _authorised(self, raw: bytes) -> bool:
        if not self.secret:
            return False
        sig = self.headers.get("X-AIGov-Signature", "")
        if sig.startswith("sha256="):
            expect = hmac.new(self.secret, raw, hashlib.sha256).hexdigest()
            return hmac.compare_digest(sig[7:].strip().lower(), expect)
        auth = self.headers.get("Authorization", "")
        if auth.startswith("Bearer "):
            return hmac.compare_digest(auth[7:].strip().encode(), self.secret)
        return False

    def do_GET(self):
        if self.path == "/healthz":
            return self._send(200, {"ok": True, "incidents_dir": str(self.incidents_dir)})
        return self._send(404, {"error": "not found"})

    def do_POST(self):
        path, _, query = self.path.partition("?")
        source = path.removeprefix("/hooks/")
        if path == source or source not in ADAPTERS:
            return self._send(404, {"error": "unknown hook", "hooks": sorted(ADAPTERS)})
        length = int(self.headers.get("Content-Length", "0") or 0)
        if length <= 0 or length > MAX_BODY:
            return self._send(413 if length > MAX_BODY else 400, {"error": "bad length"})
        raw = self.rfile.read(length)
        try:
            body = json.loads(raw.decode("utf-8"))
        except (ValueError, json.JSONDecodeError):
            return self._send(400, {"error": "body is not JSON"})
        # Event Grid validation handshake happens before the subscription can deliver; it carries no secret.
        if source == "azure-eventgrid" and isinstance(body, list) and body and isinstance(body[0], dict) \
                and body[0].get("eventType") == "Microsoft.EventGrid.SubscriptionValidationEvent":
            code = (body[0].get("data") or {}).get("validationCode", "")
            return self._send(200, {"validationResponse": str(code)[:200]})
        if not self._authorised(raw):
            return self._send(401, {"error": "unauthorised"})
        q_system = None
        for part in query.split("&"):
            k, _, v = part.partition("=")
            if k == "system":
                q_system = v
        written = []
        for ev in ADAPTERS[source](body, q_system):
            written.append(write_incident(ev, self.incidents_dir, raw + json.dumps(ev, sort_keys=True).encode()).name)
        return self._send(202, {"accepted": len(written), "incidents": written})


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=8081)
    ap.add_argument("--incidents", type=Path, default=ROOT / "incidents")
    args = ap.parse_args()
    secret = os.environ.get("AIGOV_WEBHOOK_SECRET", "")
    if len(secret) < 16:
        sys.exit("AIGOV_WEBHOOK_SECRET must be set (16+ characters)")
    Handler.secret = secret.encode()
    Handler.incidents_dir = args.incidents
    srv = ThreadingHTTPServer((args.host, args.port), Handler)
    print(f"aigov hooks listening on http://{args.host}:{args.port}  → {args.incidents}", file=sys.stderr)
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass
    return 0


if __name__ == "__main__":
    sys.exit(main())
