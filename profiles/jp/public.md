# Japan — Public sector

<sub>Generated from `catalog/` by `tools/build.py` · status as of 2026-10-13 · not legal advice.</sub>

> The AI Promotion Act is promotional with no penalties; obligations come from APPI, sector rules and voluntary guidelines.

## Frameworks applied

| Framework | Status | Verification |
|---|---|---|
| [Japan Act on the Protection of Personal Information (APPI), as amended by Act No. 56 of 2026](https://www.aoshearman.com/en/insights/ao-shearman-on-data/amendments-to-the-act-on-the-protection-of-personal-information-promulgated) | Phased | ◐ secondary |
| [ISO/IEC 27001:2022 + Amd 1:2024](https://www.iso.org/standard/27001) | Organisational baseline (voluntary) | ✓ primary |
| [ISO/IEC 42001:2023 AI management system](https://www.iso.org/standard/81230.html) | Organisational baseline (voluntary) | ◐ secondary |
| [Zero trust (NIST SP 800-207, CISA ZTMM v2.0)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf) | Organisational baseline (voluntary) | ✓ primary |

## Laws, regulations and guidance


### AI law and frameworks

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Act on Promotion of Research and Development, and Deployment of AI-related Technology | Act No. 53 of 2025 | In force · 2025-09-01 | AIG-01, AIG-16 | [✓ primary](https://www8.cao.go.jp/cstp/ai/ai_plan/aiplan_eng_20260714.pdf) |
| Second AI Basic Plan (agentic, physical and sovereign AI; stronger AISI) | Cabinet decision 2026 (English provisional translation 14 Jul 2026) | Voluntary | AIG-01 | [✓ primary](https://www8.cao.go.jp/cstp/ai/ai_plan/aiplan_eng_20260714.pdf) |
| AI Business Operator Guidelines v1.2 (METI/MIC) | 31 Mar 2026 | Voluntary | AIG-01, AIG-03, AIG-10, AIG-14 | [◐ secondary](https://www.ibanet.org/japan-health-data-reforms-ai) |

### Data protection

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Act on the Protection of Personal Information (APPI), as amended by Act No. 56 of 2026 | — | Phased · Penalties from 2027-01-17; main reforms by Cabinet Order no later than 2028-07-17 | AIG-04, AIG-05, AIG-18 | [◐ secondary](https://www.aoshearman.com/en/insights/ao-shearman-on-data/amendments-to-the-act-on-the-protection-of-personal-information-promulgated) |

### Cybersecurity

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Active Cyber Defense law (Cyber Response Capability Enhancement Act) | — | Phased · Main enforcement 2026-10-01; CI incident reporting by ~Nov 2026; asset notifications 2027-03-31 | AIG-02, AIG-16 | [◐ secondary](https://www.trendmicro.com/ja_jp/jp-security/26/h/securitytrend-20260814-01.html) |

### Sector rules: Public sector

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Digital Agency Guideline for Government Procurement and Utilisation of Generative AI v2.0 | Approved 12 Jun 2026 | In force | AIG-01, AIG-02, AIG-03, AIG-06 | [✓ primary](https://www.digital.go.jp/en/news/3579c42d-b11c-4756-b66e-3d3e35175623) |

## Typical AI scenarios and high-risk triggers

- Eligibility and entitlement decisions for benefits and services
- Caseworker and contact-centre assistants
- Policy drafting, summarisation and translation
- Fraud and compliance risk scoring

**Pushes a system into a higher risk tier in Japan:**

- Government AI policies require registers, accountable officials and impact assessments (AU DTA policy; US OMB M-25-21; JP Digital Agency guideline; NZ Public Service AI Framework; Spain LO bill; Argentina JGM Disp. 2/2023)
- Decisions about citizens' rights and entitlements are consequential decisions under data-protection law

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Act on Promotion of Research and Development, and Deployment of AI-related Technology; Second AI Basic Plan; AI Business Operator Guidelines v1.2; Digital Agency Guideline for Government Procurement and Utilisation of Generative AI v2.0 | · | · | ○ | ○ | · | · | · |
| **AIG-02** AI system and agent inventory ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Active Cyber Defense law; Digital Agency Guideline for Government Procurement and Utilisation of Generative AI v2.0 | ● | ○ | ○ | ● | ○ | · | ● |
| **AIG-03** Risk classification and impact assessment ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; AI Business Operator Guidelines v1.2; Digital Agency Guideline for Government Procurement and Utilisation of Generative AI v2.0 | · | · | ○ | ○ | · | · | · |
| **AIG-04** Data governance, quality and provenance | Japan Act on the Protection of Personal Information; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | ● |
| **AIG-05** Personal data protection and minimisation | Japan Act on the Protection of Personal Information; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | ○ | ● | ○ | ● | ● | · | ● |
| **AIG-06** Approved models and AI supply chain | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Digital Agency Guideline for Government Procurement and Utilisation of Generative AI v2.0 | ○ | ● | ● | ● | ● | ● | ● |
| **AIG-07** Workload and agent identity with least privilege | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-08** Network isolation and data residency ★ | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ● | ● | ○ | ○ |
| **AIG-09** Encryption and key management | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ○ | ● | · | ○ |
| **AIG-10** Runtime guardrails and content safety | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; AI Business Operator Guidelines v1.2 | ○ | ● | ● | ○ | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions ★ | ISO/IEC 42001:2023 AI management system; Zero trust | · | ○ | ○ | ○ | ○ | · | ○ |
| **AIG-12** Transparency, notice and explanation ★ | ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | ○ | · |
| **AIG-13** Logging, monitoring and record-keeping | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; AI Business Operator Guidelines v1.2 | · | · | ○ | ○ | · | ○ | · |
| **AIG-15** Change management and model lifecycle | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | ● | ● | ● | · | · | · |
| **AIG-16** Incident management and regulator notification | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Act on Promotion of Research and Development, and Deployment of AI-related Technology; Active Cyber Defense law | · | · | ● | ○ | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | ● | · | ○ | ○ | · | · | ● |
| **AIG-18** Cross-border transfer safeguards ★ | Japan Act on the Protection of Personal Information; ISO/IEC 27001:2022 + Amd 1:2024 | ● | · | ○ | ● | ● | ○ | ● |
| **AIG-19** AI literacy and training | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | · |
| **AIG-20** Fairness and non-discrimination ★ | ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`public.system.yaml`](public.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/jp/public.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
