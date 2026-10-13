# Framework-specific obligations that go beyond the shared controls: date-aware,
# condition-aware rules taken from the catalogue (catalog/frameworks.yaml and
# catalog/jurisdictions/*.yaml). A finding is raised only when its framework
# applies to the system. Obligations not yet in force are raised as "warn"
# with their start date, so teams can prepare.
package aigov

ff(fw, control, severity, message) := {
	"id": sprintf("%s:%s", [fw, control]),
	"control": control,
	"severity": severity,
	"frameworks": [fw],
	"message": message,
}

dated(d) := "deny" if on_or_after(d)

dated(d) := "warn" if not on_or_after(d)

# ── EU AI Act (Reg (EU) 2024/1689 as amended by 2026/1744) ────────────────────

framework_findings contains ff("eu-ai-act", "AIG-03", "deny", "Art 5: the system performs a prohibited AI practice and cannot be placed on the EU market or used") if {
	yes(["system", "prohibited_practice"])
}

# Art 50(1) is a provider duty; deployers still meet the shared AIG-12 control.
framework_findings contains ff("eu-ai-act", "AIG-12", dated("2026-08-02"), "Art 50(1): providers must design the system so people know they are interacting with AI (applies from 2026-08-02)") if {
	role != "deployer"
	yes(["system", "user_facing"])
	no(["transparency", "ai_disclosure"])
}

# Art 50(2) is a PROVIDER duty. Systems placed on the market before 2 Aug 2026
# have until 2 Dec 2026 (Reg (EU) 2026/1744 transitional).
framework_findings contains ff("eu-ai-act", "AIG-12", dated(marking_deadline), sprintf("Art 50(2): providers must mark synthetic audio, image, video or text output in a machine-readable format (applies from %s)", [marking_deadline])) if {
	role != "deployer"
	yes(["system", "generates_synthetic_content"])
	no(["transparency", "synthetic_content_marking"])
}

marking_deadline := "2026-12-02" if {
	yes(["system", "placed_on_market_before_2026_08_02"])
} else := "2026-08-02"

# Art 27 FRIA is a DEPLOYER duty: public bodies and private bodies providing
# public services (any Annex III area except point 2 critical infrastructure),
# plus deployers assessing creditworthiness or life/health insurance pricing.
framework_findings contains ff("eu-ai-act", "AIG-03", dated("2027-12-02"), "Art 27: deployers must complete a fundamental rights impact assessment before first use of this Annex III system (applies from 2027-12-02)") if {
	role != "provider"
	fria_required
	no(["risk", "fria", "completed"])
}

fria_required if {
	annex_iii != "critical_infrastructure"
	public_service_deployer
}

fria_required if annex_iii in {"credit_scoring", "life_health_insurance_pricing"}

public_service_deployer if input.context.public_body == true

public_service_deployer if yes(["context", "provides_public_service"])

# Art 49: providers register before placing on the market (49(1)); deployers
# register only when they are public authorities or bodies (49(3)).
framework_findings contains ff("eu-ai-act", "AIG-02", dated("2027-12-02"), "Art 49: register this Annex III high-risk system in the EU database before placing it on the market or putting it into use (applies from 2027-12-02)") if {
	annex_iii
	registration_duty
	no(["governance", "eu_database_registered"])
}

registration_duty if role != "deployer"

registration_duty if input.context.public_body == true

framework_findings contains ff("eu-ai-act", "AIG-11", dated("2027-12-02"), "Art 14 / Art 26(2): assign human oversight of the high-risk system to competent, trained people with authority to intervene (applies from 2027-12-02)") if {
	annex_iii
	no(["oversight", "human_in_the_loop"])
}

framework_findings contains ff("eu-ai-act", "AIG-19", "deny", "Art 4: take measures to support the AI literacy of staff operating the system") if {
	no(["governance", "ai_literacy_training"])
}

