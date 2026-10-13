# Australia — Health

<sub>Generated from `catalog/` by `tools/build.py` · status as of 2026-10-13 · not legal advice.</sub>

> The National AI Plan (Dec 2025) relies on existing laws; there are no mandatory AI guardrails.

## Frameworks applied

| Framework | Status | Verification |
|---|---|---|
| [Australian Privacy Act 1988 (APPs) incl. POLA Act 2024](https://www.oaic.gov.au/privacy/australian-privacy-principles/read-the-australian-privacy-principles) | In force (phased) | ✓ primary |
| [ISO/IEC 27001:2022 + Amd 1:2024](https://www.iso.org/standard/27001) | Organisational baseline (voluntary) | ✓ primary |
| [ISO/IEC 42001:2023 AI management system](https://www.iso.org/standard/81230.html) | Organisational baseline (voluntary) | ◐ secondary |
| [Zero trust (NIST SP 800-207, CISA ZTMM v2.0)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf) | Organisational baseline (voluntary) | ✓ primary |

## Laws, regulations and guidance


### AI law and frameworks

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Guidance for AI Adoption (six essential practices) | National AI Centre, 17 Oct 2025 (updates the Voluntary AI Safety Standard) | Voluntary | AIG-01, AIG-03, AIG-11, AIG-12, AIG-14 | [✓ primary](https://www.industry.gov.au/publications/guidance-for-ai-adoption) |

### Data protection

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Privacy Act 1988 — Australian Privacy Principles | Privacy Act 1988 (Cth); Privacy and Other Legislation Amendment Act 2024 | Phased · Statutory tort 2025-06-10; APP 1.7–1.9 ADM transparency 2026-12-10 | AIG-02, AIG-04, AIG-05, AIG-08, AIG-12, AIG-16, AIG-18 | [✓ primary](https://www.oaic.gov.au/news/media-centre/new-resources-on-transparency-for-use-of-ai-and-automated-decision-making) |

### Cybersecurity

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Security of Critical Infrastructure Act 2018 (SOCI) | — | In force | AIG-02, AIG-07, AIG-16, AIG-17 | [⚠ unverified](https://www.legislation.gov.au/C2018A00029/latest) |
| Cyber Security Act 2024 (ransomware payment reporting) | — | In force · 2025-05-30 | AIG-16 | [◐ secondary](https://www.minterellison.com/articles/new-ransomware-payment-reporting-obligations-in-australia) |

### Sector rules: Health

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| TGA software-based medical device regulation incl. AI (Jul 2025 review findings) | Therapeutic Goods Act 1989 | In force | AIG-14, AIG-15 | [◐ secondary](https://www.minterellison.com/articles/tga-publishes-findings-on-ai-and-medical-devices) |
| My Health Records Act 2012 | — | In force | AIG-05, AIG-07 | [⚠ unverified](https://www.legislation.gov.au/C2012A00063/latest) |

## Typical AI scenarios and high-risk triggers

- Clinical documentation and ambient scribing
- Clinical decision support and diagnostic imaging triage
- Patient-facing triage and navigation assistants
- Claims, coding and revenue-cycle automation

**Pushes a system into a higher risk tier in Australia:**

- AI that is or is part of a software medical device (TGA, HSA, ANVISA, ANMAT, PMDA, FDA device rules)
- Health data is special-category / sensitive data

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Guidance for AI Adoption | · | · | ○ | ○ | · | · | · |
| **AIG-02** AI system and agent inventory | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Security of Critical Infrastructure Act 2018 | ● | ○ | ○ | ● | ○ | · | ● |
| **AIG-03** Risk classification and impact assessment ★ | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Guidance for AI Adoption | · | · | ○ | ○ | · | · | · |
| **AIG-04** Data governance, quality and provenance | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | ● |
| **AIG-05** Personal data protection and minimisation ★ | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; My Health Records Act 2012 | ○ | ● | ○ | ● | ● | · | ● |
| **AIG-06** Approved models and AI supply chain | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ○ | ● | ● | ● | ● | ● | ● |
| **AIG-07** Workload and agent identity with least privilege | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Security of Critical Infrastructure Act 2018; My Health Records Act 2012 | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-08** Network isolation and data residency | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ● | ● | ○ | ○ |
| **AIG-09** Encryption and key management ★ | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ○ | ● | · | ○ |
| **AIG-10** Runtime guardrails and content safety | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ○ | ● | ● | ○ | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions ★ | Australian Privacy Act 1988; ISO/IEC 42001:2023 AI management system; Zero trust; Guidance for AI Adoption | · | ○ | ○ | ○ | ○ | · | ○ |
| **AIG-12** Transparency, notice and explanation ★ | Australian Privacy Act 1988; ISO/IEC 42001:2023 AI management system; Guidance for AI Adoption | · | · | ○ | ○ | · | ○ | · |
| **AIG-13** Logging, monitoring and record-keeping | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming ★ | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Guidance for AI Adoption; TGA software-based medical device regulation incl. AI | · | · | ○ | ○ | · | ○ | · |
| **AIG-15** Change management and model lifecycle ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; TGA software-based medical device regulation incl. AI | · | ● | ● | ● | · | · | · |
| **AIG-16** Incident management and regulator notification | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Security of Critical Infrastructure Act 2018; Cyber Security Act 2024 | · | · | ● | ○ | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Security of Critical Infrastructure Act 2018 | ● | · | ○ | ○ | · | · | ● |
| **AIG-18** Cross-border transfer safeguards | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024 | ● | · | ○ | ● | ● | ○ | ● |
| **AIG-19** AI literacy and training | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | · |
| **AIG-20** Fairness and non-discrimination ★ | Australian Privacy Act 1988; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`health.system.yaml`](health.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/au/health.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
