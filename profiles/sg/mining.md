# Singapore — Mining and resources

<sub>Generated from `catalog/` by `tools/build.py` · status as of 2026-10-13 · not legal advice.</sub>

> No AI statute; model governance frameworks and sector guidelines. MAS AI Risk Management Guidelines were finalised in Oct 2026.

## Frameworks applied

| Framework | Status | Verification |
|---|---|---|
| [Singapore PDPA 2012 + PDPC advisory guidelines on AI recommendation and decision systems](https://www.rajahtannasia.com/viewpoints/pdpc-issues-advisory-guidelines-on-use-of-personal-data-in-ai-recommendation-and-decision-systems/) | In force | ◐ secondary |
| [ISO/IEC 27001:2022 + Amd 1:2024](https://www.iso.org/standard/27001) | Organisational baseline (voluntary) | ✓ primary |
| [ISO/IEC 42001:2023 AI management system](https://www.iso.org/standard/81230.html) | Organisational baseline (voluntary) | ◐ secondary |
| [Zero trust (NIST SP 800-207, CISA ZTMM v2.0)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf) | Organisational baseline (voluntary) | ✓ primary |

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

### Sector rules: Mining and resources

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Not applicable — no material mining sector (use the WSH Act generically) | — | No specific rule | AIG-17 | [◐ secondary](https://www.mddi.gov.sg/newsroom/04122023/) |

## Typical AI scenarios and high-risk triggers

- Autonomous haulage and drilling
- Predictive maintenance on fixed and mobile plant
- Geological and ore-body modelling
- Safety monitoring with computer vision (fatigue, proximity, exclusion zones)

**Pushes a system into a higher risk tier in Singapore:**

- Worker monitoring and safety-critical automation under general work health and safety law

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Model AI Governance Framework for Generative AI | · | · | ○ | ○ | · | · | · |
| **AIG-02** AI system and agent inventory | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ● | ○ | ○ | ● | ○ | · | ● |
| **AIG-03** Risk classification and impact assessment ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Model AI Governance Framework for Agentic AI | · | · | ○ | ○ | · | · | · |
| **AIG-04** Data governance, quality and provenance | Singapore PDPA 2012 + PDPC advisory guidelines on AI recommendation and decision systems; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | ● |
| **AIG-05** Personal data protection and minimisation | Singapore PDPA 2012 + PDPC advisory guidelines on AI recommendation and decision systems; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | ○ | ● | ○ | ● | ● | · | ● |
| **AIG-06** Approved models and AI supply chain | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Model AI Governance Framework for Generative AI | ○ | ● | ● | ● | ● | ● | ● |
| **AIG-07** Workload and agent identity with least privilege | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Model AI Governance Framework for Agentic AI; Cybersecurity Act 2018 as amended by the Cybersecurity | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-08** Network isolation and data residency | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ● | ● | ○ | ○ |
| **AIG-09** Encryption and key management | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ○ | ● | · | ○ |
| **AIG-10** Runtime guardrails and content safety | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Model AI Governance Framework for Generative AI; Model AI Governance Framework for Agentic AI | ○ | ● | ● | ○ | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions ★ | ISO/IEC 42001:2023 AI management system; Zero trust; Model AI Governance Framework for Agentic AI | · | ○ | ○ | ○ | ○ | · | ○ |
| **AIG-12** Transparency, notice and explanation | Singapore PDPA 2012 + PDPC advisory guidelines on AI recommendation and decision systems; ISO/IEC 42001:2023 AI management system; Model AI Governance Framework for Generative AI | · | · | ○ | ○ | · | ○ | · |
| **AIG-13** Logging, monitoring and record-keeping ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Model AI Governance Framework for Agentic AI | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Model AI Governance Framework for Generative AI | · | · | ○ | ○ | · | ○ | · |
| **AIG-15** Change management and model lifecycle ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | ● | ● | ● | · | · | · |
| **AIG-16** Incident management and regulator notification ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Model AI Governance Framework for Generative AI; Cybersecurity Act 2018 as amended by the Cybersecurity | · | · | ● | ○ | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | ● | · | ○ | ○ | · | · | ● |
| **AIG-18** Cross-border transfer safeguards | Singapore PDPA 2012 + PDPC advisory guidelines on AI recommendation and decision systems; ISO/IEC 27001:2022 + Amd 1:2024 | ● | · | ○ | ● | ● | ○ | ● |
| **AIG-19** AI literacy and training | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | · |
| **AIG-20** Fairness and non-discrimination | ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`mining.system.yaml`](mining.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/sg/mining.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
