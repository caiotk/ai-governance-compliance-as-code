# Singapore — Technology companies

<sub>Generated from `catalog/` by `tools/build.py` · status as of 2026-10-13 · not legal advice.</sub>

> No AI statute; model governance frameworks and sector guidelines. MAS AI Risk Management Guidelines were finalised in Oct 2026.

## Frameworks applied

| Framework | Status | Verification |
|---|---|---|
| [Singapore PDPA 2012 + PDPC advisory guidelines on AI recommendation and decision systems](https://www.rajahtannasia.com/viewpoints/pdpc-issues-advisory-guidelines-on-use-of-personal-data-in-ai-recommendation-and-decision-systems/) | In force | ◐ secondary |
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

### Sector rules: Technology companies

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Copyright Act 2021 s 244 computational data analysis exception (lawful access required) | — | In force | AIG-04 | [◐ secondary](https://www.reedsmith.com/articles/text-and-data-mining-in-singapore/) |
| Online Safety (Relief and Accountability) Act 2025 — Online Safety Commission from 29 Jun 2026 | — | In force | AIG-10, AIG-12 | [✓ primary](https://www.mlaw.gov.sg/online-safety-commission-and-online-safety-relief-and-accountability-act-2025-to-start-on-29-june-2026/) |

## Typical AI scenarios and high-risk triggers

- Building and distributing AI products and agents to customers
- Fine-tuning or training models, including general-purpose models
- AI coding assistants in the software supply chain
- Consumer chat and content-generation features

**Pushes a system into a higher risk tier in Singapore:**

- Training on copyrighted data (JP Copyright Act Art 30-4; SG Copyright Act s 244; AU has no TDM exception)
- Products used by children (Brazil ECA Digital; Australia Online Safety Act; Singapore Online Safety Act 2025)
- Consumer-facing AI claims and deception (FTC Act §5; consumer protection law)

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | mistral | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; Anthropic; Model AI Governance Framework for Generative AI | · | · | ○ | ○ | · | · | · | · |
| **AIG-02** AI system and agent inventory | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | ● | ○ | ○ | ● | ○ | · | ● | ● |
| **AIG-03** Risk classification and impact assessment | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; Model AI Governance Framework for Agentic AI | · | · | ○ | ○ | · | · | · | · |
| **AIG-04** Data governance, quality and provenance ★ | Singapore PDPA 2012 + PDPC advisory guidelines on AI recommendation and decision systems; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; Copyright Act 2021 s 244 computational data analysis exception | · | · | ○ | ○ | · | · | · | ● |
| **AIG-05** Personal data protection and minimisation | Singapore PDPA 2012 + PDPC advisory guidelines on AI recommendation and decision systems; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS | ○ | ● | ○ | ● | ● | · | ○ | ● |
| **AIG-06** Approved models and AI supply chain ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework; Model AI Governance Framework for Generative AI | ○ | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-07** Workload and agent identity with least privilege | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; Model AI Governance Framework for Agentic AI; Cybersecurity Act 2018 as amended by the Cybersecurity | ● | ● | ● | ● | ● | ○ | ● | ● |
| **AIG-08** Network isolation and data residency | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | ○ | ● | ● | ● | ● | ○ | ○ | ○ |
| **AIG-09** Encryption and key management | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust; MITRE ATLAS; Anthropic | ○ | ● | ● | ○ | ● | · | ○ | ○ |
| **AIG-10** Runtime guardrails and content safety ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; Model AI Governance Framework for Generative AI; Model AI Governance Framework for Agentic AI; Online Safety | ○ | ● | ● | ○ | ● | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions | ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; Model AI Governance Framework for Agentic AI | · | ○ | ○ | ○ | ○ | · | ○ | ○ |
| **AIG-12** Transparency, notice and explanation ★ | Singapore PDPA 2012 + PDPC advisory guidelines on AI recommendation and decision systems; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; Model AI Governance Framework for Generative AI; Online Safety | · | · | ○ | ○ | · | ○ | · | · |
| **AIG-13** Logging, monitoring and record-keeping | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework; Business continuity and disaster recovery for AI services; Model AI Governance Framework for Agentic AI | ● | ● | ● | ● | ● | ○ | ● | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; Model AI Governance Framework for Generative AI | · | · | ○ | ○ | · | ○ | ● | · |
| **AIG-15** Change management and model lifecycle ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; MITRE ATLAS | · | ● | ● | ● | · | · | · | · |
| **AIG-16** Incident management and regulator notification ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; Anthropic; Business continuity and disaster recovery for AI services; Model AI Governance Framework for Generative AI; Cybersecurity Act 2018 as amended by the Cybersecurity | · | · | ● | ○ | · | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; FinOps Framework; Business continuity and disaster recovery for AI services | ● | · | ○ | ○ | · | · | ○ | ● |
| **AIG-18** Cross-border transfer safeguards | Singapore PDPA 2012 + PDPC advisory guidelines on AI recommendation and decision systems; ISO/IEC 27001:2022 + Amd 1:2024 | ● | · | ○ | ● | ● | ○ | ● | ● |
| **AIG-19** AI literacy and training | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO 19011:2026 Guidelines for auditing management systems; MITRE ATLAS | · | · | ○ | ○ | · | · | · | · |
| **AIG-20** Fairness and non-discrimination | ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment | · | · | ○ | ○ | · | · | · | · |
| **AIG-21** Internal audit and independent assurance | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO 19011:2026 Guidelines for auditing management systems | · | · | · | · | · | · | · | · |
| **AIG-22** AI FinOps — token budgets, consumption limits and cost allocation | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework | · | · | · | · | · | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`tech.system.yaml`](tech.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/sg/tech.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
