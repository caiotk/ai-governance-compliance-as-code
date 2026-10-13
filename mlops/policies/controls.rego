# Control-level checks (AIG-01 … AIG-22). A violation here becomes a finding
# only when at least one applicable framework maps to the control, and the
# finding names those frameworks (see `required` in main.rego).
package aigov

email_re := `^[^@\s]+@[^@\s]+\.[^@\s]+$`

# AIG-01 Governance, policy and accountable ownership
control_violations contains {"control": "AIG-01", "message": "metadata.owner must be a named, accountable person (email address)"} if {
	not regex.match(email_re, object.get(input.metadata, "owner", ""))
}

control_violations contains {"control": "AIG-01", "message": "governance.policy_approved: the system must operate under an approved AI policy"} if {
	no(["governance", "policy_approved"])
}

# AIG-02 Inventory
control_violations contains {"control": "AIG-02", "message": "governance.registered_in_inventory: register the system in the AI inventory"} if {
	no(["governance", "registered_in_inventory"])
}

# AIG-03 Risk classification and impact assessment
control_violations contains {"control": "AIG-03", "message": "risk.classification is missing (minimal | limited | high | prohibited)"} if {
	not object.get(input, ["risk", "classification"], null) in {"minimal", "limited", "high", "prohibited"}
}

control_violations contains {"control": "AIG-03", "message": "risk.impact_assessment.completed: complete an AI system impact assessment before deployment"} if {
	no(["risk", "impact_assessment", "completed"])
}

control_violations contains {"control": "AIG-03", "message": "risk.classification is 'prohibited': this system must not be deployed"} if {
	object.get(input, ["risk", "classification"], "") == "prohibited"
}

# AIG-04 Data governance and provenance
control_violations contains {"control": "AIG-04", "message": "data.provenance_documented: document the source and lineage of training, grounding and evaluation data"} if {
	no(["data", "provenance_documented"])
}

# AIG-05 Personal data protection
control_violations contains {"control": "AIG-05", "message": "runtime.pii_filtering: personal data is processed, so prompts and outputs need PII detection/masking"} if {
	personal_data
	no(["runtime", "pii_filtering"])
}

# AIG-06 Approved models and supply chain
control_violations contains {"control": "AIG-06", "message": "model.approved: the model/version is not on the approved-model list"} if {
	no(["model", "approved"])
}

control_violations contains {"control": "AIG-06", "message": "supplier.assessed: complete a third-party/vendor assessment for the model provider"} if {
	no(["supplier", "assessed"])
}

control_violations contains {"control": "AIG-06", "message": "supplier.no_training_on_customer_data: contract must prohibit training on your data"} if {
	no(["supplier", "no_training_on_customer_data"])
}

# AIG-07 Workload and agent identity
control_violations contains {"control": "AIG-07", "message": "security.local_auth_disabled: disable shared API keys; use managed or federated identity"} if {
	no(["security", "local_auth_disabled"])
}

control_violations contains {"control": "AIG-07", "message": "security.least_privilege: the workload/agent identity must have least-privilege, scoped permissions"} if {
	no(["security", "least_privilege"])
}

# AIG-08 Network isolation and residency
control_violations contains {"control": "AIG-08", "message": "security.private_network: reach the model over private endpoints / perimeter only"} if {
	no(["security", "private_network"])
}

control_violations contains {"control": "AIG-08", "message": "security.data_residency_region: record the processing region"} if {
	not present(["security", "data_residency_region"])
}

# AIG-09 Encryption — CMK required for high-risk or special-category processing
control_violations contains {"control": "AIG-09", "message": "security.cmk: high-risk or special-category processing requires customer-managed keys"} if {
	cmk_required
	no(["security", "cmk"])
}

cmk_required if high_risk

cmk_required if yes(["data", "special_category"])

# AIG-10 Runtime guardrails
control_violations contains {"control": "AIG-10", "message": "runtime.content_filters: enable harmful-content filtering on prompts and outputs"} if {
	no(["runtime", "content_filters"])
}

control_violations contains {"control": "AIG-10", "message": "runtime.prompt_attack_detection: enable prompt-injection/jailbreak detection"} if {
	no(["runtime", "prompt_attack_detection"])
}

control_violations contains {"control": "AIG-10", "message": "runtime.guardrail_enforced_centrally: agents need guardrails enforced outside the application (org policy, gateway or floor setting)"} if {
	yes(["system", "agentic"])
	no(["runtime", "guardrail_enforced_centrally"])
}