framework_findings contains ff("eu-ai-act", "AIG-06", "deny", "Art 53: GPAI providers must keep technical documentation, a copyright policy honouring TDM opt-outs, and publish a training-content summary") if {
	entity("gpai_provider")
	not gpai_documented
}

gpai_documented if {
	yes(["governance", "gpai_technical_documentation"])
	yes(["governance", "gpai_copyright_policy"])
	yes(["governance", "gpai_training_summary_published"])
}

# ── GDPR ─────────────────────────────────────────────────────────────────────

framework_findings contains ff("gdpr", "AIG-04", "deny", "Art 6: record the lawful basis for processing personal data in this system (data.lawful_basis)") if {
	personal_data
	not present(["data", "lawful_basis"])
}

framework_findings contains ff("gdpr", "AIG-03", "deny", "Art 35: complete a DPIA — the system processes special-category data or makes consequential decisions about people") if {
	dpia_required
	no(["risk", "dpia", "completed"])
}

dpia_required if {
	personal_data
	yes(["data", "special_category"])
}

dpia_required if {
	personal_data
	consequential
}

framework_findings contains ff("gdpr", "AIG-11", "deny", "Art 22: a solely automated decision with legal or similarly significant effect needs human intervention, the right to contest, and an Art 22(2) basis") if {
	personal_data
	consequential
	yes(["system", "fully_automated_decision"])
	no(["oversight", "contest_and_review"])
}

framework_findings contains ff("gdpr", "AIG-18", "deny", "Arts 44–49: personal data is transferred outside the EEA without an adequacy decision, SCCs or another Chapter V mechanism") if {
	personal_data
	yes(["data", "cross_border_transfer"])
	not present(["data", "transfer_mechanism"])
}

# ── United States (state laws; no federal AI Act) ────────────────────────────

framework_findings contains ff("us-ai", "AIG-12", dated("2027-01-01"), "Colorado SB 26-189: give pre-use notice before ADMT materially influences a consequential decision, and explain adverse decisions within 30 days (from 2027-01-01)") if {
	us_state("CO")
	consequential
	not co_notice_ok
}

co_notice_ok if {
	yes(["transparency", "adm_notice"])
	yes(["transparency", "adverse_decision_explanation"])
}

framework_findings contains ff("us-ai", "AIG-11", dated("2027-01-01"), "Colorado SB 26-189: offer data correction and meaningful human review of adverse decisions where commercially reasonable (from 2027-01-01)") if {
	us_state("CO")
	consequential
	no(["oversight", "contest_and_review"])
}

framework_findings contains ff("us-ai", "AIG-03", "deny", "Texas TRAIGA (HB 149): AI developed or deployed with a prohibited intent (manipulation toward harm, infringing constitutional rights, unlawful discrimination, CSAM/sexual deepfakes) is banned") if {
	us_state("TX")
	yes(["system", "tx_prohibited_intent"])
}

framework_findings contains ff("us-ai", "AIG-20", "deny", "NYC Local Law 144: automated employment decision tools used for New York City candidates need an independent bias audit within the past year and candidate notice") if {
	us_locality("NYC")
	annex_iii == "employment"
	not nyc_aedt_ok
}

nyc_aedt_ok if {
	yes(["testing", "independent_bias_audit"])
	yes(["transparency", "adm_notice"])
}

framework_findings contains ff("us-ai", "AIG-12", "deny", "Illinois HB 3773: notify employees when AI is used in employment decisions (in force 2026-01-01)") if {
	us_state("IL")
	annex_iii == "employment"
	no(["transparency", "adm_notice"])
}

framework_findings contains ff("us-ai", "AIG-12", dated("2027-01-01"), "California CCPA ADMT regulations: pre-use notice and opt-out/appeal for significant decisions (from 2027-01-01)") if {
	us_state("CA")
	consequential
	personal_data
	no(["transparency", "adm_notice"])
}

