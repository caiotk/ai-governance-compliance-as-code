package aigov_test

import data.aigov

# A fully evidenced baseline record; tests mutate it with object.union.
base := {
	"apiVersion": "aigov/v1",
	"kind": "AISystem",
	"metadata": {"id": "t", "name": "t", "owner": "owner@example.com"},
	"context": {"countries": ["NZ"], "sector": "tech", "role": "deployer", "public_body": false, "entity_types": [], "evaluation_date": "2026-10-13"},
	"system": {"purpose": "t", "decision_impact": "assistive", "annex_iii_area": null, "user_facing": true, "agentic": false, "irreversible_actions": false, "critical_operation": false},
	"governance": {"policy_approved": true, "registered_in_inventory": true, "ai_literacy_training": true, "risk_tolerance_defined": true, "internal_audit": {"programme": true, "last_audit": "2026-06-01", "findings_tracked": true}},
	"risk": {"classification": "limited", "impact_assessment": {"completed": true, "method": "ISO/IEC 42005:2025", "review_date": "2027-06-01", "interested_parties_identified": true}, "dpia": {"completed": true}},
	"data": {"personal_data": false, "provenance_documented": true},
	"model": {"approved": true},
	"supplier": {"assessed": true, "no_training_on_customer_data": true, "ai_bom": true},
	"security": {"local_auth_disabled": true, "least_privilege": true, "private_network": true, "data_residency_region": "nz", "cmk": true},
	"runtime": {"content_filters": true, "prompt_attack_detection": true, "pii_filtering": true},
	"oversight": {"human_in_the_loop": true, "override_and_stop": true},
	"transparency": {"ai_disclosure": true},
	"logging": {"invocation_logging": true, "retention_days": 365, "siem_integrated": true},
	"monitoring": {"drift_and_bias": true},
	"testing": {"evaluation_completed": true, "red_team_completed": true, "bias_assessment": true, "threat_model": {"completed": true, "references": ["OWASP-LLM-2026", "MITRE-ATLAS-2026.09"]}},
	"lifecycle": {"versioned": true, "promotion_gate": true},
	"incident": {"runbook": true, "notification_matrix": [], "lessons_learned": true},
}

# Everything an agent needs on top of `base` to pass the zero-trust, OWASP,
# ATLAS and Anthropic rules.
agent_ok := {
	"system": {"purpose": "t", "decision_impact": "assistive", "annex_iii_area": null, "user_facing": true, "agentic": true, "irreversible_actions": true, "critical_operation": false},
	"security": {"local_auth_disabled": true, "least_privilege": true, "private_network": true, "data_residency_region": "nz", "cmk": true, "short_lived_credentials": true, "tool_allowlist": true, "egress_allowlist": true, "sandboxed_execution": true, "idp_federated_identity": true},
	"runtime": {"content_filters": true, "prompt_attack_detection": true, "pii_filtering": true, "guardrail_enforced_centrally": true, "output_validation": true},
	"oversight": {"human_in_the_loop": true, "override_and_stop": true, "per_action_approval": true},
	"monitoring": {"drift_and_bias": true, "agent_telemetry": true},
}

with_(patch) := object.union(base, patch)

decide(rec) := d if {
	d := aigov.decision with input as rec
}

has_deny(d, control) if {
	some f in d.deny
	f.control == control
}

has_warn(d, control, fw) if {
	some f in d.warn
	f.control == control
	fw in f.frameworks
}

test_baseline_is_allowed if {
	decide(base).allow
}

test_baseline_frameworks_for_nz if {
	decide(base).frameworks == ["anthropic-zero-trust", "iso19011", "iso27001", "iso42001", "iso42005", "mitre-atlas", "nist-ai-rmf", "nist-sp-800-61", "nz-privacy", "owasp-genai", "zero-trust"]
}

test_baseline_has_no_warnings if {
	count(decide(base).warn) == 0
}

test_owner_must_be_named_person if {
	d := decide(with_({"metadata": {"id": "t", "name": "t", "owner": "team"}}))
	has_deny(d, "AIG-01")
}

