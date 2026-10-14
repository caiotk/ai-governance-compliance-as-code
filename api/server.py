#!/usr/bin/env python3
"""Read-only HTTP/JSON API over the catalogue, profiles, inventory and gate.

    python3 api/server.py --port 8080                 # open, local use
    AIGOV_API_TOKEN=... python3 api/server.py --host 0.0.0.0 --port 8080   # bearer-token protected

    GET  /                                  summary and endpoint list
    GET  /openapi.json                      OpenAPI 3.1 description
    GET  /v1/frameworks[?jurisdiction=NZ&baseline=1]
    GET  /v1/frameworks/{id}
    GET  /v1/controls                       22 controls with clause mappings
    GET  /v1/controls/{id}                  + vendor packs implementing it, risks it treats
    GET  /v1/crosswalk[?control=AIG-03&framework=eu-ai-act]
    GET  /v1/risks[?category=agentic]       36 risks
    GET  /v1/risks/{id}
    GET  /v1/sectors
    GET  /v1/jurisdictions/{cc}[?sector=fsi]  frameworks that apply
    GET  /v1/profiles                       70 country × sector profiles (index)
    GET  /v1/profiles/{cc}/{sector}         profile with Markdown and system template
    GET  /v1/vendors, /v1/vendors/{id}
    GET  /v1/systems[?gate=1]               inventory of systems/*.yaml
    GET  /v1/systems/{id}                   record + gate decision
    GET  /v1/incidents[?system=id&open=1]
    POST /v1/evaluate                       body: AI system record (JSON) → gate decision (nothing is stored)

No write endpoints exist. Pagination is not needed at this size; the hosted,
multi-tenant API with evidence, approvals and webhooks is the NexGuide.AI
GovMap edition.
"""
from __future__ import annotations

import argparse
import hmac
import json
import os
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlsplit

sys.path.insert(0, str(Path(__file__).resolve().parent))
import data  # noqa: E402

MAX_BODY = 2_000_000


def openapi() -> dict:
    s = data.summary()
    paths = {
        "/v1/frameworks": {"get": {"summary": "List frameworks", "parameters": [{"name": "jurisdiction", "in": "query", "schema": {"type": "string"}}, {"name": "baseline", "in": "query", "schema": {"type": "string"}}]}},
        "/v1/frameworks/{id}": {"get": {"summary": "Framework", "parameters": [{"name": "id", "in": "path", "required": True, "schema": {"type": "string"}}]}},
        "/v1/controls": {"get": {"summary": "List controls"}},
        "/v1/controls/{id}": {"get": {"summary": "Control with implementers and risks", "parameters": [{"name": "id", "in": "path", "required": True, "schema": {"type": "string"}}]}},
        "/v1/crosswalk": {"get": {"summary": "Control × framework clause crosswalk", "parameters": [{"name": "control", "in": "query", "schema": {"type": "string"}}, {"name": "framework", "in": "query", "schema": {"type": "string"}}]}},
        "/v1/risks": {"get": {"summary": "List risks", "parameters": [{"name": "category", "in": "query", "schema": {"type": "string"}}]}},
        "/v1/risks/{id}": {"get": {"summary": "Risk", "parameters": [{"name": "id", "in": "path", "required": True, "schema": {"type": "string"}}]}},
        "/v1/sectors": {"get": {"summary": "Sectors"}},
        "/v1/jurisdictions/{cc}": {"get": {"summary": "Frameworks applying in a jurisdiction", "parameters": [{"name": "cc", "in": "path", "required": True, "schema": {"type": "string"}}, {"name": "sector", "in": "query", "schema": {"type": "string"}}]}},
        "/v1/profiles": {"get": {"summary": "Profile index"}},
        "/v1/profiles/{cc}/{sector}": {"get": {"summary": "Profile", "parameters": [{"name": "cc", "in": "path", "required": True, "schema": {"type": "string"}}, {"name": "sector", "in": "path", "required": True, "schema": {"type": "string"}}]}},
        "/v1/vendors": {"get": {"summary": "Vendor packs"}},
        "/v1/vendors/{id}": {"get": {"summary": "Vendor pack mapping", "parameters": [{"name": "id", "in": "path", "required": True, "schema": {"type": "string"}}]}},
        "/v1/systems": {"get": {"summary": "Inventory", "parameters": [{"name": "gate", "in": "query", "schema": {"type": "string"}}]}},
        "/v1/systems/{id}": {"get": {"summary": "System record and decision", "parameters": [{"name": "id", "in": "path", "required": True, "schema": {"type": "string"}}]}},
        "/v1/incidents": {"get": {"summary": "Incidents", "parameters": [{"name": "system", "in": "query", "schema": {"type": "string"}}, {"name": "open", "in": "query", "schema": {"type": "string"}}]}},
        "/v1/evaluate": {"post": {"summary": "Evaluate a record with the gate (stateless)", "requestBody": {"required": True, "content": {"application/json": {"schema": {"type": "object"}}}}}},
    }
    return {"openapi": "3.1.0", "info": {"title": s["name"] + " API", "version": s["version"], "license": {"name": "Apache-2.0"}},
            "components": {"securitySchemes": {"bearer": {"type": "http", "scheme": "bearer"}}}, "paths": paths}