# SR 26-2 covers predictive models and expressly excludes generative AI.
framework_findings contains ff("us-ai", "AIG-14", "deny", "SR 26-2: predictive models used by banks need independent validation and ongoing monitoring (SR 26-2 excludes generative AI)") if {
	entity("us_bank")
	get(["system", "generative"]) == false
	no(["testing", "independent_validation"])
}

# ── APRA (CPS 230 / CPS 234 / AI letter 30 Apr 2026) ─────────────────────────

framework_findings contains ff("apra", "AIG-06", "deny", "CPS 230 paras 49–52: record the AI provider in the material service provider register") if {
	yes(["supplier", "material_service_provider"])
	no(["supplier", "register_entry"])
}

framework_findings contains ff("apra", "AIG-17", "deny", "CPS 230 paras 34–46 and the APRA AI letter: critical operations need tolerance levels, a credible fallback and tested exit/substitution") if {
	yes(["system", "critical_operation"])
	not apra_resilience_ok
}

apra_resilience_ok if {
	yes(["resilience", "tolerance_levels_set"])
	yes(["resilience", "fallback_tested"])
	yes(["resilience", "exit_plan"])
}

framework_findings contains ff("apra", "AIG-16", "deny", "CPS 230 para 33 / CPS 234 para 35: the incident matrix must include APRA notification within 72 hours") if {
	not "APRA:72h" in object.get(input, ["incident", "notification_matrix"], [])
}

framework_findings contains ff("apra", "AIG-07", "deny", "APRA AI letter: agentic workflows need privileged access management for non-human identities") if {
	yes(["system", "agentic"])
	no(["security", "non_human_identity_pam"])
}

# ── RBNZ BS11 (registered banks ≥ NZ$10bn) ───────────────────────────────────

framework_findings contains ff("rbnz-bs11", "AIG-17", "deny", "BS11: an outsourced AI service supporting a critical function needs backup capability and must not compromise the four required outcomes") if {
	yes(["supplier", "outsourced"])
	yes(["system", "critical_operation"])
	no(["resilience", "backup_capability"])
}

framework_findings contains ff("rbnz-bs11", "AIG-08", "deny", "BS11: RBNZ and a statutory manager must retain access to systems and data used by the outsourced AI service") if {
	yes(["supplier", "outsourced"])
	no(["supplier", "regulator_access_assured"])
}

# ── Australian Privacy Act ───────────────────────────────────────────────────

framework_findings contains ff("au-privacy", "AIG-12", dated("2026-12-10"), "APP 1.7–1.9: describe in the privacy policy the personal information used and the decisions made or substantially assisted by computer programs (from 2026-12-10)") if {
	personal_data
	consequential
	no(["transparency", "privacy_policy_adm_disclosure"])
}

framework_findings contains ff("au-privacy", "AIG-18", "deny", "APP 8: take reasonable steps so an overseas recipient (e.g. a model hosted offshore) does not breach the APPs") if {
	personal_data
	yes(["data", "cross_border_transfer"])
	not present(["data", "transfer_mechanism"])
}

# ── NZ Privacy Act ───────────────────────────────────────────────────────────

framework_findings contains ff("nz-privacy", "AIG-12", dated("2026-05-01"), "IPP 3A: notify individuals when their personal information is collected from another source (from 2026-05-01)") if {
	personal_data
	yes(["data", "indirect_collection"])
	no(["transparency", "indirect_collection_notice"])
}

framework_findings contains ff("nz-privacy", "AIG-03", "deny", "Biometric Processing Privacy Code 2025 rule 1: complete a proportionality assessment before biometric processing") if {
	yes(["system", "biometric_processing"])
	no(["risk", "biometric_proportionality_assessment"])
}

framework_findings contains ff("nz-privacy", "AIG-18", "deny", "IPP 12: disclosure outside New Zealand needs comparable safeguards or another IPP 12 ground") if {
	personal_data
	yes(["data", "cross_border_transfer"])
	not present(["data", "transfer_mechanism"])
}

