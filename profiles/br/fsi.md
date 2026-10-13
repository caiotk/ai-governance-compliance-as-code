# Brazil — Financial services

<sub>Generated from `catalog/` by `tools/build.py` · status as of 2026-10-13 · not legal advice.</sub>

> No AI statute in force. PL 2338/2023 passed the Senate (Dec 2024) and sits with a Chamber special committee; a vote is expected after the Oct 2026 elections.

## Frameworks applied

| Framework | Status | Verification |
|---|---|---|
| [Brazil LGPD — Lei 13.709/2018](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm) | In force | ✓ primary |
| [ISO/IEC 27001:2022 + Amd 1:2024](https://www.iso.org/standard/27001) | Organisational baseline (voluntary) | ✓ primary |
| [ISO/IEC 42001:2023 AI management system](https://www.iso.org/standard/81230.html) | Organisational baseline (voluntary) | ◐ secondary |
| [Zero trust (NIST SP 800-207, CISA ZTMM v2.0)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf) | Organisational baseline (voluntary) | ✓ primary |

## Laws, regulations and guidance


### AI law and frameworks

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Marco Legal da Inteligência Artificial (bill) | PL 2338/2023 | Pending — not law | AIG-03, AIG-11, AIG-12 | [◐ secondary](https://www.mobiletime.com.br/noticias/24/08/2026/marco-ia-voto-fim-do-ano/) |
| Plano Brasileiro de Inteligência Artificial 2024–2028 | MCTI, Jul 2024 | Voluntary | AIG-19 | [◐ secondary](https://dplnews.com/um-ano-de-plano-brasileiro-de-inteligencia-artificial-o-que-esta-sendo-feito/) |

### Data protection

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Lei Geral de Proteção de Dados (LGPD) | Lei 13.709/2018 | In force | AIG-03, AIG-05, AIG-11, AIG-12, AIG-18 | [✓ primary](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm) |
| ANPD standard contractual clauses for international transfers | Resolução CD/ANPD 19/2024 | In force · SCC adoption deadline 2025-08-23 | AIG-18 | [◐ secondary](https://lefosse.com/noticias/alerta/transferencia-internacional-de-dados-prazo-para-adocao-das-clausulas-padrao-da-anpd-se-encerra-em-23-de-agosto/) |

### Cybersecurity

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Política Nacional de Cibersegurança | Decreto 11.856/2023 | In force | AIG-07, AIG-16 | [✓ primary](https://planalto.gov.br/ccivil_03/_ato2023-2026/2023/decreto/d11856.htm) |

### Sector rules: Financial services

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Cybersecurity policy and cloud/data-processing outsourcing for financial institutions | Resolução CMN 4.893/2021, amended by Resolução CMN 5.274/2025 | In force · Amendment adjustments due 2026-03-01 | AIG-06, AIG-07, AIG-13, AIG-16, AIG-17 | [◐ secondary](https://okai.com.br/documento/2025-12-18/resolucao-cmn-n-5-274) |

**Track, but do not yet treat as law:** Marco Legal da Inteligência Artificial (bill).

## Typical AI scenarios and high-risk triggers

- Credit decisioning and affordability assessment
- Fraud and financial-crime detection
- Customer service agents and advice assistants
- Software engineering and operations copilots on core systems

**Pushes a system into a higher risk tier in Brazil:**

- Consequential decisions about customers (LGPD Art 20; Ley 21.719 Art 8 bis; Ley 25.326 Art 20)

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | · | · | ○ | ○ | · | · | · |
| **AIG-02** AI system and agent inventory ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ● | ○ | ○ | ● | ○ | · | ● |
| **AIG-03** Risk classification and impact assessment ★ | Brazil LGPD; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | · |
| **AIG-04** Data governance, quality and provenance | Brazil LGPD; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | ● |
| **AIG-05** Personal data protection and minimisation | Brazil LGPD; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | ○ | ● | ○ | ● | ● | · | ● |
| **AIG-06** Approved models and AI supply chain ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Cybersecurity policy and cloud/data-processing outsourcing for financial institutions | ○ | ● | ● | ● | ● | ● | ● |
| **AIG-07** Workload and agent identity with least privilege ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Política Nacional de Cibersegurança; Cybersecurity policy and cloud/data-processing outsourcing for financial institutions | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-08** Network isolation and data residency | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ● | ● | ○ | ○ |
| **AIG-09** Encryption and key management | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ○ | ● | · | ○ |
| **AIG-10** Runtime guardrails and content safety | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ○ | ● | ● | ○ | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions ★ | Brazil LGPD; ISO/IEC 42001:2023 AI management system; Zero trust | · | ○ | ○ | ○ | ○ | · | ○ |
| **AIG-12** Transparency, notice and explanation | ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | ○ | · |
| **AIG-13** Logging, monitoring and record-keeping ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Cybersecurity policy and cloud/data-processing outsourcing for financial institutions | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | ○ | · |
| **AIG-15** Change management and model lifecycle ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | ● | ● | ● | · | · | · |
| **AIG-16** Incident management and regulator notification ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Política Nacional de Cibersegurança; Cybersecurity policy and cloud/data-processing outsourcing for financial institutions | · | · | ● | ○ | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Cybersecurity policy and cloud/data-processing outsourcing for financial institutions | ● | · | ○ | ○ | · | · | ● |
| **AIG-18** Cross-border transfer safeguards | Brazil LGPD; ISO/IEC 27001:2022 + Amd 1:2024; ANPD standard contractual clauses for international transfers | ● | · | ○ | ● | ● | ○ | ● |
| **AIG-19** AI literacy and training | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Plano Brasileiro de Inteligência Artificial 2024–2028 | · | · | ○ | ○ | · | · | · |
| **AIG-20** Fairness and non-discrimination ★ | ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`fsi.system.yaml`](fsi.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/br/fsi.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
