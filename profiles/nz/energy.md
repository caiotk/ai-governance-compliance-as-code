# New Zealand — Energy (oil, gas and electricity)

<sub>Generated from `catalog/` by `tools/build.py` · status as of 2026-10-13 · not legal advice.</sub>

> No AI-specific statute; the AI Strategy (Jul 2025) is adoption-first. BS11 applies only to NZ-incorporated registered banks with liabilities ≥ NZ$10bn.

## Frameworks applied

| Framework | Status | Verification |
|---|---|---|
| [New Zealand Privacy Act 2020 (IPPs) incl. IPP 3A and Biometric Processing Privacy Code 2025](https://www.privacy.org.nz/resources-and-learning/a-z-topics/ipp3a/) | In force (phased) | ✓ primary |
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
| New Zealand's Strategy for AI — Investing with confidence; Responsible AI Guidance for Businesses | MBIE, 8 Jul 2025 | Voluntary | AIG-01, AIG-03, AIG-19 | [✓ primary](https://www.mbie.govt.nz/about/news/artificial-intelligence-strategy-and-business-guidance-now-available) |

### Data protection

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Privacy Act 2020 — Information Privacy Principles incl. IPP 3A | Privacy Act 2020 (2020 No 31); Privacy Amendment Act 2025 | Phased · IPP 3A from 2026-05-01 | AIG-03, AIG-04, AIG-05, AIG-08, AIG-12, AIG-16, AIG-18 | [✓ primary](https://www.privacy.org.nz/resources-and-learning/a-z-topics/ipp3a/) |
| Biometric Processing Privacy Code 2025 | — | In force · New processing 2025-11-03; existing processing 2026-08-03 | AIG-03, AIG-05, AIG-12 | [✓ primary](https://www.privacy.org.nz/assets/Codes-of-Practice-2020/Biometrics-Processing-Privacy-Code-2025-website-version.pdf) |

### Cybersecurity

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| No NIS-style cyber statute; NZ Information Security Manual (NZISM) applies to government agencies | — | No specific rule | AIG-07 | [⚠ unverified](https://nzism.gcsb.govt.nz/) |

### Sector rules: Energy (oil, gas and electricity)

| Instrument | Citation | Status / effective | Drives controls | Source |
|---|---|---|---|---|
| Electricity Industry Act 2010 and Electricity Industry Participation Code 2010 (Part 8 system operator security, Part 10 metering, Part 13 dispatch and offers) | 2010 No 116; Code amendment on battery energy storage effective 2026-10-30 / 2028-03-31 | In force | AIG-11, AIG-13, AIG-15 | [✓ primary](https://www.ea.govt.nz/code-and-compliance/the-code/) |
| Gas Act 1992 and gas governance rules incl. critical contingency management | — | In force | AIG-16, AIG-17 | [✓ primary](https://www.gasindustry.co.nz/about-us/legislative-framework/) |
| Critical infrastructure resilience legislation (DPMC policy work; minimum resilience standards and incident reporting for energy) | — | Proposed | AIG-16, AIG-17 | [⚠ unverified](https://www.dpmc.govt.nz/) |
| NCSC (GCSB) cyber security guidance for operational technology | — | Voluntary | AIG-08, AIG-13 | [⚠ unverified](https://www.ncsc.govt.nz/) |

**Track, but do not yet treat as law:** Critical infrastructure resilience legislation (DPMC policy work; minimum resilience standards and incident reporting for energy).

## Typical AI scenarios and high-risk triggers

- Load, renewable-output and inflow forecasting feeding scheduling and dispatch
- Dispatch, balancing and curtailment recommendations to control-room operators
- Predictive maintenance on generation, transmission, pipeline and refinery assets
- Outage management, restoration prioritisation and vegetation/asset inspection with computer vision
- Wholesale trading, bidding and nomination algorithms
- Safety monitoring on rigs, plants and pipelines (leak and methane detection, alarm triage)
- Customer service, billing and demand-response on smart-meter data

**Pushes a system into a higher risk tier in New Zealand:**

- AI that generates or executes wholesale bids, offers or nominations (REMIT, NER bidding rules, EA Code Part 13, FERC 18 CFR 1c, CAMMESA, CCEE, JEPX, NEMS)
- AI advising control-room operators or automating actions on energised plant, pipelines or rigs — human control and alarm management must be preserved

## Required controls

★ = emphasised for this sector (stricter evidence expected).

| Control | Driven by | anthropic-claude | aws-bedrock | azure-foundry | copilot-studio | gcp-vertex | meta-llama | mistral | openai |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **AIG-01** AI governance, policy and accountable ownership | New Zealand Privacy Act 2020; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; Anthropic; New Zealand's Strategy for AI — Investing with confidence; Responsible AI Guidance for Businesses | · | · | ○ | ○ | · | · | · | · |
| **AIG-02** AI system and agent inventory | New Zealand Privacy Act 2020; Energy critical-infrastructure and incident-reporting regimes; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | ● | ○ | ○ | ● | ○ | · | ● | ● |
| **AIG-03** Risk classification and impact assessment | New Zealand Privacy Act 2020; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; New Zealand's Strategy for AI — Investing with confidence; Responsible AI Guidance for Businesses; Biometric Processing Privacy Code 2025 | · | · | ○ | ○ | · | · | · | · |
| **AIG-04** Data governance, quality and provenance | New Zealand Privacy Act 2020; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | · | · | ○ | ○ | · | · | · | ● |
| **AIG-05** Personal data protection and minimisation | New Zealand Privacy Act 2020; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Biometric Processing Privacy Code 2025 | ○ | ● | ○ | ● | ● | · | ○ | ● |
| **AIG-06** Approved models and AI supply chain ★ | Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework | ○ | ● | ● | ● | ● | ● | ○ | ● |
| **AIG-07** Workload and agent identity with least privilege ★ | New Zealand Privacy Act 2020; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | ● | ● | ● | ● | ● | ○ | ● | ● |
| **AIG-08** Network isolation and data residency ★ | New Zealand Privacy Act 2020; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; NCSC | ○ | ● | ● | ● | ● | ○ | ○ | ○ |
| **AIG-09** Encryption and key management | New Zealand Privacy Act 2020; ISO/IEC 27001:2022 + Amd 1:2024; Zero trust; MITRE ATLAS; Anthropic | ○ | ● | ● | ○ | ● | · | ○ | ○ |
| **AIG-10** Runtime guardrails and content safety | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | ○ | ● | ● | ○ | ● | ● | ● | ● |
| **AIG-11** Human oversight of consequential decisions and actions ★ | New Zealand Privacy Act 2020; Energy critical-infrastructure and incident-reporting regimes; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; Electricity Industry Act 2010 and Electricity Industry Participation Code 2010 | · | ○ | ○ | ○ | ○ | · | ○ | ○ |
| **AIG-12** Transparency, notice and explanation | New Zealand Privacy Act 2020; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; Biometric Processing Privacy Code 2025 | · | · | ○ | ○ | · | ○ | · | · |
| **AIG-13** Logging, monitoring and record-keeping ★ | Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; Zero trust; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework; Business continuity and disaster recovery for AI services; Electricity Industry Act 2010 and Electricity Industry Participation Code 2010; NCSC | ● | ● | ● | ● | ● | ○ | ● | ● |
| **AIG-14** Pre-deployment testing, evaluation and red-teaming | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; OWASP GenAI Security Project; MITRE ATLAS; Anthropic | · | · | ○ | ○ | · | ○ | ● | · |
| **AIG-15** Change management and model lifecycle ★ | IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment; MITRE ATLAS; Electricity Industry Act 2010 and Electricity Industry Participation Code 2010 | · | ● | ● | ● | · | · | · | · |
| **AIG-16** Incident management and regulator notification ★ | New Zealand Privacy Act 2020; Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; Anthropic; Business continuity and disaster recovery for AI services; Gas Act 1992 and gas governance rules incl. critical contingency management | · | · | ● | ○ | · | · | · | · |
| **AIG-17** Operational resilience, outsourcing and exit ★ | Energy critical-infrastructure and incident-reporting regimes; IEC 62443; ISO/IEC 27019:2024; ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; NIST SP 800-61 Rev. 3; OWASP GenAI Security Project; FinOps Framework; Business continuity and disaster recovery for AI services; Gas Act 1992 and gas governance rules incl. critical contingency management | ● | · | ○ | ○ | · | · | ○ | ● |
| **AIG-18** Cross-border transfer safeguards | New Zealand Privacy Act 2020; ISO/IEC 27001:2022 + Amd 1:2024 | ● | · | ○ | ● | ● | ○ | ● | ● |
| **AIG-19** AI literacy and training | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO 19011:2026 Guidelines for auditing management systems; MITRE ATLAS; New Zealand's Strategy for AI — Investing with confidence; Responsible AI Guidance for Businesses | · | · | ○ | ○ | · | · | · | · |
| **AIG-20** Fairness and non-discrimination | New Zealand Privacy Act 2020; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO/IEC 42005:2025 AI system impact assessment | · | · | ○ | ○ | · | · | · | · |
| **AIG-21** Internal audit and independent assurance | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; ISO 19011:2026 Guidelines for auditing management systems | · | · | · | · | · | · | · | · |
| **AIG-22** AI FinOps — token budgets, consumption limits and cost allocation | ISO/IEC 27001:2022 + Amd 1:2024; ISO/IEC 42001:2023 AI management system; NIST AI Risk Management Framework 1.0 + Generative AI Profile; OWASP GenAI Security Project; MITRE ATLAS; Anthropic; FinOps Framework | · | · | · | · | · | · | · | · |

● vendor pack enforces or evidences the control · ○ documented platform gap (handle in process or another layer) · · not applicable

## Run the MLOps gate for this profile

A pre-filled system record is in [`energy.system.yaml`](energy.system.yaml). Complete it for your system, then:

```bash
python3 tools/gate.py profiles/nz/energy.system.yaml
```

Status labels: ✓ primary = checked against the issuer · ◐ secondary = located via a reputable secondary source, re-check the primary text · ⚠ unverified = confirm before relying on it.