# ── National rules outside the EU/AU/NZ/US frameworks ────────────────────────
# These jurisdictions have no horizontal AI statute; their data-protection and
# sector rules still drive obligations. They are keyed on the country code.

in_country(c) if c in input.context.countries

framework_findings contains ff("br-lgpd", "AIG-11", "deny", "LGPD Art 20: a decision taken solely on automated processing that affects the person's interests must offer review on request") if {
	in_country("BR")
	personal_data
	consequential
	yes(["system", "fully_automated_decision"])
	no(["oversight", "contest_and_review"])
}

framework_findings contains ff("br-lgpd", "AIG-04", "deny", "LGPD Arts 7 and 11: record the legal basis for processing personal (and sensitive) data (data.lawful_basis)") if {
	in_country("BR")
	personal_data
	not present(["data", "lawful_basis"])
}

framework_findings contains ff("br-lgpd", "AIG-18", "deny", "LGPD Arts 33–36 and ANPD Res. 19/2024: an international transfer needs a recognised mechanism (e.g. ANPD standard contractual clauses)") if {
	in_country("BR")
	personal_data
	yes(["data", "cross_border_transfer"])
	not present(["data", "transfer_mechanism"])
}

# CFM 2.454/2026 was published 27 Feb 2026 and took effect 180 days later (late Aug 2026).
framework_findings contains ff("br-cfm", "AIG-11", dated("2026-08-26"), "CFM Res. 2.454/2026: a physician makes the final clinical decision, patients are told when AI is used, and AI use is recorded in the chart (invocation logging is the proxy evidence)") if {
	in_country("BR")
	sector == "health"
	not br_cfm_ok
}

br_cfm_ok if {
	yes(["oversight", "human_in_the_loop"])
	yes(["transparency", "ai_disclosure"])
	yes(["logging", "invocation_logging"])
}

framework_findings contains ff("cl-21719", "AIG-11", dated("2026-12-01"), "Chile Ley 21.719 Art 8 bis: individuals have rights over decisions based solely on automated processing, including profiling (in force 2026-12-01 unless bill 18.623-07 postpones it)") if {
	in_country("CL")
	personal_data
	consequential
	yes(["system", "fully_automated_decision"])
	no(["oversight", "contest_and_review"])
}

framework_findings contains ff("cl-21663", "AIG-16", "deny", "Chile Ley 21.663: operators of vital importance must report significant cyber incidents to the CSIRT Nacional — include it in the notification matrix") if {
	in_country("CL")
	entity("critical_infrastructure")
	not "CSIRT-Nacional" in object.get(input, ["incident", "notification_matrix"], [])
}

# Ley 25.326 Art 20 ("impugnación de valoraciones personales") targets judicial
# decisions and administrative acts that evaluate a person's conduct from
# automated processing. Scoped to public bodies and raised as a warning because
# the clause wording was not re-read in the verification pass.
framework_findings contains ff("ar-25326", "AIG-11", "warn", "Argentina Ley 25.326 Art 20: judicial decisions and administrative acts that assess a person's conduct must not rest solely on automated processing of personal data without the possibility of challenge — confirm against the clause text") if {
	in_country("AR")
	input.context.public_body == true
	personal_data
	consequential
	yes(["system", "fully_automated_decision"])
	no(["oversight", "contest_and_review"])
}

framework_findings contains ff("ar-25326", "AIG-18", "deny", "Argentina Ley 25.326 Art 12: international transfer needs adequate protection or a recognised mechanism") if {
	in_country("AR")
	personal_data
	yes(["data", "cross_border_transfer"])
	not present(["data", "transfer_mechanism"])
}

