# Frameworks and Laws: Status and AI-Relevant Clauses (verified 13 Oct 2026)


**How to read the labels**
- `UNVERIFIED:` means the item was **not** confirmed against a source. It comes from prior knowledge or a single secondary source. Check it before encoding it in policy.
- `STATUS UNCERTAIN` marks places where the status is genuinely unsettled.
- The sectoral US items (HIPAA, GLBA, FDA) were not re-checked in the verification pass and are marked UNVERIFIED.
- Source quality varies. Primary sources (eur-lex, iso.org, nist.gov, apra.gov.au, rbnz.govt.nz, privacy.org.nz, whitehouse.gov) are preferred. Secondary law-firm sources are named as such.

---

## 0. Headline changes since most training data (read this first)

| # | Change | Effect on the repo |
|---|---|---|
| 1 | **The EU AI Act was amended by Regulation (EU) 2026/1744** (the "Digital Omnibus on AI"). It is dated 8 Jul 2026, was published in the OJ on 24 Jul 2026 and entered into force on 27 Jul 2026. Annex III high-risk obligations now apply from **2 Dec 2027** (was 2 Aug 2026). Annex I obligations now apply from **2 Aug 2028** (was 2 Aug 2027). | Change every `effective_date` for high-risk controls. |
| 2 | **The GDPR part of the Digital Omnibus is NOT law.** It is procedure 2025/0360(COD). As of Sep 2026 it was still at first reading, with no Council mandate and no trilogues. | Keep the current GDPR text as the baseline. |
| 3 | **The Colorado AI Act (SB 24-205) was repealed and replaced** by SB 26-189, an automated decision-making technology (ADMT) disclosure law. It was signed on 14 May 2026 and takes effect **1 Jan 2027**. The duty of care, impact assessments and risk-management program requirements are gone. | Remove the Colorado risk-program and impact-assessment controls. Add notice, adverse-decision explanation and appeal controls. |
| 4 | **The US has no federal AI statute.** EO 14365 (11 Dec 2025) attacks state laws through litigation and funding conditions, but an executive order cannot preempt state law by itself. EO 14434 (29 Sep 2026) renames "AI" to "Super Intelligence" in agency communications only. | Treat state laws as live. |
| 5 | **SR 11-7 has been superseded by SR 26-2** (17 Apr 2026, Fed/FDIC/OCC). It explicitly does not cover generative AI. | Update model-risk control references. |
| 6 | **APRA letter to industry on AI (30 Apr 2026).** | This is the primary APRA AI source. |
| 7 | **The RBNZ DTA Outsourcing Standard (draft) will replace BS11.** All DTA standards are to be issued by 31 May 2027 and commence on **1 Dec 2028**. | BS11 stays in force until then. |
| 8 | **NZ IPP 3A has been in force since 1 May 2026.** The Biometric Processing Privacy Code 2025 applies to processing that existed before 3 Nov 2025 from **3 Aug 2026**. | |

---

## 1. ISO/IEC 27001:2022 + Amd 1:2024

### Identification
- **Official name:** ISO/IEC 27001:2022 *Information security, cybersecurity and privacy protection — Information security management systems — Requirements*.
- **Amendment:** ISO/IEC 27001:2022/Amd 1:2024 *Amendment 1: Climate action changes*. Published 23 Feb 2024, stage 60.60. https://www.iso.org/standard/88435.html
- **Issuing body:** ISO/IEC JTC 1/SC 27.

