# Entry point for the MLOps governance gate.
#
#   opa eval -d mlops/policies -d mlops/data/catalog.json \
#            -i system.json 'data.aigov.decision'
#
# The decision lists every framework that applies to the system (from its
# countries, sector and entity types), every finding, and whether the system may
# be promoted. Findings with severity "deny" block promotion; "warn" findings are
# obligations that are not yet in force, advisory, or a gap in the record itself,
# surfaced so teams can prepare before the deadline.
package aigov

import data.aigov_catalog as catalog

# ── Evaluation date ──────────────────────────────────────────────────────────
eval_date := input.context.evaluation_date if {
	input.context.evaluation_date
} else := time.format([time.now_ns(), "UTC", "2006-01-02"])

on_or_after(d) if eval_date >= d

# ── Small helpers over the system record ─────────────────────────────────────
get(path) := object.get(input, path, null)

yes(path) if get(path) == true

no(path) if not yes(path)

# A string field counts as evidence only when it is non-empty.
present(path) if {
	v := get(path)
	is_string(v)
	v != ""
	not startswith(v, "FILL IN")
}

entity(t) if t in object.get(input.context, "entity_types", [])

sector := input.context.sector

role := input.context.role

consequential if input.system.decision_impact == "consequential"

personal_data if yes(["data", "personal_data"])

# `annex_iii_area: null` means "not an Annex III use" — only a real value is high-risk.
annex_iii := v if {
	v := object.get(input.system, "annex_iii_area", null)
	v != null
}

high_risk if annex_iii

high_risk if object.get(input, ["risk", "classification"], "") == "high"

us_state(s) if s in object.get(input.context, "us_states", [])

us_locality(l) if l in object.get(input.context, "us_localities", [])

# ── Applicable frameworks ────────────────────────────────────────────────────
# A framework applies when one of the system's countries lists it, unless the
# catalogue gates it on an entity type (prudential and critical-infrastructure
# regimes). Gated frameworks bind the ENTITY whatever sector the record declares,
# so a bank's engineering copilot is still APRA- or MAS-supervised.
frameworks contains fw if {
	some c in input.context.countries
	some fw in catalog.jurisdictions[c].frameworks
	gate_ok(fw)
}

frameworks contains fw if {
	some c in input.context.countries
	some fw in object.get(catalog.jurisdictions[c], ["sector_frameworks", sector], [])
	gate_ok(fw)
}

frameworks contains fw if {
	some c in input.context.countries
	some _, fws in object.get(catalog.jurisdictions[c], "sector_frameworks", {})
	some fw in fws
	catalog.gates[fw]
	entity(catalog.gates[fw].entity_type)
}

# Baseline standards (ISO 27001/42001/42005/19011, NIST AI RMF, SP 800-61,
# OWASP, MITRE ATLAS, zero trust) apply to every system regardless of country.
frameworks contains fw if {
	some fw in catalog.baseline
}

gate_ok(fw) if not catalog.gates[fw]

gate_ok(fw) if entity(catalog.gates[fw].entity_type)

# ── Controls required by those frameworks ────────────────────────────────────
required[c] := fws if {
	some c, ctl in catalog.controls
	fws := {fw | some fw in ctl.frameworks; fw in frameworks}
	count(fws) > 0
}

# ── Findings ─────────────────────────────────────────────────────────────────
findings contains f if {
	some v in control_violations
	fws := required[v.control]
	f := {
		"id": v.control,
		"control": v.control,
		"severity": "deny",
		"frameworks": sort([fw | some fw in fws]),
		"message": v.message,
	}
}

findings contains f if {
	some f in framework_findings
	some fw in f.frameworks
	fw in frameworks
}

# Record-quality findings: the record itself is missing context the gate needs.
findings contains {
	"id": "record:us_states",
	"control": "AIG-02",
	"severity": "warn",
	"frameworks": ["us-ai"],
	"message": "context.us_states is empty: US state laws (Colorado, Texas, California, Illinois, New York City) cannot be evaluated. List every state where affected people are located.",
} if {
	"US" in input.context.countries
	count(object.get(input.context, "us_states", [])) == 0
}

deny := sort([f | some f in findings; f.severity == "deny"])

warn := sort([f | some f in findings; f.severity == "warn"])

decision := {
	"system": input.metadata.id,
	"evaluation_date": eval_date,
	"frameworks": sort([fw | some fw in frameworks]),
	"required_controls": sort([c | some c, _ in required]),
	"allow": count(deny) == 0,
	"deny": deny,
	"warn": warn,
}