framework_findings contains ff("jp-appi", "AIG-18", "deny", "Japan APPI Art 28: transfer of personal data to a third party abroad needs consent, an adequate country or equivalent safeguards") if {
	in_country("JP")
	personal_data
	yes(["data", "cross_border_transfer"])
	not present(["data", "transfer_mechanism"])
}

framework_findings contains ff("jp-appi", "AIG-04", "deny", "Japan APPI: specify the purpose of use and the basis for using personal data in training or inference (data.lawful_basis)") if {
	in_country("JP")
	personal_data
	not present(["data", "lawful_basis"])
}

framework_findings contains ff("sg-pdpa", "AIG-18", "deny", "Singapore PDPA s 26: a transfer outside Singapore needs a comparable standard of protection (e.g. contractual clauses)") if {
	in_country("SG")
	personal_data
	yes(["data", "cross_border_transfer"])
	not present(["data", "transfer_mechanism"])
}

framework_findings contains ff("sg-pdpa", "AIG-12", "deny", "Singapore PDPA s 20 notification obligation (as applied by the PDPC AI advisory guidelines): tell individuals that personal data is used in an AI recommendation or decision system and for what purpose") if {
	in_country("SG")
	personal_data
	consequential
	no(["transparency", "adm_notice"])
}

framework_findings contains ff("sg-mas-airm", "AIG-02", dated("2027-10-01"), "MAS Guidelines on AI Risk Management: maintain an AI inventory with a materiality assessment for each system (sections 3–4 effective Oct 2027)") if {
	in_country("SG")
	entity("mas_regulated")
	not sg_inventory_ok
}

sg_inventory_ok if {
	yes(["governance", "registered_in_inventory"])
	yes(["risk", "impact_assessment", "completed"])
}

# ── ISO/IEC 42001 and zero trust: the organisation's voluntary baseline ───────

framework_findings contains ff("iso42001", "AIG-03", "deny", "ISO/IEC 42001 6.1 / A.5: AI risk assessment and impact assessment must be documented") if {
	no(["risk", "impact_assessment", "completed"])
}

framework_findings contains ff("zero-trust", "AIG-07", "deny", "Zero trust (SP 800-207 tenets 3 and 6; agentic AI guidance): agents must use per-session, short-lived credentials and a tool allow-list") if {
	yes(["system", "agentic"])
	not zt_agent_ok
}

zt_agent_ok if {
	yes(["security", "short_lived_credentials"])
	yes(["security", "tool_allowlist"])
}

# ── ISO 19011:2026 — auditing the management system ──────────────────────────
# ISO 19011 is guidance, so its findings are warnings; the programme itself is
# AIG-21 (deny) because ISO/IEC 42001 9.2 and ISO/IEC 27001 9.2 require it.

framework_findings contains ff("iso19011", "AIG-21", "warn", "ISO 19011 cl. 5.5 / ISO/IEC 42001 9.2: no internal audit has been recorded for this system (governance.internal_audit.last_audit); audit within the programme cycle") if {
	yes(["governance", "internal_audit", "programme"])
	not present(["governance", "internal_audit", "last_audit"])
}

framework_findings contains ff("iso19011", "AIG-21", "warn", sprintf("ISO 19011 cl. 5.4–5.5: the last internal audit (%s) is outside the programme cycle (12 months in this repository; ISO 19011 sets no cadence); re-audit", [last_audit])) if {
	present(["governance", "internal_audit", "last_audit"])
	last_audit := get(["governance", "internal_audit", "last_audit"])
	regex.match(`^\d{4}-\d{2}-\d{2}$`, last_audit)
	audit_overdue(last_audit)
}

framework_findings contains ff("iso19011", "AIG-21", "warn", "governance.internal_audit.last_audit must be a calendar date (YYYY-MM-DD) so the audit cycle can be evaluated") if {
	present(["governance", "internal_audit", "last_audit"])
	not regex.match(`^\d{4}-\d{2}-\d{2}$`, get(["governance", "internal_audit", "last_audit"]))
}

