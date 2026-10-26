# Standards research batch 3 — ISO/IEC 27090, EN 18286, IEEE 2863, Australian AI standards

Research date: 2026-10-26. Issuer pages were used where they were reachable; where only a secondary source confirmed a fact, the catalogue entry is labelled `secondary` and the fact is marked below. Anything not confirmed is marked **UNVERIFIED:**. No standard's text was purchased or read; clause numbers are therefore not cited for these four entries.

Headline corrections versus the brief (a LinkedIn post, 18 Oct 2026):

- **IEEE 2863-2026 is a recommended practice**, not a normative standard: "IEEE Recommended Practice for Organizational Governance of Artificial Intelligence".
- **EN 18286:2026 does not by itself make a QMS compliant with Art 17.** It gives a presumption of conformity only for the Art 17(1) points listed in its Annex ZA, not for Art 17(2)–(4), and only while the Official Journal reference stands.
- **There are no "Australian Standards for AI" in force.** The Government announced them on 15 Jul 2026; legislation is expected in early 2027 and no bill has been tabled. What applies today is the voluntary Guidance for AI Adoption (AI6) and AS ISO/IEC 42001:2023.

Also corrected in this batch (found while re-checking related entries):

- **MAS AI Risk Management Guidelines**: issued 7 Oct 2026, take effect **7 Oct 2027**; sections 5–6 apply by **7 Oct 2028**. The catalogue previously assumed 1 Oct.
- **NZ Privacy Act 2020**: every phased date has passed (IPP 3A since 1 May 2026; the biometric code, in force since 3 Nov 2025, has covered existing processing since 3 Aug 2026), so the framework is now `in-force`.
- **Guidance for AI Adoption** was published on **21 Oct 2025** (the catalogue said 17 Oct 2025).

---

## 1. ISO/IEC 27090:2026 — Cybersecurity — Artificial intelligence — Addressing security threats and compromises to AI systems

| Item | Fact | Source | Label |
|---|---|---|---|
| Title | "Cybersecurity — Artificial intelligence (AI) — Addressing security threats and compromises to AI systems" (iso.org FDIS page: "Guidance for addressing security threats and compromises to artificial intelligence systems") | https://www.iso27001security.com/html/27090 ; https://www.iso.org/standard/56581.html | secondary (published title from iso27001security.com and cyberdelegate.com; the iso.org FDIS title differs) |
| Committee | ISO/IEC JTC 1/SC 27; edition 1 | https://www.iso.org/standard/56581.html | primary |
| Publication | Published 14 Oct 2026, 56 pages | https://www.cyberdelegate.com/iso-iec-27090-a-security-rulebook-for-ai-systems-finally-arrives/ | secondary — iso.org still showed stage 50.00 (FDIS) when checked on 26 Oct 2026 |
| Scope | Guidance for any organisation that develops or uses AI: understand, detect and mitigate security threats to AI systems across the life cycle; builds on ISO/IEC 27001/27002; draws on ISO/IEC 22989, 5338, 42001 and 38507 | iso.org abstract; iso27001security.com | primary |
| Threats covered | Data poisoning (incl. operational data reused for retraining), direct model poisoning, evasion, membership inference, model inversion, model stealing / exfiltration via legitimate-looking queries, prompt injection, sensitive information in outputs, outputs carrying injection attacks | iso27001security.com; cyberdelegate.com | secondary |
| Mitigation themes | Governance, zero-trust principles, secure engineering and development environments, supply-chain security, threat modelling, red teaming, logging and monitoring, malicious-input detection, limiting model use; safeguards can conflict; models and mitigations degrade over time | cyberdelegate.com | secondary |
| Out of scope | Largely excludes accidental failures and insider threats; excludes AI-versus-AI attacks | iso27001security.com | secondary |
| Certifiable? | No — guidance only; there is no "27090 certificate" | cyberdelegate.com | secondary |

Catalogue: `iso27090`, `baseline: true`, `status: voluntary`, mapped to AIG-04, 05, 06, 07, 10, 13, 14, 15 by threat and mitigation theme, and referenced from risks RSK-01, 02, 03, 04, 06.

## 2. EN 18286:2026 — Artificial intelligence — Quality management system for EU AI Act regulatory purposes

| Item | Fact | Source | Label |
|---|---|---|---|
| Approval | Approved by CEN on 12 Jul 2026 | https://docs.modulos.ai/frameworks/eu-ai-act/harmonized-standards/en-18286/faq | secondary |
| OJ citation | Commission Implementing Decision (EU) 2026/2274 "on the harmonised standards for high-risk AI systems", adopted 12 Oct 2026, in force 14 Oct 2026; reference to EN 18286:2026 published in the OJ on 14 Oct 2026 | https://eur-lex.europa.eu/eli/dec_impl/2026/2274/oj/eng (metadata); https://digital.nemko.com/news/en-18286-eu-ai-act-cites-new-harmonized-qms-standard | primary for the decision's date and entry into force; secondary for the annex listing EN 18286 (the annex text was not machine-readable) |
| What it supports | AI Act Art 17 quality management system for providers of (primarily high-risk) AI systems | Nemko; Modulos | secondary |
| Presumption of conformity | Only for the provisions in Annex ZA (Table ZA.1); Art 17(2), 17(3) and 17(4) not covered; some rows conditional (e.g. 17(1)(g) only where the risk management system complies with Art 9); lasts while the OJ reference stands; not a certificate | Modulos | secondary |
| Relation to ISO/IEC 42001 | Annex C gives a clause correspondence with EN ISO/IEC 42001:2026; ISO/IEC 42001 has no Annex ZA, so it gives no presumption of conformity; the two are not equivalent | Modulos | secondary |
| First harmonised standard | First AI Act harmonised standard cited; standards for other requirements (risk management, data governance, cybersecurity) have no citation yet | Nemko | secondary |
| When Art 17 applies | Annex III high-risk providers from 2 Dec 2027; Annex I from 2 Aug 2028 (Art 113 as amended by Reg (EU) 2026/1744) | catalogue `eu-ai-act` | primary |

