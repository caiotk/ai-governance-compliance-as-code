# Singapore — Energy (oil, gas and electricity)

<sub>Generated from `catalog/` by `tools/build.py` · status as of 2026-10-13 · not legal advice.</sub>

> No AI statute; model governance frameworks and sector guidelines. MAS AI Risk Management Guidelines were finalised in Oct 2026.

## Frameworks applied

| Framework | Status | Verification |
|---|---|---|
| [Singapore PDPA 2012 + PDPC advisory guidelines on AI recommendation and decision systems](https://www.rajahtannasia.com/viewpoints/pdpc-issues-advisory-guidelines-on-use-of-personal-data-in-ai-recommendation-and-decision-systems/) | In force | ◐ secondary |
| [Energy critical-infrastructure and incident-reporting regimes (national)](https://github.com/caiotk/ai-governance-compliance-as-code/blob/main/docs/sources/energy-sector.md) | In force | ✓ primary |
| [IEC 62443 — Security for industrial automation and control systems (2-1:2024, 2-4:2015+AMD1:2017, 3-3:2013, 4-1:2018, 4-2:2019)](https://webstore.iec.ch/en/publication/62883) | Voluntary | ✓ primary |
| [ISO/IEC 27019:2024 — Information security controls for the energy utility industry](https://www.iso.org/standard/85056.html) | Voluntary | ✓ primary |
| [ISO/IEC 27001:2022 + Amd 1:2024](https://www.iso.org/standard/27001) | Organisational baseline (voluntary) | ✓ primary |
| [ISO/IEC 42001:2023 AI management system](https://www.iso.org/standard/81230.html) | Organisational baseline (voluntary) | ◐ secondary |
| [Zero trust (NIST SP 800-207, CISA ZTMM v2.0)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf) | Organisational baseline (voluntary) | ✓ primary |
| [NIST AI Risk Management Framework 1.0 + Generative AI Profile](https://www.nist.gov/itl/ai-risk-management-framework) | Organisational baseline (voluntary) | ✓ primary |
| [NIST SP 800-61 Rev. 3 — Incident Response Recommendations and Considerations for Cybersecurity Risk Management (CSF 2.0 Community Profile)](https://csrc.nist.gov/pubs/sp/800/61/r3/final) | Organisational baseline (voluntary) | ✓ primary |
| [ISO 19011:2026 Guidelines for auditing management systems](https://www.iso.org/standard/19011) | Organisational baseline (voluntary) | ✓ primary |
| [ISO/IEC 42005:2025 AI system impact assessment](https://www.iso.org/standard/44545.html) | Organisational baseline (voluntary) | ✓ primary |
| [OWASP GenAI Security Project — LLM Top 10 (2026) and Top 10 for Agentic Applications](https://genai.owasp.org/llm-top-10/) | Organisational baseline (voluntary) | ✓ primary |
| [MITRE ATLAS (release 2026.09)](https://atlas.mitre.org/) | Organisational baseline (voluntary) | ✓ primary |
| [Anthropic — Zero Trust for AI Agents (eBook and CISO guidance)](https://claude.com/blog/zero-trust-for-ai-agents) | Organisational baseline (voluntary) | ✓ primary |
| [FinOps Framework (FinOps Foundation) — FinOps for AI](https://www.finops.org/wg/finops-for-ai-overview/) | Organisational baseline (voluntary) | ✓ primary |
| [Business continuity and disaster recovery for AI services (NIST SP 800-34 Rev. 1, NIST CSF 2.0 RC/PR.IR, ISO 22301:2019)](https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-34r1.pdf) | Organisational baseline (voluntary) | ✓ primary |

## Laws, regulations and guidance


### AI law and frameworks

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Model AI Governance Framework for Generative AI | IMDA / AI Verify Foundation, May 2024 | Voluntary | AIG-01, AIG-06, AIG-10, AIG-12, AIG-14, AIG-16 | [◐ secondary](https://morganlewis.com/pubs/2024/07/singapore-expands-its-ai-governance-approach-to-include-generative-ai) |
| Model AI Governance Framework for Agentic AI | IMDA, 22 Jan 2026 | Voluntary | AIG-03, AIG-07, AIG-10, AIG-11, AIG-13 | [✓ primary](https://www.mddi.gov.sg/newsroom/singapore-launches-new-model-ai-governance-framework-for-agentic-ai--/) |

### Data protection

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Personal Data Protection Act 2012 + Advisory Guidelines on Personal Data in AI Recommendation and Decision Systems | PDPA 2012; PDPC guidelines 1 Mar 2024 | In force | AIG-04, AIG-05, AIG-12, AIG-18 | [◐ secondary](https://www.rajahtannasia.com/viewpoints/pdpc-issues-advisory-guidelines-on-use-of-personal-data-in-ai-recommendation-and-decision-systems/) |

### Cybersecurity

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Cybersecurity Act 2018 as amended by the Cybersecurity (Amendment) Act 2024 | — | In force · Key provisions 2025-10-31 | AIG-07, AIG-16 | [◐ secondary](https://www.hlc.com/en/publications/provisions-in-singapores-cybersecurity-amendment-act-came-into-force-on-31-october-2025) |

### Sector rules: Energy (oil, gas and electricity)

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Cybersecurity Act 2018 as amended by Act 19 of 2024 — energy essential services (electricity generation/transmission/distribution; natural gas supply for generation); s 14 incident reporting incl. supplier systems; s 15 audit every 2 years and annual risk assessment; Part 3A third-party-owned CII | Act 9 of 2018; Act 19 of 2024 in operation 2025-10-31 | In force | AIG-06, AIG-13, AIG-16, AIG-21 | [✓ primary](https://sso.agc.gov.sg/Act/CA2018) |
| Cybersecurity Code of Practice for CII 2026 — risk framework (3.4), cloud restriction (3.9.3), outsourcing oversight (3.10), OT requirements (10), interconnected systems (12); board accountability clauses from 29 Jul 2027 | CCoP 2026 Release 1 | In force (phased) · 2026-07-29; new clauses by 2027-07-29 | AIG-01, AIG-03, AIG-06, AIG-08, AIG-13, AIG-14, AIG-21 | [✓ primary](https://www.csa.gov.sg/legislation/codes-of-practice) |
| Cybersecurity (Critical Information Infrastructure) Regulations 2018 — prescribed incident-reporting period (2 hours, then details within 14 days) | S 590/2018 | In force | AIG-16 | [◐ secondary](https://sso.agc.gov.sg/SL/CA2018-S590-2018) |
| Electricity Act 2001 and Gas Act 2001 (EMA licensing, Transmission Code, Market Rules) | — | In force | AIG-11, AIG-13 | [✓ primary](https://sso.agc.gov.sg/Act/EA2001) |

## Typical AI scenarios and high-risk triggers

- Load, renewable-output and inflow forecasting feeding scheduling and dispatch
- Dispatch, balancing and curtailment recommendations to control-room operators
- Predictive maintenance on generation, transmission, pipeline and refinery assets
- Outage management, restoration prioritisation and vegetation/asset inspection with computer vision
- Wholesale trading, bidding and nomination algorithms
- Safety monitoring on rigs, plants and pipelines (leak and methane detection, alarm triage)
- Customer service, billing and demand-response on smart-meter data

**Pushes a system into a higher risk tier in Singapore:**

- AI touching critical information infrastructure, incl. cloud-hosted services (CCoP 2026 §3.9.3, §10 OT)
- AI that generates or executes wholesale bids, offers or nominations (REMIT, NER bidding rules, EA Code Part 13, FERC 18 CFR 1c, CAMMESA, CCEE, JEPX, NEMS)
- AI advising control-room operators or automating actions on energised plant, pipelines or rigs — human control and alarm management must be preserved

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | mistral | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; Anthropic; Model AI Governance Framework for Generative AI; Cybersecurity Code of Practice for CII 2026 — risk framework | · | · | ○ | ○ | · | · | · | · |
| **AIG-02** AI system and agent inventory | Energy critical-infrastructure and incident-reporting regimes; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | ● | ○ | ○ | ● | ○ | · | ● | ● |
| **AIG-03** Risk classification and impact assessment | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; Model AI Governance Framework for Agentic AI; Cybersecurity Code of Practice for CII 2026 — risk framework | · | · | ○ | ○ | · | · | · | · |
| **AIG-04** Data governance, quality and provenance | Singapore PDPA 2012 + PDPC advisory guidelines on AI recommendation and decision systems; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | · | · | ○ | ○ | · | · | · | ● |
| **AIG-05** Personal data protection and minimisation | Singapore PDPA 2012 + PDPC advisory guidelines on AI recommendation and decision systems; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS | ○ | ● | ○ | ● | ● | · | ○ | ● |
| **AIG-06** Approved models and AI supply chain ★ | Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework; Model AI Governance Framework for Generative AI; Cybersecurity Act 2018 as amended by Act 19 of 2024 — energy essential services; Cybersecurity Code of Practice for CII 2026 — risk framework | ○ | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-07** Workload and agent identity with least privilege ★ | IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; Model AI Governance Framework for Agentic AI; Cybersecurity Act 2018 as amended by the Cybersecurity | ● | ● | ● | ● | ● | ○ | ● | ● |
| **AIG-08** Network isolation and data residency ★ | IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; Cybersecurity Code of Practice for CII 2026 — risk framework | ○ | ● | ● | ● | ● | ○ | ○ | ○ |
| **AIG-09** Encryption and key management | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust; MITRE ATLAS; Anthropic | ○ | ● | ● | ○ | ● | · | ○ | ○ |
| **AIG-10** Runtime guardrails and content safety | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; Model AI Governance Framework for Generative AI; Model AI Governance Framework for Agentic AI | ○ | ● | ● | ○ | ● | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions ★ | Energy critical-infrastructure and incident-reporting regimes; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; Model AI Governance Framework for Agentic AI; Electricity Act 2001 and Gas Act 2001 | · | ○ | ○ | ○ | ○ | · | ○ | ○ |
| **AIG-12** Transparency, notice and explanation | Singapore PDPA 2012 + PDPC advisory guidelines on AI recommendation and decision systems; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; Model AI Governance Framework for Generative AI | · | · | ○ | ○ | · | ○ | · | · |
| **AIG-13** Logging, monitoring and record-keeping ★ | Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework; Business continuity and disaster recovery for AI services; Model AI Governance Framework for Agentic AI; Cybersecurity Act 2018 as amended by Act 19 of 2024 — energy essential services; Cybersecurity Code of Practice for CII 2026 — risk framework; Electricity Act 2001 and Gas Act 2001 | ● | ● | ● | ● | ● | ○ | ● | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; Model AI Governance Framework for Generative AI; Cybersecurity Code of Practice for CII 2026 — risk framework | · | · | ○ | ○ | · | ○ | ● | · |
| **AIG-15** Change management and model lifecycle ★ | IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; MITRE ATLAS | · | ● | ● | ● | · | · | · | · |
| **AIG-16** Incident management and regulator notification ★ | Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; Anthropic; Business continuity and disaster recovery for AI services; Model AI Governance Framework for Generative AI; Cybersecurity Act 2018 as amended by the Cybersecurity; Cybersecurity Act 2018 as amended by Act 19 of 2024 — energy essential services; Cybersecurity | · | · | ● | ○ | · | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit ★ | Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; FinOps Framework; Business continuity and disaster recovery for AI services | ● | · | ○ | ○ | · | · | ○ | ● |
| **AIG-18** Cross-border transfer safeguards | Singapore PDPA 2012 + PDPC advisory guidelines on AI recommendation and decision systems; ISO/IEC 27001:2022 + Amd 1:2024 | ● | · | ○ | ● | ● | ○ | ● | ● |
| **AIG-19** AI literacy and training | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO 19011:2026 Guidelines for auditing management systems; MITRE ATLAS | · | · | ○ | ○ | · | · | · | · |
| **AIG-20** Fairness and non-discrimination | ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment | · | · | ○ | ○ | · | · | · | · |
| **AIG-21** Internal audit and independent assurance | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO 19011:2026 Guidelines for auditing management systems; Cybersecurity Act 2018 as amended by Act 19 of 2024 — energy essential services; Cybersecurity Code of Practice for CII 2026 — risk framework | · | · | · | · | · | · | · | · |
| **AIG-22** AI FinOps — token budgets, consumption limits and cost allocation | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework | · | · | · | · | · | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`energy.system.yaml`](energy.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/sg/energy.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