audit_overdue(d) if {
	t := time.parse_rfc3339_ns(sprintf("%sT00:00:00Z", [d]))
	e := time.parse_rfc3339_ns(sprintf("%sT00:00:00Z", [eval_date]))
	e - t > (((365 * 24) * 60) * 60) * 1000000000
}

framework_findings contains ff("iso19011", "AIG-21", "warn", "ISO 19011 cl. 6.7 / ISO/IEC 42001 10.2: audit findings must be tracked to closure (governance.internal_audit.findings_tracked)") if {
	yes(["governance", "internal_audit", "programme"])
	no(["governance", "internal_audit", "findings_tracked"])
}

# ── ISO/IEC 42005:2025 — AI system impact assessment method ──────────────────

framework_findings contains ff("iso42005", "AIG-03", "warn", "ISO/IEC 42005 cl. 5.2 (documenting the process): record the impact-assessment method used (risk.impact_assessment.method, e.g. \"ISO/IEC 42005:2025\") so the assessment is repeatable and reviewable") if {
	yes(["risk", "impact_assessment", "completed"])
	not present(["risk", "impact_assessment", "method"])
}

framework_findings contains ff("iso42005", "AIG-03", "warn", "ISO/IEC 42005 cl. 5.12: high-risk and consequential systems need a scheduled review of the impact assessment (risk.impact_assessment.review_date)") if {
	yes(["risk", "impact_assessment", "completed"])
	impact_review_needed
	not present(["risk", "impact_assessment", "review_date"])
}

impact_review_needed if high_risk

impact_review_needed if consequential

framework_findings contains ff("iso42005", "AIG-20", "warn", "ISO/IEC 42005 cl. 6.7 / Annex C: identify the interested parties who may be affected and the benefits and harms to each (risk.impact_assessment.interested_parties_identified)") if {
	consequential
	no(["risk", "impact_assessment", "interested_parties_identified"])
}

# ── NIST AI RMF 1.0 — GOVERN / MAP / MEASURE / MANAGE ────────────────────────

framework_findings contains ff("nist-ai-rmf", "AIG-01", "warn", "NIST AI RMF MAP 1.5 / GOVERN 1.3: document the organisation's risk tolerance for this system's use case (governance.risk_tolerance_defined)") if {
	no(["governance", "risk_tolerance_defined"])
}

framework_findings contains ff("nist-ai-rmf", "AIG-13", "warn", "NIST AI RMF MEASURE 2.4 / MANAGE 4.1: deployed systems need post-deployment monitoring for drift and bias (monitoring.drift_and_bias)") if {
	no(["monitoring", "drift_and_bias"])
}

# ── NIST SP 800-61 Rev. 3 — incident response on CSF 2.0 ─────────────────────

framework_findings contains ff("nist-sp-800-61", "AIG-16", "warn", "NIST SP 800-61r3 ID.IM-03/04: run post-incident lessons-learned and feed them back into the runbook (incident.lessons_learned)") if {
	yes(["incident", "runbook"])
	no(["incident", "lessons_learned"])
}

framework_findings contains ff("nist-sp-800-61", "AIG-13", "warn", "NIST SP 800-61r3 DE.CM / DE.AE: AI telemetry (prompts, tool calls, guardrail hits) must reach the SOC for detection and analysis (logging.siem_integrated)") if {
	no(["logging", "siem_integrated"])
}

# ── OWASP GenAI Security Project — LLM Top 10 2026 and Agentic Top 10 ────────
# OWASP, MITRE ATLAS and the Anthropic guidance are awareness material and
# vendor guidance, not law. The "deny" severities below are this repository's
# ORGANISATIONAL BASELINE for agentic systems (an agent that acts without a
# threat model, output validation, telemetry, egress control or per-action
# approval is not promotable); everything else is a warning.