### Status (Oct 2026)
- **Current edition:** The current edition is 2022 + Amd 1:2024. No 2026 edition or Amd 2 has been identified (secondary source: https://www.brightdefense.com/news/iso-27001-what-changed-in-2026/).
- **Transition from 2013:** The transition period for ISO/IEC 27001:2013 certificates ended on **31 Oct 2025**.
- **ISO/IEC 27000:** A new edition, ISO/IEC 27000:2026, was published on 3 Jul 2026 (secondary source).
- **Amd 1 content.** UNVERIFIED: the exact wording. It adds to clause 4.1 that the organization shall determine whether climate change is a relevant issue. It also adds a note to clause 4.2 that interested parties can have climate-change requirements.

### Structure
- **Clauses:** 4–10 use the ISO Harmonized Structure.
- **Annex A:** 93 controls in four themes: 5 Organizational (37), 6 People (8), 7 Physical (14), 8 Technological (34).
- **Source for titles:** Control titles were checked against the full list at https://sparta.aerospace.org/v1.0/countermeasures/iso/controls (secondary source, verbatim titles).

### Annex A controls most relevant to AI pipelines and MLOps (numbers and titles confirmed)

| Control | Title | AI/MLOps mapping |
|---|---|---|
| 5.7 | Threat intelligence | Adversarial ML and prompt-injection threat feeds |
| 5.9 | Inventory of information and other associated assets | Model, dataset and agent inventory |
| 5.10 | Acceptable use of information and other associated assets | GenAI acceptable-use policy |
| 5.12 | Classification of information | Training-data classification and labels |
| 5.14 | Information transfer | Data sent to external model APIs |
| 5.15 | Access control | Model registry and feature-store access |
| 5.16 | Identity management | Non-human and agent identities |
| 5.17 | Authentication information | API keys and secrets for model endpoints |
| 5.18 | Access rights | |
| 5.19 | Information security in supplier relationships | Model vendors |
| 5.20 | Addressing information security within supplier agreements | Contract terms such as no-training-on-customer-data |
| 5.21 | Managing information security in the information and communication technology (ICT) supply chain | Model, weight and package provenance; AIBOM |
| 5.22 | Monitoring, review and change management of supplier services | Changes to model versions |
| 5.23 | Information security for use of cloud services | Hosted LLMs |
| 5.24–5.28 | Incident management planning; assessment of events; response; learning; collection of evidence | AI incident response |
| 5.31 | Legal, statutory, regulatory and contractual requirements | |
| 5.33 | Protection of records | |
| 5.34 | Privacy and protection of personal identifiable information (PII) | |
| 5.37 | Documented operating procedures | |
| 6.3 | Information security awareness, education, and training | Links to EU AI Act Art 4 (AI literacy) |
| 8.2 | Privileged access rights | |
| 8.3 | Information access restriction | |
| 8.4 | Access to source code | |
| 8.5 | Secure authentication | |
| 8.8 | Management of technical vulnerabilities | |
| 8.9 | Configuration management | |
| 8.10 | Information deletion | |
| 8.11 | Data masking | |
| 8.12 | Data leakage prevention | |
| 8.13 | Information backup | |
| 8.15 | Logging | |
| 8.16 | Monitoring activities | |
| 8.20 | Networks security | |
| 8.22 | Segregation of networks | |
| 8.24 | Use of cryptography | |
| 8.25 | Secure development life cycle | |
| 8.26 | Application security requirements | |
| 8.27 | Secure system architecture and engineering principles | |
| 8.28 | Secure coding | |
| 8.29 | Security testing in development and acceptance | Red-teaming and evals |
| 8.30 | Outsourced development | |
| 8.31 | Separation of development, test and production environments | |
| 8.32 | Change management | Model promotion gates |
| 8.33 | Test information | Use of production data in tests |

- **Title variant to note:** Some vendors write 8.12 as "Data leakage protection". The standard's title is "Data leakage prevention".
- **Official page:** https://www.iso.org/standard/27001

---

## 2. ISO/IEC 42001:2023 (AI management system) and related standards

### Identification
- **Official name:** ISO/IEC 42001:2023 *Information technology — Artificial intelligence — Management system*.
- **Edition:** Edition 1, published **18 Dec 2023**, stage 60.60.
- **Amendments:** iso.org shows no amendment in progress.
- **Issuing body:** ISO/IEC JTC 1/SC 42.
- **URL:** https://www.iso.org/standard/81230.html

### Clause structure (Harmonized Structure)
- 4 Context of the organization
- 5 Leadership (includes 5.2 AI policy)
- 6 Planning (6.1 actions to address risks and opportunities, AI risk assessment, AI risk treatment, AI system impact assessment; 6.2 AI objectives; 6.3 planning of changes)
- 7 Support
- 8 Operation (8.2 AI risk assessment, 8.3 AI risk treatment, 8.4 AI system impact assessment)
- 9 Performance evaluation
- 10 Improvement

UNVERIFIED: the sub-clause numbering 6.1.2 / 6.1.3 / 6.1.4 / 8.2–8.4. It comes from prior knowledge and was not re-fetched.

### Annexes
- Annex A: reference control objectives and controls (normative).
- Annex B: implementation guidance.
- Annex C: potential AI-related organizational objectives and risk sources.
- Annex D: use across domains and sectors.

### Annex A: 38 controls in 9 objectives
- **Source:** Titles come from a secondary source (https://riskprofs.com/iso-42001-annex-a-controls-list/). They were not checked against the standard's text. Verify them before publishing.

| Objective | Controls |
|---|---|
| **A.2 Policies related to AI** | A.2.2 AI policy; A.2.3 Alignment with other organizational policies; A.2.4 Review of the AI policy |
| **A.3 Internal organization** | A.3.2 AI roles and responsibilities; A.3.3 Reporting of concerns |
| **A.4 Resources for AI systems** | A.4.2 Resource documentation; A.4.3 Data resources; A.4.4 Tooling resources; A.4.5 System and computing resources; A.4.6 Human resources |
| **A.5 Assessing impacts of AI systems** | A.5.2 AI system impact assessment process; A.5.3 Documentation of AI system impact assessments; A.5.4 Assessing AI system impact on individuals or groups of individuals; A.5.5 Assessing societal impacts of AI systems |
| **A.6 AI system life cycle** | A.6.1.2 Objectives for responsible development of AI system; A.6.1.3 Processes for responsible AI system design and development; A.6.2.2 AI system requirements and specification; A.6.2.3 Documentation of AI system design and development; A.6.2.4 AI system verification and validation; A.6.2.5 AI system deployment; A.6.2.6 AI system operation and monitoring; A.6.2.7 AI system technical documentation; A.6.2.8 AI system recording of event logs |
| **A.7 Data for AI systems** | A.7.2 Data for development and enhancement of AI system; A.7.3 Acquisition of data; A.7.4 Quality of data for AI systems; A.7.5 Data provenance; A.7.6 Data preparation |
| **A.8 Information for interested parties of AI systems** | A.8.2 System documentation and information for users; A.8.3 External reporting; A.8.4 Communication of incidents; A.8.5 Information for interested parties |
| **A.9 Use of AI systems** | A.9.2 Processes for responsible use of AI systems; A.9.3 Objectives for responsible use of AI system; A.9.4 Intended use of the AI system |
| **A.10 Third-party and customer relationships** | A.10.2 Allocating responsibilities; A.10.3 Suppliers; A.10.4 Customers |

### Related standards

| Standard | Title | Published | Stage | URL |
|---|---|---|---|---|
| **ISO/IEC 23894:2023** | *Guidance on risk management* | 6 Feb 2023, Edition 1 | 60.60, no revision shown | https://www.iso.org/standard/77304.html |
| **ISO/IEC 42005:2025** | *AI system impact assessment* | **28 May 2025**, Edition 1 | 60.60 | https://www.iso.org/standard/44545.html (also https://committee.iso.org/standard/42005) |
| **ISO/IEC 42006:2025** | *Requirements for bodies providing audit and certification of AI management systems* | **7 Jul 2025** (released 2025-07) | 60.60 | https://www.iso.org/standard/42006 |

- **EN 18286:2026** *Artificial intelligence — Quality management system for EU AI Act regulatory purposes* (CEN-CENELEC JTC 21).
  - BS EN 18286:2026 was published on **31 Jul 2026** (https://knowledge.bsigroup.com/products/artificial-intelligence-quality-management-system-for-eu-ai-act-regulatory-purposes).
  - It is the candidate harmonised standard for AI Act Art 17.
  - **STATUS UNCERTAIN:** whether it has been cited in the OJ, which would give presumption of conformity, was not verified.

---

## 3. Zero trust, NIST AI RMF and NIST AI security work

### NIST SP 800-207 *Zero Trust Architecture*
- **Issued:** Aug 2020 by NIST. Final.
- **Seven tenets (§2.1):**
  1. All data sources and computing services are considered resources.
  2. All communication is secured regardless of network location.
  3. Access to individual enterprise resources is granted on a per-session basis.
  4. Access to resources is determined by dynamic policy.
  5. The enterprise monitors and measures the integrity and security posture of all owned and associated assets.
  6. All resource authentication and authorization are dynamic and strictly enforced before access is allowed.
  7. The enterprise collects as much information as possible about the current state of assets, network infrastructure and communications, and uses it to improve its security posture.
- **Logical components (§3):** Policy Engine (PE), Policy Administrator (PA), Policy Enforcement Point (PEP).
- **URL:** https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf

### NIST SP 1800-35 *Implementing a Zero Trust Architecture*
- **Final:** 10 Jun 2025.
- **Scope:** 19 example implementations built with 24 vendors.
- **URL:** https://csrc.nist.gov/News/2025/implementing-a-zero-trust-architecture-sp-1800-35

### CISA Zero Trust Maturity Model v2.0
- **Issued:** Apr 2023.
- **Five pillars:** Identity, Devices, Networks, Applications & Workloads, Data.
- **Three cross-cutting capabilities:** Visibility & Analytics, Automation & Orchestration, Governance.
- **Four stages:** Traditional, Initial, Advanced, Optimal.
- **URLs:** https://www.cisa.gov/zero-trust-maturity-model (summary verified via https://learn.microsoft.com/en-us/security/zero-trust/cisa-zero-trust-maturity-model-intro)

### Zero trust and agent guidance from 2025–26

**"Careful Adoption of Agentic AI Services"**
- **Published:** **1 May 2026**, jointly by CISA, NSA, ASD's ACSC, UK NCSC, Canadian Centre for Cyber Security and NZ NCSC.
- **Key recommendations:**
  - least privilege for agents
  - trusted agent registry and inventory
  - zero-trust architecture plus RBAC
  - human approval gates for high-risk actions
  - continuous logging of tool calls, inter-agent messages and decision chains
- **Source:** secondary summary at https://www.crowell.com/en/insights/client-alerts/american-and-allied-cyber-agencies-issue-first-joint-guidance-on-securing-agentic-ai

**NIST CAISI "AI Agent Standards Initiative"**
- **Launched:** Feb 2026 (announced 17 Feb 2026).
- **RFI on securing AI agent systems:** issued 12 Jan 2026 (docket NIST-2025-0035), closed 9 Mar 2026. An analysis of the responses was published on 18 May 2026.
- **NCCoE draft concept paper:** "Accelerating the Adoption of Software and AI Agent Identity and Authorization", 5 Feb 2026.
- **Outputs:** No final standard has been published yet.
- **Source:** secondary (https://casrai.org/guides/nist-ai-agent-standards-initiative). Verify on nist.gov.

### NIST AI RMF 1.0 (NIST AI 100-1)
- **Released:** 26 Jan 2023.
- **Functions:** **GOVERN, MAP, MEASURE, MANAGE**.
- **Revision:** NIST states that "The AI RMF 1.0 is being revised as part of the White House AI Action Plan". No draft or date has been published.
- **New profile work:** On 7 Apr 2026 NIST released a concept note for an "AI RMF Profile on Trustworthy AI in Critical Infrastructure".
- **URL:** https://www.nist.gov/itl/ai-risk-management-framework

### NIST AI 600-1 *Generative AI Profile*
- **Released:** 26 Jul 2024. Final.
- **URL:** https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-generative-artificial-intelligence
- UNVERIFIED: the profile's 12 GAI risk categories: CBRN information; confabulation; dangerous/violent/hateful content; data privacy; environmental impacts; harmful bias and homogenization; human-AI configuration; information integrity; information security; intellectual property; obscene/degrading/abusive content; value chain and component integration.

### NIST IR 8596 *Cybersecurity Framework Profile for Artificial Intelligence* ("Cyber AI Profile")
- **Status:** **Initial Preliminary Draft only**, published 16 Dec 2025. Comments closed 30 Jan 2026. Working sessions ran Apr–May 2026.
- **Later drafts:** As of Oct 2026 no initial public draft or final is listed.
- **Focus areas:** Secure (AI system components), Defend (AI-enabled cyber defense), Thwart (AI-enabled attacks). Built on CSF 2.0.
- **Terminology note:** The NIST page says NIST will update its terminology to "super intelligence" under EO 14434.
- **URLs:** https://csrc.nist.gov/pubs/ir/8596/iprd and https://nvlpubs.nist.gov/nistpubs/ir/2025/NIST.IR.8596.iprd.pdf

### NIST COSAiS (SP 800-53 Control Overlays for Securing AI Systems)
- **Concept paper:** 14 Aug 2025.
- **Five planned overlays:**
  - Generative AI (assistant/LLM)
  - Predictive AI (using and fine-tuning)
  - Single-agent AI
  - Multi-agent AI
  - Controls for AI developers
- **Progress:** The only artifact so far is the annotated outline for the **Predictive AI** overlay, released 8 Jan 2026 with feedback due 13 Feb 2026. The page was last updated 8 Jan 2026.
- **STATUS UNCERTAIN:** whether any initial public draft overlay has appeared since.
- UNVERIFIED: a "NISTIR 8605" number has been linked to COSAiS in third-party trackers.
- **URL:** https://csrc.nist.gov/projects/cosais

---

## 4. EU AI Act — Regulation (EU) 2024/1689, as amended by Regulation (EU) 2026/1744

### Identification
- **Official name:** Regulation (EU) 2024/1689 laying down harmonised rules on artificial intelligence (Artificial Intelligence Act).
- **Dates:** Dated 13 Jun 2024, published in the OJ 12 Jul 2024, in force since 1 Aug 2024.
- **Issuing body:** European Parliament and Council. Supervision sits with the AI Office (European Commission) and national market surveillance authorities.
- **URLs:** https://eur-lex.europa.eu/eli/reg/2024/1689/oj/eng · https://digital-strategy.ec.europa.eu/en/policies/regulatory-framework-ai

### Digital Omnibus on AI: ENACTED
- **Official name:** Regulation (EU) **2026/1744** of 8 Jul 2026, amending Regulations (EU) 2024/1689, 2018/1139 and 2023/1230.
- **Legislative path:**
  - Commission proposal COM(2025) 836, procedure 2025/0359(COD), 19 Nov 2025.
  - Provisional agreement 6–7 May 2026.
  - EP adoption 16 Jun 2026.
  - Council adoption 29 Jun 2026.
- **Published:** OJ 24 Jul 2026. **Entered into force: 27 Jul 2026** (eur-lex ELI metadata).
- **URLs:** https://eur-lex.europa.eu/eli/reg/2026/1744/oj/eng · https://eur-lex.europa.eu/legal-content/EN/TXT/HTML/?uri=CELEX:32026R1744
- **Secondary summaries:**
  - https://www.cuatrecasas.com/en/global/intellectual-property/art/digital-omnibus-ai-has-been-published
  - https://www.steptoe.com/en/news-publications/steptechtoe-blog/eu-ai-act-amendments-enter-into-force.html
  - https://www.gibsondunn.com/eu-ai-act-omnibus-agreement-postponed-high-risk-deadlines-and-other-key-changes/

### Application timeline (Oct 2026)

| Date | What applies |
|---|---|
| 2 Feb 2025 | Ch. I (incl. **Art 4 AI literacy**) and Ch. II (**Art 5 prohibitions**) |
| 2 Aug 2025 | GPAI obligations (Ch. V: Arts 53, 55), governance, notified bodies, penalties framework |
| **2 Aug 2026** | General application. **Art 50** transparency obligations apply (except the 50(2) transitional below). The Commission's GPAI enforcement powers, including fines, start. |
| **2 Dec 2026** | (a) Art 50(2) machine-readable marking for generative systems placed on the market **before** 2 Aug 2026. (b) **New Art 5(1)(ba)/(bb) prohibitions**: AI generating non-consensual intimate imagery ("nudifiers") or CSAM. |
| 2 Aug 2027 | National AI regulatory sandboxes must be operational (Art 57(1), moved from 2 Aug 2026). Legacy GPAI models placed on the market before 2 Aug 2025 must comply. |
| 2 Sep 2027 | Commission guidance and template for the post-market monitoring plan (Art 72(3)) |
| **2 Dec 2027** | **Annex III (stand-alone) high-risk systems**: Ch. III Sections 1–3, i.e. Arts 8–27 etc. Was 2 Aug 2026. |
| 28 Jan 2028 | Notified-body designation application deadline under amended Art 43(3) |
| **2 Aug 2028** | **Annex I (product-embedded) high-risk systems**. Was 2 Aug 2027. Machinery Regulation moved to Annex I Section B. |

- **Source note:** The 2 Dec 2027 and 2 Aug 2028 dates were confirmed in the Omnibus recitals and in multiple secondary sources. The operative Art 113 amendment text could not be extracted from EUR-Lex HTML.

### Other Omnibus changes
- **Art 4 AI literacy** is now an obligation of means: providers and deployers "shall take measures to support the development of AI literacy of their staff" (verified text). The Commission will publish practical examples.
- **New Art 4a** creates a legal basis to process special categories of personal data where "strictly necessary" for bias detection and correction. The data must be deleted once the bias is corrected. Secondary sources say this was extended beyond high-risk systems to all AI systems and GPAI models, but the verified fragment refers to high-risk. **STATUS UNCERTAIN.**
- **Art 6(3) systems** (Annex III systems the provider deems not high-risk) still require EU database registration, with simplified Annex VIII information (Steptoe).
- **Art 111 grace period:** further units of a high-risk design lawfully placed on the market before the application date can continue without new obligations unless the design changes significantly.
- **SMCs:** Small mid-caps (<750 staff; turnover ≤€150m or balance sheet ≤€129m) get SME privileges, including simplified technical documentation and proportionate QMS and fines (Art 3(14a)/(14b)).
- **AI Office:** gets exclusive supervision of AI systems built on a GPAI model by the same provider or group, and of AI in VLOPs/VLOSEs (Arts 75, 75a–75d).
- **Real-world testing:** new **Art 60a** allows real-world testing outside sandboxes for Annex I Section B products.
- **GPAI:** obligations are **not** suspended or deferred.

### Key articles (titles confirmed)

| Art | Title | Notes / cross-refs |
|---|---|---|
| 4 | AI literacy | ISO 27001 A.6.3 |
| 5 | Prohibited AI practices | now includes (ba)/(bb) |
| 6 | Classification rules for high-risk AI systems | Art 6(3) derogation |
| 9 | Risk management system | ISO 42001 6.1 / ISO 23894 |
| 10 | Data and data governance | ISO 42001 A.7 |
| 11 | Technical documentation | Annex IV |
| 12 | Record-keeping | automatic logs; ISO 42001 A.6.2.8; ISO 27001 8.15 |
| 13 | Transparency and provision of information to deployers | ISO 42001 A.8.2 |
| 14 | Human oversight | |
| 15 | Accuracy, robustness and cybersecurity | |
| 17 | Quality management system | EN 18286 |
| 26 | Obligations of deployers of high-risk AI systems | incl. log retention ≥6 months, monitoring, informing workers |
| 27 | Fundamental rights impact assessment for high-risk AI systems | for public bodies, private providers of public services, and Annex III 5(b)/(c) credit and insurance deployers |
| 49 | Registration | |
| 50 | Transparency obligations for providers and deployers of certain AI systems | chatbots disclosure; synthetic content marking (50(2)); emotion recognition / biometric categorisation notice; deepfake labelling |
| 53 | Obligations for providers of general-purpose AI models | |
| 55 | Obligations of providers of general-purpose AI models with systemic risk | |
| 72 | Post-market monitoring by providers and post-market monitoring plan for high-risk AI systems | |
| 73 | Reporting of serious incidents | |
| 99 | Penalties | |
| 113 | Entry into force and application | |

- **Penalties (Art 99).** UNVERIFIED:
  - up to €35m or 7% of turnover for Art 5 breaches
  - up to €15m or 3% for most other obligations
  - up to €7.5m or 1% for incorrect information
  - GPAI fines are in Art 101.
- **Annex III areas.** UNVERIFIED (exact headings not re-fetched; from the Regulation text as known):
  1. biometrics
  2. critical infrastructure
  3. education and vocational training
  4. employment, workers' management and access to self-employment
  5. access to and enjoyment of essential private services and essential public services and benefits (incl. creditworthiness, life/health insurance pricing)
  6. law enforcement
  7. migration, asylum and border control management
  8. administration of justice and democratic processes

### GPAI Code of Practice
- **Published:** **10 Jul 2025** by the AI Office.
- **Chapters:**
  - Transparency (Art 53(1)(a)–(b)), with a Model Documentation Form.
  - Copyright (Art 53(1)(c)).
  - Safety & Security (Art 55, systemic-risk models only).
- **Companion documents:** The GPAI guidelines and the Art 53(1)(d) training-data summary template were published in Jul 2025.
- **Sources:** https://www.globalpolicywatch.com/2025/07/ai-office-publishes-final-version-of-the-code-of-practice-for-general-purpose-ai-models/ · https://digital-strategy.ec.europa.eu/en/policies/contents-code-gpai

### Commission guidance in 2026 (secondary: Mayer Brown, 30 Jul 2026)
- **Art 6 high-risk classification guidelines:** draft published 19 May 2026. Not final.
- **Art 50 transparency guidelines:** final, adopted 20 Jul 2026.
- **Updated GPAI guidelines:** 2026. The date is inconsistent in the source (28 Apr or 18 Jul 2026).
- **Source URL:** https://www.mayerbrown.com/en/insights/publications/2026/07/eu-ai-act-news-digital-omnibus-on-ai-new-guidance-on-risk-classification-gpai-and-transparency-obligations
- UNVERIFIED: the guidelines on prohibited practices (4 Feb 2025) and on the AI system definition (6 Feb 2025).

---

## 5. United States

### Federal: no comprehensive AI statute as of Oct 2026

**EO 14179** *Removing Barriers to American Leadership in Artificial Intelligence*
- Issued 23 Jan 2025. It revoked EO 14110.
- UNVERIFIED: the exact date and title (prior knowledge, consistent with OMB memo citations).

**OMB M-25-21** *Accelerating Federal Use of AI through Innovation, Governance, and Public Trust* (3 Apr 2025)
- Requires a Chief AI Officer within 60 days.
- Requires an agency AI strategy within 180 days.
- Requires AI and GenAI policies within 270 days.
- Sets minimum practices for "high-impact AI".
- Source: https://www.sheppard.com/insights/blogs/all-american-ai-new-omb-memos-set-priorities-for-federal-ai-use-and-acquisition
- UNVERIFIED: that it replaced M-24-10.

**OMB M-25-22** *Driving Efficient Acquisition of Artificial Intelligence in Government* (3 Apr 2025)
- Applies to solicitations issued 180 days or more after the memo.
- UNVERIFIED: that it replaced M-24-18.

**America's AI Action Plan**
- UNVERIFIED: date 23 Jul 2025, from prior knowledge. NIST confirms the AI RMF revision is being made "as part of the White House AI Action Plan".

**EO 14319 and OMB M-26-04**
- UNVERIFIED: EO 14319, *Preventing Woke AI in the Federal Government*, 23 Jul 2025.
- OMB **M-26-04** *Increasing Public Trust in Artificial Intelligence Through Unbiased AI Principles* (Dec 2025) applies to federal LLM procurement: https://www.whitehouse.gov/wp-content/uploads/2025/12/M-26-04-Increasing-Public-Trust-in-Artificial-Intelligence-Through-Unbiased-AI-Principles-1.pdf

**EO 14365** *Ensuring a National Policy Framework for Artificial Intelligence* (11 Dec 2025)
- **Directives:**
  - DOJ AI Litigation Task Force (30 days).
  - Commerce list of "onerous" state laws (90 days).
  - BEAD non-deployment funds conditioned on states.
  - FCC proceeding on a federal reporting and disclosure standard.
  - FTC policy statement on UDAP and "truthful outputs".
  - A legislative preemption proposal.
- **Carve-outs:** child safety, compute and data-centre infrastructure, state procurement and use of AI.
- **Status as of Sep 2026:** no reported Task Force lawsuit outcome. An EO cannot itself preempt state law.
- **Sources:**
  - https://www.consumerfinancialserviceslawmonitor.com/2025/12/white-house-issues-executive-order-outlining-a-national-policy-framework-for-ai/
  - https://casrai.org/news/federal-ai-moratorium-state-preemption-fight-2026
- **STATUS UNCERTAIN:** litigation outcomes.

**EO 14434** *Inaugurating the Era of Super Intelligence* (29 Sep 2026)
- Agencies are to use "Super Intelligence (SI)" in place of "AI" in non-statutory documents.
- SI is defined by reference to 15 U.S.C. 9401(3).
- OSTP is to propose an SI statutory definition within 60 days.
- No obligations on industry and no preemption.
- URL: https://www.whitehouse.gov/presidential-actions/2026/09/inaugurating-the-era-of-super-intelligence/
- **Repo impact:** Keep "AI" in control IDs. Optionally add the alias.

**Congress**
- The 2025 reconciliation 10-year state moratorium was stripped 99–1 in the Senate in Jul 2025.
- The "Great American AI Act" was released as a House discussion draft on 4 Jun 2026: a 3-year preemption of state AI **development** rules. It has not been introduced and has stalled.
- **No federal AI preemption statute has been enacted.**

### State and local

**Colorado**
- **SB 24-205** (Colorado AI Act): was delayed to 30 Jun 2026, then **repealed and replaced** by **SB 26-189** *Automated Decision-Making Technology*. SB 26-189 was signed 14 May 2026 and is **effective 1 Jan 2027**.
- **Developers must** document intended uses, limitations and training-data categories for deployers, and keep records for 3 years.
- **Deployers must:**
  - give pre-use notice before ADMT materially influences a consequential decision
  - give a plain-language explanation within 30 days of an adverse decision
  - offer data correction and meaningful human review where commercially reasonable
  - keep records for 3 years
- **Enforcement:** AG under the CCPA (Colorado Consumer Protection Act), with a 60-day cure until 1 Jan 2030. No private right of action.
- **Source:** https://www.finnegan.com/en/insights/articles/colorado-replaces-landmark-ai-act-an-overview-of-the-new-sb-26-189-framework.html
- **STATUS UNCERTAIN:** the leg.colorado.gov bill page (https://leg.colorado.gov/bills/sb26-189) displayed only "introduced 05/01/2026" when fetched. This is probably a stale render. Confirm the signing on the legislature or governor's site.

**Texas: TRAIGA, HB 149 (89th Leg.)**
- **Effective:** **1 Jan 2026**.
- **Prohibits** developing or deploying AI with intent to:
  - manipulate people toward self-harm, harm or crime
  - infringe constitutional rights
  - unlawfully discriminate (disparate impact alone is not enough)
  - produce CSAM or sexual deepfakes
- **Government agencies** must disclose AI interactions.
- **Biometrics:** CUBI carve-outs.
- **Enforcement:** AG only, with a 60-day cure. Penalties $10k–$200k per violation and $2k–$40k per day.
- **Other:** a regulatory sandbox and the Texas AI Advisory Council.
- **Source:** https://www.ashurstperkinscoie.com/en/insights/update/texas-enacts-responsible-artificial-intelligence-governance-act/
- UNVERIFIED: the codification (Bus. & Com. Code Title 11 Subtitle D), the 36-month sandbox term, and the affirmative defense for NIST AI RMF alignment.

**California SB 53** — Transparency in Frontier Artificial Intelligence Act (TFAIA)
- **Signed / effective:** signed 29 Sep 2025, **effective 1 Jan 2026**.
- **Scope:** frontier models trained with >10^26 FLOPs. A "large frontier developer" has more than $500m revenue.
- **Obligations:**
  - publish a frontier AI framework, updated annually
  - publish transparency reports at deployment
  - report critical safety incidents to Cal OES within 15 days, or within 24 hours if there is imminent risk of death or serious injury
  - whistleblower protections
- **Penalties:** up to $1m per violation, enforced by the AG.
- **Source:** https://www.mofo.com/pdf/resources/insights/251001-california-enacts-ai-safety-transparency-regulation-tfaia-sb-53
- UNVERIFIED: the code section (Bus. & Prof. Code §22757.10 et seq.).

**California CCPA regulations on ADMT, risk assessments and cybersecurity audits** (CPPA; approved by OAL 23 Sep 2025; effective 1 Jan 2026)

| Requirement | Date |
|---|---|
| ADMT obligations for significant decisions | **1 Jan 2027** |
| Risk assessments | from 1 Jan 2026 |
| Attestation and summary of risk assessments to the CPPA | by **1 Apr 2028** |
| Cybersecurity audit certification, revenue >$100m | 1 Apr 2028 |
| Cybersecurity audit certification, revenue $50–100m | 1 Apr 2029 |
| Cybersecurity audit certification, revenue <$50m | 1 Apr 2030 |

- Source: https://www.hunton.com/privacy-and-cybersecurity-law-blog/newly-approved-ccpa-regulations-have-staggered-deadlines-for-compliance
- UNVERIFIED: the CCR section numbers (Cal. Code Regs. tit. 11, §7150 et seq. for risk assessments; §7200 et seq. for ADMT).

**Utah AI Policy Act** (SB 149, effective 1 May 2024)
- **SB 332 (2025)** extended the sunset to **1 Jul 2027**.
- **SB 226 (2025)** narrowed the GenAI disclosure duty to two situations: when a consumer clearly asks, and in "high-risk" interactions. A safe harbor applies for upfront disclosure.
- **HB 452 (2025)** regulates mental-health chatbots.
- **Source:** https://fpf.org/blog/chatbots-in-check-utahs-latest-ai-legislation/
- No 2026 changes were found. UNVERIFIED.

**NYC Local Law 144** (automated employment decision tools)
- Enforced since 5 Jul 2023.
- Requires an annual independent bias audit, public posting of the audit summary, and candidate notice. Enforced by DCWP.
- The NY State Comptroller audit (Dec 2025, report 2024-N-6) found enforcement ineffective.
- **Source:** https://www.nelsonmullins.com/insights/blogs/ai-task-force/ai/states-take-aim-at-ai-in-employment-decisions-illinois-s-disclosure-and-anti-discrimination-requirements-enforcement-gaps-under-nyc-s-local-law-144-and-connecticut-s-new-ai-law

**Illinois HB 3773** (amends the Illinois Human Rights Act, 775 ILCS 5)
- **Effective 1 Jan 2026.**
- Prohibits discriminatory effect from AI in employment decisions, including zip code used as a proxy.
- Requires notice to employees when AI is used.
- IDHR draft rules (Subpart J) cover notice content and 4-year retention. The rules hearing was postponed as of 2 Jun 2026. **STATUS UNCERTAIN.**

**Connecticut SB 5 (2026)**
- Covers AEDT notice in employment.
- Effective **1 Oct 2027** (same Nelson Mullins source).
- UNVERIFIED: the public act number.

### Sectoral

**Model risk: SR 26-2** *Supervisory Guidance on Model Risk Management*
- **Issued:** **17 Apr 2026** by the Fed, FDIC and OCC. It supersedes SR 11-7 (2011).
- **Approach:** risk-based. Most relevant to institutions above $30bn in assets.
- **Third-party models:** the institution remains responsible.
- **AI coverage:** **explicitly does not address generative/advanced AI.** Separate guidance is promised.
- **Source:** https://www.bakertilly.com/insights/updated-interagency-guidance-on-model-risk-management
- UNVERIFIED: the OCC Bulletin 2026-13 identifier (third-party tracker).

**HIPAA** (45 CFR Parts 160/164)
- Security Rule: §164.308 administrative, §164.310 physical, §164.312 technical (access control, audit controls, integrity, transmission security).
- UNVERIFIED: the status of the HHS Security Rule NPRM (published 6 Jan 2025). Not re-checked.

**HHS Section 1557, 45 CFR §92.210** (patient care decision support tools, including AI)
- UNVERIFIED: compliance date 1 May 2025.

**GLBA**
- FTC Safeguards Rule, 16 CFR Part 314.
- UNVERIFIED: the breach notification amendment, effective 13 May 2024.

**FDA**
- UNVERIFIED (not re-checked the 13 Oct 2026 verification pass):
  - PCCP final guidance for AI-enabled device software functions (Dec 2024).
  - Draft guidance "Artificial Intelligence-Enabled Device Software Functions: Lifecycle Management and Marketing Submission Recommendations" (Jan 2025). Final status as of Oct 2026 is unknown.
  - GMLP guiding principles (2021).
- URL: https://www.fda.gov/medical-devices/software-medical-device-samd/artificial-intelligence-enabled-medical-devices

---

## 6. GDPR — Regulation (EU) 2016/679

### Identification
- **Status:** In force; applies since 25 May 2018.
- **Issuing bodies:** EP and Council. The EDPB issues guidance; national DPAs enforce.
- **URLs:** https://eur-lex.europa.eu/eli/reg/2016/679/oj/eng · titles verified via https://gdpr-info.eu/

### Key articles (titles confirmed)
- Art 5 Principles relating to processing of personal data
- Art 6 Lawfulness of processing
- Art 9 Processing of special categories of personal data
- Art 13 Information to be provided where personal data are collected from the data subject
- Art 14 Information to be provided where personal data have not been obtained from the data subject
- Art 15 Right of access by the data subject
- Art 22 Automated individual decision-making, including profiling
- Art 25 Data protection by design and by default
- Art 28 Processor
- Art 30 Records of processing activities
- Art 32 Security of processing
- Art 33 Notification of a personal data breach to the supervisory authority (72 h)
- Art 35 Data protection impact assessment
- Art 44 General principle for transfers
- Art 45 Transfers on the basis of an adequacy decision
- Art 46 Transfers subject to appropriate safeguards
- Art 49 Derogations for specific situations

### EDPB Opinion 28/2024 on certain data protection aspects related to the processing of personal data in the context of AI models
- **Adopted:** 17 Dec 2024, under Art 64(2) at the request of the Irish DPC.
- **Questions covered:**
  1. Model anonymity is assessed case by case. Extraction or regurgitation must be insignificant with means reasonably likely to be used.
  2. Legitimate interest uses the three-step test. Examples: conversational agents, cybersecurity.
  3. Seven criteria for reasonable expectations.
  4. Consequences of unlawful processing in the development phase for later deployment.
- **URLs:** https://edpb.europa.eu/system/files/2024-12/edpb_opinion_202428_ai-models_en.pdf · https://www.hunton.com/privacy-and-cybersecurity-law-blog/edpb-publishes-opinion-on-processing-of-personal-data-in-the-context-of-ai-models

### New EDPB drafts (8 Jul 2026 plenary)
- Draft Guidelines on anonymisation, open for consultation **until 30 Oct 2026**.
- Draft Guidelines on web scraping in the context of generative AI, open for consultation **until 30 Oct 2026**.
- Blockchain Guidelines 02/2025 v2 adopted as final.
- URL: https://www.edpb.europa.eu/news/edpb-sheds-light-on-anonymisation-and-web-scraping-for-generative-ai-and-adopts-final-version_en

### Digital Omnibus (data/GDPR part), procedure 2025/0360(COD): NOT ADOPTED
- **Proposal:** 19 Nov 2025.
- **Parliament:** The EP LIBE/ITRE draft report was published 22 Jun 2026. More than 1,750 amendments were tabled.
- **Council:** The COREPER II mandate vote was cancelled. No trilogues as of 24 Sep 2026. Final adoption is not expected before late 2026 at the earliest.
- **Source:** https://acompli.ie/news/digital-omnibus-gdpr-cookies-status-september-2026/
- **Proposed changes.** UNVERIFIED, proposal-stage only. Do not encode as law:
  - a relative/entity-specific definition of personal data
  - a new legitimate-interest provision for AI development and operation (Art 88c)
  - a residual special-category data derogation for AI
  - a single-entry-point breach notification with a 96-hour high-risk threshold
  - EU-level DPIA lists
  - moving cookie rules into the GDPR

### Related enacted change
- AI Act **Art 4a** (via 2026/1744) gives a narrow legal basis for special-category data processing for bias detection. Treat it as an Art 9(2)(g)-type basis. STATUS UNCERTAIN: its exact interplay with the GDPR.

---

## 7. APRA (Australia)

### CPS 230 *Operational Risk Management*
- **Commencement:** **1 Jul 2025** (para 6).
- **Transition:** Pre-existing service-provider contracts must comply at the earlier of renewal or **1 Jul 2026** (para 7).
- **Replaced:** CPS 231, CPS 232, SPS 231, SPS 232, HPS 231.
- **Amendments:** Targeted amendments were finalised on 30 Apr 2026 and took effect on 1 Jul 2026. This is from a secondary source (https://allitservices.com.au/apras-cps-230-grace-period-ends-1-july-what-it-means-for-financial-firms-and-the-businesses-that-supply-them/).
- **Paragraph map (verified against the APRA PDF):**

| Paras | Requirement |
|---|---|
| 12–15 | Key principles. Para 15: must not rely on a service provider unless it can ensure critical operations within tolerance. |
| 16–19 | Risk management framework (links to CPS 220) |
| 20–23 | Board and senior management roles |
| 24–25 | Operational risk management; information and IT capability |
| 26–28 | Risk profile; assessment before material change, e.g. new AI use |
| 29–31 | Controls: design, monitor, test, remediate |
| 32–33 | Incidents. Notify APRA within **72 h** of a material operational risk incident. |
| 34–46 | Business continuity, critical operations and tolerance levels (35–39). Notify APRA within **24 h** of a disruption outside tolerance (42). BCP testing (43–46). |
| 47–60 | Service providers: policy (47–48); material service provider register (49–52, submitted annually); agreement terms (53–56). Notify APRA within **20 business days** of material arrangements (59). |

- **URL:** https://www.apra.gov.au/sites/default/files/2023-07/Prudential%20Standard%20CPS%20230%20Operational%20Risk%20Management%20-%20clean.pdf

### CPS 234 *Information Security*
- **Commencement:** **1 Jul 2019** (para 5).
- **Paragraph map (verified against the APRA PDF):**

| Paras | Requirement |
|---|---|
| 13 | Board ultimately responsible |
| 14 | Roles and responsibilities |
| 15–17 | Capability, including third parties |
| 18–19 | Policy framework |
| 20 | Classification of information assets, including those managed by third parties |
| 21–22 | Controls, including third-party controls |
| 23–25 | Incident detection and response plans |
| 26–31 | Annual review and testing; independence |
| 32–34 | Internal audit |
| 35 | Notify APRA ≤**72 h** of material information security incidents |
| 36 | Notify APRA ≤**10 business days** of material control weaknesses |

- **URL:** https://www.apra.gov.au/sites/default/files/cps_234_july_2019_for_public_release.pdf

### CPS 220 *Risk Management*
- UNVERIFIED (not fetched): in force since 1 Jan 2015; requires a risk management framework, a Risk Management Strategy, a Business Plan, and a CRO.
- **Guidance:** CPG 234 and CPG 235 (Managing Data Risk) are relevant guidance.

### APRA Letter to Industry on Artificial Intelligence
- **Date:** **30 Apr 2026**, by Therese McCarthy Hockey. Addressed to all regulated entities.
- **Expectations:**
  - AI lifecycle ownership and accountability.
  - Board AI literacy and strategy within risk appetite.
  - An **inventory of AI tooling and use cases**.
  - Continuous validation for drift and bias, with second-line and audit capability.
  - AI supply-chain mapping including fourth parties, with tested exit, substitution and portability.
  - Controls over **agentic/autonomous workflows**, privileged access management for non-human identities, patching and hardening.
  - Security testing of AI-generated code.
  - Credible fallback processes for critical operations.
  - Human involvement for high-risk decisions.
  - Enforceable technical controls rather than policy alone.
- **Prudential standards:** The letter says "existing prudential standards apply". It does not name CPS 230/234; the mapping to them is an inference.
- **URL:** https://www.apra.gov.au/apra-letter-to-industry-on-artificial-intelligence-ai
- **Related:** ASIC open letter on cyber resilience and frontier AI, 8 May 2026 (https://www.ashurstperkinscoie.com/en/insights/apra-and-asic-sound-the-ai-alarm-for-boards-and-executives/).

---

## 8. RBNZ BS11 *Outsourcing Policy* (New Zealand registered banks)

### Current BS11
- **Version:** BS11 issued **Sep 2022**. Some arrangements may still be under the Jan 2006 version.
- **Scope:** NZ-incorporated registered banks with liabilities, net of amounts owed to related parties, of **≥ NZ$10bn**.
- **Required outcomes.** Outsourcing must not compromise the bank's ability to:
  1. meet clearing, settlement and other time-critical obligations
  2. monitor and manage credit, liquidity and market risk positions
  3. give the statutory manager and RBNZ access to systems and data
  4. provide basic banking services to existing customers
- **Foreign-owned banks** must be able to achieve these outcomes stand-alone if separated from the parent.
- **Supporting documents:** an Exempt list, a Pre-approved functions and services list, application forms A–E, and separation-plan guidance.
- **URL:** https://www.rbnz.govt.nz/regulation-and-supervision/banks/prudential-requirements/outsourcing-policy (page updated 11 Dec 2023)
- **UNVERIFIED:**
  - the specific BS11 compliance deadlines (end of a transition, reportedly Oct 2022/2023)
  - the outsourcing compendium requirements
  - cloud treatment via the pre-approved list
  - the 3-yearly independent review (the DTA draft says the "3-yearly review cycle continues from last BS11 review date", which implies it exists)

### Replacement: Deposit Takers (Outsourcing) Standard (draft)
- **Consultation:** Exposure draft in DTA tranche 3, published 18 Jun 2026. Consultation closed 11 Sep 2026.
- **Timeline:**
  - All DTA standards to be issued by **31 May 2027**.
  - They commence **1 Dec 2028**. This was moved from Jul 2028 in Jul 2025.
  - Crisis-preparedness standards commence later, around 2029.
  - Legislative backstop: Jul 2029.
- **Draft content (guidance note):**
  - Applies to Group 1 deposit takers, intended to cover BS11-scope banks.
  - Existing BS11 non-objections carry over (Sch 1).
  - Same four outcomes (cl. 3).
  - Prescribed contract terms (cl. 7) and parallel rights (cl. 8).
  - Backup capability with annual end-to-end testing (cl. 9–11).
  - RBNZ approvals (cl. 12–19).
  - Separation plan for overseas-group banks: annual test; impediments reported within 24 h (cl. 31–38).
  - Independent review every 3 years (cl. 42).
  - Shares the critical operations register with the new **Operational Resilience Standard**.
- **URLs:**
  - https://www.rbnz.govt.nz/regulation-and-supervision/deposit-takers-act/dta-timeline
  - https://www.rbnz.govt.nz/news-and-events/news/2026/06/dta-consultations-on-crisis-preparedness-and-draft-standards
  - https://consultations.rbnz.govt.nz/dta-and-dcs/dta-standards-exposure-drafts-tranche-3/user_uploads/outsourcing-standard-draft-guidance.pdf
- **STATUS UNCERTAIN:** final text and BS11 revocation date. BS11 is presumably revoked when the DTA standards commence on 1 Dec 2028; not confirmed.

### RBNZ on AI
- **No AI-specific prudential guidance** has been found. RBNZ says existing standards apply.
- **Relevant publications:**
  - FSR May 2025 special topic "Rise of the machines" (5 May 2025): https://www.rbnz.govt.nz/hub/publications/financial-stability-report/2025/may/ai-pre-release/rise-of-the-machines
  - The May 2026 FSR flagged frontier-model cyber risk and concentration on overseas AI providers. Secondary source: https://www.insurancebusinessmag.com/nz/news/cyber/rbnz-named-an-ai-model-as-a-financial-stability-risk--top-regulator-says-they-are-all-pretty-scary-587971.aspx

---

## 9. Australia: Privacy Act 1988 (Cth) and AI policy

### APP titles (verified via OAIC)

| APP | Title |
|---|---|
| 1 | Open and transparent management of personal information |
| 3 | Collection of solicited personal information |
| 5 | Notification of the collection of personal information |
| 6 | Use or disclosure of personal information |
| 8 | Cross-border disclosure of personal information |
| 10 | Quality of personal information |
| 11 | Security of personal information |
| 12 | Access to personal information |

- **Source:** https://www.oaic.gov.au/privacy/australian-privacy-principles/read-the-australian-privacy-principles
- **Act:** https://www.legislation.gov.au/C2004A03712/latest

### Privacy and Other Legislation Amendment Act 2024 (POLA Act)
- **Passed:** Dec 2024. UNVERIFIED: Royal Assent on 10 Dec 2024.
- **ADM transparency:** new **APP 1.7–1.9** commence **10 Dec 2026**.
  - APP 1.7: ADM is in scope where a computer program makes a decision, or does a thing substantially and directly related to making it, that could reasonably be expected to significantly affect an individual's rights or interests, using personal information.
  - APP 1.8: the privacy policy must describe the kinds of personal information used, the decisions made solely by programs, and the decisions where a program does a substantially related step.
  - APP 1.9: examples of affecting rights or interests.
  - Non-compliance attracts infringement notices and civil penalties.
  - Source: https://jws.com.au/what-we-think/practical-implications-of-new-transparency-requirements-for-automated-decision-making/
- **Statutory tort** for serious invasions of privacy (Schedule 2 to the Privacy Act): commenced **10 Jun 2025**. Source: https://www.oaic.gov.au/privacy/your-privacy-rights/more-privacy-rights/statutory-tort-for-serious-invasions-of-privacy
- **OAIC infringement and compliance notice powers:** from 11 Dec 2024.

### Tranche 2 reform (not law)
- **Bill:** *Privacy Amendment (Personal Data Protection) Bill 2026*, exposure draft. Consultation closed **18 Sep 2026**.
- **Proposals:**
  - a "fair and reasonable" test replacing most of APPs 3, 4 and 6
  - "relates to" an individual in the definition of personal information
  - 72-hour notification of breaches to the OAIC
  - a controller/processor distinction
- **Commencement:** deferred.
- **Source:** https://www.hsfkramer.com/insights/2026-09/the-draft-tranche-2-privacy-act-reforms-whats-there-whats-new-and-whats-missing

### OAIC AI guidance (both released 21 Oct 2024)
- *Guidance on privacy and the use of commercially available AI products*.
- *Guidance on privacy and developing and training generative AI models*.
- **Key points:**
  - Do not enter personal information into public GenAI tools (best practice).
  - Inferred or generated information is personal information.
  - APP 10 accuracy; APP 6 secondary use; APP 11 security.
  - Privacy policy and collection notice transparency.
- **URLs:** https://www.oaic.gov.au/privacy/privacy-guidance-for-organisations-and-government-agencies/guidance-on-privacy-and-the-use-of-commercially-available-ai-products · https://www.claytonutz.com/insights/2024/november/new-oaic-privacy-guidance-on-ai-what-you-need-to-know

### Voluntary AI Safety Standard (VAISS)
- UNVERIFIED: issued Sep 2024 by DISR/NAIC with 10 guardrails.
- It has been **updated and consolidated by the Guidance for AI Adoption**. Whether the VAISS has been formally withdrawn is not stated.

### Guidance for AI Adoption (NAIC)
- **Released:** **17 Oct 2025**.
- **Six essential practices ("AI6"):**
  1. Decide who is accountable
  2. Understand impacts and plan accordingly
  3. Measure and manage risks
  4. Share essential information
  5. Test and monitor
  6. Maintain human control
- **Two versions:** *Foundations*, and *Implementation Practices* (aligned to ISO/IEC 42001 and the NIST AI RMF).
- **URLs:** https://www.industry.gov.au/publications/guidance-for-ai-adoption · https://www.hlc.com/en/publications/australias-new-guidance-for-ai-adoption-a-strategic-step-toward-responsible-innovation

### National AI Plan
- **Release:** **Dec 2025**. UNVERIFIED: the exact release date of 2 Dec 2025.
- **No standalone AI Act.** The government will **not** mandate the proposed mandatory guardrails and will rely on existing laws.
- **Australian AI Safety Institute:** announced 25 Nov 2025, with about A$30m.
- **Three goals:** capture opportunities, spread benefits, keep Australians safe.
- **Source:** https://www.minterellison.com/articles/australia-introduces-a-national-ai-plan-four-things-leaders-need-to-know

---

## 10. New Zealand: Privacy Act 2020 and AI policy

### Privacy Act 2020 (2020 No 31)
- **In force:** since 1 Dec 2020.
- **Administrator:** Office of the Privacy Commissioner.
- **URL:** https://www.legislation.govt.nz/act/public/2020/0031/latest/whole.html
- **IPP titles (verified via OPC):**

| IPP | Title |
|---|---|
| 1 | Purpose of collection |
| 2 | Collecting from the individual |
| 3 | Telling individuals when collecting directly |
| **3A** | **Telling individuals when collecting from another source** |
| 4 | Manner of collection |
| 5 | Storage and security |
| 6 | Access |
| 7 | Correction |
| 8 | Accuracy before use |
| 9 | Retention limits |
| 10 | Limits on use |
| 11 | Disclosure |
| 12 | Disclosure outside New Zealand |
| 13 | Unique identifiers |

### IPP 3A (Privacy Amendment Act 2025)
- **In force: 1 May 2026.**
- **Requirement:** For indirect collection, take reasonable steps as soon as reasonably practicable to make the individual aware of:
  - the collection and its purpose
  - the intended recipients
  - the name and address of the collecting and holding agency
  - the authorising law
  - access and correction rights
- **Exceptions:** include publicly available information, notification not reasonably practicable, non-identifying use, research and statistics, and trade-secret prejudice.
- **URL:** https://www.privacy.org.nz/resources-and-learning/a-z-topics/ipp3a/
- UNVERIFIED: the date of Royal Assent.

### Biometric Processing Privacy Code 2025
- **Issued:** Aug 2025.
- **In force:** **3 Nov 2025** for new processing. Processing that existed before 3 Nov 2025 must comply by **3 Aug 2026**.
- **Key rules:**
  - Rule 1: proportionality assessment, effectiveness, and the least privacy-intrusive alternative.
  - Enhanced notice: alternatives, complaints, and where the assessment is available.
  - Limits on biometric categorisation (inferring emotion, personality, mood).
- **Amendment No 1** adds **rule 3A** (indirect collection of biometrics). It commences 1 May 2026 for processing begun after 3 Nov 2025, and 3 Aug 2026 for earlier processing.
- **URLs:**
  - https://www.privacy.org.nz/assets/Codes-of-Practice-2020/Biometrics-Processing-Privacy-Code-2025-website-version.pdf
  - https://www.privacy.org.nz/assets/Codes-of-Practice-2020/Amendment-No-1-to-Biometrics-Processing-Privacy-Code-2025.pdf
  - https://www.bellgully.com/insights/biometrics-regulation-arrives-are-you-ready/
- UNVERIFIED: the rule number of the restrictions on categorisation (believed to be Rule 10).

### OPC guidance: *Artificial intelligence and the Information Privacy Principles*
- **Published:** Sep 2023 (reported 26 Sep 2023).
- **Content:** All IPPs apply to AI. It expects:
  - privacy considered early (PIAs)
  - human review of automated decisions affecting people
  - accuracy checks on training data
  - transparency and opt-out where personal information is used for training
  - caution on the "publicly available" exception
  - Māori perspectives
- **Source:** https://www.russellmcveagh.com/Insights/September-2023/AI-tools-OPC-releases-guidance-for-organisations-u
- UNVERIFIED: whether OPC has updated it since.

### Public Service AI Framework (GCDO/DIA)
- **Released:** **29 Jan 2025**. Non-binding.
- **Principles (OECD-aligned):**
  - inclusive, sustainable development
  - human-centred values
  - transparency and explainability
  - safety and security
  - accountability
- **Work-programme pillars:** governance, guardrails, capability, innovation, social licence, global voice.
- **Related:** "Responsible AI Guidance for the Public Service: GenAI".
- **URL:** https://www.digital.govt.nz/standards-and-guidance/technology-and-architecture/artificial-intelligence/public-service-artificial-intelligence-framework

### National AI strategy and business guidance (MBIE)
- *New Zealand's Strategy for Artificial Intelligence: Investing with confidence* and *Responsible AI Guidance for Businesses* (voluntary) were released together on **8 Jul 2025**.
- The strategy is OECD-principles-based and adoption-first. **No AI-specific law.**
- **URLs:**
  - https://www.mbie.govt.nz/about/news/artificial-intelligence-strategy-and-business-guidance-now-available
  - https://www.mbie.govt.nz/assets/responsible-ai-guidance-for-businesses.pdf

### Algorithm Charter for Aotearoa New Zealand (Stats NZ)
- **Launched:** Jul 2020.
- **Signatories:** 29 current.
- **Six commitment areas:** transparency, partnership (Te Tiriti), people, data, privacy/ethics/human rights, human oversight.
- **Risk matrix:** likelihood × impact.
- **Review:** an independent review (Taylor Fry) was completed Dec 2021. The data.govt.nz page was last reviewed Jun 2023. No 2025–26 refresh was found. **STATUS UNCERTAIN:** whether it is being folded into the GCDO framework.
- **URL:** https://data.govt.nz/toolkit/data-ethics/government-algorithm-transparency-and-accountability/algorithm-charter

---

## Items to re-verify before publishing
1. The EU AI Act Art 113 operative text as amended by 2026/1744: the exact list of articles tied to 2 Dec 2027 and 2 Aug 2028.
2. The scope of the new Art 4a: high-risk only, or all AI systems and GPAI models.
3. Colorado SB 26-189 signing, on leg.colorado.gov or the Governor's site.
4. The sectoral US items: HIPAA Security Rule final rule status, FDA AI device lifecycle guidance (final?), and the Section 1557 §92.210 date.
5. ISO/IEC 42001 Annex A titles verbatim from the standard. Current titles come from a secondary source.
6. The BS11 transition deadlines and the BS11 revocation date under the DTA.
7. The COSAiS overlay drafts and NIST IR 8596 initial public draft, after Jan–May 2026.
