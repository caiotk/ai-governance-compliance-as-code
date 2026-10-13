# Argentina — Public sector

<sub>Generated from `catalog/` by `tools/build.py` · status as of 2026-10-13 · not legal advice.</sub>

> No AI law. 53 AI-related bills were filed in 2025; none enacted as of Apr 2026.

## Frameworks applied

| Framework | Status | Verification |
|---|---|---|
| [Argentina Ley 25.326 personal data protection](https://abogados.com.ar/promulgacion-de-la-ley-27699-de-adhesion-al-convenio-108-en-materia-de-proteccion-de-datos-personales/31732) | In force | ⚠ unverified |
| [ISO/IEC 27001:2022 + Amd 1:2024](https://www.iso.org/standard/27001) | Organisational baseline (voluntary) | ✓ primary |
| [ISO/IEC 42001:2023 AI management system](https://www.iso.org/standard/81230.html) | Organisational baseline (voluntary) | ◐ secondary |
| [Zero trust (NIST SP 800-207, CISA ZTMM v2.0)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf) | Organisational baseline (voluntary) | ✓ primary |

## Laws, regulations and guidance


### AI law and frameworks

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| AAIP Guía para usar la IA de manera responsable + Res. 161/2023 programme | AAIP Res. 161/2023; guide Sep 2024 | Voluntary | AIG-03, AIG-05, AIG-12 | [✓ primary](https://www.argentina.gob.ar/node/443099) |

### Data protection

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Ley de Protección de los Datos Personales | Ley 25.326; Ley 27.699 (Convention 108+) | In force | AIG-05, AIG-11, AIG-12, AIG-18 | [◐ secondary](https://abogados.com.ar/promulgacion-de-la-ley-27699-de-adhesion-al-convenio-108-en-materia-de-proteccion-de-datos-personales/31732) |

### Cybersecurity

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Segunda Estrategia Nacional de Ciberseguridad (no cyber statute) | JGM Res. 1/2023 | Voluntary | AIG-07, AIG-16 | [◐ secondary](https://www.marval.com/publicacion/segunda-estrategia-nacional-de-ciberseguridad-de-la-republica-argentina-15397) |

### Sector rules: Public sector

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Recomendaciones para una Inteligencia Artificial Fiable (public sector) | JGM Disposición 2/2023 | Voluntary | AIG-01, AIG-03, AIG-11, AIG-12 | [◐ secondary](https://iapp.org/news/a/argentina-emite-recomendaciones-para-la-implementacion-de-inteligencia-artificial-en-el-sector-publico) |

## Typical AI scenarios and high-risk triggers

- Eligibility and entitlement decisions for benefits and services
- Caseworker and contact-centre assistants
- Policy drafting, summarisation and translation
- Fraud and compliance risk scoring

**Pushes a system into a higher risk tier in Argentina:**

- Government AI policies require registers, accountable officials and impact assessments (AU DTA policy; US OMB M-25-21; JP Digital Agency guideline; NZ Public Service AI Framework; Spain LO bill; Argentina JGM Disp. 2/2023)
- Decisions about citizens' rights and entitlements are consequential decisions under data-protection law

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Recomendaciones para una Inteligencia Artificial Fiable | · | · | ○ | ○ | · | · | · |
| **AIG-02** AI system and agent inventory ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ● | ○ | ○ | ● | ○ | · | ● |
| **AIG-03** Risk classification and impact assessment ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; AAIP Guía para usar la IA de manera responsable + Res. 161/2023 programme; Recomendaciones para una Inteligencia Artificial Fiable | · | · | ○ | ○ | · | · | · |
| **AIG-04** Data governance, quality and provenance | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | ● |
| **AIG-05** Personal data protection and minimisation | Argentina Ley 25.326 personal data protection; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; AAIP Guía para usar la IA de manera responsable + Res. 161/2023 programme; Ley de Protección de los Datos Personales | ○ | ● | ○ | ● | ● | · | ● |
| **AIG-06** Approved models and AI supply chain | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ○ | ● | ● | ● | ● | ● | ● |
| **AIG-07** Workload and agent identity with least privilege | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Segunda Estrategia Nacional de Ciberseguridad | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-08** Network isolation and data residency ★ | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ● | ● | ○ | ○ |
| **AIG-09** Encryption and key management | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ○ | ● | · | ○ |
| **AIG-10** Runtime guardrails and content safety | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ○ | ● | ● | ○ | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions ★ | Argentina Ley 25.326 personal data protection; ISO/IEC 42001:2023 AI management system; Zero trust; Ley de Protección de los Datos Personales; Recomendaciones para una Inteligencia Artificial Fiable | · | ○ | ○ | ○ | ○ | · | ○ |
| **AIG-12** Transparency, notice and explanation ★ | ISO/IEC 42001:2023 AI management system; AAIP Guía para usar la IA de manera responsable + Res. 161/2023 programme; Ley de Protección de los Datos Personales; Recomendaciones para una Inteligencia Artificial Fiable | · | · | ○ | ○ | · | ○ | · |
| **AIG-13** Logging, monitoring and record-keeping | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | ○ | · |
| **AIG-15** Change management and model lifecycle | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | ● | ● | ● | · | · | · |
| **AIG-16** Incident management and regulator notification | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Segunda Estrategia Nacional de Ciberseguridad | · | · | ● | ○ | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | ● | · | ○ | ○ | · | · | ● |
| **AIG-18** Cross-border transfer safeguards ★ | Argentina Ley 25.326 personal data protection; ISO/IEC 27001:2022 + Amd 1:2024; Ley de Protección de los Datos Personales | ● | · | ○ | ● | ● | ○ | ● |
| **AIG-19** AI literacy and training | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | · |
| **AIG-20** Fairness and non-discrimination ★ | ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`public.system.yaml`](public.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/ar/public.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
