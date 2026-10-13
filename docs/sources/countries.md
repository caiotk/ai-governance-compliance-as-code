# Country research: AI governance policy-as-code profiles

Status as of **2026-10-13**. Every item has a source URL. Law-firm or news URLs mark where the primary text was located; open the gazette or regulator link before encoding. Anything marked `UNVERIFIED:` was not confirmed.

## Cross-cutting EU items (apply to Spain and Portugal)

- **EU AI Act**: Regulation (EU) 2024/1689.
  - Amended by the **AI Omnibus, Regulation (EU) 2026/1744**: published in the OJ on 24 Jul 2026, in force 27 Jul 2026.
  - New application dates: Annex III high-risk systems on **2 Dec 2027**; Annex I (product-embedded) on **2 Aug 2028**.
  - Art 50 transparency still applies from 2 Aug 2026. Machine-readable marking gets a grace period to 2 Dec 2026.
  - Two new prohibited practices (AI-generated intimate imagery and CSAM) apply from 2 Dec 2026. GPAI obligations are unchanged.
  - Sources: https://natlawreview.com/article/eu-digital-omnibus-ai-enters-force ; https://www.iubenda.com/en/blog/ai-omnibus-parliament-adoption-june-2026
- **GDPR**: Regulation (EU) 2016/679.
  - AI-relevant articles: Art 22 (automated decisions), Art 35 (DPIA), Chapter V (international transfers).
  - Source: https://eur-lex.europa.eu/eli/reg/2016/679/oj
- **DORA**: Regulation (EU) 2022/2554, applies from 17 Jan 2025. Covers ICT risk and ICT third-party risk, including AI and cloud vendors.
  - Source: https://eur-lex.europa.eu/eli/reg/2022/2554/oj (UNVERIFIED: date not re-checked the 13 Oct 2026 verification pass)
- **EU Data Act**: Regulation (EU) 2023/2854, applies from 12 Sep 2025. Gives users access and sharing rights over connected-product data, such as tractors and farm IoT.
  - Source: https://www.garrigues.com/en_GB/garrigues-digital/data-act-and-regulated-access-data-essentials ; https://www.bkt-tires.com/bkt-blog/insights-forecasts/data-act-2025-a-revolution-in-agricultural-machinery-data-management/
- **EU MDR**: Regulation (EU) 2017/745. AI software as a medical device is regulated here, and is AI Act Annex I high-risk from 2 Aug 2028 under the Omnibus.
  - Source: https://eur-lex.europa.eu/eli/reg/2017/745/oj
- **European Health Data Space**: Regulation (EU) 2025/327, in force 26 Mar 2025.
  - General application 26 Mar 2027. Most primary-use and secondary-use provisions apply 26 Mar 2029; genomic data and similar categories 26 Mar 2031.
  - Source: https://www.kennedyslaw.com/en/thought-leadership/article/2026/the-european-health-data-space-is-in-force-implications-for-healthcare-medtech-and-life-sciences
- **Copyright DSM Directive**: (EU) 2019/790. Art 4 is the text-and-data-mining exception with opt-out. AI Act Art 53(1)(c) requires a GPAI copyright policy that respects the opt-out.
  - Source: https://eur-lex.europa.eu/eli/dir/2019/790/oj

---

## Brazil

### A. Horizontal AI law/framework
- **PL 2338/2023** (Marco Legal da IA).
  - Passed the Senate in Dec 2024. Now before a Special Committee of the Câmara dos Deputados; rapporteur is Aguinaldo Ribeiro (PP-PB).
  - The planned June 2026 vote slipped. As of 24 Aug 2026 the rapporteur expects a vote after the Oct 2026 elections, at year end.
  - Copyright and the choice of oversight body are still open. The text returns to the Senate after the Câmara votes. **Not law.**
  - Sources: https://teletime.com.br/28/05/2026/motta-votacao-pl-da-ia-junho/ ; https://www.mobiletime.com.br/noticias/24/08/2026/marco-ia-voto-fim-do-ano/
- **PBIA** (Plano Brasileiro de IA) 2024–2028: about R$23 bn, run by MCTI, presented Jul 2024.
  - Source: https://dplnews.com/um-ano-de-plano-brasileiro-de-inteligencia-artificial-o-que-esta-sendo-feito/

### B. Data protection
- **LGPD**: Lei 13.709/2018.
  - Art 20 gives a right to review of decisions taken solely by automated processing. Arts 33–36 cover international transfers. Art 38 covers the DPIA (relatório de impacto).
  - Source: https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm
- **ANPD** (Agência Nacional de Proteção de Dados).
  - Lei 15.352/2026 (25 Feb 2026, converting MP 1.317/2025) made it an "autarquia de natureza especial" with full autonomy.
  - Source: https://www.legjur.com/legislacao/htm/lei_00153522026
- **International transfers**: Resolução CD/ANPD 19/2024 sets the standard contractual clauses. The deadline to adopt them was 23 Aug 2025.
  - Source: https://lefosse.com/noticias/alerta/transferencia-internacional-de-dados-prazo-para-adocao-das-clausulas-padrao-da-anpd-se-encerra-em-23-de-agosto/

### C. Cybersecurity
- **PNCiber**: Decreto 11.856/2023, the national cybersecurity policy. There is no horizontal cyber statute yet.
  - Source: https://planalto.gov.br/ccivil_03/_ato2023-2026/2023/decreto/d11856.htm
- Financial-sector cyber rules (Res. CMN 4.893/2021 and its amendment) are listed under FSI below.

### D. Sector rules
**Health**
- **ANVISA RDC 657/2022** (SaMD) and **RDC 751/2022** (device classification and registration).
  - Neither mentions AI expressly. AI SaMD must still describe its training and validation datasets and justify the AI technique.
  - Sources: https://antigo.anvisa.gov.br/documents/10181/5141677/RDC_657_2022_COMP.pdf/d2da154d-bd76-40ba-87ee-3d9baadb5dd3 ; https://www.mattosfilho.com.br/unico/inteligencia-artificial-dispositivos-medicos/
