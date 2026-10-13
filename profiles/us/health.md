# United States — Health

<sub>Generated from `catalog/` by `tools/build.py` · status as of 2026-10-13 · not legal advice.</sub>

> No federal AI statute. State laws apply by where the people affected are; EO 14365 (11 Dec 2025) challenges state AI laws but does not itself preempt them. Profiles list the main state laws; scope them to the states you operate in.

## Frameworks applied

| Framework | Status | Verification |
|---|---|---|
| [United States AI obligations (no single federal AI Act)](https://www.nist.gov/itl/ai-risk-management-framework) | In force (phased) | ◐ secondary |
| [ISO/IEC 27001:2022 + Amd 1:2024](https://www.iso.org/standard/27001) | Organisational baseline (voluntary) | ✓ primary |
| [ISO/IEC 42001:2023 AI management system](https://www.iso.org/standard/81230.html) | Organisational baseline (voluntary) | ◐ secondary |
| [Zero trust (NIST SP 800-207, CISA ZTMM v2.0)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf) | Organisational baseline (voluntary) | ✓ primary |

## Laws, regulations and guidance


### AI law and frameworks

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Texas Responsible Artificial Intelligence Governance Act | HB 149 (89th Leg.) | In force · 2026-01-01 | AIG-10, AIG-12, AIG-20 | [◐ secondary](https://www.ashurstperkinscoie.com/en/insights/update/texas-enacts-responsible-artificial-intelligence-governance-act/) |
| Colorado Automated Decision-Making Technology law (replaced the Colorado AI Act SB 24-205) | SB 26-189 | Phased · 2027-01-01 | AIG-04, AIG-11, AIG-12, AIG-13 | [◐ secondary](https://www.finnegan.com/en/insights/articles/colorado-replaces-landmark-ai-act-an-overview-of-the-new-sb-26-189-framework.html) |
| California Transparency in Frontier Artificial Intelligence Act | SB 53 | In force · 2026-01-01 | AIG-14, AIG-16 | [◐ secondary](https://www.mofo.com/pdf/resources/insights/251001-california-enacts-ai-safety-transparency-regulation-tfaia-sb-53) |
| AI in employment — Illinois HB 3773 (from 2026-01-01), NYC Local Law 144 bias audits (NYC only), Connecticut SB 5 (from 2027-10-01) | — | In force | AIG-12, AIG-20 | [◐ secondary](https://www.nelsonmullins.com/insights/blogs/ai-task-force/ai/states-take-aim-at-ai-in-employment-decisions-illinois-s-disclosure-and-anti-discrimination-requirements-enforcement-gaps-under-nyc-s-local-law-144-and-connecticut-s-new-ai-law) |
| Utah Artificial Intelligence Policy Act (GenAI disclosure when asked or in high-risk interactions; mental-health chatbots) | SB 149 (2024), SB 226 and HB 452 (2025); sunset 2027-07-01 | In force | AIG-12 | [◐ secondary](https://fpf.org/blog/chatbots-in-check-utahs-latest-ai-legislation/) |
| NIST AI RMF 1.0 and Generative AI Profile (voluntary) | NIST AI 100-1; NIST AI 600-1 | Voluntary | AIG-01, AIG-03, AIG-10, AIG-13, AIG-14 | [✓ primary](https://www.nist.gov/itl/ai-risk-management-framework) |

### Data protection

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| California CCPA regulations on ADMT, risk assessments and cybersecurity audits | Cal. Code Regs. tit. 11 (CPPA) | Phased · Risk assessments 2026-01-01; ADMT duties 2027-01-01; attestations 2028-04-01 | AIG-03, AIG-11, AIG-12 | [◐ secondary](https://www.hunton.com/privacy-and-cybersecurity-law-blog/newly-approved-ccpa-regulations-have-staggered-deadlines-for-compliance) |

### Cybersecurity

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| NYDFS Cybersecurity Regulation (amended) | 23 NYCRR 500 | In force · Final phase 2025-11-01 | AIG-02, AIG-07, AIG-16 | [◐ secondary](https://hlc.com/en/publications/nydfs-final-set-of-cybersecurity-requirements-under-amended-part-500-take-effect-november-1-2025) |

### Sector rules: Health

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| HIPAA Privacy and Security Rules | 45 CFR Parts 160 and 164 | In force | AIG-05, AIG-07, AIG-09, AIG-13 | [⚠ unverified](https://www.hhs.gov/hipaa/for-professionals/security/index.html) |
| ACA §1557 non-discrimination in patient care decision support tools | 45 CFR 92.210 | In force | AIG-20 | [◐ secondary](https://www.crowell.com/en/insights/client-alerts/hhs-applies-discrimination-prohibitions-to-use-of-automated-and-non-automated-patient-care-decision-support-tools) |
| FDA PCCP guidance for AI-enabled device software functions (final, Dec 2024); AI lifecycle management guidance (Jan 2025 — final status unconfirmed); revised CDS software guidance (Jan 2026) | — | In force | AIG-14, AIG-15 | [⚠ unverified](https://fda.gov/regulatory-information/search-fda-guidance-documents/artificial-intelligence-enabled-device-software-functions-lifecycle-management-and-marketing) |

## Typical AI scenarios and high-risk triggers

- Clinical documentation and ambient scribing
- Clinical decision support and diagnostic imaging triage
- Patient-facing triage and navigation assistants
- Claims, coding and revenue-cycle automation

**Pushes a system into a higher risk tier in United States:**

- AI that is or is part of a software medical device (TGA, HSA, ANVISA, ANMAT, PMDA, FDA device rules)
- Health data is special-category / sensitive data

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership | United States AI obligations; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI RMF 1.0 and Generative AI Profile | · | · | ○ | ○ | · | · | · |
| **AIG-02** AI system and agent inventory | United States AI obligations; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NYDFS Cybersecurity Regulation | ● | ○ | ○ | ● | ○ | · | ● |
| **AIG-03** Risk classification and impact assessment ★ | United States AI obligations; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI RMF 1.0 and Generative AI Profile; California CCPA regulations on ADMT, risk assessments and cybersecurity audits | · | · | ○ | ○ | · | · | · |
| **AIG-04** Data governance, quality and provenance | United States AI obligations; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Colorado Automated Decision-Making Technology law | · | · | ○ | ○ | · | · | ● |
| **AIG-05** Personal data protection and minimisation ★ | United States AI obligations; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; HIPAA Privacy and Security Rules | ○ | ● | ○ | ● | ● | · | ● |
| **AIG-06** Approved models and AI supply chain | United States AI obligations; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ○ | ● | ● | ● | ● | ● | ● |
| **AIG-07** Workload and agent identity with least privilege | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NYDFS Cybersecurity Regulation; HIPAA Privacy and Security Rules | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-08** Network isolation and data residency | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ● | ● | ○ | ○ |
| **AIG-09** Encryption and key management ★ | United States AI obligations; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust; HIPAA Privacy and Security Rules | ○ | ● | ● | ○ | ● | · | ○ |
| **AIG-10** Runtime guardrails and content safety | United States AI obligations; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Texas Responsible Artificial Intelligence Governance Act; NIST AI RMF 1.0 and Generative AI Profile | ○ | ● | ● | ○ | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions ★ | United States AI obligations; ISO/IEC 42001:2023 AI management system; Zero trust; Colorado Automated Decision-Making Technology law; California CCPA regulations on ADMT, risk assessments and cybersecurity audits | · | ○ | ○ | ○ | ○ | · | ○ |
| **AIG-12** Transparency, notice and explanation ★ | United States AI obligations; ISO/IEC 42001:2023 AI management system; Texas Responsible Artificial Intelligence Governance Act; Colorado Automated Decision-Making Technology law; AI in employment — Illinois HB 3773; Utah Artificial Intelligence Policy Act; California CCPA regulations on ADMT, risk assessments and cybersecurity audits | · | · | ○ | ○ | · | ○ | · |
| **AIG-13** Logging, monitoring and record-keeping | United States AI obligations; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Colorado Automated Decision-Making Technology law; NIST AI RMF 1.0 and Generative AI Profile; HIPAA Privacy and Security Rules | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming ★ | United States AI obligations; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; California Transparency in Frontier Artificial Intelligence Act; NIST AI RMF 1.0 and Generative AI Profile; FDA PCCP guidance for AI-enabled device software functions | · | · | ○ | ○ | · | ○ | · |
| **AIG-15** Change management and model lifecycle ★ | United States AI obligations; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; FDA PCCP guidance for AI-enabled device software functions | · | ● | ● | ● | · | · | · |
| **AIG-16** Incident management and regulator notification | United States AI obligations; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; California Transparency in Frontier Artificial Intelligence Act; NYDFS Cybersecurity Regulation | · | · | ● | ○ | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | ● | · | ○ | ○ | · | · | ● |
| **AIG-18** Cross-border transfer safeguards | ISO/IEC 27001:2022 + Amd 1:2024 | ● | · | ○ | ● | ● | ○ | ● |
| **AIG-19** AI literacy and training | United States AI obligations; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | · |
| **AIG-20** Fairness and non-discrimination ★ | United States AI obligations; ISO/IEC 42001:2023 AI management system; Texas Responsible Artificial Intelligence Governance Act; AI in employment — Illinois HB 3773; ACA §1557 non-discrimination in patient care decision support tools | · | · | ○ | ○ | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`health.system.yaml`](health.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/us/health.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
