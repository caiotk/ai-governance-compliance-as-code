# Brazil — Health

<sub>Generated from `catalog/` by `tools/build.py` · status as of 2026-10-13 · not legal advice.</sub>

> No AI statute in force. PL 2338/2023 passed the Senate (Dec 2024) and sits with a Chamber special committee; a vote is expected after the Oct 2026 elections.

## Frameworks applied

| Framework | Status | Verification |
|---|---|---|
| [Brazil LGPD — Lei 13.709/2018](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm) | In force | ✓ primary |
| [ISO/IEC 27001:2022 + Amd 1:2024](https://www.iso.org/standard/27001) | Organisational baseline (voluntary) | ✓ primary |
| [ISO/IEC 42001:2023 AI management system](https://www.iso.org/standard/81230.html) | Organisational baseline (voluntary) | ◐ secondary |
| [Zero trust (NIST SP 800-207, CISA ZTMM v2.0)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf) | Organisational baseline (voluntary) | ✓ primary |
| [Brazil CFM Resolution 2.454/2026 on AI in medicine](https://portal.cfm.org.br/noticias/cfm-normatiza-uso-da-ia-na-medicina) | In force | ✓ primary |

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

### Sector rules: Health

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| ANVISA software as a medical device rules | RDC 657/2022; RDC 751/2022 | In force | AIG-04, AIG-14, AIG-15 | [✓ primary](https://antigo.anvisa.gov.br/documents/10181/5141677/RDC_657_2022_COMP.pdf/d2da154d-bd76-40ba-87ee-3d9baadb5dd3) |
| CFM resolution on AI in medicine | Resolução CFM 2.454/2026 | In force · ~2026-08 (180 days after publication on 2026-02-27) | AIG-01, AIG-03, AIG-11, AIG-12, AIG-13 | [✓ primary](https://portal.cfm.org.br/noticias/cfm-normatiza-uso-da-ia-na-medicina) |

**Track, but do not yet treat as law:** Marco Legal da Inteligência Artificial (bill).

## Typical AI scenarios and high-risk triggers

- Clinical documentation and ambient scribing
- Clinical decision support and diagnostic imaging triage
- Patient-facing triage and navigation assistants
- Claims, coding and revenue-cycle automation

**Pushes a system into a higher risk tier in Brazil:**

- AI that is or is part of a software medical device (TGA, HSA, ANVISA, ANMAT, PMDA, FDA device rules)
- Health data is special-category / sensitive data

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Brazil CFM Resolution 2.454/2026 on AI in medicine; CFM resolution on AI in medicine | · | · | ○ | ○ | · | · | · |
| **AIG-02** AI system and agent inventory | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ● | ○ | ○ | ● | ○ | · | ● |
| **AIG-03** Risk classification and impact assessment ★ | Brazil LGPD; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; CFM resolution on AI in medicine | · | · | ○ | ○ | · | · | · |
| **AIG-04** Data governance, quality and provenance | Brazil LGPD; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; ANVISA software as a medical device rules | · | · | ○ | ○ | · | · | ● |
| **AIG-05** Personal data protection and minimisation ★ | Brazil LGPD; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | ○ | ● | ○ | ● | ● | · | ● |
| **AIG-06** Approved models and AI supply chain | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ○ | ● | ● | ● | ● | ● | ● |
| **AIG-07** Workload and agent identity with least privilege | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Política Nacional de Cibersegurança | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-08** Network isolation and data residency | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ● | ● | ○ | ○ |
| **AIG-09** Encryption and key management ★ | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ○ | ● | · | ○ |
| **AIG-10** Runtime guardrails and content safety | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ○ | ● | ● | ○ | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions ★ | Brazil LGPD; ISO/IEC 42001:2023 AI management system; Zero trust; Brazil CFM Resolution 2.454/2026 on AI in medicine; CFM resolution on AI in medicine | · | ○ | ○ | ○ | ○ | · | ○ |
| **AIG-12** Transparency, notice and explanation ★ | ISO/IEC 42001:2023 AI management system; Brazil CFM Resolution 2.454/2026 on AI in medicine; CFM resolution on AI in medicine | · | · | ○ | ○ | · | ○ | · |
| **AIG-13** Logging, monitoring and record-keeping | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; Brazil CFM Resolution 2.454/2026 on AI in medicine; CFM resolution on AI in medicine | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; ANVISA software as a medical device rules | · | · | ○ | ○ | · | ○ | · |
| **AIG-15** Change management and model lifecycle ★ | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; ANVISA software as a medical device rules | · | ● | ● | ● | · | · | · |
| **AIG-16** Incident management and regulator notification | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Política Nacional de Cibersegurança | · | · | ● | ○ | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | ● | · | ○ | ○ | · | · | ● |
| **AIG-18** Cross-border transfer safeguards | Brazil LGPD; ISO/IEC 27001:2022 + Amd 1:2024; ANPD standard contractual clauses for international transfers | ● | · | ○ | ● | ● | ○ | ● |
| **AIG-19** AI literacy and training | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Plano Brasileiro de Inteligência Artificial 2024–2028 | · | · | ○ | ○ | · | · | · |
| **AIG-20** Fairness and non-discrimination ★ | ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`health.system.yaml`](health.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/br/health.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