- **Resolução CFM 2.454/2026** (AI in medicine).
  - Published in the DOU on 27 Feb 2026; in force after 180 days (about late Aug 2026).
  - Rules: the physician has the final decision; patients must be told when AI is used; AI use must be recorded in the chart; risk tiers are low, medium, high and unacceptable; institutions need internal AI governance.
  - Source: https://portal.cfm.org.br/noticias/cfm-normatiza-uso-da-ia-na-medicina

**FSI**
- **Res. CMN 4.893/2021** (cybersecurity policy and cloud/data-processing outsourcing), amended by **Res. CMN 5.274** of 18 Dec 2025.
  - The amendment adds network, certificate, pentest and RSFN/Pix security requirements, with an adjustment deadline of 1 Mar 2026. It has no AI-specific provisions.
  - Source: https://okai.com.br/documento/2025-12-18/resolucao-cmn-n-5-274
- **No BCB AI-specific rule.** In Sep 2025 the BCB said it did not plan AI regulation before end-2026. It ran a market survey and plans a regulatory impact assessment in 2026.
  - Source: https://www.revistaoeste.com/economia/banco-central-planeja-regulamentacao-gradual-da-ia-no-setor-financeiro/

**Public sector**
- **PBIA** (above) includes training up to 115k public servants by 2026, plus a government cloud and mapping of public databases.
  - Source: https://dplnews.com/um-ano-de-plano-brasileiro-de-inteligencia-artificial-o-que-esta-sendo-feito/
- LGPD Chapter IV (public-sector processing) also applies.
  - Source: https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm

**Agriculture**
- **No AI-specific agri rule found.** Embrapa publishes agri-data governance studies, which are non-binding.
  - Source: https://www.alice.cnptia.embrapa.br/alice/bitstream/doc/1170049/1/LV-Agrodados-Regulacao-2024.pdf
- LGPD applies to farmer personal data.

**Mining**
- **NR-22** (mining safety and health), new text approved by Portaria MTE 225 of 26 Feb 2024.
  - No AI or autonomous-equipment specific rule found.
  - Source: https://conexaotrabalho.portaldaindustria.com.br/publicacoes/detalhe/trabalhista/-geral/publicada-nova-redacao-da-nr-22-seguranca-e-saude-na-mineracao
  - UNVERIFIED: whether ANM has any automation guidance.

**Technology companies**
- **ECA Digital**: Lei 15.211/2025.
  - Fully in force since 17 Mar 2026; implemented by Decreto 12.880/2026 (18 Mar 2026). ANPD is the regulator.
  - Obligations: age assurance, parental tools, no ad-profiling of minors, a ban on manipulative design, and child-rights impact assessments.
  - Sanctions from about Nov 2026.
  - Source: https://www.mayerbrown.com/pt/insights/publications/2026/04/enforcement-of-brazils-eca-digital-introduces-new-obligations-for-companies
- **Marco Civil da Internet**: Lei 12.965/2014 (platform liability).
  - Source: https://www.planalto.gov.br/ccivil_03/_ato2011-2014/2014/lei/l12965.htm (UNVERIFIED: the 2025 STF Art 19 ruling's details were not re-checked)

---

## Chile

### A. Horizontal AI law/framework
- **AI bill**: Boletines 16821-19 (Executive message, May 2024) and 15869-19 (merged).
  - Câmara approved it in general on 4 Aug 2025 and dispatched it on 13 Oct 2025. It is in the Senate (second trámite) at the Comisión de Desafíos del Futuro.
  - On 26 May 2026 the new government (Minister Lincolao) presented a pro-innovation "ley marco" approach, expected as an indicación sustitutiva that moves review from ex ante to ex post. **Not law.**
  - Sources: https://www.camara.cl/cms/2025/10/13/camara-despacho-marco-regulatorio-para-uso-de-la-inteligencia-artificial-ia/ ; https://www.senado.cl/comunicaciones/noticias/senadores-conocen-propuesta-del-ejecutivo-para-ley-marco-de-ia
- **Política Nacional de IA, 2024 update**: Decreto 12/2024 (MinCiencia), published in the Diario Oficial on 28 Jan 2025. It runs to 2031.
  - Source: https://www.diariooficial.interior.gob.cl/publicaciones/2025/01/28/44060/01/2600578.pdf

### B. Data protection
- **Ley 21.719** (published in the Diario Oficial 13 Dec 2024). It replaces Ley 19.628 and creates the Agencia de Protección de Datos Personales.
  - In force **1 Dec 2026**.
  - **Pending:** Boletín 18.623-07 (filed 1 Sep 2026) would postpone it to 1 Dec 2027. Senators are pushing for 6 months instead. Committee discussion started in the second week of Oct 2026.
  - The Agency's council is not yet appointed.
  - Art 8 bis covers automated individual decisions and profiling.
  - Sources: https://www.cariola.cl/app/uploads/2026/09/Alerta-legal_-2septiembre.pdf ; https://www.pauta.cl/actualidad/2026/10/02/ley-de-datos-personales-senadores-proponen-prorroga-de-seis-meses-frente-al-ano-que-pide-el-gobierno.html ; https://www.diarioconstitucional.cl/cartas-al-director/inaplicabilidad-material-del-articulo-8-bis-de-la-ley-n-21-719-frente-a-sistemas-de-inteligencia-artificial-basados-en-deep-learning/

### C. Cybersecurity
- **Ley 21.663** (Ley Marco de Ciberseguridad).
  - In force 1 Jan 2025. The ANCI agency started the same day.
  - OIV qualification (Art 5), OIV duties (Art 8), incident reporting to CSIRT Nacional (Art 9) and sanctions apply from 1 Mar 2025.
  - Source: https://www.carey.cl/entrada-en-vigencia-de-la-ley-de-ciberseguridad

### D. Sector rules
**Health**
- **Ley 20.584** (patient rights and duties; confidentiality of the ficha clínica).
  - Health data becomes "sensitive data" under Ley 21.719.
  - Source: https://www.superdesalud.gob.cl/app/uploads/2025/12/ficha-clinica-desafios-en-ley-de-derechos-y-acreditacion-en-salud.pdf
