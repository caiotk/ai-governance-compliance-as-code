#!/usr/bin/env python3
"""Model Context Protocol server (stdio) over the catalogue, profiles, inventory and gate.

Lets an assistant ask "which frameworks apply to a bank's agent in Australia?",
"what does AIG-11 require under the EU AI Act?", "evaluate this record", or
"which risks apply to an agentic system?" against the verified catalogue
instead of guessing. Read-only; no dependencies beyond the repository's.

Claude Desktop / Claude Code / Cursor configuration:

    {"mcpServers": {"ai-governance": {"command": "python3", "args": ["/path/to/repo/mcp/server.py"]}}}

Tools: list_frameworks, get_framework, frameworks_for, list_controls, get_control,
crosswalk, list_risks, get_risk, get_profile, list_vendor_packs, get_vendor_pack,
list_systems, get_system, evaluate_system, list_incidents.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

import yaml

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "api"))
import data  # noqa: E402

PROTOCOL_VERSIONS = ("2025-06-18", "2025-03-26", "2024-11-05")

TOOLS = [
    {"name": "list_frameworks", "description": "List the laws, standards and guidance in the catalogue (id, name, type, status, verification). Optional: jurisdiction (ISO country code) or baseline only.",
     "inputSchema": {"type": "object", "properties": {"jurisdiction": {"type": "string"}, "baseline_only": {"type": "boolean"}}}},
    {"name": "get_framework", "description": "Full catalogue entry for one framework (status, key dates, components, notes, source URL, verification label).",
     "inputSchema": {"type": "object", "properties": {"id": {"type": "string"}}, "required": ["id"]}},
    {"name": "frameworks_for", "description": "Which frameworks apply to a system in a country (and sector). Gated prudential regimes (APRA, MAS, RBNZ BS11, critical infrastructure) are included only when entity_types names them.",
     "inputSchema": {"type": "object", "properties": {"country": {"type": "string"}, "sector": {"type": "string", "enum": ["health", "fsi", "public", "agriculture", "mining", "tech", "energy"]}}, "required": ["country"]}},
    {"name": "list_controls", "description": "The 22 shared controls AIG-01 … AIG-22 with objective and the frameworks each maps to.", "inputSchema": {"type": "object", "properties": {}}},
    {"name": "get_control", "description": "One control: objective, evidence fields, clause-by-clause mappings, vendor packs that implement it natively, risks it treats.",
     "inputSchema": {"type": "object", "properties": {"id": {"type": "string", "description": "e.g. AIG-11"}}, "required": ["id"]}},
    {"name": "crosswalk", "description": "Control × framework clause references. Filter by control and/or framework id.",
     "inputSchema": {"type": "object", "properties": {"control": {"type": "string"}, "framework": {"type": "string"}}}},
    {"name": "list_risks", "description": "The AI risk catalogue (RSK-01 … RSK-36): category, severity, when it applies, controls that treat it, OWASP/ATLAS/NIST references.",
     "inputSchema": {"type": "object", "properties": {"category": {"type": "string"}}}},
    {"name": "get_risk", "description": "One risk in full.", "inputSchema": {"type": "object", "properties": {"id": {"type": "string"}}, "required": ["id"]}},
    {"name": "get_profile", "description": "Country × sector compliance profile: applicable instruments, high-risk triggers, required controls, vendor coverage, and a pre-filled system record template.",
     "inputSchema": {"type": "object", "properties": {"country": {"type": "string"}, "sector": {"type": "string"}}, "required": ["country", "sector"]}},
    {"name": "list_vendor_packs", "description": "Vendor policy packs (Foundry, Copilot Studio, Bedrock, Vertex, OpenAI, Anthropic, Mistral, Llama): native tools, attestations.", "inputSchema": {"type": "object", "properties": {}}},
    {"name": "get_vendor_pack", "description": "One vendor pack's mapping: controls implemented, gaps, native tools, attestations.", "inputSchema": {"type": "object", "properties": {"id": {"type": "string"}}, "required": ["id"]}},
    {"name": "list_systems", "description": "AI system inventory from systems/*.yaml (owner, scope, classification, model, flags). Set run_gate to include the gate result (needs opa).",
     "inputSchema": {"type": "object", "properties": {"run_gate": {"type": "boolean"}}}},
    {"name": "get_system", "description": "One system record with its gate decision (findings, frameworks, required controls, risks, evidence status).",
     "inputSchema": {"type": "object", "properties": {"id": {"type": "string"}}, "required": ["id"]}},
    {"name": "evaluate_system", "description": "Run the governance gate on an AI system record given as YAML or JSON text (schema: mlops/schema/ai-system.schema.json). Returns allow/deny with every finding. Nothing is stored.",
     "inputSchema": {"type": "object", "properties": {"record": {"type": "string"}, "date": {"type": "string", "description": "Evaluate as of YYYY-MM-DD"}}, "required": ["record"]}},
    {"name": "list_incidents", "description": "Incident records from incidents/ (runtime events from hooks/receiver.py or manual).",
     "inputSchema": {"type": "object", "properties": {"system": {"type": "string"}, "open_only": {"type": "boolean"}}}},
]


def call(name: str, a: dict):
    c = data.catalogue()
    if name == "list_frameworks":
        return [{k: f.get(k) for k in ("id", "name", "type", "status", "scope", "baseline", "verification")} for f in data.frameworks(bool(a.get("baseline_only")), a.get("jurisdiction"))]
    if name == "get_framework":
        return c["frameworks"].get(a["id"]) or {"error": "unknown framework"}
    if name == "frameworks_for":
        ids = data.frameworks_for(a["country"], a.get("sector"))
        return {"country": a["country"].upper(), "sector": a.get("sector"), "frameworks": [{"id": i, "name": c["frameworks"][i]["name"], "status": c["frameworks"][i]["status"], "gated_on": c["frameworks"][i].get("applies_when")} for i in ids if i in c["frameworks"]],
                "note": "Frameworks with gated_on apply only when the system's context.entity_types includes that entity type."}
    if name == "list_controls":
        return [{"id": i, "title": x["title"], "objective": x["objective"], "frameworks": sorted(x["mappings"])} for i, x in c["controls"].items()]
    if name == "get_control":
        return data.control(a["id"]) or {"error": "unknown control"}
    if name == "crosswalk":
        return data.crosswalk(a.get("control"), a.get("framework"))
    if name == "list_risks":
        return {"categories": c["risk_categories"], "risks": [r for r in c["risks"].values() if not a.get("category") or r["category"] == a["category"]]}
    if name == "get_risk":
        return data.risk(a["id"]) or {"error": "unknown risk"}
    if name == "get_profile":
        return data.profile(a["country"], a["sector"]) or {"error": "unknown profile", "countries": sorted(c["jurisdictions"]), "sectors": sorted(c["sectors"])}
    if name == "list_vendor_packs":
        return {vid: {k: vp.get(k) for k in ("name", "verified", "native_tools", "attestations")} for vid, vp in c["vendors"].items()}
    if name == "get_vendor_pack":
        return data.vendor(a["id"]) or {"error": "unknown vendor pack"}
    if name == "list_systems":
        return data.systems(run_gate=bool(a.get("run_gate")))
    if name == "get_system":
        return data.system(a["id"]) or {"error": "unknown system"}
    if name == "evaluate_system":
        try:
            rec = yaml.safe_load(a["record"])
        except yaml.YAMLError as e:
            return {"error": f"record is not valid YAML/JSON: {e}"}
        if not isinstance(rec, dict):
            return {"error": "record must be a mapping"}
        return data.evaluate(rec, a.get("date"))
    if name == "list_incidents":
        return data.incidents(a.get("system"), bool(a.get("open_only")))
    return {"error": f"unknown tool {name}"}


def reply(id_, result=None, error=None) -> None:
    msg = {"jsonrpc": "2.0", "id": id_}
    if error is not None:
        msg["error"] = error
    else:
        msg["result"] = result
    sys.stdout.write(json.dumps(msg, ensure_ascii=False, default=str) + "\n")
    sys.stdout.flush()


def main() -> int:
    s = data.summary()
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            req = json.loads(line)
        except json.JSONDecodeError:
            reply(None, error={"code": -32700, "message": "parse error"})
            continue
        method, id_, params = req.get("method"), req.get("id"), req.get("params") or {}
        if method == "initialize":
            v = params.get("protocolVersion")
            reply(id_, {"protocolVersion": v if v in PROTOCOL_VERSIONS else PROTOCOL_VERSIONS[0],
                        "capabilities": {"tools": {"listChanged": False}},
                        "serverInfo": {"name": "ai-governance-compliance-as-code", "version": s["version"]},
                        "instructions": f"Read-only access to the AI governance catalogue (verified as of {s['catalogue_as_of']}), 70 country × sector profiles, the risk catalogue, the system inventory and the MLOps gate. Every fact carries a verification label (primary/secondary/unverified); say so when you rely on secondary or unverified entries. Not legal advice."})
        elif method in ("notifications/initialized", "notifications/cancelled"):
            continue
        elif method == "ping":
            reply(id_, {})
        elif method == "tools/list":
            reply(id_, {"tools": TOOLS})
        elif method == "tools/call":
            name, args = params.get("name"), params.get("arguments") or {}
            try:
                out = call(name, args)
                is_err = isinstance(out, dict) and "error" in out
                reply(id_, {"content": [{"type": "text", "text": json.dumps(out, ensure_ascii=False, indent=1, default=str)}], "isError": is_err})
            except Exception as e:  # noqa: BLE001
                reply(id_, {"content": [{"type": "text", "text": f"{type(e).__name__}: {e}"}], "isError": True})
        elif method in ("resources/list", "prompts/list"):
            reply(id_, {"resources": [], "prompts": []} if method == "resources/list" else {"prompts": []})
        elif id_ is not None:
            reply(id_, error={"code": -32601, "message": f"method not found: {method}"})
    return 0


if __name__ == "__main__":
    sys.exit(main())
