# Chile — Energy (oil, gas and electricity)

<sub>Generated from `catalog/` by `tools/build.py` · status as of 2026-10-13 · not legal advice.</sub>

> The AI bill is in the Senate and the government plans an innovation-first substitute text. Ley 21.719 is due in force 1 Dec 2026, but bill 18.623-07 would postpone it.

## Frameworks applied

| Framework | Status | Verification |
|---|---|---|
| [Chile Ley 21.719 personal data protection](https://www.cariola.cl/app/uploads/2026/09/Alerta-legal_-2septiembre.pdf) | Phased | ◐ secondary |
| [Chile Ley 21.663 Ley Marco de Ciberseguridad](https://www.leychile.cl/Consulta/obtxml?opt=7&idNorma=1202434) — operators of vital importance / critical infrastructure only | In force | ✓ primary |
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

### Sector rules: Energy (oil, gas and electricity)

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Ley 21.663 — energy generation, transmission, distribution, fuel transport/storage/distribution and the Coordinador Eléctrico as essential services; OIV duties (Art 8) and reporting 3 h / 72 h (24 h for OIV) / 15 days (Art 9) | Ley 21.663, D.O. 2024-04-08, Arts 4-9, 28, 40 | In force | AIG-01, AIG-13, AIG-16, AIG-17, AIG-21 | [✓ primary](https://www.leychile.cl/Consulta/obtxml?opt=7&idNorma=1202434) |
| Norma Técnica de Seguridad y Calidad de Servicio (CNE) — grid security and quality obligations on the Coordinador and coordinated entities | Res. Ex. 299/2018 as amended to Res. Ex. 45/2026 (versión enero 2026) | In force | AIG-11, AIG-15, AIG-17 | [✓ primary](https://www.cne.cl/normativas/electrica/normas-tecnicas/) |
| Coordinador Eléctrico Nacional — Estándar de Ciberseguridad para el Sistema Eléctrico Nacional | — | In force | AIG-07, AIG-08, AIG-13 | [⚠ unverified](https://www.coordinador.cl/) |

**Track, but do not yet treat as law:** Proyecto de ley que regula los sistemas de inteligencia artificial.

## Typical AI scenarios and high-risk triggers

- Load, renewable-output and inflow forecasting feeding scheduling and dispatch
- Dispatch, balancing and curtailment recommendations to control-room operators
- Predictive maintenance on generation, transmission, pipeline and refinery assets
- Outage management, restoration prioritisation and vegetation/asset inspection with computer vision
- Wholesale trading, bidding and nomination algorithms
- Safety monitoring on rigs, plants and pipelines (leak and methane detection, alarm triage)
- Customer service, billing and demand-response on smart-meter data

**Pushes a system into a higher risk tier in Chile:**

- AI in the control-centre or operational data scope of an operator of vital importance (Ley 21.663 Art 8) or inside ONS ARCiber
- AI that generates or executes wholesale bids, offers or nominations (REMIT, NER bidding rules, EA Code Part 13, FERC 18 CFR 1c, CAMMESA, CCEE, JEPX, NEMS)
- AI advising control-room operators or automating actions on energised plant, pipelines or rigs — human control and alarm management must be preserved

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | mistral | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; Anthropic; Política Nacional de Inteligencia Artificial; Ley 21.663 — energy generation, transmission, distribution, fuel transport/storage/distribution and the Coordinador Eléctrico as essential services; OIV duties | · | · | ○ | ○ | · | · | · | · |
| **AIG-02** AI system and agent inventory | Energy critical-infrastructure and incident-reporting regimes; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | ● | ○ | ○ | ● | ○ | · | ● | ● |
| **AIG-03** Risk classification and impact assessment | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; Ley de Protección de Datos Personales | · | · | ○ | ○ | · | · | · | · |
| **AIG-04** Data governance, quality and provenance | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | · | · | ○ | ○ | · | · | · | ● |
| **AIG-05** Personal data protection and minimisation | Chile Ley 21.719 personal data protection; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Ley de Protección de Datos Personales | ○ | ● | ○ | ● | ● | · | ○ | ● |
| **AIG-06** Approved models and AI supply chain ★ | Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework | ○ | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-07** Workload and agent identity with least privilege ★ | Chile Ley 21.663 Ley Marco de Ciberseguridad; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; Ley Marco de Ciberseguridad; Coordinador Eléctrico Nacional — Estándar de Ciberseguridad para el Sistema Eléctrico Nacional | ● | ● | ● | ● | ● | ○ | ● | ● |
| **AIG-08** Network isolation and data residency ★ | IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; Coordinador Eléctrico Nacional — Estándar de Ciberseguridad para el Sistema Eléctrico Nacional | ○ | ● | ● | ● | ● | ○ | ○ | ○ |
| **AIG-09** Encryption and key management | ISO/IEC 27001:2022 + Amd 1:2024; Zero trust; MITRE ATLAS; Anthropic | ○ | ● | ● | ○ | ● | · | ○ | ○ |
| **AIG-10** Runtime guardrails and content safety | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | ○ | ● | ● | ○ | ● | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions ★ | Chile Ley 21.719 personal data protection; Energy critical-infrastructure and incident-reporting regimes; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; Ley de Protección de Datos Personales; Norma Técnica de Seguridad y Calidad de Servicio | · | ○ | ○ | ○ | ○ | · | ○ | ○ |
| **AIG-12** Transparency, notice and explanation | Chile Ley 21.719 personal data protection; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; Ley de Protección de Datos Personales | · | · | ○ | ○ | · | ○ | · | · |
| **AIG-13** Logging, monitoring and record-keeping ★ | Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework; Business continuity and disaster recovery for AI services; Ley Marco de Ciberseguridad; Ley 21.663 — energy generation, transmission, distribution, fuel transport/storage/distribution and the Coordinador Eléctrico as essential services; OIV duties; Coordinador Eléctrico Nacional — Estándar de Ciberseguridad para el Sistema Eléctrico Nacional | ● | ● | ● | ● | ● | ○ | ● | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | · | · | ○ | ○ | · | ○ | ● | · |
| **AIG-15** Change management and model lifecycle ★ | IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; MITRE ATLAS; Norma Técnica de Seguridad y Calidad de Servicio | · | ● | ● | ● | · | · | · | · |
| **AIG-16** Incident management and regulator notification ★ | Chile Ley 21.663 Ley Marco de Ciberseguridad; Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; Anthropic; Business continuity and disaster recovery for AI services; Ley Marco de Ciberseguridad; Ley 21.663 — energy generation, transmission, distribution, fuel transport/storage/distribution and the Coordinador Eléctrico as essential services; OIV duties | · | · | ● | ○ | · | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit ★ | Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; FinOps Framework; Business continuity and disaster recovery for AI services; Ley 21.663 — energy generation, transmission, distribution, fuel transport/storage/distribution and the Coordinador Eléctrico as essential services; OIV duties; Norma Técnica de Seguridad y Calidad de Servicio | ● | · | ○ | ○ | · | · | ○ | ● |
| **AIG-18** Cross-border transfer safeguards | Chile Ley 21.719 personal data protection; ISO/IEC 27001:2022 + Amd 1:2024; Ley de Protección de Datos Personales | ● | · | ○ | ● | ● | ○ | ● | ● |
| **AIG-19** AI literacy and training | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO 19011:2026 Guidelines for auditing management systems; MITRE ATLAS; Política Nacional de Inteligencia Artificial | · | · | ○ | ○ | · | · | · | · |
| **AIG-20** Fairness and non-discrimination | ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment | · | · | ○ | ○ | · | · | · | · |
| **AIG-21** Internal audit and independent assurance | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO 19011:2026 Guidelines for auditing management systems; Ley 21.663 — energy generation, transmission, distribution, fuel transport/storage/distribution and the Coordinador Eléctrico as essential services; OIV duties | · | · | · | · | · | · | · | · |
| **AIG-22** AI FinOps — token budgets, consumption limits and cost allocation | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework | · | · | · | · | · | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`energy.system.yaml`](energy.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/cl/energy.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
