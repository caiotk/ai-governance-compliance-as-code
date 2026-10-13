# Australia — Financial services

<sub>Generated from `catalog/` by `tools/build.py` · status as of 2026-10-13 · not legal advice.</sub>

> The National AI Plan (Dec 2025) relies on existing laws; there are no mandatory AI guardrails.

## Frameworks applied

| Framework | Status | Verification |
|---|---|---|
| [Australian Privacy Act 1988 (APPs) incl. POLA Act 2024](https://www.oaic.gov.au/privacy/australian-privacy-principles/read-the-australian-privacy-principles) | In force (phased) | ✓ primary |
| [ISO/IEC 27001:2022 + Amd 1:2024](https://www.iso.org/standard/27001) | Organisational baseline (voluntary) | ✓ primary |
| [ISO/IEC 42001:2023 AI management system](https://www.iso.org/standard/81230.html) | Organisational baseline (voluntary) | ◐ secondary |
| [Zero trust (NIST SP 800-207, CISA ZTMM v2.0)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf) | Organisational baseline (voluntary) | ✓ primary |
| [APRA prudential standards (CPS 230, CPS 234, CPS 220) + APRA letter on AI](https://www.apra.gov.au/apra-letter-to-industry-on-artificial-intelligence-ai) — APRA-regulated entities only | In force | ✓ primary |

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

### Sector rules: Financial services

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| APRA CPS 230 Operational Risk Management | — | In force · 2025-07-01 (legacy contracts by 2026-07-01) | AIG-02, AIG-03, AIG-06, AIG-15, AIG-16, AIG-17 | [✓ primary](https://www.apra.gov.au/sites/default/files/2023-07/Prudential%20Standard%20CPS%20230%20Operational%20Risk%20Management%20-%20clean.pdf) |
| APRA CPS 234 Information Security | — | In force · 2019-07-01 | AIG-01, AIG-07, AIG-08, AIG-09, AIG-13, AIG-14, AIG-16 | [✓ primary](https://www.apra.gov.au/sites/default/files/cps_234_july_2019_for_public_release.pdf) |
| APRA letter to industry on artificial intelligence (supervisory expectations under existing standards) | 30 Apr 2026 | Voluntary | AIG-01, AIG-02, AIG-06, AIG-07, AIG-10, AIG-11, AIG-13, AIG-14, AIG-17, AIG-19, AIG-20 | [✓ primary](https://www.apra.gov.au/apra-letter-to-industry-on-artificial-intelligence-ai) |
| ASIC REP 798 Beware the gap — governance arrangements in the face of AI innovation | 29 Oct 2024 | Voluntary | AIG-01, AIG-02 | [✓ primary](https://asic.gov.au/regulatory-resources/find-a-document/reports/rep-798-beware-the-gap-governance-arrangements-in-the-face-of-ai-innovation/) |

## Typical AI scenarios and high-risk triggers

- Credit decisioning and affordability assessment
- Fraud and financial-crime detection
- Customer service agents and advice assistants
- Software engineering and operations copilots on core systems

**Pushes a system into a higher risk tier in Australia:**

- Material service provider or outsourcing of critical operations (APRA CPS 230)

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; APRA prudential standards; Guidance for AI Adoption; APRA CPS 234 Information Security; APRA letter to industry on artificial intelligence; ASIC REP 798 Beware the gap — governance arrangements in the face of AI innovation | · | · | ○ | ○ | · | · | · |
| **AIG-02** AI system and agent inventory ★ | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; APRA prudential standards; Security of Critical Infrastructure Act 2018; APRA CPS 230 Operational Risk Management; APRA letter to industry on artificial intelligence; ASIC REP 798 Beware the gap — governance arrangements in the face of AI innovation | ● | ○ | ○ | ● | ○ | · | ● |
| **AIG-03** Risk classification and impact assessment ★ | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; APRA prudential standards; Guidance for AI Adoption; APRA CPS 230 Operational Risk Management | · | · | ○ | ○ | · | · | · |
| **AIG-04** Data governance, quality and provenance | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | ● |
| **AIG-05** Personal data protection and minimisation | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | ○ | ● | ○ | ● | ● | · | ● |
| **AIG-06** Approved models and AI supply chain ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; APRA prudential standards; APRA CPS 230 Operational Risk Management; APRA letter to industry on artificial intelligence | ○ | ● | ● | ● | ● | ● | ● |
| **AIG-07** Workload and agent identity with least privilege ★ | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; APRA prudential standards; Security of Critical Infrastructure Act 2018; APRA CPS 234 Information Security; APRA letter to industry on artificial intelligence | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-08** Network isolation and data residency | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust; APRA prudential standards; APRA CPS 234 Information Security | ○ | ● | ● | ● | ● | ○ | ○ |
| **AIG-09** Encryption and key management | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust; APRA prudential standards; APRA CPS 234 Information Security | ○ | ● | ● | ○ | ● | · | ○ |
| **AIG-10** Runtime guardrails and content safety | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; APRA prudential standards; APRA letter to industry on artificial intelligence | ○ | ● | ● | ○ | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions ★ | Australian Privacy Act 1988; ISO/IEC 42001:2023 AI management system; Zero trust; APRA prudential standards; Guidance for AI Adoption; APRA letter to industry on artificial intelligence | · | ○ | ○ | ○ | ○ | · | ○ |
| **AIG-12** Transparency, notice and explanation | Australian Privacy Act 1988; ISO/IEC 42001:2023 AI management system; Guidance for AI Adoption | · | · | ○ | ○ | · | ○ | · |
| **AIG-13** Logging, monitoring and record-keeping ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; APRA prudential standards; APRA CPS 234 Information Security; APRA letter to industry on artificial intelligence | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming ★ | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; APRA prudential standards; Guidance for AI Adoption; APRA CPS 234 Information Security; APRA letter to industry on artificial intelligence | · | · | ○ | ○ | · | ○ | · |
| **AIG-15** Change management and model lifecycle ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; APRA prudential standards; APRA CPS 230 Operational Risk Management | · | ● | ● | ● | · | · | · |
| **AIG-16** Incident management and regulator notification ★ | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; APRA prudential standards; Security of Critical Infrastructure Act 2018; Cyber Security Act 2024; APRA CPS 230 Operational Risk Management; APRA CPS 234 Information Security | · | · | ● | ○ | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; APRA prudential standards; Security of Critical Infrastructure Act 2018; APRA CPS 230 Operational Risk Management; APRA letter to industry on artificial intelligence | ● | · | ○ | ○ | · | · | ● |
| **AIG-18** Cross-border transfer safeguards | Australian Privacy Act 1988; ISO/IEC 27001:2022 + Amd 1:2024 | ● | · | ○ | ● | ● | ○ | ● |
| **AIG-19** AI literacy and training | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; APRA prudential standards; APRA letter to industry on artificial intelligence | · | · | ○ | ○ | · | · | · |
| **AIG-20** Fairness and non-discrimination ★ | Australian Privacy Act 1988; ISO/IEC 42001:2023 AI management system; APRA prudential standards; APRA letter to industry on artificial intelligence | · | · | ○ | ○ | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`fsi.system.yaml`](fsi.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/au/fsi.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
