# Animal Birthday Predictor (ABP)

[![Flutter](https://img.shields.io/badge/Flutter-3.10.4+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State_Management-Riverpod_2.5.1-blueviolet)](https://riverpod.dev)
[![Backend](https://img.shields.io/badge/Backend-Supabase_PostgreSQL-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Status](https://img.shields.io/badge/Status-Production--Ready_%26_Feature--Complete-success)]()
[![Tests](https://img.shields.io/badge/Tests-34_Suites_Passing-brightgreen)]()

An enterprise-grade, cross-platform animal breeding, gestational milestone scheduling, clinical healthcare, and pedigree certification ecosystem tailored for professional equine stud managers, horse owners, canine breeders, and veterinary practitioners.

---

## 📄 Complete Project Documentation & Google Doc Files

Complete and comprehensive documentation files have been created covering **what the project is about, why it was created, how it is being carried out, how it works, and an exhaustive inventory of everything done so far**:

1. **Microsoft Word & Google Docs File:**
   - [`Animal_Birthday_Predictor_Complete_Project_Summary.docx`](file:///c:/projects/internship_2/Animal-Birthday-Predictor-/Animal_Birthday_Predictor_Complete_Project_Summary.docx) *(Ready to open in Microsoft Word or upload directly to Google Drive / Google Docs)*
2. **Master Project Markdown Documentation:**
   - [`PROJECT_COMPLETE_SUMMARY_DOCUMENTATION.md`](file:///c:/projects/internship_2/Animal-Birthday-Predictor-/PROJECT_COMPLETE_SUMMARY_DOCUMENTATION.md)
   - [`docs/PROJECT_COMPLETE_SUMMARY_DOCUMENTATION.md`](file:///c:/projects/internship_2/Animal-Birthday-Predictor-/docs/PROJECT_COMPLETE_SUMMARY_DOCUMENTATION.md)
3. **Interactive Google Docs-Formatted HTML:**
   - [`docs/PROJECT_COMPLETE_SUMMARY.html`](file:///c:/projects/internship_2/Animal-Birthday-Predictor-/docs/PROJECT_COMPLETE_SUMMARY.html) *(Open in any browser, press Ctrl+A -> Ctrl+C -> Paste into Google Docs with 100% formatted headings, tables, and colors)*

---

## 🚀 Core Features

- **Multi-Species Registry:** Register Horses, Dogs, Cats, and other domestic animals with microchips, DNA profiles, brands, and parentage.
- **Tri-View Physical Markings Subsystem:** Left Side, Right Side, and Head photographic capture with detailed markings notes.
- **Equine Breeding & Gestation Engine:** Natural Service, Chilled AI, Frozen AI, ICSI, and Embryo Transfer (ET) with donor and recipient mare tracking.
- **Automated Clinical Milestones:** Real-time calculation of Scan 1 (14–16 days, twin check), Scan 2 (28–30 days, heartbeat), Scan 3 (45–60 days, fetal sexing), and exact 340-day foaling countdown.
- **Advanced Clinical Procedures:** Caslick surgery tracking and Fetal Sex Scan (Filly vs. Colt) with attached ultrasound imaging.
- **Preventative Healthcare Protocols:** 9-vaccine equine protocol, canine DHPP protocols, deworming schedules, dental rasping, and 4–6 week farrier hoof care with click-to-call.
- **Offspring & Litter Management:** Foals (IgG colostrum antibody levels, stud book, sale status) and Puppies (collar tag colors, birth order, birth/departure weights, growth progression curves).
- **Professional Contacts Directory:** Unified address book for veterinarians, farriers, equine dentists, stud owners, and buyers with one-touch phone dialer (`tel:`) and SMS.
- **Publication-Quality Vector PDF Certificates:** Automated generation of official A4 pedigree and health certificates with luxury gold border styling, real-time preview, direct wireless printing, and native OS sharing.
- **Enterprise Security & Data Isolation:** 100% Row-Level Security (RLS) on all Supabase tables, cascading foreign keys, and GDPR-compliant account deletion via `delete_user_account()` RPC.

---

## 🛠 Technology Stack

- **Frontend:** Flutter SDK 3.10.4+ / Material 3 Design
- **State Management:** Flutter Riverpod 2.5.1 (`AsyncValue`, `AutoDisposeNotifier`)
- **Backend & Cloud DB:** Supabase (PostgreSQL 15+) with Row-Level Security
- **Local Storage:** `shared_preferences`
- **Native Hardware Integrations:** `image_picker`, `permission_handler`, `url_launcher`, `pdf`, `printing`
- **Quality Assurance:** 34 Comprehensive Automated Test Suites (100% Pass Rate)

---

## 🧪 Testing

To run the full suite of automated tests:
```bash
flutter test
```
All 34 test suites in `test/` validate requirements, date mathematics, responsive viewports (320px to 1440px), crash safety, and database RLS isolation.
