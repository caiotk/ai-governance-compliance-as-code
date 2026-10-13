# Portugal — Mining and resources

<sub>Generated from `catalog/` by `tools/build.py` · status as of 2026-10-13 · not legal advice.</sub>

## Frameworks applied

| Framework | Status | Verification |
|---|---|---|
| [EU AI Act — Regulation (EU) 2024/1689, as amended by Regulation (EU) 2026/1744](https://eur-lex.europa.eu/eli/reg/2024/1689/oj/eng) | In force (phased) | ✓ primary |
| [GDPR — Regulation (EU) 2016/679](https://eur-lex.europa.eu/eli/reg/2016/679/oj/eng) | In force | ✓ primary |
| [ISO/IEC 27001:2022 + Amd 1:2024](https://www.iso.org/standard/27001) | Organisational baseline (voluntary) | ✓ primary |
| [ISO/IEC 42001:2023 AI management system](https://www.iso.org/standard/81230.html) | Organisational baseline (voluntary) | ◐ secondary |
| [Zero trust (NIST SP 800-207, CISA ZTMM v2.0)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf) | Organisational baseline (voluntary) | ✓ primary |

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

### AI law and frameworks

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| AI Act national authorities — ANACOM (market surveillance, single point of contact) and 14 Art 77 fundamental-rights authorities | Designation Sep 2025 (legal instrument unverified) | In force | AIG-16 | [◐ secondary](https://cms.law/en/int/expert-guides/ai-regulation-scanner/portugal) |
| Agenda Nacional de Inteligência Artificial 2026–2030 | RCM 2/2026 | Voluntary | AIG-19 | [◐ secondary](https://cms.law/pt/prt/news-information/agenda-nacional-de-inteligencia-artificial-2026-2030) |
| Carta Portuguesa de Direitos Humanos na Era Digital (Art 9 AI) | Lei 27/2021 | In force | AIG-11, AIG-12, AIG-20 | [◐ secondary](https://www.lexmundi.com/guides/ai-legislative-guide/jurisdictions/europe/portugal/) |
| Labour Code amendment on algorithmic and AI employment decisions (all employers) | Lei 13/2023 | In force | AIG-12, AIG-20 | [◐ secondary](https://www.lexmundi.com/guides/ai-legislative-guide/jurisdictions/europe/portugal/) |

### Data protection

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| GDPR national execution law | Lei 58/2019 | In force | AIG-05, AIG-12, AIG-18 | [⚠ unverified](https://diariodarepublica.pt/dr/detalhe/lei/58-2019-123815982) |

### Cybersecurity

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Regime Jurídico da Cibersegurança (NIS2 transposition) | Decreto-Lei 125/2025 | In force · 2026-04-03 | AIG-07, AIG-13, AIG-16 | [◐ secondary](https://www.ecija.com/adcecija/novo-regime-juridico-da-ciberseguranca-entrou-em-vigor-em-portugal/) |

### Sector rules: Mining and resources

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| No AI-specific mining rule found | — | No specific rule | AIG-11, AIG-17 | [⚠ unverified](https://www.lexmundi.com/guides/ai-legislative-guide/jurisdictions/europe/portugal/) |

## Typical AI scenarios and high-risk triggers

- Autonomous haulage and drilling
- Predictive maintenance on fixed and mobile plant
- Geological and ore-body modelling
- Safety monitoring with computer vision (fatigue, proximity, exclusion zones)

**Pushes a system into a higher risk tier in Portugal:**

- Safety components of machinery (Machinery Regulation; AI Act Annex I Section B)
- Biometric or behavioural monitoring of workers (AI Act Annex III(4))
- Worker monitoring and safety-critical automation under general work health and safety law

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership | EU AI Act; GDPR; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | · | · | ○ | ○ | · | · | · |
| **AIG-02** AI system and agent inventory | EU AI Act; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ● | ○ | ○ | ● | ○ | · | ● |
| **AIG-03** Risk classification and impact assessment ★ | EU AI Act; GDPR; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | · |
| **AIG-04** Data governance, quality and provenance | EU AI Act; GDPR; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | · | ● |
| **AIG-05** Personal data protection and minimisation | EU AI Act; GDPR; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; GDPR national execution law | ○ | ● | ○ | ● | ● | · | ● |
| **AIG-06** Approved models and AI supply chain | EU AI Act; GDPR; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ○ | ● | ● | ● | ● | ● | ● |
| **AIG-07** Workload and agent identity with least privilege | EU AI Act; GDPR; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIS2 Directive; Regime Jurídico da Cibersegurança | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-08** Network isolation and data residency | EU AI Act; GDPR; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ● | ● | ○ | ○ |
| **AIG-09** Encryption and key management | GDPR; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust | ○ | ● | ● | ○ | ● | · | ○ |
| **AIG-10** Runtime guardrails and content safety | EU AI Act; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust | ○ | ● | ● | ○ | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions ★ | EU AI Act; GDPR; ISO/IEC 42001:2023 AI management system; Zero trust; Carta Portuguesa de Direitos Humanos na Era Digital | · | ○ | ○ | ○ | ○ | · | ○ |
| **AIG-12** Transparency, notice and explanation | EU AI Act; GDPR; ISO/IEC 42001:2023 AI management system; Carta Portuguesa de Direitos Humanos na Era Digital; Labour Code amendment on algorithmic and AI employment decisions; GDPR national execution law | · | · | ○ | ○ | · | ○ | · |
| **AIG-13** Logging, monitoring and record-keeping ★ | EU AI Act; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIS2 Directive; Regime Jurídico da Cibersegurança | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming ★ | EU AI Act; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | · | ○ | ○ | · | ○ | · |
| **AIG-15** Change management and model lifecycle ★ | EU AI Act; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | · | ● | ● | ● | · | · | · |
| **AIG-16** Incident management and regulator notification ★ | EU AI Act; GDPR; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIS2 Directive; AI Act national authorities — ANACOM; Regime Jurídico da Cibersegurança | · | · | ● | ○ | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit ★ | EU AI Act; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system | ● | · | ○ | ○ | · | · | ● |
| **AIG-18** Cross-border transfer safeguards | GDPR; ISO/IEC 27001:2022 + Amd 1:2024; GDPR national execution law | ● | · | ○ | ● | ● | ○ | ● |
| **AIG-19** AI literacy and training | EU AI Act; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Agenda Nacional de Inteligência Artificial 2026–2030 | · | · | ○ | ○ | · | · | · |
| **AIG-20** Fairness and non-discrimination | EU AI Act; GDPR; ISO/IEC 42001:2023 AI management system; Carta Portuguesa de Direitos Humanos na Era Digital; Labour Code amendment on algorithmic and AI employment decisions | · | · | ○ | ○ | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`mining.system.yaml`](mining.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/pt/mining.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