test_prudential_frameworks_are_gated_by_entity_type if {
	fsi := {"context": {"countries": ["AU", "NZ"], "sector": "fsi", "role": "deployer", "entity_types": [], "evaluation_date": "2026-10-13"}}
	d := decide(with_(fsi))
	not "apra" in d.frameworks
	not "rbnz-bs11" in d.frameworks
	regulated := {"context": {"countries": ["AU", "NZ"], "sector": "fsi", "role": "deployer", "entity_types": ["apra_regulated", "nz_registered_bank"], "evaluation_date": "2026-10-13"}}
	d2 := decide(with_(regulated))
	"apra" in d2.frameworks
	"rbnz-bs11" in d2.frameworks
}

test_apra_requires_72h_notification if {
	rec := with_({"context": {"countries": ["AU"], "sector": "fsi", "role": "deployer", "entity_types": ["apra_regulated"], "evaluation_date": "2026-10-13"}})
	has_deny(decide(rec), "AIG-16")
	ok := object.union(rec, {"incident": {"runbook": true, "notification_matrix": ["APRA:72h"]}})
	decide(ok).allow
}

test_nz_ipp3a_is_enforced_after_commencement if {
	rec := with_({"data": {"personal_data": true, "provenance_documented": true, "indirect_collection": true, "lawful_basis": "x"}})
	before := object.union(rec, {"context": {"countries": ["NZ"], "sector": "tech", "role": "deployer", "evaluation_date": "2026-04-30"}})
	has_warn(decide(before), "AIG-12", "nz-privacy")
	has_deny(decide(rec), "AIG-12")
}

test_eu_fria_is_a_warning_until_dec_2027 if {
	public := {
		"context": {"countries": ["ES"], "sector": "public", "role": "deployer", "public_body": true, "evaluation_date": "2026-10-13"},
		"system": {"purpose": "t", "decision_impact": "consequential", "annex_iii_area": "essential_services", "user_facing": true},
	}
	d := decide(with_(public))
	has_warn(d, "AIG-03", "eu-ai-act")
	later := object.union(with_(public), {"context": {"countries": ["ES"], "sector": "public", "role": "deployer", "public_body": true, "evaluation_date": "2027-12-02"}})
	has_deny(decide(later), "AIG-03")
}

test_gdpr_dpia_required_for_special_category if {
	rec := with_({
		"context": {"countries": ["PT"], "sector": "health", "role": "deployer", "evaluation_date": "2026-10-13"},
		"data": {"personal_data": true, "special_category": true, "provenance_documented": true, "lawful_basis": "Art 9(2)(h)"},
		"risk": {"classification": "high", "impact_assessment": {"completed": true}, "dpia": {"completed": false}},
	})
	has_deny(decide(rec), "AIG-03")
}

test_colorado_admt_starts_2027 if {
	co := {
		"context": {"countries": ["US"], "us_states": ["CO"], "sector": "fsi", "role": "deployer", "evaluation_date": "2026-10-13"},
		"system": {"purpose": "t", "decision_impact": "consequential", "user_facing": false},
		"monitoring": {"drift_and_bias": true},
	}
	has_warn(decide(with_(co)), "AIG-12", "us-ai")
	later := object.union(with_(co), {"context": {"countries": ["US"], "us_states": ["CO"], "sector": "fsi", "role": "deployer", "evaluation_date": "2027-01-01"}})
	has_deny(decide(later), "AIG-12")
}

test_agents_need_central_guardrails_and_zero_trust_identity if {
	d := decide(with_({"system": {"purpose": "t", "decision_impact": "assistive", "user_facing": true, "agentic": true}}))
	has_deny(d, "AIG-10")
	has_deny(d, "AIG-07")
}

# Regression: `annex_iii_area: null` must not be treated as high-risk (B1).
test_null_annex_iii_is_not_high_risk if {
	rec := with_({
		"context": {"countries": ["ES"], "sector": "public", "role": "deployer", "public_body": true, "evaluation_date": "2028-01-15"},
		"system": {"purpose": "memo translation", "decision_impact": "none", "annex_iii_area": null, "user_facing": false},
		"risk": {"classification": "minimal", "impact_assessment": {"completed": true}, "dpia": {"completed": true}},
		"security": {"local_auth_disabled": true, "least_privilege": true, "private_network": true, "data_residency_region": "eu", "cmk": false},
		"testing": {"evaluation_completed": true, "red_team_completed": false, "bias_assessment": false},
	})
	decide(rec).allow
}

