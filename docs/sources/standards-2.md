# Standards research batch 2 — ISO 19011, ISO/IEC 42005, OWASP GenAI, MITRE ATLAS, NIST AI RMF, NIST SP 800-61

Research date: 2026-10-13. Every fact below was taken from issuer pages (iso.org, owasp.org / genai.owasp.org / owaspai.org / aivss.owasp.org, atlas.mitre.org / github.com/mitre-atlas, nist.gov / csrc.nist.gov / nvlpubs.nist.gov). Where an issuer's own text was only reachable through a reseller preview of the issuer PDF (ANSI webstore preview pages of the ISO document), this is stated. Anything not confirmed is marked **UNVERIFIED:**.

Headline corrections versus the brief:

- **ISO 19011:2018 is no longer current.** ISO withdrew it on 2026-05-27 and published **ISO 19011:2026 (4th edition)** the same day. Repos should cite ISO 19011:2026.
- **OWASP published a 2026 edition of the LLM Top 10** (3 Aug 2026) with re-ordered entries and one rename (System Prompt Leakage → Hidden Context Exposure). The 2025 list in the brief is correct for the 2025 edition only.
- **MITRE ATLAS no longer uses v5.x.** Since release 2026.05 the content version is `YYYY.MM` (current **2026.09**, 2026-09-15) with data format v6.0.0. Several mitigation titles in the brief are out of date (e.g. AML.M0004 is now "Limit AI Service Query Volume and Rate"; AML.M0019 is "...in Production", not "...at Rest").
- **NIST AI RMF**: nist.gov says only that "The AI RMF 1.0 is being revised as part of the White House AI Action Plan" — no draft, number ("1.1"/"2.0"), RFI or date is published on the AI RMF page.

---

## 1. ISO 19011 — Guidelines for auditing management systems

### Status (as of Oct 2026)

| Item | Fact | Source |
|---|---|---|
| Current edition | **ISO 19011:2026**, Edition 4, published **2026-05-27** (cover date 2026-05), 46 pages, stage 60.60, ISO/TMBG (prepared by ISO/PC 302, Vienna Agreement with CEN/CLC/JTC 1), ICS 03.120.20 | https://www.iso.org/standard/19011 |
| Previous edition | **ISO 19011:2018**, Edition 3, published 2018-07-03, 46 pages — **Withdrawn 2026-05-27** (stage 95.99). Life cycle: systematic review 2022-07-15; review closed 2022-12-03; "to be revised" 2023-10-02; withdrawn 2026-05-27 | https://www.iso.org/standard/70017.html |
| Revision history of the 2026 edition | New project approved 2024-02-01; CD 2024-05-22; DIS registered 2025-01-15; DIS ballot 2025-03-17→2025-06-10; FDIS registered 2025-12-15; FDIS ballot 2026-02-16→2026-04-14; published 2026-05-27 | https://www.iso.org/standard/19011 |
| No further revision in progress | ISO page shows no 90.x review stage dates for ISO 19011:2026 | https://www.iso.org/standard/19011 |
| Main changes in 2026 edition (Foreword) | Technically revised; expanded guidance on **remote auditing methods** (drawing on ISO/IEC TS 17012); expanded Annex A with guidance on remote auditing and virtual locations | Foreword of ISO 19011:2026 via ANSI preview of the ISO PDF: https://webstore.ansi.org/preview-pages/ISO/preview_ISO+19011-2026.pdf |

### Clause structure (ISO 19011:2026; same top-level structure as 2018)

| Clause | Title |
|---|---|
| 1 | Scope |
| 2 | Normative references |
| 3 | Terms and definitions |
| 4 | Principles of auditing (4.1 General; 4.2–4.8 the seven principles) |
| 5 | Managing an audit programme (5.1 General; 5.2 Establishing audit programme objectives; 5.3 Determining and evaluating audit programme risks and opportunities; 5.4 Establishing the audit programme; 5.5 Implementing the audit programme; 5.6 Monitoring the audit programme; 5.7 Reviewing and improving the audit programme) |
| 6 | Conducting an audit (6.1 General; 6.2 Initiating the audit; 6.3 Preparing auditing activities; 6.4 Conducting auditing activities; 6.5 Preparing and distributing the audit report; 6.6 Completing the audit; 6.7 Conducting the audit follow-up) |
| 7 | Competence and evaluation of auditors (7.1 General; 7.2 Determining auditor competence; 7.3 Establishing the auditor evaluation criteria; 7.4 Selecting the appropriate auditor evaluation method; 7.5 Conducting the auditor evaluation; 7.6 Maintaining and improving auditor competence) |
| Annex A (informative) | Additional guidance for auditors for planning and conducting audits |
| — | Bibliography |

Notable 6.4 subclauses: 6.4.7 Collecting and verifying information; 6.4.8 Generating the audit findings; 6.4.9 Determining the audit conclusions; 6.4.10 Conducting the closing meeting.

### The seven principles of auditing (clause 4, exact titles)

| Subclause | Principle |
|---|---|
| 4.2 | Integrity |
| 4.3 | Fair presentation |
| 4.4 | Due professional care |
| 4.5 | Confidentiality |
| 4.6 | Independence |
| 4.7 | Evidence-based approach |
| 4.8 | Risk-based approach |

(The brief wrote "5.?" — the principles are in **clause 4**, not 5. Clause 5 is the audit programme.) The 2018 edition had the same seven principles under the same clause 4 numbering. **UNVERIFIED:** 2018 subclause numbering 4.2–4.8 was not re-fetched; the 2026 numbering above is confirmed.