- **ISP / MINSAL medical device control**: devices are brought under mandatory registration in waves (e.g., Decreto Exento 25/2026).
  - Source: https://cms.bioaccessla.com/?p=95589
  - UNVERIFIED: whether software or AI devices are in scope.

**FSI**
- **CMF RAN 20-10** (information security and cybersecurity for banks).
  - Source: https://transtecnia.cl/articulo-contable/cmf-publica-normativa-para-la-gestion-de-la-seguridad-de-la-informacion-y-ciberseguridad/
- **Ley Fintec 21.521** and the Sistema de Finanzas Abiertas (open finance, implementation 2027).
  - Source: https://www.cmfchile.cl/portal/prensa/615/w3-article-110881.html
- **No CMF AI rule yet.** CMF is "working on guidelines" and flags AI as an emerging risk.
  - Source: https://www.ey.com/es_cl/newsroom/2026/02/2026-un-ano-cargado-de-regulacion-e-innovacion

**Public sector**
- **Política Nacional de IA 2024** (above).
- The AI bill as passed by the Câmara expands the Consejo para la Transparencia's role under Ley 20.285 (algorithmic transparency).
  - Source: https://www.camara.cl/cms/?p=90888

**Agriculture**
- **No AI-specific agri rule found.** Ley 21.719 applies.

**Mining**
- **DS 132/2002** (Reglamento de Seguridad Minera, Sernageomin) under Ley 16.744.
  - An update has been announced since 2024; not confirmed as issued.
  - Source: https://www.reporteminero.cl/noticia/noticias/2024/05/sernageomin-ctmin-actualizar-ecreto-supremo-132
- **Sernageomin guide on pilots and validation of autonomous equipment** (31 Mar 2021, with the Centro Nacional de Pilotaje).
  - Requires hardware, software and firmware verification, comms and navigation checks, and a stable network design.
  - Source: https://www.df.cl/df-lab/transformacion-digital/sernageomin-lanzo-primera-guia-para-pilotar-equipos-autonomos-en-faenas

**Technology companies**
- Consumer protection (Ley 19.496) and Ley 21.719 apply.
- The AI bill would add the risk tiers and a ban on subliminal manipulation.
  - Source: https://www.camara.cl/cms/?p=90888
- UNVERIFIED: no Chilean TDM or copyright AI exception was confirmed.

---

## Argentina

### A. Horizontal AI law/framework
- **No AI law.** In 2025, 53 AI-related bills were filed, 11 of them comprehensive; none enacted as of Apr 2026.
  - Source: https://dplnews.com/?p=311680
- **AAIP Res. 161/2023**: programme on transparency and data protection in AI use.
  - Source: https://www.diariojudicial.com/news-95865-ia-con-proteccion-de-datos
- **AAIP "Guía para usar la IA de manera responsable"** (Sep 2024): covers impact assessments, transparency and security across the AI lifecycle.
  - Source: https://www.argentina.gob.ar/node/443099
- **JGM Disposición 2/2023** ("Recomendaciones para una IA Fiable", public sector).
  - Source: https://iapp.org/news/a/argentina-emite-recomendaciones-para-la-implementacion-de-inteligencia-artificial-en-el-sector-publico

### B. Data protection
- **Ley 25.326** (1999); the regulator is the AAIP. Art 20 covers decisions based solely on automated processing of data.
  - Ley 27.699 approves Convention 108+ (with Art 9 automated-decision rights).
  - Replacement bills have been filed; none enacted.
  - Sources: https://abogados.com.ar/promulgacion-de-la-ley-27699-de-adhesion-al-convenio-108-en-materia-de-proteccion-de-datos-personales/31732 ; https://lexlatin.com/noticias/ley-25326-argentina-reemplazar-proteccion-datos-personales
  - UNVERIFIED: Art 20 wording was not re-read.

### C. Cybersecurity
- **No cyber statute.** The Second National Cybersecurity Strategy went to consultation via JGM Res. 1/2023.
  - Source: https://www.marval.com/publicacion/segunda-estrategia-nacional-de-ciberseguridad-de-la-republica-argentina-15397

### D. Sector rules
**Health**
- **ANMAT Disp. 64/2025**: incorporates MERCOSUR GMC Res. 25/2021, including the SaMD definition.
- **ANMAT Disp. 8194/2023**: tecnovigilancia good practices.
- There is no AI-specific change-control mechanism.
  - Source: https://www.allende.com/life-sciences/inteligencia-artificial-y-software-medico-en-argentina-desafios-regulatorios-para-el-regimen-de-productos-medicos-08-26-2026/

**FSI**
- **BCRA Com. "A" 7724** (Mar 2023): minimum requirements for technology and information-security risk management. Explicitly covers third-party relationships involving AI/ML.
  - Sources: https://blog.invgate.com/es/comunicacion-a-7724-bcra ; https://abogados.com.ar/seguridad-informatica-comunicacion-a-7724-bcra/33748

**Public sector**
- **Disp. 2/2023 (JGM)** (above).
- Province of Buenos Aires Res. 9/2025 on AI in public administration.
  - Source: https://ligadelconsorcista.org/inteligencia-artificial-para-administracion-publica-de-provincia-de-buenos-aires-resolucion-9-2025
  - UNVERIFIED: the issuing body was not confirmed.

**Agriculture**
- **No AI-specific agri rule found.**

**Mining**
- **Decreto 249/2007**: health and safety regulation for mining (under Ley 19.587). Not AI-specific.
  - Source: https://www.fio.unicen.edu.ar/extension/seh/images/pdf/minera/dec249-07.pdf

**Technology companies**
- Ley 25.326 and the consumer protection law (Ley 24.240) apply.
- No AI copyright exception.
  - UNVERIFIED: no TDM exception confirmed.

---

## Portugal

### A. Horizontal AI law/framework
- **EU AI Act plus AI Omnibus** (see the EU block).
- **ANACOM** is the market surveillance authority and single point of contact, designated Sep 2025.
- **14 Art 77 fundamental-rights authorities**, including ERS (health), IGF, ACT, ASAE and ERSE.
- No dedicated national AI implementing law was found.
  - Sources: https://cms.law/en/int/expert-guides/ai-regulation-scanner/portugal ; https://www.lexmundi.com/guides/ai-legislative-guide/jurisdictions/europe/portugal/
  - UNVERIFIED: the legal instrument for the ANACOM designation and the sanctions regime.
