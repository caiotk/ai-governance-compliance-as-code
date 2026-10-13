# Spain — Energy (oil, gas and electricity)

<sub>Generated from `catalog/` by `tools/build.py` · status as of 2026-10-13 · not legal advice.</sub>

> Spain's national AI law is a Proyecto de Ley Orgánica before the Congreso (BOCG 12 Jun 2026). NIS2 is not transposed; the Commission referred Spain to the CJEU on 8 Jul 2026.

## Frameworks applied

| Framework | Status | Verification |
|---|---|---|
| [EU AI Act — Regulation (EU) 2024/1689, as amended by Regulation (EU) 2026/1744](https://eur-lex.europa.eu/eli/reg/2024/1689/oj/eng) | In force (phased) | ✓ primary |
| [GDPR — Regulation (EU) 2016/679](https://eur-lex.europa.eu/eli/reg/2016/679/oj/eng) | In force | ✓ primary |
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


### AI law and frameworks (inherited from European Union (shared layer))

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Artificial Intelligence Act | Regulation (EU) 2024/1689 as amended by Regulation (EU) 2026/1744 | Phased · Prohibitions 2025-02-02; GPAI 2025-08-02; Art 50 2026-08-02; Annex III high-risk 2027-12-02; Annex I 2028-08-02 | AIG-01, AIG-02, AIG-03, AIG-04, AIG-10, AIG-11, AIG-12, AIG-13, AIG-14, AIG-16, AIG-19, AIG-20 | [✓ primary](https://eur-lex.europa.eu/eli/reg/2024/1689/oj/eng) |

### Data protection (inherited from European Union (shared layer))

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| General Data Protection Regulation | Regulation (EU) 2016/679 | In force · 2018-05-25 | AIG-03, AIG-04, AIG-05, AIG-11, AIG-12, AIG-16, AIG-18 | [✓ primary](https://eur-lex.europa.eu/eli/reg/2016/679/oj/eng) |

### Cybersecurity (inherited from European Union (shared layer))

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| NIS2 Directive | Directive (EU) 2022/2555 | In force · National transposition varies (Portugal DL 125/2025 in force; Spain not transposed) | AIG-07, AIG-13, AIG-16 | [⚠ unverified](https://eur-lex.europa.eu/eli/dir/2022/2555/oj) |

### Sector rules: Energy (oil, gas and electricity) (inherited from European Union (shared layer))

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| NIS2 Directive Annex I "Energy" — electricity, district heating, oil, gas and hydrogen entities; Art 21 measures, Art 20 management accountability, Art 23 reporting 24 h / 72 h / 1 month | Directive (EU) 2022/2555, OJ L 333/80 | In force · applies from 2024-10-18 (national transposition) | AIG-01, AIG-06, AIG-07, AIG-13, AIG-16 | [✓ primary](https://eur-lex.europa.eu/eli/dir/2022/2555/oj) |
| Network Code on Cybersecurity for the electricity sector (NCCS) — Commission Delegated Regulation (EU) 2024/1366; high-impact/critical-impact entities, CSOC capabilities and 4-hour reporting of reportable cyber-attacks (Art 38) | Delegated Regulation (EU) 2024/1366, OJ L 2024/1366 | In force (phased) · in force 2024-06-13; methodologies and entity identification phased | AIG-06, AIG-13, AIG-16 | [✓ primary](https://eur-lex.europa.eu/eli/reg_del/2024/1366/oj) |
| CER Directive (EU) 2022/2557 — critical entities in energy identified by 17 Jul 2026; resilience measures and incident notification (Art 15) | Directive (EU) 2022/2557, OJ L 333/164 | In force · critical entities identified by 2026-07-17 | AIG-16, AIG-17 | [✓ primary](https://eur-lex.europa.eu/eli/dir/2022/2557/oj) |
| EU AI Act Annex III(2) — AI systems intended as safety components in the management and operation of critical digital infrastructure or in the supply of water, gas, heating or electricity (high-risk) | Regulation (EU) 2024/1689, Annex III point 2 | Phased · Annex III obligations apply from 2027-12-02 (as amended by Reg (EU) 2026/1744) | AIG-03, AIG-04, AIG-11, AIG-13, AIG-14 | [✓ primary](https://eur-lex.europa.eu/eli/reg/2024/1689/oj) |
| REMIT (Regulation (EU) 1227/2011 as amended by Regulation (EU) 2024/1106) — wholesale energy market integrity, algorithmic trading | — | In force | AIG-11, AIG-13 | [◐ secondary](https://eur-lex.europa.eu/eli/reg/2024/1106/oj) |

### AI law and frameworks

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Proyecto de Ley Orgánica para el buen uso y la gobernanza de la inteligencia artificial | BOCG 15-A-97-1 (2026-06-12) | Pending — not law | AIG-01, AIG-02, AIG-03 | [✓ primary](https://www.congreso.es/public_oficiales/L15/CONG/BOCG/A/BOCG-15-A-97-1.PDF) |
| AESIA — Agencia Española de Supervisión de la Inteligencia Artificial | Market surveillance authority and single point of contact | In force | AIG-16 | [◐ secondary](https://www.osborneclarke.com/es/insights/espana-avanza-en-la-regulacion-de-la-ia-claves-de-la-nueva-ley-organica-de-gobernanza) |

### Data protection

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Ley Orgánica de Protección de Datos Personales y garantía de los derechos digitales | LO 3/2018 | In force | AIG-05, AIG-12, AIG-18 | [⚠ unverified](https://www.boe.es/eli/es/lo/2018/12/05/3/con) |

### Cybersecurity

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Esquema Nacional de Seguridad and NIS1-era law (NIS2 not transposed) | RD 311/2022 (ENS); RDL 12/2018; RD 43/2021 | In force | AIG-07, AIG-13, AIG-16 | [◐ secondary](https://www.legiscope.com/blog/nis2-espana-transposicion.html) |

### Sector rules: Energy (oil, gas and electricity)

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Ley 8/2011 de protección de las infraestructuras críticas (PIC) — critical operators in energy, Plan de Seguridad del Operador, Planes de Protección Específicos | BOE núm. 102, 29/04/2011 | In force | AIG-01, AIG-16, AIG-17 | [✓ primary](https://www.boe.es/buscar/act.php?id=BOE-A-2011-7630) |
| Real Decreto 43/2021 (desarrollo del RDL 12/2018 NIS) — Declaración de Aplicabilidad, responsable de seguridad, Art 9 notification of critical/very high/high incidents via the CSIRT de referencia | BOE núm. 24, 28/01/2021 | In force · 2021-01-29; NIS2 transposition pending (CJEU referral 2026-07-08) | AIG-01, AIG-13, AIG-16 | [✓ primary](https://www.boe.es/buscar/act.php?id=BOE-A-2021-1192) |
| CNMC supervision of electricity and gas markets (Ley 24/2013, Ley 34/1998) and REMIT algorithmic-trading surveillance | — | In force | AIG-11, AIG-13 | [◐ secondary](https://www.cnmc.es/ambitos-de-actuacion/energia) |

**Track, but do not yet treat as law:** Proyecto de Ley Orgánica para el buen uso y la gobernanza de la inteligencia artificial.

## Typical AI scenarios and high-risk triggers

- Load, renewable-output and inflow forecasting feeding scheduling and dispatch
- Dispatch, balancing and curtailment recommendations to control-room operators
- Predictive maintenance on generation, transmission, pipeline and refinery assets
- Outage management, restoration prioritisation and vegetation/asset inspection with computer vision
- Wholesale trading, bidding and nomination algorithms
- Safety monitoring on rigs, plants and pipelines (leak and methane detection, alarm triage)
- Customer service, billing and demand-response on smart-meter data

**Pushes a system into a higher risk tier in Spain:**

- AI as a safety component in the supply of water, gas, heating or electricity (AI Act Annex III(2))
- AI that generates or executes wholesale bids, offers or nominations (REMIT, NER bidding rules, EA Code Part 13, FERC 18 CFR 1c, CAMMESA, CCEE, JEPX, NEMS)
- AI advising control-room operators or automating actions on energised plant, pipelines or rigs — human control and alarm management must be preserved

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | mistral | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership | EU AI Act; GDPR; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; Anthropic; NIS2 Directive Annex I "Energy" — electricity, district heating, oil, gas and hydrogen entities; Art 21 measures, Art 20 management accountability, Art 23 reporting 24 h / 72 h / 1 month; Ley 8/2011 de protección de las infraestructuras críticas; Real Decreto 43/2021 | · | · | ○ | ○ | · | · | · | · |
| **AIG-02** AI system and agent inventory | EU AI Act; Energy critical-infrastructure and incident-reporting regimes; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | ● | ○ | ○ | ● | ○ | · | ● | ● |
| **AIG-03** Risk classification and impact assessment | EU AI Act; GDPR; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; EU AI Act Annex III(2) — AI systems intended as safety components in the management and operation of critical digital infrastructure or in the supply of water, gas, heating or electricity | · | · | ○ | ○ | · | · | · | · |
| **AIG-04** Data governance, quality and provenance | EU AI Act; GDPR; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; EU AI Act Annex III(2) — AI systems intended as safety components in the management and operation of critical digital infrastructure or in the supply of water, gas, heating or electricity | · | · | ○ | ○ | · | · | · | ● |
| **AIG-05** Personal data protection and minimisation | EU AI Act; GDPR; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Ley Orgánica de Protección de Datos Personales y garantía de los derechos digitales | ○ | ● | ○ | ● | ● | · | ○ | ● |
| **AIG-06** Approved models and AI supply chain ★ | EU AI Act; GDPR; Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework; NIS2 Directive Annex I "Energy" — electricity, district heating, oil, gas and hydrogen entities; Art 21 measures, Art 20 management accountability, Art 23 reporting 24 h / 72 h / 1 month; Network Code on Cybersecurity for the electricity sector | ○ | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-07** Workload and agent identity with least privilege ★ | EU AI Act; GDPR; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; NIS2 Directive; NIS2 Directive Annex I "Energy" — electricity, district heating, oil, gas and hydrogen entities; Art 21 measures, Art 20 management accountability, Art 23 reporting 24 h / 72 h / 1 month; Esquema Nacional de Seguridad and NIS1-era law | ● | ● | ● | ● | ● | ○ | ● | ● |
| **AIG-08** Network isolation and data residency ★ | EU AI Act; GDPR; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | ○ | ● | ● | ● | ● | ○ | ○ | ○ |
| **AIG-09** Encryption and key management | GDPR; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust; MITRE ATLAS; Anthropic | ○ | ● | ● | ○ | ● | · | ○ | ○ |
| **AIG-10** Runtime guardrails and content safety | EU AI Act; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | ○ | ● | ● | ○ | ● | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions ★ | EU AI Act; GDPR; Energy critical-infrastructure and incident-reporting regimes; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; EU AI Act Annex III(2) — AI systems intended as safety components in the management and operation of critical digital infrastructure or in the supply of water, gas, heating or electricity; REMIT; CNMC supervision of electricity and gas markets | · | ○ | ○ | ○ | ○ | · | ○ | ○ |
| **AIG-12** Transparency, notice and explanation | EU AI Act; GDPR; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; Ley Orgánica de Protección de Datos Personales y garantía de los derechos digitales | · | · | ○ | ○ | · | ○ | · | · |
| **AIG-13** Logging, monitoring and record-keeping ★ | EU AI Act; Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework; Business continuity and disaster recovery for AI services; NIS2 Directive; NIS2 Directive Annex I "Energy" — electricity, district heating, oil, gas and hydrogen entities; Art 21 measures, Art 20 management accountability, Art 23 reporting 24 h / 72 h / 1 month; Network Code on Cybersecurity for the electricity sector; EU AI Act Annex III(2) — AI systems intended as safety components in the management and operation of critical digital infrastructure or in the supply of water, gas, heating or electricity; REMIT; Esquema Nacional de Seguridad and NIS1-era law; Real Decreto 43/2021; CNMC supervision of electricity and gas markets | ● | ● | ● | ● | ● | ○ | ● | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming | EU AI Act; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; EU AI Act Annex III(2) — AI systems intended as safety components in the management and operation of critical digital infrastructure or in the supply of water, gas, heating or electricity | · | · | ○ | ○ | · | ○ | ● | · |
| **AIG-15** Change management and model lifecycle ★ | EU AI Act; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; MITRE ATLAS | · | ● | ● | ● | · | · | · | · |
| **AIG-16** Incident management and regulator notification ★ | EU AI Act; GDPR; Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; Anthropic; Business continuity and disaster recovery for AI services; NIS2 Directive; NIS2 Directive Annex I "Energy" — electricity, district heating, oil, gas and hydrogen entities; Art 21 measures, Art 20 management accountability, Art 23 reporting 24 h / 72 h / 1 month; Network Code on Cybersecurity for the electricity sector; CER Directive; AESIA — Agencia Española de Supervisión de la Inteligencia Artificial; Esquema Nacional de Seguridad and NIS1-era law; Ley 8/2011 de protección de las infraestructuras críticas; Real Decreto 43/2021 | · | · | ● | ○ | · | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit ★ | EU AI Act; Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; FinOps Framework; Business continuity and disaster recovery for AI services; CER Directive; Ley 8/2011 de protección de las infraestructuras críticas | ● | · | ○ | ○ | · | · | ○ | ● |
| **AIG-18** Cross-border transfer safeguards | GDPR; ISO/IEC 27001:2022 + Amd 1:2024; Ley Orgánica de Protección de Datos Personales y garantía de los derechos digitales | ● | · | ○ | ● | ● | ○ | ● | ● |
| **AIG-19** AI literacy and training | EU AI Act; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO 19011:2026 Guidelines for auditing management systems; MITRE ATLAS | · | · | ○ | ○ | · | · | · | · |
| **AIG-20** Fairness and non-discrimination | EU AI Act; GDPR; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment | · | · | ○ | ○ | · | · | · | · |
| **AIG-21** Internal audit and independent assurance | EU AI Act; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO 19011:2026 Guidelines for auditing management systems | · | · | · | · | · | · | · | · |
| **AIG-22** AI FinOps — token budgets, consumption limits and cost allocation | EU AI Act; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework | · | · | · | · | · | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`energy.system.yaml`](energy.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/es/energy.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