### Relationship to ISO/IEC 42001 clause 9.2 and ISO/IEC 42006:2025

- ISO/IEC 42001:2023 clause **9.2 Internal audit** (9.2.1 General; 9.2.2 Internal audit programme) requires the organisation to plan, establish, implement and maintain an audit programme — the harmonised-structure wording that ISO 19011 is written to support. ISO 19011 is the guideline (not a requirements standard) for the audit programme (cl. 5), the conduct of individual audits (cl. 6) and auditor competence (cl. 7). Source for 42001 clause titles: ANSI preview of the ISO PDF https://webstore.ansi.org/preview-pages/ISO/preview_ISO+IEC+42001-2023.pdf . **UNVERIFIED:** whether ISO 19011 is explicitly cited in the 42001 bibliography (not checked).
- **ISO/IEC 42006:2025** "Information technology — Artificial intelligence — Requirements for bodies providing audit and certification of artificial intelligence management systems", Edition 1, published **2025-07-07**, 31 pages, ISO/IEC JTC 1/SC 42, ICS 35.020 and 03.120.20. It **supplements ISO/IEC 17021-1** with AI-specific requirements for certification bodies auditing ISO/IEC 42001 AIMS, and may be used with ISO/IEC 17065 schemes. The iso.org page does not mention ISO 19011. https://www.iso.org/standard/44546.html
- Practical division: ISO 19011 → first-party (internal) and second-party audits of an AIMS; ISO/IEC 42006 (+17021-1) → third-party certification audits. **UNVERIFIED:** whether 42006 normatively references 19011 (full text not accessed).

---

## 2. ISO/IEC 42005:2025 — AI system impact assessment

### Status

| Item | Fact | Source |
|---|---|---|
| Reference / title | ISO/IEC 42005:2025 "Information technology — Artificial intelligence (AI) — AI system impact assessment" | https://www.iso.org/standard/44545.html |
| Publication | Edition 1, **published 2025-05-28** (cover 2025-05), stage 60.60, 39 pages, ISO/IEC JTC 1/SC 42, ICS 35.020 | same |
| ISO description | Guides organisations in assessing how AI systems and their foreseeable applications may affect individuals, groups or society; supports transparency, accountability and trust by helping identify, evaluate and document potential impacts across the AI system life cycle. Related standards named by ISO: ISO/IEC 42001, ISO/IEC 38507, ISO/IEC 23894 | same |

### Clause structure (from the ISO PDF, via ANSI preview https://webstore.ansi.org/preview-pages/ISO/preview_ISO+IEC+42005-2025.pdf)

| Clause | Title |
|---|---|
| 1 | Scope |
| 2 | Normative references |
| 3 | Terms and definitions |
| 4 | Abbreviated terms |
| 5 | **Developing and implementing an AI system impact assessment process** — 5.1 General; 5.2 Documenting the process; 5.3 Integration with other organizational management processes; 5.4 Timing of AI system impact assessment; 5.5 Scope of the AI system impact assessment; 5.6 Allocating responsibilities; 5.7 Establishing thresholds for sensitive uses, restricted uses and impact scales; 5.8 Performing the AI system impact assessment; 5.9 Analysing the results of the AI system impact assessment; 5.10 Recording and reporting; 5.11 Approval process; 5.12 Monitoring and review |
| 6 | **Documenting the AI system impact assessment** — 6.1 General; 6.2 Scope of the AI system impact assessment; 6.3 AI system information (6.3.1 description; 6.3.2 functionalities and capabilities; 6.3.3 purpose; 6.3.4 Intended uses; 6.3.5 Unintended uses); 6.4 Data information and quality (6.4.2 Data information; 6.4.3 Data quality documentation); 6.5 Algorithm and model information (6.5.2–6.5.5 algorithms used / algorithm development / models used / model development); 6.6 Deployment environment (6.6.1 Geographical area and languages; 6.6.2 complexity and constraints); 6.7 Relevant interested parties (6.7.2 Directly affected interested parties; 6.7.3 Other relevant interested parties); 6.8 Actual and reasonably foreseeable impacts (6.8.2 Benefits and harms; 6.8.3 AI system failures and reasonably foreseeable misuse); 6.9 Measures to address harms and benefits |
| Annex A (informative) | Guidance for use with ISO/IEC 42001 |
| Annex B (informative) | Guidance for use with ISO/IEC 23894 |
| Annex C (informative) | Harms and benefits taxonomy |
| Annex D (informative) | Aligning AI system impact assessment with other assessments |
| Annex E (informative) | Example of an AI system impact assessment template |
| — | Bibliography |

Note: the brief guessed "4 understanding, 5 … process, 6 documentation". Actual: clause 4 is Abbreviated terms; the process is **clause 5**, documentation is **clause 6**.

### What an impact assessment must cover (mapped to the brief's list)