def route(method: str, path: str, q: dict, body) -> tuple[int, object]:
    parts = [p for p in path.split("/") if p]
    one = lambda k: (q.get(k) or [None])[0]  # noqa: E731
    if method == "GET":
        if not parts:
            return 200, {**data.summary(), "endpoints": sorted(openapi()["paths"])}
        if parts == ["openapi.json"]:
            return 200, openapi()
        if parts == ["healthz"]:
            return 200, {"ok": True}
        if parts[0] != "v1" or len(parts) < 2:
            return 404, {"error": "not found"}
        res, rest = parts[1], parts[2:]
        c = data.catalogue()
        if res == "frameworks":
            if rest:
                f = c["frameworks"].get(rest[0])
                return (200, f) if f else (404, {"error": "unknown framework"})
            return 200, data.frameworks(baseline_only=one("baseline") in ("1", "true"), jurisdiction=one("jurisdiction"))
        if res == "controls":
            if rest:
                ctl = data.control(rest[0])
                return (200, ctl) if ctl else (404, {"error": "unknown control"})
            return 200, list(c["controls"].values())
        if res == "crosswalk":
            return 200, data.crosswalk(one("control"), one("framework"))
        if res == "risks":
            if rest:
                r = data.risk(rest[0])
                return (200, r) if r else (404, {"error": "unknown risk"})
            cat = one("category")
            return 200, {"categories": c["risk_categories"], "risks": [r for r in c["risks"].values() if not cat or r["category"] == cat]}
        if res == "sectors":
            return 200, list(c["sectors"].values())
        if res == "jurisdictions" and rest:
            if rest[0].upper() not in c["jurisdictions"]:
                return 404, {"error": "unknown jurisdiction", "known": sorted(c["jurisdictions"])}
            ids = data.frameworks_for(rest[0], one("sector"))
            return 200, {"jurisdiction": rest[0].upper(), "sector": one("sector"), "frameworks": [c["frameworks"][i] for i in ids if i in c["frameworks"]]}
        if res == "profiles":
            if len(rest) == 2:
                p = data.profile(rest[0], rest[1])
                return (200, p) if p else (404, {"error": "unknown profile"})
            return 200, c["profiles"]
        if res == "vendors":
            if rest:
                v = data.vendor(rest[0])
                return (200, v) if v else (404, {"error": "unknown vendor pack"})
            return 200, {vid: {k: vp.get(k) for k in ("name", "verified", "native_tools", "attestations")} for vid, vp in c["vendors"].items()}
        if res == "systems":
            if rest:
                s = data.system(rest[0])
                return (200, s) if s else (404, {"error": "unknown system"})
            return 200, data.systems(run_gate=one("gate") in ("1", "true"))
        if res == "incidents":
            return 200, data.incidents(one("system"), one("open") in ("1", "true"))
        return 404, {"error": "not found"}
    if method == "POST" and parts == ["v1", "evaluate"]:
        if not isinstance(body, dict):
            return 400, {"error": "body must be an AI system record (JSON object)"}
        return 200, data.evaluate(body, one("date"))
    return 405, {"error": "method not allowed"}


class Handler(BaseHTTPRequestHandler):
    token: bytes = b""
    server_version = "aigov-api/1.0"

    def log_message(self, fmt, *args):
        sys.stderr.write(f"{self.address_string()} {fmt % args}\n")

    def _send(self, code: int, obj) -> None:
        body = json.dumps(obj, ensure_ascii=False, default=str).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        self.wfile.write(body)

    def _auth(self) -> bool:
        if not self.token:
            return True
        auth = self.headers.get("Authorization", "")
        return auth.startswith("Bearer ") and hmac.compare_digest(auth[7:].strip().encode(), self.token)

    def _handle(self, method: str) -> None:
        u = urlsplit(self.path)
        if u.path not in ("/", "/healthz", "/openapi.json") and not self._auth():
            return self._send(401, {"error": "unauthorised"})
        body = None
        if method == "POST":
            n = int(self.headers.get("Content-Length", "0") or 0)
            if n > MAX_BODY:
                return self._send(413, {"error": "body too large"})
            try:
                body = json.loads(self.rfile.read(n).decode("utf-8")) if n else None
            except (ValueError, json.JSONDecodeError):
                return self._send(400, {"error": "body is not JSON"})
        try:
            code, obj = route(method, u.path, parse_qs(u.query), body)
        except Exception as e:  # noqa: BLE001 - report, never crash the server
            code, obj = 500, {"error": type(e).__name__, "detail": str(e)[:300]}
        self._send(code, obj)

    def do_GET(self):
        self._handle("GET")

    def do_POST(self):
        self._handle("POST")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=8080)
    args = ap.parse_args()
    Handler.token = os.environ.get("AIGOV_API_TOKEN", "").encode()
    if args.host != "127.0.0.1" and not Handler.token:
        print("warning: binding beyond localhost without AIGOV_API_TOKEN", file=sys.stderr)
    srv = ThreadingHTTPServer((args.host, args.port), Handler)
    print(f"aigov api listening on http://{args.host}:{args.port}  ({'token' if Handler.token else 'open'})", file=sys.stderr)
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass
    return 0


if __name__ == "__main__":
    sys.exit(main())