Catalogue: `en-18286` added to the EU layer (`catalog/jurisdictions/eu.yaml`, inherited by Portugal and Spain), `status: voluntary`, mapped to AIG-01, 03, 04, 06, 13, 14, 15, 16 by the Art 17(1) point each control implements; `eu-ai-act` gains the 14 Oct 2026 key date and a `harmonised_standards` list.

Art 17(1) points used in the mappings: (a) strategy for regulatory compliance incl. management of modifications; (b) design, design control and verification; (c) development, quality control and quality assurance; (d) examination, test and validation; (e) technical specifications; (f) data management; (g) risk management system (Art 9); (h) post-market monitoring (Art 72); (i) serious-incident reporting (Art 73); (j) communication with authorities; (k) record-keeping; (l) resource management incl. security of supply; (m) accountability framework — https://eur-lex.europa.eu/eli/reg/2024/1689/oj/eng (primary).

## 3. IEEE 2863-2026 — IEEE Recommended Practice for Organizational Governance of Artificial Intelligence

| Item | Fact | Source | Label |
|---|---|---|---|
| Type and status | Recommended practice; Active Standard | https://standards.ieee.org/ieee/2863/10142/ | primary |
| Dates | PAR approved 13 Feb 2020; IEEE SA Standards Board approval 4 Jun 2026; published 16 Oct 2026 | https://standards.ieee.org/ieee/2863/10142/ | primary |
| Scope | Governance activities for organisations that develop or use AI, to enable "responsible, ethical, and accountable development or use of artificial intelligence"; governance principles for the governing body to consider and prioritise; processes to implement them; case studies on resolving tensions between principles | https://standards.ieee.org/ieee/2863/10142/ | primary |

Catalogue: `ieee-2863`, `baseline: true`, `status: voluntary`, mapped from the published scope to AIG-01, 03 and 20. **UNVERIFIED:** clause numbers and any further mapping (the text was not read).

## 4. Australian AI standards

| Item | Fact | Source | Label |
|---|---|---|---|
| AS ISO/IEC 42001:2023 | Adopted by Standards Australia on 16 Feb 2024; JAS-ANZ accreditation for AIMS certification from Dec 2024 | https://compliancecouncil.com.au/insights/australia-ai-standards-july-2026-reversal-what-it-means/ | secondary |
| Voluntary AI Safety Standard | Ten guardrails, published 5 Sep 2024 with the mandatory-guardrails proposals paper; remains published Commonwealth guidance | https://www.mallesons.com/au/en/insights/latest-thinking/ai-regulation-is-coming-to-australia-what-you-need-to-know ; compliancecouncil.com.au | secondary |
| Guidance for AI Adoption (AI6) | Published 21 Oct 2025 by the National AI Centre; "streamlined the 10 guardrails down to 6 key practices"; foundational and extended versions | https://www.industry.gov.au/publications/guidance-for-ai-adoption | primary |
| AI6 practices | 1 Accountability; 2 Impacts; 3 Risk; 4 Information (incl. an AI system register); 5 Testing and monitoring (incl. incident thresholds); 6 Human control | https://safeaiaus.org/safety-standards/guidance-for-ai-adoption-ai6/ | secondary (the industry.gov.au page does not list them) |
| National AI Plan | 2 Dec 2025: did not proceed with mandatory guardrails; relies on existing technology-neutral law | compliancecouncil.com.au | secondary |
| Australian Standards for AI | Announced by the Prime Minister on 15 Jul 2026 with an Office of AI in PM&C; first focus large data centres and AI training | compliancecouncil.com.au; https://safeaiaus.org/safety-standards/australian-standards-for-ai/ | secondary |
| National Cabinet | 26 Aug 2026: endorsed mandatory national data-centre standards (energy, water, land use, skills) | safeaiaus.org | secondary — the page itself notes it had not been checked against the communiqué |
| Joint Select Committee | Early advice 12 Oct 2026 (risk-based framework, incident reporting, data-sovereignty rules, skills, procurement); full report by 30 Nov 2026 | safeaiaus.org | secondary |
| Legislation | Expected early 2027; no bill tabled as of 19 Oct 2026 | safeaiaus.org | secondary |

Catalogue: `au-ai-standards` (`status: voluntary`, AU only) mapped to AIG-01, 02, 03, 11, 12, 13, 14, 16, 20 through the six AI6 practices; the AU jurisdiction gains the AI6 instrument (replacing `au-ai-adoption`) and a tracked `proposed` instrument for the announced Australian Standards for AI (AIG-03, 08, 16, anticipating the committee's advice).

## Not changed

- No new Rego rules: ISO/IEC 27090, IEEE 2863, EN 18286 and AI6 are evidenced through the shared controls they map to. The MAS rule's start date moved to 2027-10-07.
- ISO/IEC 42001 stays `secondary` (Annex A titles), now noting EN ISO/IEC 42001:2026 and AS ISO/IEC 42001:2023.
