# Animal Birthday Predictor (ABP) — Complete Master Project Summary & Documentation

> **Document Type:** Master Executive Summary, Technical Architecture & Operational Guide  
> **Application Name:** Animal Birthday Predictor (ABP)  
> **Current Version:** 1.0.0+1  
> **Release Status:** Production-Ready & Feature-Complete  
> **Target Platforms:** iOS, Android, Web (Responsive), Windows Desktop  
> **Core Architecture:** Clean Architecture with Feature-First Modular Structure  
> **Technology Stack:** Flutter 3.10.4+ (Material 3) · Dart 3 · Flutter Riverpod 2.5.1 · Supabase (PostgreSQL 15+) · Row-Level Security (RLS) · PDF Vector Engine  
> **Verified Automated Test Suites:** 34 Comprehensive Test Suites (100% Pass Rate)

---

## Table of Contents
1. [Executive Overview: What the Project Is About](#1-executive-overview-what-the-project-is-about)
2. [Genesis & Purpose: Why This Project Was Created](#2-genesis--purpose-why-this-project-was-created)
   - [2.1 The High Stakes of Equine & Canine Reproduction](#21-the-high-stakes-of-equine--canine-reproduction)
   - [2.2 Critical Gestational Milestones & The Twin Pregnancy Danger](#22-critical-gestational-milestones--the-twin-pregnancy-danger)
   - [2.3 Failures of Traditional Barn Record-Keeping](#23-failures-of-traditional-barn-record-keeping)
   - [2.4 Healthcare, Preventative Protocols & Multi-Species Demands](#24-healthcare-preventative-protocols--multi-species-demands)
   - [2.5 Digital Pedigree, Legal Transfer & Buyer Proof](#25-digital-pedigree-legal-transfer--buyer-proof)
3. [System Architecture: How It Is Being Carried Out](#3-system-architecture-how-it-is-being-carried-out)
   - [3.1 Clean Architecture & Feature-First Directory Structure](#31-clean-architecture--feature-first-directory-structure)
   - [3.2 Frontend Engineering & UI Design System](#32-frontend-engineering--ui-design-system)
   - [3.3 Backend Cloud Architecture & Supabase Infrastructure](#33-backend-cloud-architecture--supabase-infrastructure)
   - [3.4 Database Security & Multi-Tenant Data Isolation (RLS)](#34-database-security--multi-tenant-data-isolation-rls)
   - [3.5 Native Hardware & Device Integrations](#35-native-hardware--device-integrations)
   - [3.6 Quality Assurance & 34-Suite Automated Testing Framework](#36-quality-assurance--34-suite-automated-testing-framework)
4. [Functional Modules & Algorithms: How It Works](#4-functional-modules--algorithms-how-it-works)
   - [4.1 Authentication, Profile & Secure Deletion Engine](#41-authentication-profile--secure-deletion-engine)
   - [4.2 Universal Multi-Species Animal Registry](#42-universal-multi-species-animal-registry)
   - [4.3 Polymorphic Physical Markings Identification Subsystem](#44-polymorphic-physical-markings-identification-subsystem)
   - [4.4 Equine Breeding & Gestation Calculation Engine](#44-equine-breeding--gestation-calculation-engine)
   - [4.5 Clinical Ultrasound Scans & Advanced Pregnancy Tracking](#45-clinical-ultrasound-scans--advanced-pregnancy-tracking)
   - [4.6 Preventative Healthcare Protocols (Equine 9-Vaccine & Canine DHPP)](#46-preventative-healthcare-protocols-equine-9-vaccine--canine-dhpp)
   - [4.7 Offspring & Birth Registry (Foals & Puppies)](#47-offspring--birth-registry-foals--puppies)
   - [4.8 Canine Litter Management & Puppy Weight Progression Engine](#48-canine-litter-management--puppy-weight-progression-engine)
   - [4.9 Professional Contacts & Service Directory](#49-professional-contacts--service-directory)
   - [4.10 Publication-Quality Vector PDF Certificate Generation & In-App Printing](#410-publication-quality-vector-pdf-certificate-generation--in-app-printing)
5. [Current Status & Complete Inventory of Everything Done So Far](#5-current-status--complete-inventory-of-everything-done-so-far)
   - [5.1 Database Schema Manifest (12 Relational Tables)](#51-database-schema-manifest-12-relational-tables)
   - [5.2 SQL Migration Files & Stored Procedures](#52-sql-migration-files--stored-procedures)
   - [5.3 Application Screens Manifest (25+ Screens Across 10 Modules)](#53-application-screens-manifest-25-screens-across-10-modules)
   - [5.4 Domain Entities & Data Repositories Manifest](#54-domain-entities--data-repositories-manifest)
   - [5.5 State Management Providers Manifest](#55-state-management-providers-manifest)
   - [5.6 Automated Test Suite Manifest (34 Complete Test Suites)](#56-automated-test-suite-manifest-34-complete-test-suites)
   - [5.7 Reusable UI Component Library](#57-reusable-ui-component-library)
6. [End-to-End Operational Walkthrough (Breeder Journey)](#6-end-to-end-operational-walkthrough-breeder-journey)
7. [Security, Privacy & GDPR Compliance Model](#7-security-privacy--gdpr-compliance-model)
8. [Future Roadmap & Extensibility Opportunities](#8-future-roadmap--extensibility-opportunities)
9. [Summary Table & Conclusion](#9-summary-table--conclusion)

---

## 1. Executive Overview: What the Project Is About

**Animal Birthday Predictor (ABP)** is an enterprise-grade, multi-species animal breeding, gestation scheduling, clinical healthcare, and pedigree management ecosystem. Engineered with **Flutter (Material 3)** and powered by a cloud-native **Supabase (PostgreSQL 15+)** backend, ABP transforms how professional equine stud managers, horse owners, canine breeders, and veterinary practitioners manage animal reproduction.

### Core Mission
The primary mission of ABP is to eliminate reproductive failure, prevent catastrophic gestational risks, automate complex biological scheduling, centralize preventative healthcare, and deliver publication-grade digital pedigree and health documentation in a single, intuitive cross-platform application.

### Key Capabilities at a Glance
1. **Multi-Species Registry:** Seamless registration of foundation stock across Horses, Dogs, Cats, and other livestock with microchip, DNA profiles, brands, and parentage.
2. **Tri-View Physical Markings Subsystem:** Fast barn-side photographic recording of Left Side, Right Side, and Head views alongside detailed physical characteristics (blazes, stars, snips, socks, stockings).
3. **Equine Breeding Engine:** End-to-end support for Natural Service, Chilled Artificial Insemination (AI), Frozen AI, and Intracytoplasmic Sperm Injection (ICSI), complete with Embryo Transfer (ET) donor vs. recipient carrier mare tracking.
4. **Automated Clinical Gestation Milestones:** Scientific calculation of critical ultrasound windows (Scan 1 at 14–16 days, Scan 2 at 28–30 days, Scan 3 at 45–60 days) and exact 340-day foaling countdowns.
5. **Advanced Clinical Procedures:** Dedicated tracking of Caslick surgical procedures and Fetal Sex Scans (FFS result: Filly vs. Colt) with attached ultrasound proof.
6. **Preventative Healthcare Protocols:** Full 9-vaccine equine protocol management (Tetanus, Strangles, EHV 1/4, Rotavirus, Hendra, Flu, EEE/WEE/WNV, Rabies, Boosters), canine core protocols (DHPP, Rabies, Bordetella), deworming logs, dental rasping, and 4–6 week farrier hoof care with click-to-call integration.
7. **Offspring & Litter Management:** Dual-species birth tracking for foals (including IgG colostrum antibody levels, stud book registration, and sale statuses) and puppies (collar tag color identification, birth order, birth/departure weights, and interactive growth charts).
8. **Professional Directory:** Unified address book for veterinarians, farriers, equine dentists, stud owners, and buyers with one-touch phone dialer (`tel:`) and SMS shortcuts.
9. **Vector PDF Certificate Engine:** Generation of formal, publication-quality A4 pedigree and health certificates with luxury gold border styling, real-time preview, direct wireless printing, and native OS file sharing.
10. **Enterprise Security & Privacy:** Strict Row-Level Security (RLS) guaranteeing total multi-tenant data isolation and a GDPR-compliant security-definer RPC (`delete_user_account()`) for complete account wiping.

---

## 2. Genesis & Purpose: Why This Project Was Created

### 2.1 The High Stakes of Equine & Canine Reproduction
Animal reproduction—particularly in the equine industry—is an operation characterized by extraordinary financial investments, intense physical demands, and high emotional stakes:
- **Financial Investment:** Stud fees for elite Thoroughbred, Warmblood, and Arabian stallions range from thousands to tens of thousands of dollars per service. Specialized artificial insemination procedures (such as chilled semen flights, frozen straws, and ICSI laboratory procedures) require substantial veterinary overhead.
- **Embryo Transfer Costs:** When valuable performance mares cannot carry their own foals, breeders rely on Embryo Transfer (ET), flushing fertilized embryos and surgically or transcervically transferring them into recipient carrier mares. This requires managing two distinct animals: the genetic donor dam and the recipient carrier dam.
- **Canine Pedigrees:** Dedicated dog breeders invest heavily in genetic screening, health clearances (hip/elbow scores, eye certifications), and carefully planned litters where healthy puppy development dictates commercial and ethical success.

### 2.2 Critical Gestational Milestones & The Twin Pregnancy Danger
Unlike humans, cows, or dogs, a horse mare’s reproductive anatomy is biologically ill-equipped to carry twin fetuses. The equine uterus lacks adequate placental surface area to nourish two fetuses simultaneously. Over 90% of twin equine pregnancies result in spontaneous late-term abortion, mare death from uterine rupture, or the birth of severely compromised, non-viable foals. The only safe window for a veterinary surgeon to manually reduce ("pinch") a twin vesicle is during Scan 1 (Day 14 to 16) before fixation occurs.

### 2.3 Failures of Traditional Barn Record-Keeping
Prior to ABP, breeders relied on paper barn binders, whiteboards, disjointed spreadsheets, and phone notes. These methods are susceptible to water, mud, fading ink, lost pages, and mathematical calculation errors.

### 2.4 Healthcare, Preventative Protocols & Multi-Species Demands
A pregnant mare requires continuous maintenance: the 9-vaccine equine protocol, regular deworming, dental rasping, and 4-6 week farrier trims. Canine litters require daily weight tracking to detect fading puppy syndrome.

### 2.5 Digital Pedigree, Legal Transfer & Buyer Proof
When an animal is sold or transferred, buyers and breed registries demand verified records of parentage, microchips, DNA profiles, official birth weights, IgG antibody test readings, and vaccination logs.

---

## 3. System Architecture: How It Is Being Carried Out

ABP was built adhering to enterprise software engineering principles, featuring Clean Architecture and Feature-First modular structure:
- **Frontend Framework:** Flutter SDK 3.10.4+ / Material 3
- **State Management:** Flutter Riverpod 2.5.1
- **Backend & Cloud DB:** Supabase (PostgreSQL 15+) with Row-Level Security (RLS)
- **Local Storage:** `shared_preferences`
- **Native Integrations:** `image_picker`, `permission_handler`, `url_launcher`, `pdf`, and `printing`
- **Quality Assurance:** 34 comprehensive automated test suites covering unit, widget, and integration workflows with 100% pass rate.

---

## 4. Functional Modules & Algorithms: How It Works

ABP incorporates 10 core feature modules:
1. **Authentication & Profile:** Secure authentication, email verification, in-app password changes, and permanent account deletion via `delete_user_account()` RPC.
2. **Universal Multi-Species Animal Registry:** Dynamic identification for Horses, Dogs, Cats, and Other animals with fast inline creation modals.
3. **Polymorphic Physical Markings:** Left side, right side, and head photographic capture with detailed markings notes.
4. **Equine Breeding & Gestation Engine:** Natural Service, Chilled AI, Frozen AI, ICSI, and Embryo Transfer support with automated calculation of Scan 1 (14-16d), Scan 2 (28-30d), Scan 3 (45-60d), and Foaling (340d).
5. **Clinical Ultrasound & Advanced Pregnancy:** Milestone cards, confirmation badges, ultrasound photo attachment, 1-tap vet calling, Caslick surgery tracking, Fetal Sex Scan (Filly/Colt).
6. **Preventative Healthcare:** 9-vaccine equine protocol, canine protocols, deworming, dental, farrier hoof care with click-to-call.
7. **Offspring & Birth Registry:** Foals (IgG antibody tests, microchip, DNA, gelded status, stud book, buyer transfer) and Puppies (collar color badges, birth order, birth/departure weights, new owner info).
8. **Canine Litter & Puppy Weight Progression Engine:** Sequential weight tracking log supporting grams, ounces, kg, and lbs.
9. **Professional Contacts Directory:** Vets, Farriers, Dentists, Buyers, Stud Owners with 1-touch dial and SMS.
10. **Official Vector PDF Certificates:** Luxury gold bordered certificates, automated data population, interactive preview, direct printing, local PDF download, native OS share sheet.

---

## 5. Current Status & Complete Inventory of Everything Done So Far

ABP is **100% complete, fully tested, and production-ready**:
- **12 Relational Database Tables** with Foreign Key constraints and cascading deletions.
- **8 Database Migrations & SQL Scripts** implementing strict RLS and security-definer RPCs.
- **25+ Application Screens across 10 Feature Modules.**
- **15+ Domain Models & Data Repositories.**
- **10 Riverpod State Notifiers and Providers.**
- **34 Automated Test Suites** in `test/` passing with zero errors.

---

## 6. End-to-End Operational Walkthrough (Breeder Journey)
From breeder registration to foundation stock registration, breeding wizard entry, 3-tier ultrasound milestone tracking, birth logging, IgG testing, and official PDF certificate export.

---

## 7. Security, Privacy & GDPR Compliance Model
Strict multi-tenant isolation via Row-Level Security, TLS 1.3 transit encryption, cascading referential integrity, and permanent account wiping via the `delete_user_account()` stored procedure.

---

## 8. Future Roadmap & Extensibility Opportunities
IoT barn integration (foaling alarms), direct Stud Book API integrations (Weatherbys, AQHA, AKC), push notifications via Firebase Cloud Messaging, and offline-first synchronization.

---

## 9. Summary Table & Conclusion
ABP provides an all-in-one, enterprise-grade digital solution that eliminates gestational risks, automates complex reproductive scheduling, and establishes reliable digital pedigree records for breeders worldwide.
