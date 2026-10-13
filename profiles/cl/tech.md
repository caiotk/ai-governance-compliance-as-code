# Chile — Technology companies

<sub>Generated from `catalog/` by `tools/build.py` · status as of 2026-10-13 · not legal advice.</sub>

> The AI bill is in the Senate and the government plans an innovation-first substitute text. Ley 21.719 is due in force 1 Dec 2026, but bill 18.623-07 would postpone it.

## Frameworks applied

| Framework | Status | Verification |
|---|---|---|
| [Chile Ley 21.719 personal data protection](https://www.cariola.cl/app/uploads/2026/09/Alerta-legal_-2septiembre.pdf) | Phased | ◐ secondary |
| [Chile Ley 21.663 Ley Marco de Ciberseguridad](https://www.carey.cl/entrada-en-vigencia-de-la-ley-de-ciberseguridad) — operators of vital importance / critical infrastructure only | In force | ◐ secondary |
| [ISO/IEC 27001:2022 + Amd 1:2024](https://www.iso.org/standard/27001) | Organisational baseline (voluntary) | ✓ primary |
| [ISO/IEC 42001:2023 AI management system](https://www.iso.org/standard/81230.html) | Organisational baseline (voluntary) | ◐ secondary |
| [Zero trust (NIST SP 800-207, CISA ZTMM v2.0)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf) | Organisational baseline (voluntary) | ✓ primary |

## Laws, regulations and guidance


### AI law and frameworks

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Proyecto de ley que regula los sistemas de inteligencia artificial | Boletines 16821-19 y 15869-19 | Pending — not law | AIG-03, AIG-10, AIG-12 | [✓ primary](https://www.senado.cl/comunicaciones/noticias/senadores-conocen-propuesta-del-ejecutivo-para-ley-marco-de-ia) |
| Política Nacional de Inteligencia Artificial (2024 update, to 2031) | Decreto 12/2024 (MinCiencia), DO 2025-01-28 | Voluntary | AIG-01, AIG-19 | [✓ primary](https://www.diariooficial.interior.gob.cl/publicaciones/2025/01/28/44060/01/2600578.pdf) |

### Data protection

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Ley de Protección de Datos Personales | Ley 21.719 (replaces Ley 19.628) | Phased · 2026-12-01 — pending bill 18.623-07 would postpone (to 2027-12-01 or by 6 months) | AIG-03, AIG-05, AIG-11, AIG-12, AIG-18 | [◐ secondary](https://www.cariola.cl/app/uploads/2026/09/Alerta-legal_-2septiembre.pdf) |

### Cybersecurity

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Ley Marco de Ciberseguridad | Ley 21.663 | In force · 2025-01-01 (OIV duties and incident reporting from 2025-03-01) | AIG-07, AIG-13, AIG-16 | [◐ secondary](https://www.carey.cl/entrada-en-vigencia-de-la-ley-de-ciberseguridad) |

### Sector rules: Technology companies

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Consumer protection law (no AI copyright/TDM exception confirmed) | Ley 19.496 | In force | AIG-12 | [⚠ unverified](https://www.bcn.cl/leychile/navegar?idNorma=61438) |

**Track, but do not yet treat as law:** Proyecto de ley que regula los sistemas de inteligencia artificial.

## Typical AI scenarios and high-risk triggers

- Building and distributing AI products and agents to customers
- Fine-tuning or training models, including general-purpose models
- AI coding assistants in the software supply chain
- Consumer chat and content-generation features

**Pushes a system into a higher risk tier in Chile:**

- Consumer-facing AI claims and deception (FTC Act §5; consumer protection law)

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Política Nacional de Inteligencia Artificial | · | · | ○ | ○ | · | · | · |
| **AIG-02** AI system and agent inventory | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ● | ○ | ○ | ● | ○ | · | ● |
| **AIG-03** Risk classification and impact assessment | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Ley de Protección de Datos Personales | · | · | ○ | ○ | · | · | · |
| **AIG-04** Data governance, quality and provenance ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | ● |
| **AIG-05** Personal data protection and minimisation | Chile Ley 21.719 personal data protection; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Ley de Protección de Datos Personales | ○ | ● | ○ | ● | ● | · | ● |
| **AIG-06** Approved models and AI supply chain ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ○ | ● | ● | ● | ● | ● | ● |
| **AIG-07** Workload and agent identity with least privilege | Chile Ley 21.663 Ley Marco de Ciberseguridad; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Ley Marco de Ciberseguridad | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-08** Network isolation and data residency | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ● | ● | ○ | ○ |
| **AIG-09** Encryption and key management | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ○ | ● | · | ○ |
| **AIG-10** Runtime guardrails and content safety ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ○ | ● | ● | ○ | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions | Chile Ley 21.719 personal data protection; ISO/IEC 42001:2023 AI management system; Zero trust; Ley de Protección de Datos Personales | · | ○ | ○ | ○ | ○ | · | ○ |
| **AIG-12** Transparency, notice and explanation ★ | Chile Ley 21.719 personal data protection; ISO/IEC 42001:2023 AI management system; Ley de Protección de Datos Personales; Consumer protection law | · | · | ○ | ○ | · | ○ | · |
| **AIG-13** Logging, monitoring and record-keeping | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Ley Marco de Ciberseguridad | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | ○ | · |
| **AIG-15** Change management and model lifecycle ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | ● | ● | ● | · | · | · |
| **AIG-16** Incident management and regulator notification ★ | Chile Ley 21.663 Ley Marco de Ciberseguridad; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Ley Marco de Ciberseguridad | · | · | ● | ○ | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | ● | · | ○ | ○ | · | · | ● |
| **AIG-18** Cross-border transfer safeguards | Chile Ley 21.719 personal data protection; ISO/IEC 27001:2022 + Amd 1:2024; Ley de Protección de Datos Personales | ● | · | ○ | ● | ● | ○ | ● |
| **AIG-19** AI literacy and training | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Política Nacional de Inteligencia Artificial | · | · | ○ | ○ | · | · | · |
| **AIG-20** Fairness and non-discrimination | ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`tech.system.yaml`](tech.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/cl/tech.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