framework_findings contains ff("owasp-genai", "AIG-14", "deny", "OWASP Agentic Top 10 (organisational baseline): agentic systems need a documented threat model covering goal hijack, tool misuse, identity and privilege abuse, supply chain and code execution (testing.threat_model.completed)") if {
	yes(["system", "agentic"])
	no(["testing", "threat_model", "completed"])
}

framework_findings contains ff("owasp-genai", "AIG-14", "warn", "OWASP LLM Top 10 2026: user-facing systems should be threat-modelled for prompt injection, sensitive information disclosure, supply chain and improper output handling (testing.threat_model.completed)") if {
	yes(["system", "user_facing"])
	not yes(["system", "agentic"])
	no(["testing", "threat_model", "completed"])
}

framework_findings contains ff("owasp-genai", "AIG-14", "warn", "OWASP: list the threat catalogues the model was built against (testing.threat_model.references, e.g. OWASP-LLM-2026, OWASP-ASI-2026, MITRE-ATLAS-2026.09)") if {
	yes(["testing", "threat_model", "completed"])
	count(object.get(input, ["testing", "threat_model", "references"], [])) == 0
}

framework_findings contains ff("owasp-genai", "AIG-10", "deny", "OWASP LLM10:2026 Improper Output Handling / ASI05 Unexpected Code Execution: agents that execute code or call tools must validate and sanitise model output before it is acted on (runtime.output_validation)") if {
	yes(["system", "agentic"])
	no(["runtime", "output_validation"])
}

# ── MITRE ATLAS — adversarial threat landscape and mitigations ────────────────

framework_findings contains ff("mitre-atlas", "AIG-13", "deny", "MITRE ATLAS AML.M0024 AI Telemetry Logging / AML.M0038 AI Agent Scope Drift Detection: agents must emit per-action telemetry (tool, parameters, outcome) so drift from the assigned task is detectable (monitoring.agent_telemetry)") if {
	yes(["system", "agentic"])
	no(["monitoring", "agent_telemetry"])
}

framework_findings contains ff("mitre-atlas", "AIG-06", "warn", "MITRE ATLAS AML.M0023 AI Bill of Materials / AML.T0110 AI Agent Tool Poisoning: maintain an AI BOM listing models, tools, MCP servers and datasets with provenance (supplier.ai_bom)") if {
	no(["supplier", "ai_bom"])
}

# ── Anthropic zero trust for AI agents (CISO guide, 2026) ─────────────────────
# Vendor-neutral practices for agentic systems: identity from the IdP, egress
# allow-listing, sandboxed execution, per-action approval, telemetry to SIEM.

framework_findings contains ff("anthropic-zero-trust", "AIG-08", "deny", "Anthropic CISO guide: egress allow-listing is the strongest control against prompt injection — agents may only reach approved domains (security.egress_allowlist)") if {
	yes(["system", "agentic"])
	no(["security", "egress_allowlist"])
}

framework_findings contains ff("anthropic-zero-trust", "AIG-10", "warn", "Anthropic CISO guide / Claude Code sandbox settings: run agent tool execution in a sandbox with filesystem and network isolation (security.sandboxed_execution)") if {
	yes(["system", "agentic"])
	no(["security", "sandboxed_execution"])
}

framework_findings contains ff("anthropic-zero-trust", "AIG-07", "warn", "Anthropic CISO guide: agent and user identity must come from the corporate IdP (SSO + SCIM), not vendor-local accounts or long-lived API keys (security.idp_federated_identity)") if {
	yes(["system", "agentic"])
	no(["security", "idp_federated_identity"])
}

framework_findings contains ff("anthropic-zero-trust", "AIG-11", "deny", "Anthropic CISO guide: irreversible actions (payments, deletions, sending) require per-action human approval (oversight.per_action_approval)") if {
	yes(["system", "agentic"])
	yes(["system", "irreversible_actions"])
	no(["oversight", "per_action_approval"])
}
