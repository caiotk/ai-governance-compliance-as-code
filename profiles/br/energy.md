# Brazil — Energy (oil, gas and electricity)

<sub>Generated from `catalog/` by `tools/build.py` · status as of 2026-10-13 · not legal advice.</sub>

> No AI statute in force. PL 2338/2023 passed the Senate (Dec 2024) and sits with a Chamber special committee; a vote is expected after the Oct 2026 elections.

## Frameworks applied

| Framework | Status | Verification |
|---|---|---|
| [Brazil LGPD — Lei 13.709/2018](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm) | In force | ✓ primary |
| [Energy critical-infrastructure and incident-reporting regimes (national)](https://github.com/caiotk/ai-governance-compliance-as-code/blob/main/docs/sources/energy-sector.md) | In force | ✓ primary |
| [IEC 62443 — Security for industrial automation and control systems (2-1:2024, 2-4:2015+AMD1:2017, 3-3:2013, 4-1:2018, 4-2:2019)](https://webstore.iec.ch/en/publication/62883) | Voluntary | ✓ primary |
| [ISO/IEC 27019:2024 — Information security controls for the energy utility industry](https://www.iso.org/standard/85056.html) | Voluntary | ✓ primary |
| [ISO/IEC 27001:2022 + Amd 1:2024](https://www.iso.org/standard/27001) | Organisational baseline (voluntary) | ✓ primary |
| [ISO/IEC 42001:2023 AI management system](https://www.iso.org/standard/81230.html) | Organisational baseline (voluntary) | ◐ secondary |
| [Zero trust (NIST SP 800-207, CISA ZTMM v2.0)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf) | Organisational baseline (voluntary) | ✓ primary |
| [NIST AI Risk Management Framework 1.0 + Generative AI Profile](https://www.nist.gov/itl/ai-risk-management-framework) | Organisational baseline (voluntary) | ✓ primary |
| [NIST SP 800-61 Rev. 3 — Incident Response Recommendations and Considerations for Cybersecurity Risk Management (CSF 2.0 Community Profile)](https://csrc.nist.gov/pubs/sp/800/61/r3/final) | Organisational baseline (voluntary) | ✓ primary |
| [ISO 19011:2026 Guidelines for auditing management systems](https://www.iso.org/standard/19011) | Organisational baseline (voluntary) | ✓ primary |
| [ISO/IEC 42005:2025 AI system impact assessment](https://www.iso.org/standard/44545.html) | Organisational baseline (voluntary) | ✓ primary |
| [OWASP GenAI Security Project — LLM Top 10 (2026) and Top 10 for Agentic Applications](https://genai.owasp.org/llm-top-10/) | Organisational baseline (voluntary) | ✓ primary |
| [MITRE ATLAS (release 2026.09)](https://atlas.mitre.org/) | Organisational baseline (voluntary) | ✓ primary |
| [Anthropic — Zero Trust for AI Agents (eBook and CISO guidance)](https://claude.com/blog/zero-trust-for-ai-agents) | Organisational baseline (voluntary) | ✓ primary |
| [FinOps Framework (FinOps Foundation) — FinOps for AI](https://www.finops.org/wg/finops-for-ai-overview/) | Organisational baseline (voluntary) | ✓ primary |
| [Business continuity and disaster recovery for AI services (NIST SP 800-34 Rev. 1, NIST CSF 2.0 RC/PR.IR, ISO 22301:2019)](https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-34r1.pdf) | Organisational baseline (voluntary) | ✓ primary |

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

### Sector rules: Energy (oil, gas and electricity)

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Resolução Normativa ANEEL nº 964/2021 — política de segurança cibernética do setor elétrico (notification of higher-impact cyber incidents to the sector coordination team) | REN 964, de 10 de dezembro de 2021 | In force | AIG-01, AIG-13, AIG-16 | [✓ primary](https://www.gov.br/aneel/pt-br/assuntos/seguranca/seguranca-cibernetica) |
| ONS Procedimentos de Rede — controles de segurança cibernética do Ambiente Regulado Cibernético (ARCiber) for control centres and operational data links | PdR 2020.12 (REN ANEEL 903/2020), in force 2021-01-01; submódulo number unverified | In force | AIG-07, AIG-08, AIG-13 | [✓ primary](https://www.ons.org.br/paginas/sobre-o-ons/procedimentos-de-rede/vigentes) |
| ANP operational safety regime — RANP 43/2007 (SGSO), 41/2015, 46/2016, 851/2021 and RANP 882/2022 incident communication (investigation report within 90 days) | RANP 43/2007; RANP 882/2022 | In force | AIG-03, AIG-11, AIG-15, AIG-16 | [✓ primary](https://www.gov.br/anp/pt-br/assuntos/exploracao-e-producao-de-oleo-e-gas/seguranca-operacional/resolucoes-procedimentos) |
| CNPE Resoluções nº 1/2021 and nº 24/2021 and Decreto 9.573/2018 (Política Nacional de Segurança de Infraestruturas Críticas) | — | In force | AIG-01, AIG-16 | [✓ primary](https://www.gov.br/aneel/pt-br/assuntos/seguranca/seguranca-cibernetica) |

**Track, but do not yet treat as law:** Marco Legal da Inteligência Artificial (bill).

## Typical AI scenarios and high-risk triggers

- Load, renewable-output and inflow forecasting feeding scheduling and dispatch
- Dispatch, balancing and curtailment recommendations to control-room operators
- Predictive maintenance on generation, transmission, pipeline and refinery assets
- Outage management, restoration prioritisation and vegetation/asset inspection with computer vision
- Wholesale trading, bidding and nomination algorithms
- Safety monitoring on rigs, plants and pipelines (leak and methane detection, alarm triage)
- Customer service, billing and demand-response on smart-meter data

**Pushes a system into a higher risk tier in Brazil:**

- AI in the control-centre or operational data scope of an operator of vital importance (Ley 21.663 Art 8) or inside ONS ARCiber
- AI that generates or executes wholesale bids, offers or nominations (REMIT, NER bidding rules, EA Code Part 13, FERC 18 CFR 1c, CAMMESA, CCEE, JEPX, NEMS)
- AI advising control-room operators or automating actions on energised plant, pipelines or rigs — human control and alarm management must be preserved

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | mistral | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; Anthropic; Resolução Normativa ANEEL nº 964/2021 — política de segurança cibernética do setor elétrico; CNPE Resoluções nº 1/2021 and nº 24/2021 and Decreto 9.573/2018 | · | · | ○ | ○ | · | · | · | · |
| **AIG-02** AI system and agent inventory | Energy critical-infrastructure and incident-reporting regimes; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | ● | ○ | ○ | ● | ○ | · | ● | ● |
| **AIG-03** Risk classification and impact assessment | Brazil LGPD; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; ANP operational safety regime — RANP 43/2007 | · | · | ○ | ○ | · | · | · | · |
| **AIG-04** Data governance, quality and provenance | Brazil LGPD; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | · | · | ○ | ○ | · | · | · | ● |
| **AIG-05** Personal data protection and minimisation | Brazil LGPD; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS | ○ | ● | ○ | ● | ● | · | ○ | ● |
| **AIG-06** Approved models and AI supply chain ★ | Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework | ○ | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-07** Workload and agent identity with least privilege ★ | IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; Política Nacional de Cibersegurança; ONS Procedimentos de Rede — controles de segurança cibernética do Ambiente Regulado Cibernético | ● | ● | ● | ● | ● | ○ | ● | ● |
| **AIG-08** Network isolation and data residency ★ | IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; ONS Procedimentos de Rede — controles de segurança cibernética do Ambiente Regulado Cibernético | ○ | ● | ● | ● | ● | ○ | ○ | ○ |
| **AIG-09** Encryption and key management | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust; MITRE ATLAS; Anthropic | ○ | ● | ● | ○ | ● | · | ○ | ○ |
| **AIG-10** Runtime guardrails and content safety | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | ○ | ● | ● | ○ | ● | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions ★ | Brazil LGPD; Energy critical-infrastructure and incident-reporting regimes; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; ANP operational safety regime — RANP 43/2007 | · | ○ | ○ | ○ | ○ | · | ○ | ○ |
| **AIG-12** Transparency, notice and explanation | ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project | · | · | ○ | ○ | · | ○ | · | · |
| **AIG-13** Logging, monitoring and record-keeping ★ | Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework; Business continuity and disaster recovery for AI services; Resolução Normativa ANEEL nº 964/2021 — política de segurança cibernética do setor elétrico; ONS Procedimentos de Rede — controles de segurança cibernética do Ambiente Regulado Cibernético | ● | ● | ● | ● | ● | ○ | ● | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | · | · | ○ | ○ | · | ○ | ● | · |
| **AIG-15** Change management and model lifecycle ★ | IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; MITRE ATLAS; ANP operational safety regime — RANP 43/2007 | · | ● | ● | ● | · | · | · | · |
| **AIG-16** Incident management and regulator notification ★ | Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; Anthropic; Business continuity and disaster recovery for AI services; Política Nacional de Cibersegurança; Resolução Normativa ANEEL nº 964/2021 — política de segurança cibernética do setor elétrico; ANP operational safety regime — RANP 43/2007; CNPE Resoluções nº 1/2021 and nº 24/2021 and Decreto 9.573/2018 | · | · | ● | ○ | · | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit ★ | Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; FinOps Framework; Business continuity and disaster recovery for AI services | ● | · | ○ | ○ | · | · | ○ | ● |
| **AIG-18** Cross-border transfer safeguards | Brazil LGPD; ISO/IEC 27001:2022 + Amd 1:2024; ANPD standard contractual clauses for international transfers | ● | · | ○ | ● | ● | ○ | ● | ● |
| **AIG-19** AI literacy and training | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO 19011:2026 Guidelines for auditing management systems; MITRE ATLAS; Plano Brasileiro de Inteligência Artificial 2024–2028 | · | · | ○ | ○ | · | · | · | · |
| **AIG-20** Fairness and non-discrimination | ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment | · | · | ○ | ○ | · | · | · | · |
| **AIG-21** Internal audit and independent assurance | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO 19011:2026 Guidelines for auditing management systems | · | · | · | · | · | · | · | · |
| **AIG-22** AI FinOps — token budgets, consumption limits and cost allocation | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework | · | · | · | · | · | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`energy.system.yaml`](energy.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/br/energy.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