# Regression: empty strings are not evidence (B2).
test_empty_strings_are_not_evidence if {
	rec := with_({
		"context": {"countries": ["PT"], "sector": "tech", "role": "deployer", "evaluation_date": "2026-10-13"},
		"data": {"personal_data": true, "provenance_documented": true, "lawful_basis": "", "cross_border_transfer": true, "transfer_mechanism": ""},
		"security": {"local_auth_disabled": true, "least_privilege": true, "private_network": true, "data_residency_region": "", "cmk": true},
	})
	d := decide(rec)
	has_deny(d, "AIG-04")
	has_deny(d, "AIG-18")
	has_deny(d, "AIG-08")
}

# Regression: prudential frameworks bind the entity whatever the sector (R1).
test_apra_applies_to_a_banks_tech_system if {
	rec := with_({"context": {"countries": ["AU"], "sector": "tech", "role": "deployer", "entity_types": ["apra_regulated"], "evaluation_date": "2026-10-13"}})
	d := decide(rec)
	"apra" in d.frameworks
	has_deny(d, "AIG-16")
}

# Regression: a US record without states gets a warning, never silent (R2).
test_us_without_states_warns if {
	rec := with_({"context": {"countries": ["US"], "sector": "fsi", "role": "deployer", "evaluation_date": "2026-10-13"}})
	d := decide(rec)
	some f in d.warn
	f.id == "record:us_states"
}

# SR 26-2 excludes generative AI (R3).
test_sr26_2_skips_generative_ai if {
	bank := {"context": {"countries": ["US"], "us_states": ["NY"], "sector": "fsi", "role": "deployer", "entity_types": ["us_bank"], "evaluation_date": "2026-10-13"}}
	gen := object.union(with_(bank), {"system": {"purpose": "t", "decision_impact": "assistive", "user_facing": true, "generative": true}})
	not has_deny(decide(gen), "AIG-14")
	pred := object.union(with_(bank), {"system": {"purpose": "t", "decision_impact": "assistive", "user_facing": true, "generative": false}})
	has_deny(decide(pred), "AIG-14")
}

# Art 50(2) is a provider duty with a 2 Dec 2026 grace for systems already on the market (C4).
test_art50_marking_scope if {
	base_es := {"context": {"countries": ["ES"], "sector": "tech", "role": "deployer", "evaluation_date": "2026-10-13"}, "system": {"purpose": "t", "decision_impact": "assistive", "user_facing": true, "generates_synthetic_content": true}}
	d := decide(with_(base_es))
	not has_deny(d, "AIG-12")
	prov := object.union(with_(base_es), {"context": {"countries": ["ES"], "sector": "tech", "role": "provider", "evaluation_date": "2026-10-13"}, "system": {"purpose": "t", "decision_impact": "assistive", "user_facing": true, "generates_synthetic_content": true, "placed_on_market_before_2026_08_02": true}})
	has_warn(decide(prov), "AIG-12", "eu-ai-act")
}

# National data-protection rules reach the gate (R5).
test_brazil_lgpd_art20 if {
	rec := with_({
		"context": {"countries": ["BR"], "sector": "fsi", "role": "deployer", "evaluation_date": "2026-10-13"},
		"system": {"purpose": "t", "decision_impact": "consequential", "fully_automated_decision": true, "user_facing": false},
		"data": {"personal_data": true, "provenance_documented": true, "lawful_basis": "contrato"},
		"monitoring": {"drift_and_bias": true},
	})
	d := decide(rec)
	"br-lgpd" in d.frameworks
	has_deny(d, "AIG-11")
}

test_mas_guidelines_gated_and_phased if {
	rec := with_({"context": {"countries": ["SG"], "sector": "tech", "role": "deployer", "entity_types": ["mas_regulated"], "evaluation_date": "2026-10-13"}, "governance": {"policy_approved": true, "registered_in_inventory": false, "ai_literacy_training": true}})
	d := decide(rec)
	"sg-mas-airm" in d.frameworks
	has_warn(d, "AIG-02", "sg-mas-airm")
}

test_prohibited_practice_is_denied_in_eu if {
	d := decide(with_({
		"context": {"countries": ["PT"], "sector": "tech", "role": "deployer", "evaluation_date": "2026-10-13"},
		"system": {"purpose": "t", "decision_impact": "assistive", "user_facing": true, "prohibited_practice": true},
	}))
	not d.allow
}