- **Agenda Nacional de IA 2026–2030** (RCM 2/2026, 8 Jan 2026): four pillars, including regulatory sandboxes and a gigafactory.
  - Source: https://cms.law/pt/prt/news-information/agenda-nacional-de-inteligencia-artificial-2026-2030
- **Lei 27/2021** (Carta Portuguesa de Direitos Humanos na Era Digital), Art 9 on AI.
  - Source: https://www.lexmundi.com/guides/ai-legislative-guide/jurisdictions/europe/portugal/

### B. Data protection
- **GDPR** plus **Lei 58/2019** (national execution); the regulator is the CNPD.
  - Source: https://diariodarepublica.pt/dr/detalhe/lei/58-2019-123815982
  - UNVERIFIED: URL not re-checked.

### C. Cybersecurity
- **Decreto-Lei 125/2025** (new Regime Jurídico da Cibersegurança, NIS2 transposition), in force **3 Apr 2026**. The authority is the CNCS.
  - Sources: https://www.ecija.com/adcecija/novo-regime-juridico-da-ciberseguranca-entrou-em-vigor-em-portugal/ ; https://www.rtp.pt/noticias/economia/regime-que-reforca-centro-nacional-de-ciberseguranca-publicado-em-diario-da-republica_n1702457

### D. Sector rules
**Health**
- **EU MDR 2017/745** and **EHDS 2025/327** (EU block). Infarmed is the device authority; ERS is an Art 77 authority.
  - Source: https://www.lexmundi.com/guides/ai-legislative-guide/jurisdictions/europe/portugal/

**FSI**
- **DORA** (EU block). Banco de Portugal and CMVM are sectoral coordinating authorities for AI in regulated areas.
  - Source: https://cms.law/en/int/expert-guides/ai-regulation-scanner/portugal
- AI Act Annex III credit scoring and life/health insurance pricing count as high-risk from 2 Dec 2027.
- **Lei 13/2023**: Labour Code amendment on algorithmic/AI employment decisions and equal treatment.
  - Source: https://www.lexmundi.com/guides/ai-legislative-guide/jurisdictions/europe/portugal/

**Public sector**
- **"Guia para a IA ética, transparente e responsável na Administração Pública"** (AMA, 2022).
  - Source: https://digital.gov.pt/en/documentos/guia-para-a-inteligencia-artificial-sumario-executivo
- **ANIA** (RCM 2/2026) names public administration as the catalyst for AI adoption.

**Agriculture**
- **EU Data Act** (EU block). No Portuguese AI-specific agri rule found.

**Mining**
- No AI-specific rule found.
  - UNVERIFIED: the national mining health and safety regulation was not confirmed.

**Technology companies**
- **Decreto-Lei 47/2023** transposes the DSM Directive (TDM exception and opt-out). AI Act Art 53 also applies.
  - Source: https://www.lexmundi.com/guides/ai-legislative-guide/jurisdictions/europe/portugal/
- **DSA execution law** (2026).
  - Source: https://www.plmj.com/xms/files/03_Novidades_legislativas/2026/DSA-Publicada_a_Lei_de_Execucao_em_Portugal.pdf

---

## Spain

### A. Horizontal AI law/framework
- **EU AI Act plus Omnibus** (see the EU block).
- **Proyecto de Ley Orgánica para el buen uso y la gobernanza de la IA**.
  - Approved by the Council of Ministers 26 May 2026. Published in BOCG 15-A-97-1 on 12 Jun 2026; the amendment deadline was 30 Jun 2026. Still in the Congreso. **Not law.**
  - Fines up to €35m / 7% of turnover. AESIA runs the sandbox. Public bodies must keep an inventory of AI systems and appoint an "AI delegate".
  - Sources: https://digital.gob.es/content/dam/portal-mtdfp/comunicacion/comunicacion_ministro/2026/05/2026-05-26/260526%20NP%20CMin%20APL%20IA.pdf ; https://finreg360.com/alerta/el-congreso-inicia-el-tramite-del-proyecto-de-ley-organica-para-el-buen-uso-y-la-gobernanza-de-la-inteligencia-artificial/ ; https://www.congreso.es/public_oficiales/L15/CONG/BOCG/A/BOCG-15-A-97-1.PDF
- **AESIA** (A Coruña) is the market surveillance authority and single point of contact.
  - Under the bill, CGPJ supervises law-enforcement systems; AEPD keeps its own remit; Banco de España, CNMV and DGSFP keep their sectoral roles.
  - Sources: https://www.hsfkramer.com/es/notes/madrid/2026-posts/alerta-espana-avanza-implementacion-reglamento-europeo-ia-junio-2026 ; https://www.osborneclarke.com/es/insights/espana-avanza-en-la-regulacion-de-la-ia-claves-de-la-nueva-ley-organica-de-gobernanza
- **RD 817/2023** (AI sandbox) would be repealed and replaced by the LO.
- **Estrategia de IA 2024** (Council of Ministers, 14 May 2024).
  - Source: https://digital.gob.es/comunicacion/notas-prensa/secretaria-digitalizacion-e-inteligencia-artificial/2024/05/2024-05-14

### B. Data protection
- **GDPR** plus **LOPDGDD** (LO 3/2018); the regulator is the AEPD.
  - Source: https://www.boe.es/eli/es/lo/2018/12/05/3/con
  - UNVERIFIED: URL not re-checked.

### C. Cybersecurity
- **NIS2 not transposed** as of 28 Sep 2026.
  - The Anteproyecto de Ley de Coordinación y Gobernanza de la Ciberseguridad dates from Jan 2025.
  - On 8 Jul 2026 the Commission referred Spain to the CJEU.
  - RDL 12/2018, RD 43/2021 and the ENS (Esquema Nacional de Seguridad) remain in force.
  - Source: https://www.legiscope.com/blog/nis2-espana-transposicion.html