| Brief topic | Where in 42005 |
|---|---|
| Intended use | 6.3.3 Purpose, 6.3.4 Intended uses, 6.3.5 Unintended uses; 6.8.3 reasonably foreseeable misuse |
| Affected individuals / groups / society | 6.7 Relevant interested parties (6.7.2 directly affected; 6.7.3 other) |
| Benefits / harms | 6.8 Actual and reasonably foreseeable impacts; 6.8.2 Benefits and harms; Annex C harms and benefits taxonomy; 6.9 Measures to address harms and benefits |
| Data quality | 6.4 Data information and quality (6.4.3 Data quality documentation) |
| Algorithmic / fairness | 6.5 Algorithm and model information; fairness-type harms sit in Annex C taxonomy (**UNVERIFIED:** exact taxonomy headings — Annex C body text not accessed) |
| Transparency / explainability, accountability | Introduction frames the assessment as a transparency/accountability instrument; 5.6 Allocating responsibilities; 5.10 Recording and reporting; 5.11 Approval process |
| Timing / triggers | 5.4 Timing of AI system impact assessment; 5.7 thresholds for sensitive uses, restricted uses and impact scales; 5.12 Monitoring and review |
| Integration with ISO/IEC 42001 6.1.4 / 8.4 | 5.3 Integration with other organizational management processes; **Annex A Guidance for use with ISO/IEC 42001**. ISO/IEC 42001 clause 6.1.4 and 8.4 are both titled "AI system impact assessment" (confirmed from 42001 ToC) |
| Integration with ISO/IEC 23894 | **Annex B Guidance for use with ISO/IEC 23894**; the introduction ties 23894 to risk management and 38507 to governance |
| Other assessments (privacy/DPIA, human rights, etc.) | Annex D Aligning AI system impact assessment with other assessments |

### Applicable to governance programmes?

**Yes.** ISO positions 42005 as guidance for any organisation developing, providing or using AI systems, and dedicates Annex A to use with ISO/IEC 42001, whose clauses 6.1.4 and 8.4 require an AI system impact assessment process and its operation. In ISO/IEC 42001 Annex A the impact-assessment control objective is **A.5 "Assessing impacts of AI systems"** — **UNVERIFIED:** exact A.5 wording and controls A.5.1–A.5.5 were not visible in the preview fetched; the clause 6.1.4/8.4/9.2 titles and Annex A/B/C/D titles were confirmed. ISO's own page: "supports transparency, accountability, and trust … across the AI system lifecycle." URL: https://www.iso.org/standard/44545.html

---

## 3. OWASP GenAI Security Project

### (a) OWASP Top 10 for LLM Applications — 2025 edition (confirmed) and 2026 edition (exists)

**2025 edition** — list page https://genai.owasp.org/llm-top-10/ ; resource page https://genai.owasp.org/resource/owasp-top-10-for-llm-applications-2025/ ; announcement 17 Nov 2024 https://genai.owasp.org/2024/11/17/owasp-reveals-updated-2025-top-10-risks-for-llms-announces-new-llm-project-sponsorship-program-and-inaugural-sponsors/

| ID | Title (2025) |
|---|---|
| LLM01:2025 | Prompt Injection |
| LLM02:2025 | Sensitive Information Disclosure |
| LLM03:2025 | Supply Chain |
| LLM04:2025 | Data and Model Poisoning |
| LLM05:2025 | Improper Output Handling |
| LLM06:2025 | Excessive Agency |
| LLM07:2025 | System Prompt Leakage |
| LLM08:2025 | Vector and Embedding Weaknesses |
| LLM09:2025 | Misinformation |
| LLM10:2025 | Unbounded Consumption |

The brief's 2025 list is **confirmed exactly**.

**2026 edition — exists.** "OWASP GenAI LLM Top 10 2026", published on genai.owasp.org **3 August 2026**, cover file name "2026-OWASP-GenAI-LLM-Top-10-v1.0" (version "2026" inside the document). Resource page: https://genai.owasp.org/resource/owasp-genai-llm-top-10-2026/ ; download https://genai.owasp.org/download/56857/ . The downloaded document still shows "[Publication date to be set]" placeholders inside, so treat the internal date as pending; the site date is 3 Aug 2026.