test_internal_audit_programme_is_required if {
	d := decide(with_({"governance": {"policy_approved": true, "registered_in_inventory": true, "ai_literacy_training": true, "risk_tolerance_defined": true, "internal_audit": {"programme": false}}}))
	has_deny(d, "AIG-21")
}

test_overdue_internal_audit_warns if {
	d := decide(with_({"governance": {"policy_approved": true, "registered_in_inventory": true, "ai_literacy_training": true, "risk_tolerance_defined": true, "internal_audit": {"programme": true, "last_audit": "2025-01-15", "findings_tracked": true}}}))
	d.allow
	has_warn(d, "AIG-21", "iso19011")
}

test_fill_in_audit_date_warns_without_error if {
	d := decide(with_({"governance": {"policy_approved": true, "registered_in_inventory": true, "ai_literacy_training": true, "risk_tolerance_defined": true, "internal_audit": {"programme": true, "last_audit": "FILL IN: YYYY-MM-DD", "findings_tracked": true}}}))
	d.allow
	has_warn(d, "AIG-21", "iso19011")
}

test_iso42005_review_date_for_consequential if {
	d := decide(with_({"system": {"purpose": "t", "decision_impact": "consequential", "annex_iii_area": null, "user_facing": false, "agentic": false, "irreversible_actions": false, "critical_operation": false}, "risk": {"classification": "limited", "impact_assessment": {"completed": true, "method": "ISO/IEC 42005:2025", "review_date": "", "interested_parties_identified": true}, "dpia": {"completed": true}}}))
	has_warn(d, "AIG-03", "iso42005")
}

test_user_facing_system_without_threat_model_warns if {
	d := decide(with_({"testing": {"threat_model": {"completed": false}}}))
	d.allow
	has_warn(d, "AIG-14", "owasp-genai")
}

test_agent_without_threat_model_is_denied if {
	patch := object.union(agent_ok, {"testing": {"threat_model": {"completed": false}}})
	d := decide(with_(patch))
	some f in d.deny
	f.control == "AIG-14"
	"owasp-genai" in f.frameworks
}

test_non_date_audit_value_warns if {
	d := decide(with_({"governance": {"internal_audit": {"last_audit": "June 2026"}}}))
	d.allow
	has_warn(d, "AIG-21", "iso19011")
}

test_fully_controlled_agent_is_allowed if {
	d := decide(with_(agent_ok))
	d.allow
	count(d.warn) == 0
}

test_agent_without_egress_allowlist_is_denied if {
	patch := object.union(agent_ok, {"security": {"local_auth_disabled": true, "least_privilege": true, "private_network": true, "data_residency_region": "nz", "cmk": true, "short_lived_credentials": true, "tool_allowlist": true, "egress_allowlist": false, "sandboxed_execution": true, "idp_federated_identity": true}})
	d := decide(with_(patch))
	some f in d.deny
	f.control == "AIG-08"
	"anthropic-zero-trust" in f.frameworks
}

test_agent_without_telemetry_is_denied_by_atlas if {
	patch := object.union(agent_ok, {"monitoring": {"drift_and_bias": true, "agent_telemetry": false}})
	d := decide(with_(patch))
	some f in d.deny
	f.control == "AIG-13"
	"mitre-atlas" in f.frameworks
}

test_irreversible_agent_actions_need_per_action_approval if {
	patch := object.union(agent_ok, {"oversight": {"human_in_the_loop": true, "override_and_stop": true, "per_action_approval": false}})
	d := decide(with_(patch))
	has_deny(d, "AIG-11")
}

test_sp800_61_lessons_learned_warns if {
	d := decide(with_({"incident": {"runbook": true, "notification_matrix": [], "lessons_learned": false}}))
	d.allow
	has_warn(d, "AIG-16", "nist-sp-800-61")
}

test_nist_ai_rmf_risk_tolerance_warns if {
	d := decide(with_({"governance": {"policy_approved": true, "registered_in_inventory": true, "ai_literacy_training": true, "risk_tolerance_defined": false, "internal_audit": {"programme": true, "last_audit": "2026-06-01", "findings_tracked": true}}}))
	d.allow
	has_warn(d, "AIG-01", "nist-ai-rmf")
}