### D. Sector rules
**Health**
- **EU MDR**, **EHDS** (EU block); AEMPS is the device authority.
- Medical-device AI keeps the existing sectoral market-surveillance authorities under the LO bill.
  - Source: https://digital.gob.es/content/dam/portal-mtdfp/comunicacion/comunicacion_ministro/2026/05/2026-05-26/260526%20NP%20CMin%20APL%20IA.pdf

**FSI**
- **DORA** (EU block). Banco de España, CNMV and DGSFP keep sectoral supervision under the LO bill.
  - Source: https://www.osborneclarke.com/es/insights/espana-avanza-en-la-regulacion-de-la-ia-claves-de-la-nueva-ley-organica-de-gobernanza

**Public sector**
- The LO bill requires an inventory of AI used in administrative procedures, an AI delegate, and civil-servant training, to be developed by Royal Decree.
- The ENS applies.
  - Source: https://digital.gob.es/content/dam/portal-mtdfp/comunicacion/comunicacion_ministro/2026/05/2026-05-26/260526%20NP%20CMin%20APL%20IA.pdf

**Agriculture**
- **RD 1054/2022 (SIEX)**, amended Jan 2025 (BOE-A-2025-998). The cuaderno digital de explotación is temporarily voluntary until the next CAP period (2027).
  - Source: https://servicio.mapama.gob.es/ca/prensa/250122boecuadernodigitaldeexplotacion_tcm34-700096.pdf
- **EU Data Act** (EU block).

**Mining**
- **RD 863/1985** (Reglamento General de Normas Básicas de Seguridad Minera) and its ITCs. Not AI-specific.
  - Source: https://boe.gob.es/boe/dias/1985/06/12/pdfs/A17869-17877.pdf

**Technology companies**
- **EU DSM Directive** TDM opt-out (transposed by RDL 24/2021) and AI Act Art 53. The LO bill adds child-protection measures and enforcement of the new prohibitions (e.g., sexual deepfakes).
  - Source: https://digital.gob.es/content/dam/portal-mtdfp/comunicacion/comunicacion_ministro/2026/05/2026-05-26/260526%20NP%20CMin%20APL%20IA.pdf
  - UNVERIFIED: the RDL 24/2021 citation.

---

## USA (brief pointer)

### A. Horizontal AI law/framework
- **No federal AI statute.**
- **EO "Ensuring a National Policy Framework for AI"** (11 Dec 2025) targets state AI laws.
  - Source: https://www.clarkhill.com/news-events/news/what-does-trumps-ai-executive-order-mean-for-colorados-ai-act/
- **Colorado SB 24-205 was repealed and replaced by SB 26-189** (signed 14 May 2026, effective 1 Jan 2027).
  - Based on automated decision-making technology (ADMT): notice, adverse-decision explanation and human review.
  - Enforcement depends on AG rules and a federal stay.
  - Source: https://www.eckertseamans.com/legal-updates/colorado-repeals-and-replaces-its-landmark-ai-statute-what-businesses-need-to-know

### B. Data protection
- Sectoral laws (HIPAA, GLBA, COPPA) plus state laws (e.g., CCPA/CPRA ADMT regulations).
  - UNVERIFIED: the CPPA ADMT regulation dates were not re-checked.

### C. Cybersecurity
- **NYDFS 23 NYCRR 500** (amended). The final phase took effect 1 Nov 2025 (MFA, asset inventory).
  - Source: https://hlc.com/en/publications/nydfs-final-set-of-cybersecurity-requirements-under-amended-part-500-take-effect-november-1-2025

### D. Sector rules
**Health**
- **HIPAA Privacy/Security Rules**.
- **ACA §1557 rule, 45 CFR 92.210**: non-discrimination in patient-care decision support tools, including AI.
  - Source: https://www.crowell.com/en/insights/client-alerts/hhs-applies-discrimination-prohibitions-to-use-of-automated-and-non-automated-patient-care-decision-support-tools
- **FDA**:
  - PCCP guidance for AI-enabled device software functions: final, Dec 2024.
  - "AI-Enabled Device Software Functions: Lifecycle Management and Marketing Submission": still **draft** (Jan 2025, docket FDA-2024-D-4488).
  - Revised CDS software guidance: Jan 2026.
  - Sources: https://www.hpnonline.com/healthcare-it/news/55247423/fda-issues-final-guidance-on-marketing-submission-for-ai-enabled-device-software-functions ; https://fda.gov/regulatory-information/search-fda-guidance-documents/artificial-intelligence-enabled-device-software-functions-lifecycle-management-and-marketing ; https://www.cov.com/en/news-and-insights/insights/2026/01/5-key-takeaways-from-fdas-revised-clinical-decision-support-cds-software-guidance

**FSI**
- **SR 11-7 / OCC 2011-12 were rescinded** and replaced by the interagency "Revised Guidance on Model Risk Management" (OCC/Fed/FDIC, 17 Apr 2026).
  - Generative and agentic AI are expressly excluded; an RFI on bank AI use is planned.
  - Source: https://www.orrick.com/en/Insights/2026/04/Agencies-Overhaul-Model-Risk-Management-Guidance-for-Banks-Heres-What-Changed
- **ECOA/Reg B adverse action**: CFPB Circular 2023-03 requires specific reasons even for AI models.
  - Source: https://www.cooley.com/news/insight/2023/2023-09-25-cfpb-mandates-additional-specificity-in-adverse-action-communications-based-on-ai-or-complex-credit-models
  - UNVERIFIED: whether the CFPB withdrew the circular in 2025–26.
- **GLBA** and **NYDFS Part 500** also apply.

**Public sector**
- **OMB M-25-21** (Apr 2025): Chief AI Officers, and minimum practices for "high-impact AI".
  - Source: https://www.whitehouse.gov/wp-content/uploads/2025/02/M-25-21-Accelerating-Federal-Use-of-AI-through-Innovation-Governance-and-Public-Trust.pdf

**Agriculture**
- **Ag Data Transparent** certification (voluntary, based on the Farm Bureau "Core Principles", updated 2024). No federal AI agri rule.
  - Source: https://dairyproducer.com/updated-core-principles-for-ag-data-2024-by-todd-janzen/

