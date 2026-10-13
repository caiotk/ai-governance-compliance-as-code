# Australia — Technology companies

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

### Sector rules: Technology companies

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Online Safety Act 2021, Phase 2 industry codes and social media minimum age (from 10 Dec 2025) | — | In force | AIG-10, AIG-12 | [◐ secondary](https://www.bakermckenzie.com/en/insight/publications/alerts/2025/09/australia-phase-2-online-safety-codes-registered-by-esafety-commissioner) |
| No text-and-data-mining copyright exception (government ruled one out, Oct 2025) | — | No specific rule | AIG-04 | [◐ secondary](https://www.simpsons.com.au/news/update-australian-government-rules-out-text-and-data-mining-exception-for-ai-training) |

## Typical AI scenarios and high-risk triggers

- Building and distributing AI products and agents to customers
- Fine-tuning or training models, including general-purpose models
- AI coding assistants in the software supply chain
- Consumer chat and content-generation features

**Pushes a system into a higher risk tier in Australia:**

- Training on copyrighted data (JP Copyright Act Art 30-4; SG Copyright Act s 244; AU has no TDM exception)
- Products used by children (Brazil ECA Digital; Australia Online Safety Act; Singapore Online Safety Act 2025)
- Consumer-facing AI claims and deception (FTC Act §5; consumer protection law)

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Guidance for AI Adoption | · | · | ○ | ○ | · | · | · |
| **AIG-02** AI system and agent inventory | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Security of Critical Infrastructure Act 2018 | ● | ○ | ○ | ● | ○ | · | ● |
| **AIG-03** Risk classification and impact assessment | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Guidance for AI Adoption | · | · | ○ | ○ | · | · | · |
| **AIG-04** Data governance, quality and provenance ★ | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | ● |
| **AIG-05** Personal data protection and minimisation | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | ○ | ● | ○ | ● | ● | · | ● |
| **AIG-06** Approved models and AI supply chain ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ○ | ● | ● | ● | ● | ● | ● |
| **AIG-07** Workload and agent identity with least privilege | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Security of Critical Infrastructure Act 2018 | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-08** Network isolation and data residency | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ● | ● | ○ | ○ |
| **AIG-09** Encryption and key management | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ○ | ● | · | ○ |
| **AIG-10** Runtime guardrails and content safety ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Online Safety Act 2021, Phase 2 industry codes and social media minimum age | ○ | ● | ● | ○ | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions | Australian Privacy Act 1988; ISO/IEC 42001:2023 AI management system; Zero trust; Guidance for AI Adoption | · | ○ | ○ | ○ | ○ | · | ○ |
| **AIG-12** Transparency, notice and explanation ★ | Australian Privacy Act 1988; ISO/IEC 42001:2023 AI management system; Guidance for AI Adoption; Online Safety Act 2021, Phase 2 industry codes and social media minimum age | · | · | ○ | ○ | · | ○ | · |
| **AIG-13** Logging, monitoring and record-keeping | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming ★ | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Guidance for AI Adoption | · | · | ○ | ○ | · | ○ | · |
| **AIG-15** Change management and model lifecycle ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | ● | ● | ● | · | · | · |
| **AIG-16** Incident management and regulator notification ★ | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Security of Critical Infrastructure Act 2018; Cyber Security Act 2024 | · | · | ● | ○ | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Security of Critical Infrastructure Act 2018 | ● | · | ○ | ○ | · | · | ● |
| **AIG-18** Cross-border transfer safeguards | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024 | ● | · | ○ | ● | ● | ○ | ● |
| **AIG-19** AI literacy and training | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | · |
| **AIG-20** Fairness and non-discrimination | Australian Privacy Act 1988; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`tech.system.yaml`](tech.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/au/tech.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