# AIG-11 Human oversight
control_violations contains {"control": "AIG-11", "message": "oversight.human_in_the_loop: consequential decisions or irreversible actions need a named human approval"} if {
	needs_human
	no(["oversight", "human_in_the_loop"])
}

control_violations contains {"control": "AIG-11", "message": "oversight.override_and_stop: provide an override and a stop (kill switch) for agents and consequential systems"} if {
	needs_human
	no(["oversight", "override_and_stop"])
}

needs_human if consequential

needs_human if yes(["system", "irreversible_actions"])

# AIG-12 Transparency
control_violations contains {"control": "AIG-12", "message": "transparency.ai_disclosure: tell people they are interacting with an AI system"} if {
	yes(["system", "user_facing"])
	no(["transparency", "ai_disclosure"])
}

# AIG-13 Logging and monitoring
control_violations contains {"control": "AIG-13", "message": "logging.invocation_logging: log prompts, outputs, tool calls and policy decisions"} if {
	no(["logging", "invocation_logging"])
}

control_violations contains {"control": "AIG-13", "message": "logging.retention_days must be at least 183 (≈ six months)"} if {
	object.get(input, ["logging", "retention_days"], 0) < 183
}

control_violations contains {"control": "AIG-13", "message": "monitoring.drift_and_bias: monitor production behaviour for drift and bias"} if {
	consequential
	no(["monitoring", "drift_and_bias"])
}

# AIG-14 Testing and red-teaming
control_violations contains {"control": "AIG-14", "message": "testing.evaluation_completed: evaluate accuracy, robustness and safety before release"} if {
	no(["testing", "evaluation_completed"])
}

control_violations contains {"control": "AIG-14", "message": "testing.red_team_completed: adversarial testing is required for agents and high-risk systems"} if {
	red_team_required
	no(["testing", "red_team_completed"])
}

red_team_required if high_risk

red_team_required if yes(["system", "agentic"])

# AIG-15 Change management
control_violations contains {"control": "AIG-15", "message": "lifecycle.versioned and lifecycle.promotion_gate: version models/prompts and promote through a gate"} if {
	not lifecycle_ok
}

lifecycle_ok if {
	yes(["lifecycle", "versioned"])
	yes(["lifecycle", "promotion_gate"])
}

# AIG-16 Incident management
control_violations contains {"control": "AIG-16", "message": "incident.runbook: an AI incident runbook with regulator notification deadlines is required"} if {
	no(["incident", "runbook"])
}

# AIG-17 Resilience and exit — for systems supporting critical operations
control_violations contains {"control": "AIG-17", "message": "resilience.fallback_tested and resilience.exit_plan: critical operations need a tested fallback and an exit plan"} if {
	yes(["system", "critical_operation"])
	not resilience_ok
}

resilience_ok if {
	yes(["resilience", "fallback_tested"])
	yes(["resilience", "exit_plan"])
}

# AIG-18 Cross-border transfers
control_violations contains {"control": "AIG-18", "message": "data.transfer_mechanism: personal data leaves the jurisdiction without a recorded transfer mechanism"} if {
	personal_data
	yes(["data", "cross_border_transfer"])
	not present(["data", "transfer_mechanism"])
}

# AIG-19 AI literacy
control_violations contains {"control": "AIG-19", "message": "governance.ai_literacy_training: staff operating the system must complete AI literacy training"} if {
	no(["governance", "ai_literacy_training"])
}

# AIG-20 Fairness
control_violations contains {"control": "AIG-20", "message": "testing.bias_assessment: consequential decisions about people need bias testing"} if {
	consequential
	no(["testing", "bias_assessment"])
}

# AIG-21 Internal audit and independent assurance
control_violations contains {"control": "AIG-21", "message": "governance.internal_audit.programme: the system must be in scope of a planned internal audit programme (ISO 19011 cl. 5; ISO/IEC 42001 9.2; ISO/IEC 27001 9.2)"} if {
	no(["governance", "internal_audit", "programme"])
}

# AIG-22 AI FinOps — budgets and consumption limits
control_violations contains {"control": "AIG-22", "message": "finops.budget_defined: every AI workload needs a monthly budget with alerts (cloud budget and/or broker cap) — see finops/"} if {
	no(["finops", "budget_defined"])
}