**Mining**
- **MSHA Safety Program for Surface Mobile Equipment**, final rule (30 CFR Part 56/57/77, compliance from Jul 2024). No autonomous-specific rule.
  - Sources: https://www.msha.gov/final-rule-safety-program-surface-mobile-equipment ; https://nssga.org/mshas-new-powered-haulage-rule-hits-july-17-are-you-ready
  - UNVERIFIED: the CFR parts.

**Technology companies**
- **FTC Act §5** deception cases on AI claims (Workado, Air AI $18m, MindSift).
- The Rytr order was set aside (Jan 2026).
- Proposed policy statement on AI accuracy (1 Jul 2026).
  - Sources: https://www.hklaw.com/en/insights/media-entities/2026/09/the-federal-trade-commissions-current-approach-to-ai-regulation ; https://www.globalpolicywatch.com/2026/01/ftc-sets-aside-rytr-final-order-pursuant-to-white-house-ai-action-plan/

---

## Australia (brief pointer)

### A. Horizontal AI law/framework
- **National AI Plan** (Dec 2025): no mandatory guardrails and no AI Act; relies on existing laws plus an AI Safety Institute (from early 2026).
  - Source: https://www.gadens.com/legal-insights/australia-launches-ai-safety-institute-and-releases-national-ai-plan/

### B. Data protection
- **Privacy Act 1988 (APPs)**; the regulator is the OAIC.
  - POLA Act 2024 automated decision-making transparency (APP 1.7–1.9) applies from **10 Dec 2026**. OAIC issued guidance on 30 Sep 2026.
  - Source: https://www.oaic.gov.au/news/media-centre/new-resources-on-transparency-for-use-of-ai-and-automated-decision-making

### C. Cybersecurity
- **Cyber Security Act 2024**: ransomware payment reporting from 30 May 2025.
  - Source: https://www.minterellison.com/articles/new-ransomware-payment-reporting-obligations-in-australia
- SOCI Act also applies (UNVERIFIED: not re-checked).

### D. Sector rules
**Health**
- **TGA SaMD regime** (Therapeutic Goods Act 1989).
  - TGA report "Clarifying and strengthening the regulation of Medical Device Software including AI" (25 Jul 2025): reviews of digital scribes and digital mental health tools, plus adaptive-AI change-control guidance.
  - Source: https://www.minterellison.com/articles/tga-publishes-findings-on-ai-and-medical-devices
- **My Health Records Act 2012** (UNVERIFIED: not re-checked).

**FSI**
- **APRA CPS 230** (operational risk, effective 1 Jul 2025) and **CPS 234**.
  - Source: https://www.cliffordchance.com/insights/resources/blogs/regulatory-investigations-financial-crime-insights/2025/04/cps-230-influence-on-ai-and-cybersecurity-strategies.html
- **ASIC REP 798 "Beware the gap"** (29 Oct 2024).
  - Source: https://asic.gov.au/regulatory-resources/find-a-document/reports/rep-798-beware-the-gap-governance-arrangements-in-the-face-of-ai-innovation/

**Public sector**
- **Policy for the responsible use of AI in government** (updated version, effective **15 Dec 2025**): strategic position, accountable officers, an internal register, and mandatory AI impact assessment.
  - Sources: https://www.dta.gov.au/media-releases/ai-policy-overhauled-new-impact-assessment-tool-and-procurement-guidance ; https://www.digital.gov.au/ai/ai-in-government-policy

**Agriculture**
- **NFF Australian Farm Data Code** v2 (May 2023), voluntary, with a certification scheme. Its FAQ covers consent for AI training on farm data.
  - Source: https://nff.org.au/programs/australian-farm-data-code/

**Mining**
- **WA Code of Practice: Safe mobile autonomous mining in WA** (republished Feb 2025, continued under the WHS Act 2020).
  - Source: https://worksafe.wa.gov.au/publications/safe-mobile-autonomous-mining-western-australia-code-practice

**Technology companies**
- **Online Safety Act 2021**, Phase 2 industry codes, and the social media minimum age rule (from 10 Dec 2025).
  - Source: https://www.bakermckenzie.com/en/insight/publications/alerts/2025/09/australia-phase-2-online-safety-codes-registered-by-esafety-commissioner
- Government **ruled out a TDM copyright exception** (Oct 2025).
  - Source: https://www.simpsons.com.au/news/update-australian-government-rules-out-text-and-data-mining-exception-for-ai-training

---

## New Zealand (brief pointer)

### A. Horizontal AI law/framework
- **NZ AI Strategy "Investing with confidence"** and MBIE Responsible AI Guidance for Businesses (Jul 2025). Light-touch; no AI Act.
  - Source: https://www.mbie.govt.nz/business-and-employment/economic-growth/digital-policy/new-zealands-ai-strategy-investing-with-confidence

### B. Data protection
- **Privacy Act 2020**:
  - **IPP 3A** (indirect-collection notice) from **1 May 2026**.
    - Source: https://www.bellgully.com/insights/preparing-for-ipp-3a-new-requirements-effective-1-may-2026/
  - **Biometric Processing Privacy Code 2025** (issued 6 Aug 2025, effective Nov 2025; 12-month transition for existing processing).
    - Source: https://www.russellmcveagh.com/insights-news/new-biometrics-code-to-come-into-effect-in-november-2025/
    - UNVERIFIED: the exact end date of the transition.

### C. Cybersecurity
- No NIS-style cyber statute.
  - UNVERIFIED: not re-checked.

### D. Sector rules
**Health**
- **Health Information Privacy Code 2020** (UNVERIFIED: not re-checked).
- **Medicines Act 1981** is still the law. The Therapeutic Products Act was repealed (2024). The **Medical Products Bill** is in policy development (Cabinet decisions Jul 2025 to Apr 2026; clarifies SaMD); introduction was not confirmed.
  - Sources: https://disclosure.legislation.govt.nz/bill/government/2024/67 ; https://www.health.govt.nz/regulation-legislation/medicines-legislation/regulating-medicines-medical-devices-and-natural-health-products/documents-on-the-medical-products-bill