| ID | Title (2026) | Change vs 2025 |
|---|---|---|
| LLM01:2026 | Prompt Injection | unchanged (#1); scope now includes cross-modal injection (images/audio) |
| LLM02:2026 | Sensitive Information Disclosure | unchanged (#2) |
| LLM03:2026 | Excessive Agency | up from #6 (largest rise) |
| LLM04:2026 | Supply Chain | down from #3; now covers model artifacts that are not what they claim |
| LLM05:2026 | Data and Model Poisoning | down from #4; now includes fine-tuning subversion |
| LLM06:2026 | Unbounded Consumption | up from #10 |
| LLM07:2026 | Misinformation | up from #9 |
| LLM08:2026 | Hidden Context Exposure | **renamed** from System Prompt Leakage (#7), broadened |
| LLM09:2026 | Vector and Embedding Weaknesses | down from #8 |
| LLM10:2026 | Improper Output Handling | down from #5 (largest drop); now covers insecure AI-generated code at scale |

No new categories; newer risks were folded into existing entries (per the document's own change notes). Source: the 2026 PDF at the download URL above.

### (b) OWASP Top 10 for Agentic Applications (for 2026)

- Title on site: "OWASP Top 10 for Agentic Applications for 2026". Published **9 December 2025** (press release datelined 10 Dec 2025); developed with 100+ contributors. Page: https://genai.owasp.org/owasp-top-10-for-agentic-applications ; resource: https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/ ; press: https://genai.owasp.org/2025/12/09/owasp-genai-security-project-releases-top-10-risks-and-mitigations-for-agentic-ai-security/ ; download: https://genai.owasp.org/download/52117/ . Version string inside the document: "2026" (cover file name suggests "12.6" build; no formal semantic version).

| ID | Exact title | Maps to LLM Top 10 (2025) | Maps to ASI Threats (T-codes) |
|---|---|---|---|
| ASI01 | Agent Goal Hijack | LLM01, LLM06 | T6, T7 |
| ASI02 | Tool Misuse and Exploitation | LLM06 | T2, T4, T16 |
| ASI03 | Identity and Privilege Abuse | LLM01, LLM02, LLM06 | T3 |
| ASI04 | Agentic Supply Chain Vulnerabilities | LLM03 | T2, T11, T12, T13, T16, T17 |
| ASI05 | Unexpected Code Execution (RCE) | LLM01, LLM05 | T11 |
| ASI06 | Memory & Context Poisoning | LLM01, LLM04, LLM08 | T1, T4, T6, T12 |
| ASI07 | Insecure Inter-Agent Communication | LLM02, LLM06 | T12, T16 |
| ASI08 | Cascading Failures | LLM01, LLM04, LLM06 | T5, T8 |
| ASI09 | Human-Agent Trust Exploitation | LLM01, LLM05, LLM06, LLM09 | T7, T8, T10 |
| ASI10 | Rogue Agents | LLM02, LLM09 | T13, T14, T15 |

Differences from the brief: ASI04 is "Agentic Supply Chain Vulnerabilities" (not plain "Supply Chain"); ASI05 is "Unexpected Code Execution (RCE)"; ASI02 is "Tool Misuse **and Exploitation**". The press release also refers to ASI01 as "Agent Behavior Hijacking" in prose; the document's entry title is "Agent Goal Hijack". Appendices map to OWASP Non-Human Identities Top 10 (NHI1–NHI10) and CycloneDX AI-BOM. (T16/T17 referenced in the mapping table imply the threat taxonomy grew past T15 — see (c).)

### (c) Other OWASP GenAI / AI security publications (issuer-confirmed)

| Publication | Version / date | URL |
|---|---|---|
| **OWASP AI Exchange** (home of the former "AI Security and Privacy Guide"; OWASP Flagship since March 2025; CC0; 300+ pages; sections 0 AI Security Overview, 1 General controls, 2 Input threats, 3 Development-time threats, 4 Runtime conventional security threats, 5 AI security testing, 6 AI privacy; liaison contributions to ISO/IEC 27090, ISO/IEC 27091 and prEN 18282 for the EU AI Act; "major update before summer 2026" announced) | living document, no version number | https://owaspai.org/ ; project page https://owasp.org/www-project-ai-security-and-privacy-guide/ |
| **Agentic AI – Threats and Mitigations** (first ASI guide) | site date **17 Feb 2025** (v1.0); the download now serves **v1.1, December 2025** | https://genai.owasp.org/resource/agentic-ai-threats-and-mitigations/ |
| Threat taxonomy in that guide (v1.1) | T1 Memory Poisoning; T2 Tool Misuse; T3 Privilege Compromise; T4 Resource Overload; T5 Cascading Hallucination Attacks; T6 Intent Breaking & Goal Manipulation; T7 Misaligned & Deceptive Behaviors; T8 Repudiation & Untraceability; T9 Identity Spoofing & Impersonation / Agent Identity Compromise; T10 Overwhelming Human in the Loop; T11 Unexpected RCE and Code Attacks; T12 Agent Communication Poisoning; T13 Rogue Agents in Multi-Agent Systems; T14 Human Attacks on Multi-Agent Systems; T15 Human Manipulation. **UNVERIFIED:** T16/T17 names (cited by the Agentic Top 10 mapping but not in the v1.1 list extracted) | same download |
| **State of Agentic AI Security and Governance** | v1.0 (earlier resource page) → **v2.01, 1 June 2026** | https://genai.owasp.org/resource/state-of-agentic-ai-security-and-governance/ |
| **AIVSS – OWASP AI Vulnerability Scoring System** ("AIVSS Scoring System for OWASP Agentic AI Core Security Risks") | **v0.8** current; v0.5 archived; v1.0 "expected by end of this year"; AIUC-1 integration announced 27 Feb 2026. **UNVERIFIED:** v0.8 release date | https://aivss.owasp.org/ |
| **A Practical Guide for Secure MCP Server Development** | ~Feb 2026 (**UNVERIFIED:** exact date; inferred from site asset path) | https://genai.owasp.org/resource/a-practical-guide-for-secure-mcp-server-development/ |
| **AI Security Solutions Landscape for Agentic AI Q2 2026** | Q2 2026 | https://genai.owasp.org/resource/ai-security-solutions-landscape-for-agentic-ai-q2-2026/ |
| **AIUC-1: Crosswalks OWASP Top 10 for Agentic Applications** | ~May 2026 (**UNVERIFIED** exact date) | https://genai.owasp.org/resource/aiuc-1-crosswalks-owasp-top-10-for-agentic-applications/ |
| **Agent Control Standard (ACS)** | **1 Sep 2026** | https://genai.owasp.org/resource/agent-control-standard-acs/ |
| **GenAI Security Industry Framework Crosswalk** | **1 Sep 2026** | https://genai.owasp.org/resource/genai-security-industry-framework-crosswalk/ |
| Agentic Security Initiative hub (announced 15 Dec 2024) | — | https://genai.owasp.org/initiatives/agentic-security-initiative/ |
| "A Practical Guide to Securing Agentic Applications" (v1.0, referenced in the Dec 2025 press release) | **UNVERIFIED:** date/URL not fetched | — |
| "Agentic AI Maturity Model", "Agent Observability" | **UNVERIFIED:** not found on the ASI pages fetched | — |

### (d) OWASP LLM AI Cybersecurity & Governance Checklist

- Current: **"LLM Applications Cybersecurity and Governance Checklist v1.1"** (English), released **7 May 2024**. Resource: https://genai.owasp.org/resource/llm-applications-cybersecurity-and-governance-checklist/ ; download https://genai.owasp.org/download/42720/ . (v1.0 was titled "LLM AI Security and Governance Checklist", Feb 2024 — v1.0 FR copy still hosted at https://owasp.org/www-project-top-10-for-large-language-model-applications/llm-top-10-governance-doc/LLM_AI_Security_and_Governance_Checklist-v1_FR.pdf .) **UNVERIFIED:** whether a v2 exists under the "AI Security Governance and Adoption" initiative (https://genai.owasp.org/initiatives/ai-security-governance-and-adoption/ not fetched).

---

## 4. MITRE ATLAS

### Current version and structure (from the issuer data repo, release 2026.09)

| Item | Fact | Source |
|---|---|---|
| Current release | **ATLAS 2026.09**, release date **2026-09-15** (CHANGELOG says 2026-09-14), data **format-version 6.0.0** | https://github.com/mitre-atlas/atlas-data (dist/manifest.yaml, dist/v6/ATLAS-2026.09.yaml) |
| Versioning scheme | Monthly content releases `YYYY.MM` (since 2026.05, 2026-05-27) + semantic format version; before that combined SemVer (last: 5.6.1, 2026-05-05; 5.6.0, 2026-04-30; 5.0.0, 2025-09-30 introduced Technique Maturity field: Feasible / Demonstrated / Realized). `dist/ATLAS.yaml` (v5.6.0) is deprecated | README + CHANGELOG |
| Counts (2026.09) | **16 tactics; 120 techniques + 88 sub-techniques (208 objects); 40 mitigations; 73 case studies** | parsed ATLAS-2026.09.yaml; matches CHANGELOG totals |
| Platforms (since 2026.05) | every technique tagged with ≥1 of Predictive AI, Generative AI, Agentic AI, Enterprise (2026.09 tags: Agentic AI 139, Generative AI 106, Enterprise 85, Predictive AI 82 technique objects) | parsed data |
| Site | https://atlas.mitre.org/ (matrix at /matrices/ATLAS, mitigations at /mitigations, techniques at /techniques/AML.T####) | — |
| ATLAS Navigator | Navigator layers generated by `tools/generate_navigator_layers.py`, targeting ATT&CK Navigator 5.3.2, layer format 4.5, custom `atlas-atlas` domain; STIX bundles `stix-atlas.json` and `stix-atlas-attack-enterprise.json` (added 2026.07) | README |

### 16 tactics (2026.09), with IDs

| ID | Tactic |
|---|---|
| AML.TA0002 | Reconnaissance |
| AML.TA0003 | Resource Development |
| AML.TA0004 | Initial Access |
| AML.TA0000 | AI Model Access |
| AML.TA0005 | Execution |
| AML.TA0006 | Persistence |
| AML.TA0012 | Privilege Escalation |
| AML.TA0007 | Defense Evasion |
| AML.TA0013 | Credential Access |
| AML.TA0008 | Discovery |
| AML.TA0015 | Lateral Movement (added 5.1.0, Nov 2025) |
| AML.TA0009 | Collection |
| AML.TA0001 | **AI Attack Adaptation** (renamed from "AI Attack Staging" in 2026.08) |
| AML.TA0014 | Command and Control |
| AML.TA0010 | Exfiltration |
| AML.TA0011 | Impact |

(Matrix display order as in the 5.6.0 matrix; the 2026.09 file lists tactics by ID.)

### Key GenAI / agentic techniques (2026.09 names, platforms, maturity)

| ID | Name | Platforms | Maturity |
|---|---|---|---|
| AML.T0051 | LLM Prompt Injection | GenAI, Agentic | Realized |
| AML.T0051.000 / .001 / .002 | Direct / Indirect / Triggered | GenAI, Agentic (Triggered: Agentic) | Realized / Demonstrated / Demonstrated |
| AML.T0054 | LLM Jailbreak | GenAI, Agentic | Realized |
| AML.T0068 | LLM Prompt Obfuscation | GenAI, Agentic | Realized |
| AML.T0070 | RAG Poisoning | GenAI, Agentic | Demonstrated |
| AML.T0077 | LLM Response Rendering | GenAI, Agentic | Demonstrated |
| AML.T0053 | AI Agent Tool Invocation | Agentic | Demonstrated |
| AML.T0099 | AI Agent Tool Data Poisoning | Agentic | Feasible |
| AML.T0100 | AI Agent Clickbait | Agentic | Demonstrated |
| AML.T0103 | Deploy AI Agent | Agentic | Realized |
| AML.T0108 | AI Agent | Agentic | Demonstrated |
| AML.T0109 | AI Supply Chain Rug Pull | all AI | Realized |
| AML.T0110 (.000 Definition and Instructions; .001 Implementation; .002 Runtime Response) | AI Agent Tool Poisoning | Agentic | Realized |
| AML.T0111 | AI Supply Chain Reputation Inflation | all AI | Demonstrated |
| AML.T0116 / T0117 / T0124 | Autonomous Reconnaissance / Autonomous Attack-Path Adaptation / Autonomous Attack Orchestration (2026.08) | all | Realized |
| AML.T0118 (.000 Communication via Shared Artifacts; .001 Direct Agent Communication) | Autonomous AI Agent Communication | Agentic, Enterprise | Realized |
| AML.T0130 / T0131 / T0133 | AI Agent Response Biasing / Crafted AI Assistant Links / Discover AI Agent Runtime Capabilities (2026.09) | GenAI/Agentic | Realized / Realized / Feasible |
| AML.T0016.004, AML.T0017.002, AML.T0010.005, AML.T0002.002 | Obtain Capabilities: AI Agent Tools; Develop Capabilities: AI Agent Tools; AI Supply Chain: AI Agent Tool; Acquire Public AI Artifacts: AI Agent Configuration | — | — |

**MCP coverage**: no technique is named "MCP"; MCP appears in technique descriptions (AML.T0110 AI Agent Tool Poisoning, AML.T0010.005, AML.T0016.004, AML.T0017.002, AML.T0002.002, AML.T0111) and in case studies **AML.CS0045 Data Exfiltration via an MCP Server used by Cursor**, **AML.CS0053 Poisoned Postmark MCP Server Email Exfiltration**, **AML.CS0054 Data Exfiltration via Remote Poisoned MCP Tool** (5.5.0, Mar 2026), plus AML.CS0039 Living Off AI: Prompt Injection via Jira Service Management.

### Mitigations — full list, 2026.09 (40)

| ID | Title (2026.09) | Note vs brief |
|---|---|---|
| AML.M0000 | Limit Public Release of Information | |
| AML.M0001 | Limit Model Artifact Release | |
| AML.M0002 | Predictive AI Output Obfuscation | renamed 2026.07 (was Passive AI Output Obfuscation) |
| AML.M0003 | Predictive AI Model Hardening | renamed (was Model Hardening) |
| AML.M0004 | **Limit AI Service Query Volume and Rate** | brief said "Restrict Number of ML Model Queries" — old title |
| AML.M0005 | **Control Access to AI Models and Data at Rest** | brief attached this title to M0019 — wrong ID |
| AML.M0006 | Predictive AI Ensembles | renamed (was Use Ensemble Methods) |
| AML.M0007 | Sanitize Training Data | |
| AML.M0008 | Validate AI Model | |
| AML.M0009 | Predictive AI Multi-Sensor Fusion | renamed (was Use Multi-Modal Sensors) |
| AML.M0010 | Predictive AI Input Restoration | renamed |
| AML.M0011 | Restrict Library Loading | |
| AML.M0012 | Encrypt Sensitive Information | |
| AML.M0013 | Code Signing | |
| AML.M0014 | Verify AI Artifacts | |
| AML.M0015 | **Predictive AI Adversarial Input Detection** | brief said "Adversarial Input Detection" — renamed 2026.07 |
| AML.M0016 | Vulnerability Scanning | confirmed |
| AML.M0017 | AI Model Distribution Methods | |
| AML.M0018 | User Training | confirmed |
| AML.M0019 | **Control Access to AI Models and Data in Production** | brief said "...at Rest" — that is M0005 |
| AML.M0020 | Generative AI Guardrails | confirmed (updated 2026.06, 2026.07, 2026.09) |
| AML.M0021 | Generative AI Guidelines | confirmed |
| AML.M0022 | Generative AI Model Alignment | confirmed |
| AML.M0023 | AI Bill of Materials | confirmed |
| AML.M0024 | AI Telemetry Logging | confirmed |
| AML.M0025 | Maintain AI Dataset Provenance | confirmed |
| AML.M0026 | Privileged AI Agent Permissions Configuration | added 5.1.0 |
| AML.M0027 | Single-User AI Agent Permissions Configuration | added 5.1.0 |
| AML.M0028 | AI Agent Tools Permissions Configuration | added 5.1.0 |
| AML.M0029 | Human In-the-Loop for AI Agent Actions | added 5.1.0 |
| AML.M0030 | Restrict AI Agent Tool Invocation on Untrusted Data | added 5.1.0 |
| AML.M0031 | Memory Hardening | added 5.1.0 |
| AML.M0032 | Segmentation of AI Agent Components | |
| AML.M0033 | Input and Output Validation for AI Agent Components | |
| AML.M0034 | Deepfake Detection | |
| AML.M0035 | AI Red Team | added 2026.07 |
| AML.M0036 | Limit AI Workload Resource Consumption | added 2026.07 |
| AML.M0037 | AI Agent Authority Expansion Controls | added 2026.08 |
| AML.M0038 | AI Agent Scope Drift Detection | added 2026.08 |
| AML.M0039 | AI Honeypots | added 2026.09 |

Sources: https://raw.githubusercontent.com/mitre-atlas/atlas-data/main/dist/v6/ATLAS-2026.09.yaml ; CHANGELOG https://raw.githubusercontent.com/mitre-atlas/atlas-data/main/CHANGELOG.md ; site pages https://atlas.mitre.org/mitigations/AML.M#### (**UNVERIFIED:** site rendering not fetched; data repo is the authoritative source the site is built from). The ATLAS Fact Sheet (https://atlas.mitre.org/pdf-files/MITRE_ATLAS_Fact_Sheet.pdf) is dated 2023-11-30 and out of date.

---

## 5. NIST AI RMF 1.0 and related

### AI RMF 1.0 (NIST AI 100-1)

- Released **26 January 2023**. PDF https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.100-1.pdf ; DOI https://doi.org/10.6028/NIST.AI.100-1 ; programme page https://www.nist.gov/itl/ai-risk-management-framework
- Core = 4 functions, **19 categories, 72 subcategories** (counted from the PDF):

| Function | Categories | Subcategories |
|---|---|---|
| GOVERN | 1–6 (6) | 19 (G1: 7, G2: 3, G3: 2, G4: 3, G5: 2, G6: 2) |
| MAP | 1–5 (5) | 18 (M1: 6, M2: 3, M3: 5, M4: 2, M5: 2) |
| MEASURE | 1–4 (4) | 22 (Me1: 3, Me2: 13, Me3: 3, Me4: 3) |
| MANAGE | 1–4 (4) | 13 (Mn1: 4, Mn2: 4, Mn3: 2, Mn4: 3) |

The brief's category ranges (GOVERN 1–6, MAP 1–5, MEASURE 1–4, MANAGE 1–4) are **confirmed**. Appendix A describes AI actor tasks (AI design, development, deployment, operation and monitoring, TEVV).

- **AI RMF Playbook**: companion published by NIST at https://airc.nist.gov/airmf-resources/playbook/ (the Trustworthy & Responsible AI Resource Center, launched 30 March 2023). Also Roadmap https://airc.nist.gov/airmf-resources/roadmap/ , Crosswalks and Perspectives. **UNVERIFIED:** Playbook's own last-updated date.

### Generative AI Profile — NIST AI 600-1

- "Artificial Intelligence Risk Management Framework: Generative Artificial Intelligence Profile", released **26 July 2024**; DOI https://doi.org/10.6028/NIST.AI.600-1 ; PDF https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf
- The 12 GAI risks (Section 2, exact titles): 2.1 CBRN Information or Capabilities; 2.2 Confabulation; 2.3 Dangerous, Violent, or Hateful Content; 2.4 Data Privacy; 2.5 Environmental Impacts; 2.6 Harmful Bias and Homogenization; 2.7 Human-AI Configuration; 2.8 Information Integrity; 2.9 Information Security; 2.10 Intellectual Property; 2.11 Obscene, Degrading, and/or Abusive Content; 2.12 Value Chain and Component Integration. **UNVERIFIED:** total count of Section 3 suggested actions (not stated in text; commonly cited as ~200+).

### Revision status (Oct 2026)

- nist.gov AI RMF page states verbatim (twice): **"The AI RMF 1.0 is being revised as part of the White House AI Action Plan."** No draft document, version label ("1.1" / "2.0"), RFI, workshop or target date is given on that page. https://www.nist.gov/itl/ai-risk-management-framework
- **No "AI RMF 2.0" draft was found on nist.gov** as of 2026-10-13. **UNVERIFIED:** any RFI/draft published elsewhere on nist.gov (search of nist.gov returned only the AI RMF page statement).
- New profile work: **7 April 2026** concept note for an "AI RMF Profile on Trustworthy AI in Critical Infrastructure" https://www.nist.gov/programs-projects/concept-note-ai-rmf-profile-trustworthy-ai-critical-infrastructure

### NIST AI 800-1 — Managing Misuse Risk for Dual-Use Foundation Models

- Author: U.S. AI Safety Institute (now CAISI) / NIST. Initial public draft **July 2024**; **second public draft announced 15 January 2025**, comments to 15 March 2025 (NISTAI800-1@nist.gov). Second draft added: appendix on model-evaluation practice, domain appendices (chem/bio misuse; cyber misuse), marginal-risk framing, proportional application to open-weight developers, supply-chain actors. Page: https://www.nist.gov/node/1871956 (nist.gov news item); ipd PDF https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.800-1.ipd.pdf
- **Status: still a second public draft; no final version found on nist.gov** as of Oct 2026. **UNVERIFIED:** whether NIST/CAISI has formally shelved or re-scoped it.

### Cyber AI Profile — NIST IR 8596

- "Cybersecurity Framework Profile for Artificial Intelligence (Cyber AI Profile): NIST Community Profile", **Initial Preliminary Draft (iprd) published 16 December 2025**, comments closed **30 January 2026** (comments "will inform the initial public draft"). Organised by CSF 2.0 Functions/Categories/Subcategories around three focus areas: **Secure** (AI system components), **Defend** (AI-enabled cyber defence), **Thwart** (AI-enabled attacks). Events: Cyber AI Workshop #2 14 Jan 2026; virtual working sessions 28 Apr, 5 May, 12 May 2026. https://csrc.nist.gov/pubs/ir/8596/iprd ; PDF https://nvlpubs.nist.gov/nistpubs/ir/2025/NIST.IR.8596.iprd.pdf ; news https://csrc.nist.gov/news/2025/nist-releases-prelim-draft-cyber-ai-profile ; NCCoE project https://www.nccoe.nist.gov/node/2581
- **Status: no initial public draft (ipd) or final listed in document history as of Oct 2026.** **UNVERIFIED:** whether an ipd was released after May 2026 (CSRC page fetched showed only the 12/16/25 entry).

---

## 6. NIST SP 800-61 — Rev. 3 vs Rev. 2

### Rev. 3 (current)

| Item | Fact |
|---|---|
| Title | SP 800-61 Rev. 3, **"Incident Response Recommendations and Considerations for Cybersecurity Risk Management: A CSF 2.0 Community Profile"** |
| Published | **April 2025** (metadata 3 April 2025); draft (ipd) 3 April 2024 |
| Authors | Alexander Nelson, Sanjay Rekhi, Murugiah Souppaya (NIST); Karen Scarfone (Scarfone Cybersecurity) |
| DOI / PDF | https://doi.org/10.6028/NIST.SP.800-61r3 ; https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r3.pdf |
| CSRC page | https://csrc.nist.gov/pubs/sp/800/61/r3/final ; news https://csrc.nist.gov/news/2025/nist-revises-sp-800-61 ; project page https://csrc.nist.gov/projects/incident-response |
| Supersedes | SP 800-61 Rev. 2 (6 Aug 2012) — stated on CSRC and inside the document ("supersedes SP 800-61r2 … Computer Security Incident Handling Guide"); §1.1 notes scope "differs significantly" from earlier versions, focusing on CSF 2.0 Functions rather than detailed incident-handling steps |

**Structure of Rev. 3**: Executive Summary; 1 Introduction (1.1 Purpose and Scope; 1.2 Document Structure); 2 Incident Response as Part of Cybersecurity Risk Management (2.1 Incident Response Life Cycle Model; 2.2 Roles and Responsibilities; 2.3 Policies, Processes, and Procedures); 3 CSF 2.0 Community Profile for Cyber Incident Risk Management (3.1 Preparation and Lessons Learned — Table 2; 3.2 Incident Response — Table 3); References; App. A Acronyms; App. B Glossary; App. C Change Log.

**Life cycle in Rev. 3 (Fig. 2, "Incident response life cycle model based on CSF 2.0 Functions")**: Govern, Identify and Protect form the preparation base (not themselves incident response); **Identify → Improvement (ID.IM)** feeds lessons learned into all Functions; **Detect, Respond, Recover** are the incident-response Functions. Rev. 3 says organisations may keep whichever life-cycle model suits them.

**Mapping of the Rev. 2 four phases to CSF 2.0 (Rev. 3 Table 1)**:

| Rev. 2 phase (2012) | CSF 2.0 Functions in Rev. 3 |
|---|---|
| Preparation | Govern; Identify (all Categories); Protect |
| Detection & Analysis | Detect; Identify (Improvement) |
| Containment, Eradication & Recovery | Respond; Recover; Identify (Improvement) |
| Post-Incident Activity | Identify (Improvement) |

**Community Profile priorities**: Table 2 (preparation) — GV mostly Low except GV.PO High, GV.RR Medium; ID Medium (ID.RA-02/-05/-06 and ID.IM-02/-03/-04 High); PR Medium (PR.DS-11 backups High). Table 3 (incident response) — all Categories High: DE.CM, DE.AE; RS.MA, RS.AN, RS.CO, RS.MI; RC.RP, RC.CO. Rows carry R (recommendation), C (consideration) or N (note).

### Rev. 2 (withdrawn)

- SP 800-61 Rev. 2 "Computer Security Incident Handling Guide", published **6 August 2012**; CSRC status **"Withdrawn on April 03, 2025"**, superseded by Rev. 3. https://csrc.nist.gov/pubs/sp/800/61/r2/final ; PDF https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r2.pdf ; DOI https://doi.org/10.6028/NIST.SP.800-61r2
- Rev. 2 four phases (as reproduced in Rev. 3 Table 1): Preparation; Detection & Analysis; Containment, Eradication & Recovery; Post-Incident Activity.

---

## Sources (issuer pages used)

- ISO: https://www.iso.org/standard/19011 · https://www.iso.org/standard/70017.html · https://www.iso.org/standard/44545.html · https://www.iso.org/standard/44546.html · ISO PDF previews via https://webstore.ansi.org/preview-pages/ISO/preview_ISO+19011-2026.pdf , …/preview_ISO+IEC+42005-2025.pdf , …/preview_ISO+IEC+42001-2023.pdf
- OWASP: https://genai.owasp.org/llm-top-10/ · https://genai.owasp.org/resource/owasp-genai-llm-top-10-2026/ · https://genai.owasp.org/owasp-top-10-for-agentic-applications · https://genai.owasp.org/2025/12/09/owasp-genai-security-project-releases-top-10-risks-and-mitigations-for-agentic-ai-security/ · https://genai.owasp.org/initiatives/agentic-security-initiative/ · https://genai.owasp.org/resource/agentic-ai-threats-and-mitigations/ · https://genai.owasp.org/resource/state-of-agentic-ai-security-and-governance/ · https://genai.owasp.org/resource/llm-applications-cybersecurity-and-governance-checklist/ · https://aivss.owasp.org/ · https://owaspai.org/ · https://owasp.org/www-project-ai-security-and-privacy-guide/
- MITRE: https://github.com/mitre-atlas/atlas-data (README, CHANGELOG.md, dist/manifest.yaml, dist/v6/ATLAS-2026.09.yaml) · https://atlas.mitre.org/
- NIST: https://www.nist.gov/itl/ai-risk-management-framework · https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.100-1.pdf · https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf · https://www.nist.gov/node/1871956 · https://csrc.nist.gov/pubs/ir/8596/iprd · https://csrc.nist.gov/pubs/sp/800/61/r3/final · https://csrc.nist.gov/pubs/sp/800/61/r2/final · https://csrc.nist.gov/news/2025/nist-revises-sp-800-61 · https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r3.pdf
