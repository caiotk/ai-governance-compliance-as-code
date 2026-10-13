# New Zealand — Financial services

<sub>Generated from `catalog/` by `tools/build.py` · status as of 2026-10-13 · not legal advice.</sub>

> No AI-specific statute; the AI Strategy (Jul 2025) is adoption-first. BS11 applies only to NZ-incorporated registered banks with liabilities ≥ NZ$10bn.

## Frameworks applied

| Framework | Status | Verification |
|---|---|---|
| [New Zealand Privacy Act 2020 (IPPs) incl. IPP 3A and Biometric Processing Privacy Code 2025](https://www.privacy.org.nz/resources-and-learning/a-z-topics/ipp3a/) | In force (phased) | ✓ primary |
| [ISO/IEC 27001:2022 + Amd 1:2024](https://www.iso.org/standard/27001) | Organisational baseline (voluntary) | ✓ primary |
| [ISO/IEC 42001:2023 AI management system](https://www.iso.org/standard/81230.html) | Organisational baseline (voluntary) | ◐ secondary |
| [Zero trust (NIST SP 800-207, CISA ZTMM v2.0)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf) | Organisational baseline (voluntary) | ✓ primary |
| [RBNZ BS11 Outsourcing Policy (registered banks)](https://www.rbnz.govt.nz/regulation-and-supervision/banks/prudential-requirements/outsourcing-policy) — NZ-incorporated registered banks with liabilities ≥ NZ$10bn only | In force | ✓ primary |

## Laws, regulations and guidance


### AI law and frameworks

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| New Zealand's Strategy for AI — Investing with confidence; Responsible AI Guidance for Businesses | MBIE, 8 Jul 2025 | Voluntary | AIG-01, AIG-03, AIG-19 | [✓ primary](https://www.mbie.govt.nz/about/news/artificial-intelligence-strategy-and-business-guidance-now-available) |

### Data protection

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Privacy Act 2020 — Information Privacy Principles incl. IPP 3A | Privacy Act 2020 (2020 No 31); Privacy Amendment Act 2025 | Phased · IPP 3A from 2026-05-01 | AIG-03, AIG-04, AIG-05, AIG-08, AIG-12, AIG-16, AIG-18 | [✓ primary](https://www.privacy.org.nz/resources-and-learning/a-z-topics/ipp3a/) |
| Biometric Processing Privacy Code 2025 | — | In force · New processing 2025-11-03; existing processing 2026-08-03 | AIG-03, AIG-05, AIG-12 | [✓ primary](https://www.privacy.org.nz/assets/Codes-of-Practice-2020/Biometrics-Processing-Privacy-Code-2025-website-version.pdf) |

### Cybersecurity

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| No NIS-style cyber statute; NZ Information Security Manual (NZISM) applies to government agencies | — | No specific rule | AIG-07 | [⚠ unverified](https://nzism.gcsb.govt.nz/) |

### Sector rules: Financial services

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| RBNZ BS11 Outsourcing Policy (expected to be replaced by the DTA Outsourcing Standard; DTA standards due to commence 2028-12-01, BS11 revocation date not confirmed) | BS11, Sep 2022 | In force | AIG-06, AIG-08, AIG-17, AIG-18 | [✓ primary](https://www.rbnz.govt.nz/regulation-and-supervision/banks/prudential-requirements/outsourcing-policy) |
| Conduct of Financial Institutions regime (FMA) | Financial Markets (Conduct of Institutions) Amendment Act 2022 | In force · 2025-03-31 | AIG-11, AIG-12, AIG-20 | [✓ primary](https://www.mbie.govt.nz/business-and-employment/business/financial-markets-regulation/conduct-of-financial-institutions-regime) |

## Typical AI scenarios and high-risk triggers

- Credit decisioning and affordability assessment
- Fraud and financial-crime detection
- Customer service agents and advice assistants
- Software engineering and operations copilots on core systems

**Pushes a system into a higher risk tier in New Zealand:**

- Outsourcing a function that affects the four BS11 outcomes (registered banks ≥ NZ$10bn)

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership | New Zealand Privacy Act 2020; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; RBNZ BS11 Outsourcing Policy; New Zealand's Strategy for AI — Investing with confidence; Responsible AI Guidance for Businesses | · | · | ○ | ○ | · | · | · |
| **AIG-02** AI system and agent inventory ★ | New Zealand Privacy Act 2020; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ● | ○ | ○ | ● | ○ | · | ● |
| **AIG-03** Risk classification and impact assessment ★ | New Zealand Privacy Act 2020; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; New Zealand's Strategy for AI — Investing with confidence; Responsible AI Guidance for Businesses; Biometric Processing Privacy Code 2025 | · | · | ○ | ○ | · | · | · |
| **AIG-04** Data governance, quality and provenance | New Zealand Privacy Act 2020; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | ● |
| **AIG-05** Personal data protection and minimisation | New Zealand Privacy Act 2020; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Biometric Processing Privacy Code 2025 | ○ | ● | ○ | ● | ● | · | ● |
| **AIG-06** Approved models and AI supply chain ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; RBNZ BS11 Outsourcing Policy | ○ | ● | ● | ● | ● | ● | ● |
| **AIG-07** Workload and agent identity with least privilege ★ | New Zealand Privacy Act 2020; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-08** Network isolation and data residency | New Zealand Privacy Act 2020; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust; RBNZ BS11 Outsourcing Policy | ○ | ● | ● | ● | ● | ○ | ○ |
| **AIG-09** Encryption and key management | New Zealand Privacy Act 2020; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ○ | ● | · | ○ |
| **AIG-10** Runtime guardrails and content safety | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ○ | ● | ● | ○ | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions ★ | New Zealand Privacy Act 2020; ISO/IEC 42001:2023 AI management system; Zero trust; Conduct of Financial Institutions regime | · | ○ | ○ | ○ | ○ | · | ○ |
| **AIG-12** Transparency, notice and explanation | New Zealand Privacy Act 2020; ISO/IEC 42001:2023 AI management system; Biometric Processing Privacy Code 2025; Conduct of Financial Institutions regime | · | · | ○ | ○ | · | ○ | · |
| **AIG-13** Logging, monitoring and record-keeping ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | ○ | · |
| **AIG-15** Change management and model lifecycle ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | ● | ● | ● | · | · | · |
| **AIG-16** Incident management and regulator notification ★ | New Zealand Privacy Act 2020; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ● | ○ | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; RBNZ BS11 Outsourcing Policy | ● | · | ○ | ○ | · | · | ● |
| **AIG-18** Cross-border transfer safeguards | New Zealand Privacy Act 2020; ISO/IEC 27001:2022 + Amd 1:2024; RBNZ BS11 Outsourcing Policy | ● | · | ○ | ● | ● | ○ | ● |
| **AIG-19** AI literacy and training | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; New Zealand's Strategy for AI — Investing with confidence; Responsible AI Guidance for Businesses | · | · | ○ | ○ | · | · | · |
| **AIG-20** Fairness and non-discrimination ★ | New Zealand Privacy Act 2020; ISO/IEC 42001:2023 AI management system; Conduct of Financial Institutions regime | · | · | ○ | ○ | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`fsi.system.yaml`](fsi.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/nz/fsi.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