**FSI**
- **CoFI regime** (Financial Markets (Conduct of Institutions) Amendment Act 2022), fully in force 31 Mar 2025; the regulator is the FMA.
  - Source: https://www.mbie.govt.nz/business-and-employment/business/financial-markets-regulation/conduct-of-financial-institutions-regime
- **RBNZ BS11** (outsourcing) (UNVERIFIED: not re-checked).

**Public sector**
- **Public Service AI Framework** (GCDO; five OECD-based principles; non-binding).
  - Source: https://www.digital.govt.nz/standards-and-guidance/technology-and-architecture/artificial-intelligence/public-service-artificial-intelligence-framework

**Agriculture**
- **Farm Data Code of Practice** (voluntary; DairyNZ/MPI/FarmIQ, 2014).
  - Source: https://www.farmersweekly.co.nz/?p=11779
  - UNVERIFIED: current administrator.

**Mining**
- **HSW (Mining Operations and Quarrying Operations) Regulations 2016**. No AI or autonomy rule.
  - Source: https://www.legislation.govt.nz/secondary-legislation/pco-drafted/2016/17/en/latest/

**Technology companies**
- Privacy Act and Fair Trading Act. No TDM exception (UNVERIFIED).

---

## Japan

### A. Horizontal AI law/framework
- **AI Promotion Act**: Act No. 53 of 2025, the Act on Promotion of Research and Development, and Deployment of AI-related Technology.
  - Enacted May 2025; fully in force 1 Sep 2025, when the AI Strategic Headquarters was also set up.
  - Promotional, with no penalties. Art 16 provides government research and incident monitoring.
  - Sources: https://cm.twobirds.com/en/insights/2025/japan/japan's-ai-governance-major-government-steps-since-the-ai-act ; https://www8.cao.go.jp/cstp/ai/ai_plan/aiplan_eng_20260714.pdf
- **AI Basic Plan**: first plan by Cabinet decision 23 Dec 2025; **Second AI Basic Plan** (English provisional translation 14 Jul 2026).
  - Adds agentic, physical and sovereign AI, a stronger AISI, and rules for government AI agents.
  - Source: https://www8.cao.go.jp/cstp/ai/ai_plan/aiplan_eng_20260714.pdf
- **AI Business Operator Guidelines** v1.2 (31 Mar 2026), METI/MIC, voluntary.
  - Source: https://www.ibanet.org/japan-health-data-reforms-ai

### B. Data protection
- **APPI**; the regulator is the PPC.
  - **Amendment Act No. 56 of 2026** (passed 10 Jul 2026, promulgated 17 Jul 2026). Changes:
    - consent exemption for "statistical creation", including AI training, where risk is low
    - administrative surcharges (Art 148-3)
    - rules for children under 16
    - a new category of specified biometric data
  - Penalties apply from 17 Jan 2027; the main reforms by Cabinet Order, no later than 17 Jul 2028.
  - Source: https://www.aoshearman.com/en/insights/ao-shearman-on-data/amendments-to-the-act-on-the-protection-of-personal-information-promulgated

### C. Cybersecurity
- **Active Cyber Defense law** (Cyber Response Capability Enhancement Act), enacted 16 May 2025, promulgated 23 May 2025.
  - Main enforcement **1 Oct 2026** (Cabinet Order No. 46).
  - Incident reporting by critical-infrastructure operators starts within 18 months of promulgation (by about Nov 2026). Asset notifications are due 31 Mar 2027.
  - Sources: https://www.trendmicro.com/ja_jp/jp-security/26/h/securitytrend-20260814-01.html ; https://www.bakermckenzie.co.jp/wp/wp-content/uploads/20250814-Client-Alert-IPTech_ENG.pdf

### D. Sector rules
**Health**
- **PMD Act**: SaMD classification by MHLW guidance; the IDATEN scheme allows post-market change plans for SaMD.
  - Source: https://www.ibanet.org/japan-health-data-reforms-ai
- **Next-Generation Medical Infrastructure Act** (anonymised medical data), amended May 2023 to add pseudonymised medical data (effective 2024).
  - Source: https://www.private-ai.com/en/blog/japan-health-data-anonymization
- **MHLW Guidelines on utilisation of medical digital data for AI R&D** (30 Sep 2024).
  - Source: https://www.ibanet.org/japan-health-data-reforms-ai

**FSI**
- **FSA AI Discussion Paper** v1.0 (4 Mar 2025); **v1.1 (3 Mar 2026)**.
  - Sources: https://www.fsa.go.jp/en/news/2025/20250304/aidp.html ; https://mondovisione.com/media-and-resources/news/japan-financial-services-agency-publication-of-ai-discussion-paper-version-11-202633/

**Public sector**
- **Digital Agency Guideline for Government Procurement and Utilisation of Generative AI**: v1 May 2025; **v2.0 approved 12 Jun 2026**.
  - Requires CAIOs and reporting of high-risk projects to the Advanced AI Utilization Advisory Board.
  - Sources: https://cadeproject.org/updates/japan-updates-government-guidelines-for-generative-ai-procurement-and-use/ ; https://www.digital.go.jp/en/news/3579c42d-b11c-4756-b66e-3d3e35175623

**Agriculture**
- **MAFF "Contract Guidelines on AI and Data in Agriculture"** (12 Mar 2020; merges the 2018 data guideline; errata Mar 2024). Voluntary.
  - Source: https://www.maff.go.jp/j/kanbo/tizai/brand/keiyaku.html

**Mining**
- **Mine Safety Act** (鉱山保安法, METI regional inspectorates). No autonomous-specific national rule found.
  - Source: https://www.safety-hokkaido.meti.go.jp/kozan_hoan/about/img/r8guidline.pdf
  - UNVERIFIED: content of that document.

**Technology companies**
- **Copyright Act Art 30-4** (exploitation not for enjoyment, which permits TDM/AI training). ACA "General Understanding on AI and Copyright" (Mar 2024).
  - Source: https://www.wipo.int/documents/d/office-japan/docs-en-tatsuhiro-ueno_general-understanding-on-ai-and-copyright-in-japan_set.pdf

---

## Singapore

### A. Horizontal AI law/framework
- **No AI statute.**
- **Model AI Governance Framework for Generative AI** (IMDA / AI Verify Foundation, May 2024; nine dimensions).
  - Source: https://morganlewis.com/pubs/2024/07/singapore-expands-its-ai-governance-approach-to-include-generative-ai
- **Model AI Governance Framework for Agentic AI**: **verified, launched 22 Jan 2026** (IMDA, Davos).
  - Four dimensions: bound risks upfront; meaningful human accountability; technical controls across the lifecycle; end-user responsibility.
  - Source: https://www.mddi.gov.sg/newsroom/singapore-launches-new-model-ai-governance-framework-for-agentic-ai--/
- **AI Verify** (testing toolkit) and **National AI Strategy 2.0** (Dec 2023).
  - Source: https://www.mddi.gov.sg/newsroom/04122023/

### B. Data protection
- **PDPA 2012**; the regulator is the PDPC.
- **Advisory Guidelines on Use of Personal Data in AI Recommendation and Decision Systems** (1 Mar 2024): business improvement and research exceptions, consent/notification, and accountability.
  - Source: https://www.rajahtannasia.com/viewpoints/pdpc-issues-advisory-guidelines-on-use-of-personal-data-in-ai-recommendation-and-decision-systems/

### C. Cybersecurity
- **Cybersecurity Act 2018** as amended by the **Cybersecurity (Amendment) Act 2024**; key provisions in force **31 Oct 2025** (foundational digital infrastructure, third-party CII, entities of special cybersecurity interest).
  - Source: https://www.hlc.com/en/publications/provisions-in-singapores-cybersecurity-amendment-act-came-into-force-on-31-october-2025
- CSA has consulted on secure agentic AI resources.
  - Source: https://connectontech.bakermckenzie.com/singapore-csa-launches-two-sets-of-resources-on-quantum-safe-migration-and-secure-agentic-ai-for-public-consultation-2/

### D. Sector rules
**Health**
- **HSA Regulatory Guidelines for Software Medical Devices: A Life Cycle Approach** (R2, Apr 2022; covers AI-MD).
  - Source: https://www.hsa.gov.sg/docs/default-source/hprg-mdb/guidance-documents-for-medical-devices/regulatory-guidelines-for-software-medical-devices---a-life-cycle-approach_r2-(2022-apr)-pub.pdf
- **MOH/HSA AIHGle 2.0** (10 Mar 2026; MOH circular 24/2026): seven principles; developer, deployer and user roles; GenAI coverage.
  - Source: https://www.bakermckenzie.com/en/insight/publications/2026/03/singapore-moh-and-hsa-launch-refreshed-ai-in-healthcare-guidelines

**FSI**
- **MAS Guidelines on AI Risk Management**: **final, issued Oct 2026**, covering all FIs and all AI.
  - Sections 3–4 effective Oct 2027; sections 5–6 Oct 2028.
  - Requires board oversight, an AI inventory and materiality assessment, lifecycle controls, and accountability for third-party AI. An agentic AI consultation is planned for 2027.
  - Sources: https://www.mas.gov.sg/regulation/guidelines/guidelines-on-artificial-intelligence-risk-management-for-financial-institutions ; https://www.blockhead.co/2026/10/08/mas-finalises-ai-risk-rules-for-financial-institutions-with-agentic-ai-guidance-to-follow-in-2027/
- **FEAT principles** (2018) and **MAS Technology Risk Management Guidelines** (2021).
  - UNVERIFIED: not re-checked.

**Public sector**
- **GovTech** responsible AI engineering practices; the **IM8** policy applies.
  - Source: https://www.tech.gov.sg/technews/engineering-responsible-ai/
  - UNVERIFIED: no single binding public-sector AI policy document was confirmed.

**Agriculture**
- **No AI-specific agri rule** (small sector; SFA food safety regime).

**Mining**
- **Not applicable** (no material mining sector). Use the WSH Act generically.

**Technology companies**
- **Copyright Act 2021 s.244** (computational data analysis exception; requires lawful access).
  - Source: https://www.reedsmith.com/articles/text-and-data-mining-in-singapore/
- **Online Safety (Relief and Accountability) Act 2025**: Online Safety Commission operational **29 Jun 2026** (intimate image abuse, doxxing, harassment, etc.).
  - Source: https://www.mlaw.gov.sg/online-safety-commission-and-online-safety-relief-and-accountability-act-2025-to-start-on-29-june-2026/

---

## Key corrections against the brief's assumptions
1. **Brazil PL 2338/2023** is still in the Câmara special committee. The vote moved to after the Oct 2026 elections.
2. **Chile Ley 21.719** is legally in force 1 Dec 2026, but bill 18.623-07, which would postpone it to Dec 2027 or by 6 months, is being debated in the Senate. Profiles should flag this as pending.
3. **Chile AI bill**: the new government plans a substitute, innovation-first text, so the earlier risk tiers may change.
4. **EU AI Act high-risk dates moved** (Omnibus 2026/1744): Annex III 2 Dec 2027; Annex I 2 Aug 2028.
5. **Spain's AI law** is now a *Proyecto de Ley Orgánica* in the Congreso (not an anteproyecto). Spain still has **not** transposed NIS2.
6. **US SR 11-7 was rescinded** (17 Apr 2026). Its replacement excludes generative and agentic AI.
7. **Colorado AI Act was replaced** by SB 26-189, effective 1 Jan 2027.
8. **MAS AI Risk Management Guidelines are final** (Oct 2026), effective in phases from Oct 2027.
9. **Japan APPI amended** (Act 56 of 2026), including an AI-training consent exemption. Japan has a **second AI Basic Plan** (2026).
10. **FDA AI-enabled device lifecycle guidance is still draft.** Only the PCCP guidance is final.
11. **Brazil BCB/CMN**: Res. 5.274/2025 amends 4.893 and has no AI content. The BCB has no AI rule before end-2026.
12. **Argentina BCRA Com. A 7724** is confirmed: Mar 2023 IT and infosec requirements, with AI/ML third-party references.
