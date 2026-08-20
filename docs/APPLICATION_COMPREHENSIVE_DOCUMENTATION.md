# Animal Birthday Predictor (ABP) — Comprehensive Application & Technical Documentation

> **Version:** 1.0.0+1  
> **Status:** Production-Ready & Feature-Complete  
> **Architecture:** Clean Architecture with Feature-First Modular Structure (Flutter + Supabase + Riverpod)  
> **Target Platforms:** Android, iOS, Web, Windows  

---

## 1. Executive Summary & Application Overview

**Animal Birthday Predictor (ABP)** is an enterprise-grade mobile and cross-platform management platform tailored for professional animal breeders, stud managers, and veterinarians. The application provides end-to-end lifecycle tracking:
1. **Animal Registration & Universal Registry** (Horses, Dogs, Cats, and Other Species)
2. **Equine Breeding & Gestation Management** (Natural, Chilled AI, Frozen AI, ICSI, and Embryo Transfer)
3. **Veterinary Scans & Milestone Calculations** (Automated scan dates & foaling countdowns)
4. **Advanced Clinical Procedures** (Caslick, Fetal Sexing, Ultrasound Imaging)
5. **Preventative Healthcare & Vaccinations** (9-vaccine equine protocol, canine protocols, dental, farrier)
6. **Birth Logging & Offspring Management** (Foals & Puppies, weight trackers, collar tagging)
7. **Contacts & Professional Directory** (Vets, Farriers, Dentists, Buyers with direct calling)
8. **Automated PDF Pedigree & Health Certificates** (Interactive preview, print, export, and share)
9. **Authentication, Security & Complete Data Privacy** (Supabase Auth, RLS isolation, RPC Account Deletion)

---

## 2. Technical Stack & Architecture

### 2.1 Core Framework & State Management
- **Flutter SDK:** 3.10.4+ / Material 3 Design
- **State Management:** Riverpod 2.5.1 (`AsyncValue`, `AutoDisposeNotifier`, `StateNotifier`, `FutureProvider`)
- **Backend & Database:** Supabase (PostgreSQL 15+) with Row-Level Security (RLS)
- **Local Storage:** `shared_preferences` (for onboarding state & user session flags)
- **Environment Management:** `flutter_dotenv` (`.env` configuration)
- **Document Generation:** `pdf` (3.11.1) and `printing` (5.13.2)
- **Media & Hardware:** `image_picker` (1.1.2) for camera capture and gallery uploads, `permission_handler` (11.3.1)
- **Communication:** `url_launcher` (6.3.0) for phone calls (`tel:`) and external web links

### 2.2 Design System & Visual Hierarchy
- **Primary Background:** `#0A192F` (Deep Dark Navy)
- **Surface & Cards:** `#112240` (Elevated Midnight Navy)
- **Input Background:** `#131B2D` (Dark Navy with Subtle Gold Borders)
- **Brand Accent:** `#D4AF37` (Luxury Gold)
- **CTA Gradient:** Linear Gradient `#D6B23F` → `#EDD086` (Champagne Gold)
- **Typography:** Custom styling with consistent heading, section label, and body scales.
- **Responsiveness:** Fluid scaling via `ResponsiveBody`, `LayoutBuilder`, and `SingleChildScrollView` to eliminate layout overflows on all device sizes.

---

## 3. Database Schema & Backend Implementation

The database is built on PostgreSQL with strict Row Level Security (RLS), automated triggers, and stored procedures (RPCs).

### 3.1 Database Tables Overview

| Table Name | Primary Key | Foreign Keys / Relations | Description |
| :--- | :--- | :--- | :--- |
| `profiles` | `id (UUID)` | References `auth.users(id)` | User profile metadata (full name, email, timestamps). Auto-created via trigger `handle_new_user`. |
| `animals` | `id (UUID)` | `account_id -> auth.users(id)` | Universal registry for all animals (Horse, Dog, Cat, Other). Stores name, breed, colour, DOB, microchip, DNA, brand, client/owner info, and photo URL. |
| `markings` | `id (UUID)` | `owner_id (UUID)` (Polymorphic: `owner_type` in `'animal'`, `'foal'`) | Left Side, Right Side, and Head View photos + physical markings notes. |
| `breeding_records` | `id (UUID)` | `account_id`, `mare_animal_id -> animals(id)`, `recipient_animal_id -> animals(id)` | Breeding events (Natural, Chilled, Frozen, ICSI), stallion name, cover date, embryo transfer flags, and genetic dam/sire names. |
| `pregnancy_records`| `id (UUID)` | `account_id`, `breeding_record_id`, `carrier_animal_id -> animals(id)` | Gestational tracking for carrier animal. Stores 3 scan due dates, confirmation flags, ultrasound URLs, foaling due date, and vet info. |
| `advanced_pregnancy_info` | `id (UUID)` | `pregnancy_record_id -> pregnancy_records(id)` (1-to-1) | Caslick surgery tracking, Fetal Sex Scan dates/done, FFS result (filly/colt), and ultrasound scans. |
| `preventative_care` | `id (UUID)` | `owner_id (UUID)` (Polymorphic: `owner_type` in `'animal'`, `'foal'`) | Deworming, 9 core equine vaccinations, Dental date/done + dentist phone, Farrier date/done + farrier phone. |
| `foals` | `id (UUID)` | `account_id`, `mare_animal_id -> animals(id)`, `recipient_animal_id -> animals(id)` | Offspring records, foal name, DOB, sex, IgG value, microchip, DNA, gelded status/date, stud book, status (keep, sold, transferred), buyer name, photo URL. |
| `puppies` | `id (UUID)` | `account_id`, `dam_animal_id -> animals(id)` | Puppy birth records, collar tag colour, birth order, birth & current weight, microchip, DNA, status, date going home, new owner details. |
| `puppy_weights` | `id (UUID)` | `puppy_id -> puppies(id)` | Historical puppy weight tracking over time with dates and units. |
| `contacts` | `id (UUID)` | `account_id -> auth.users(id)` | Professional directory (Veterinarian, Farrier, Dentist, Buyer, Stud Owner, Other) with phone, email, notes, and address. |
| `calendar_reminders` | `id (UUID)` | `account_id -> auth.users(id)` | Generic reminder records linking date fields to notification / calendar syncing. |

### 3.2 SQL Migrations & Stored Procedures (RPCs)
- **`01_schema.sql`**: Complete table definitions, check constraints, foreign keys with `ON DELETE CASCADE`, indexes, and `set_updated_at` triggers.
- **`02_rls_policies.sql`**: Explicit SELECT, INSERT, UPDATE, DELETE policies isolating user rows with `auth.uid() = account_id`.
- **`03_add_animal_sex.sql`**: Extension adding sex specification to general animals.
- **`04_create_markings_table.sql`**: Dedicated physical markings table creation.
- **`05_strict_user_data_isolation.sql`**: Hardened isolation policies across all tables.
- **`06_delete_account_rpc.sql`**: Security definer RPC `delete_user_account()` allowing users to permanently wipe their profile, animal records, breeding histories, foals, puppies, contacts, and Supabase auth account.
- **`foal_and_buyer_migration.sql`**: Foal table extensions for buyer names, sale dates, and indexed lookups.

---

## 4. Completed Modules & Feature Breakdown

### 4.1 Authentication & Onboarding Module
- **Onboarding Carousel (`OnboardingScreen`)**: 3-step visual onboarding highlighting birth prediction, pregnancy health schedules, and certificate generation. Persists view status in `SharedPreferences`.
- **Sign Up (`SignUpScreen`)**: Validated registration with full name, email, and password. Emits custom feedback and syncs with Supabase profiles.
- **Sign In (`SignInScreen`)**: Email/Password authentication with password visibility toggle, session restore, and deep linking listeners.
- **Password Recovery (`PasswordResetScreen` & `UpdatePasswordScreen`)**: Flow for requesting OTP / reset links and setting new passwords.
- **In-App Password Change (`ChangePasswordScreen`)**: Allows authenticated users to change their password securely from the Profile/Settings screen.
- **Email Verification (`EmailVerificationScreen`)**: Deep-link listener and resend link functionality.

### 4.2 Universal Animals Management Module
- **Species Selector (`SpeciesSelectionScreen`)**: Interactive selection between Horse (Equine), Dog (Canine), Cat (Feline), and Other species.
- **Saved Animals Directory (`SavedAnimalsScreen`)**:
  - Filterable by species tabs (All, Horses, Dogs, Cats).
  - Real-time search by name, breed, or microchip number.
  - Pull-to-refresh and empty-state placeholders.
  - Delete with confirmation dialog and swipe actions.
- **Animal Registration & Details Form (`AnimalDetailsScreen` / `MareDetailsScreen`)**:
  - Dynamic fields adapting to species:
    - **Horse:** Name, Sex (Mare, Stallion, Gelding), Breed, Colour, DOB, Microchip Number, DNA Profile, Brand, Owner/Client details.
    - **Dog/Cat/Other:** Name, Sex, Breed, Colour, DOB, Microchip Number, DNA, Client Name & Contact Number.
  - Integrated Camera & Gallery photo capture with avatar preview.
- **Animal Comprehensive Profile (`AnimalProfileScreen`)**:
  - Displays full identification, microchip, DNA, and owner data.
  - Quick action buttons to **Physical Markings** and **Preventative Care**.
  - History view of past breedings, pregnancies, or offspring linked to this animal.
- **Reusable Selection Modal (`SelectOrAddAnimalModal`)**:
  - Universal modal used across the app to either select an existing registered animal (auto-filling known information) or quickly register a new one inline.

### 4.3 Physical Markings Sub-system
- **Markings Capture (`MarkingsScreen`)**:
  - Polymorphic architecture supporting both adult animals and new foals.
  - Left Side View photo, Right Side View photo, Head View photo.
  - Notes for unique markings (blazes, stars, snips, socks, stockings).
  - Direct camera launch priority for fast barn-side capture.

### 4.4 Equine Breeding & Gestation Engine
- **Breeding Details (`BreedingDetailsScreen`)**:
  - Mare selector with "Select Existing vs Add New" modal pattern.
  - Stallion Name (free-text entry for external stud/sire reference).
  - 4 Breeding Methods:
    1. Natural Service
    2. Chilled Artificial Insemination (AI)
    3. Frozen Artificial Insemination (AI)
    4. Intracytoplasmic Sperm Injection (ICSI)
  - Cover / Insemination / Transfer Date picker.
  - **Embryo Transfer (ET) Mode:**
    - Toggle to enable Recipient Mare selection.
    - Captures genetic dam and sire names.
  - **Automated Calculation Engine (`PregnancyCalculationUtils`)**:
    - Scan 1 Due Date: 14–16 days post-cover (Pregnancy & twin confirmation).
    - Scan 2 Due Date: 28–30 days post-cover (Heartbeat check).
    - Scan 3 Due Date: 45–60 days post-cover (Fetal sexing & organ development).
    - Foaling Due Date: Exactly 340 days average equine gestation.
  - Automatically initializes linked `pregnancy_records` and `advanced_pregnancy_info` records.

### 4.5 Pregnancy & Clinical Scans Tracking
- **Pregnancy Overview (`PregnancyModuleScreen`)**:
  - Central dashboard showing all active pregnancies.
  - Displays carrier mare, sire, breeding method, foaling due date countdown, and scan badges.
- **Pregnancy Details Screen (`PregnancyDetailsScreen`)**:
  - Gestational age counter, carrier mare info, and direct links to Vet Scans, Advanced Info, and Mare Preventative Care.
- **Veterinarian Pregnancy Scans (`VeterinarianPregnancyScansScreen` / `PregnancyScansScreen`)**:
  - Milestone blocks for Scan 1, Scan 2, and Scan 3.
  - Status confirmation checkboxes with automatic date logging.
  - Ultrasound image capture/upload for each scan milestone.
  - Assigned Veterinarian Name and Click-to-Call Phone Number.
- **Advanced Pregnancy Info (`AdvancedPregnancyInfoScreen`)**:
  - Caslick procedure tracking (Date performed & status).
  - Fetal Sex Scan (Date & confirmation status).
  - FFS Result selector (Filly or Colt) with ultrasound scan attachment.

### 4.6 Preventative Care Sub-system
- **Equine Preventative Care (`PreventativeCareScreen` / `MarePreventativeCareScreen`)**:
  - Deworming (Wormer date given and status).
  - **9 Core Equine Vaccinations:**
    1. Tetanus Toxoid
    2. Strangles
    3. Equine Herpesvirus (EHV 1/4)
    4. Rotavirus
    5. Hendra Virus
    6. Equine Influenza
    7. EEE / WEE / WNV (Equine Encephalomyelitis & West Nile)
    8. Rabies
    9. Custom / Booster Dose
  - Dental Care (Date, status, dentist phone number).
  - Farrier / Hoof Care (Date, status, farrier phone number).
  - Click-to-call integration for dentists and farriers.
- **Canine Preventative Care (`DogPreventativeCareScreen`)**:
  - Core Canine Vaccinations (DHPP 5-in-1, Rabies, Bordetella, Leptospirosis, Lyme).
  - Deworming schedule tracking (2, 4, 6, 8 weeks, and monthly intervals).
  - General veterinary examinations and health checkpoints.

### 4.7 Foal & Birth Registry Module
- **Birth Registry Hub (`FoalModuleScreen`)**:
  - Tabbed interface switching seamlessly between **Foals** (Equine) and **Puppies** (Canine).
  - Filter chips by status: All, Keep, Sold, Transferred.
  - Search by offspring name or microchip.
- **Foal Details (`FoalDetailsScreen`)**:
  - Genetic Dam (Mare) selector.
  - Recipient Mare display (if embryo transfer).
  - Stallion (Sire) reference.
  - Foal Name, Date of Birth, Sex (Filly / Colt), Breed, Colour.
  - IgG antibody level test result.
  - Microchip number & DNA test record.
  - Gelded checkbox and Gelded Date.
  - Stud Book Association / Breed Society registration.
  - Status management (Keep, Sold, Transferred) & Buyer Name / Sale Date.
  - Shortcuts to Foal Markings, Foal Preventative Care, and Certificate Generation.
- **Birth Celebration (`CongratulationsScreen`)**:
  - Celebratory visual modal on recording a successful birth, providing instant shortcuts to generate certificates or log markings.

### 4.8 Canine / Puppy Registry & Weight Tracker
- **Puppy Directory (`PuppyListScreen`)**:
  - List of registered puppies/litters with custom collar tag badges and status badges.
- **Puppy Details (`PuppyDetailsScreen`)**:
  - Dam (Mother) picker and Sire (Father) details.
  - Puppy Name and Collar Tag Colour identifier.
  - Sex (Male / Female), Coat Colour, Birth Order.
  - Date & Time of Birth, Birth Weight, Current Departure Weight.
  - Microchip, DNA, Status (Available, Reserved, Sold, Keep, Transferred).
  - Date Going Home & New Owner Information (Name, Phone, Address).
  - Notes & Photo capture.
- **Puppy Weight Tracker (`PuppyWeightTrackerScreen`)**:
  - Interactive log of weight readings across days/weeks.
  - Tracks growth progress with dates, weights in grams/kg/lbs, and milestone notes.

### 4.9 Contacts Directory
- **Contacts Directory Screen (`ContactsDirectoryScreen`)**:
  - Unified address book for all equine & canine service providers.
  - Category filters: All, Veterinarians, Farriers, Dentists, Buyers, Stud Owners, Others.
  - Fast-action buttons to Call (`tel:`) or Message.
  - Add, edit, and delete contacts modal with full validation.
- **Contact Selection Modal (`SelectOrAddContactModal`)**:
  - Inline picker embedded in Vet, Farrier, and Dentist fields to pick an existing contact or quickly save a new one.

### 4.10 PDF Certificate Generation & In-App Printing
- **Certificate Generation Engine (`PdfCertificateService`)**:
  - Generates official, publication-quality A4 vector PDF documents with luxury gold borders, ABP branding, and legal disclaimers.
  - **Equine / Foal Certificate:** Includes registered foal name, breed, sex, DOB, microchip, DNA, stud book, dam & sire lineage, full preventative care history (tetanus, strangles, wormer, dental, farrier), breeder attestation, and buyer transfer record.
  - **Canine / Puppy Certificate:** Includes puppy name, collar tag colour, sex, birth order, DOB, birth & departure weights, parentage, full vaccination & worming protocol, breeder details, and new owner information.
- **Interactive Certificate Screen (`CertificateScreen`)**:
  - Real-time PDF preview.
  - Native Print integration.
  - Save / Export PDF to local device storage.
  - Native OS Share sheet to share certificates via WhatsApp, Email, AirDrop, etc.

### 4.11 User Profile, Settings & Account Deletion
- **Profile Overview (`ProfileScreen`)**: Displays user name, email, stats summary (total horses, foals, puppies, contacts), and navigation shortcuts.
- **Settings Screen (`SettingsScreen`)**:
  - Push notification preferences toggle.
  - Dark theme options.
  - Terms of Service & Privacy Policy views.
  - Customer support email shortcut.
  - Secure Account Deletion entry point.
- **Permanent Account Deletion (`DeleteAccountScreen`)**:
  - Security confirmation modal requiring explicit confirmation.
  - Executes PostgreSQL RPC `delete_user_account()`, cleanly deleting all foreign-keyed data (animals, breeding records, pregnancies, foals, puppies, contacts, profiles) and the Supabase auth record.

---

## 5. Directory Structure & File Manifest

```
animal_birthday_predictor/
├── 01_schema.sql                       # Core Supabase database schema
├── 02_rls_policies.sql                 # Row Level Security (RLS) policies
├── 03_add_animal_sex.sql               # Animal sex migration
├── 04_create_markings_table.sql        # Markings table migration
├── 05_strict_user_data_isolation.sql   # Data isolation policies
├── 06_delete_account_rpc.sql           # Delete Account RPC stored procedure
├── foal_and_buyer_migration.sql        # Foal & buyer fields migration
├── pubspec.yaml                        # Dependencies and asset declarations
├── lib/
│   ├── main.dart                       # App entry point, Supabase & Deep link init
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart         # Theme colors & gold gradients
│   │   │   ├── app_env.dart            # Supabase URL & Anon Key config
│   │   │   ├── app_spacing.dart        # Margins, padding, and corner radii
│   │   │   └── app_typography.dart     # Font scales and text styles
│   │   ├── router/
│   │   │   └── app_router.dart         # 25+ named routes and argument handling
│   │   ├── services/
│   │   │   └── permission_service.dart # Camera & storage permissions
│   │   ├── theme/
│   │   │   └── app_theme.dart          # Dark Gold ThemeData
│   │   ├── utils/
│   │   │   ├── app_uuid.dart           # UUID generator utility
│   │   │   └── error_handler.dart      # User-friendly error message parser
│   │   └── widgets/
│   │       ├── app_error_view.dart
│   │       ├── app_feedback_snackbar.dart
│   │       ├── app_image_picker.dart
│   │       ├── app_loading_view.dart
│   │       ├── app_logout_dialog.dart
│   │       ├── app_thumbnail_avatar.dart
│   │       ├── app_unsaved_changes_dialog.dart
│   │       ├── auth_header_banner.dart
│   │       ├── custom_text_field.dart
│   │       ├── feature_list_item.dart
│   │       ├── gradient_cta_button.dart
│   │       ├── responsive_body.dart
│   │       ├── section_divider_label.dart
│   │       ├── social_auth_button.dart
│   │       └── trust_card.dart
│   └── features/
│       ├── animals/
│       │   ├── data/
│       │   │   ├── animal_repository.dart
│       │   │   └── mare_repository.dart
│       │   ├── domain/
│       │   │   ├── animal.dart
│       │   │   ├── animal_type.dart
│       │   │   ├── mare.dart
│       │   │   └── markings.dart
│       │   ├── presentation/
│       │   │   ├── providers/
│       │   │   │   ├── animal_provider.dart
│       │   │   │   └── mare_provider.dart
│       │   │   ├── screens/
│       │   │   │   ├── animal_details_screen.dart
│       │   │   │   ├── animal_listings_screen.dart
│       │   │   │   ├── animal_profile_screen.dart
│       │   │   │   ├── mare_details_screen.dart
│       │   │   │   ├── markings_screen.dart
│       │   │   │   ├── saved_animals_screen.dart
│       │   │   │   └── species_selection_screen.dart
│       │   │   └── widgets/
│       │   │       ├── animal_list_tile.dart
│       │   │       ├── select_or_add_animal_modal.dart
│       │   │       └── species_select_card.dart
│       ├── auth/
│       │   ├── data/
│       │   │   └── auth_repository.dart
│       │   ├── domain/
│       │   │   └── user_profile.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── auth_provider.dart
│       │       └── screens/
│       │           ├── change_password_screen.dart
│       │           ├── email_verification_screen.dart
│       │           ├── home_placeholder_screen.dart
│       │           ├── password_reset_screen.dart
│       │           ├── sign_in_screen.dart
│       │           ├── sign_up_screen.dart
│       │           └── update_password_screen.dart
│       ├── certificates/
│       │   ├── data/
│       │   │   └── pdf_certificate_service.dart
│       │   └── presentation/
│       │       └── screens/
│       │           └── certificate_screen.dart
│       ├── contacts/
│       │   ├── data/
│       │   │   └── contact_repository.dart
│       │   ├── domain/
│       │   │   └── contact.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── contact_provider.dart
│       │       ├── screens/
│       │       │   └── contacts_directory_screen.dart
│       │       └── widgets/
│       │           └── select_or_add_contact_modal.dart
│       ├── dashboard/
│       │   └── presentation/
│       │       └── screens/
│       │           └── dashboard_home_screen.dart
│       ├── foal/
│       │   ├── data/
│       │   │   └── foal_repository.dart
│       │   ├── domain/
│       │   │   └── foal_record.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── foal_provider.dart
│       │       └── screens/
│       │           ├── congratulations_screen.dart
│       │           ├── foal_details_screen.dart
│       │           ├── foal_module_screen.dart
│       │           └── foal_preventative_care_screen.dart
│       ├── main/
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── main_navigation_provider.dart
│       │       └── screens/
│       │           └── main_navigation_screen.dart
│       ├── onboarding/
│       │   └── presentation/
│       │       └── screens/
│       │           └── onboarding_screen.dart
│       ├── pregnancy/
│       │   ├── data/
│       │   │   ├── pregnancy_repository.dart
│       │   │   └── preventative_care_repository.dart
│       │   ├── domain/
│       │   │   ├── advanced_pregnancy_info.dart
│       │   │   ├── breeding_record.dart
│       │   │   ├── calendar_reminder.dart
│       │   │   ├── pregnancy_calculation_utils.dart
│       │   │   ├── pregnancy_record.dart
│       │   │   └── preventative_care_record.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   ├── pregnancy_provider.dart
│       │       │   └── preventative_care_provider.dart
│       │       ├── screens/
│       │       │   ├── advanced_pregnancy_info_screen.dart
│       │       │   ├── breeding_details_screen.dart
│       │       │   ├── mare_preventative_care_screen.dart
│       │       │   ├── pregnancy_details_screen.dart
│       │       │   ├── pregnancy_module_screen.dart
│       │       │   ├── pregnancy_scans_screen.dart
│       │       │   ├── preventative_care_screen.dart
│       │       │   ├── recipient_mare_details_screen.dart
│       │       │   └── veterinarian_pregnancy_scans_screen.dart
│       │       └── widgets/
│       │           ├── contact_number_block.dart
│       │           ├── scan_due_block.dart
│       │           └── vaccination_row.dart
│       ├── profile/
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── settings_provider.dart
│       │       └── screens/
│       │           ├── change_password_screen.dart
│       │           ├── delete_account_screen.dart
│       │           ├── profile_screen.dart
│       │           └── settings_screen.dart
│       └── puppy/
│           ├── data/
│           │   └── puppy_repository.dart
│           ├── domain/
│           │   ├── dog_preventative_care.dart
│           │   ├── puppy.dart
│           │   └── puppy_weight.dart
│           └── presentation/
│               ├── providers/
│               │   └── puppy_provider.dart
│               └── screens/
│                   ├── dog_preventative_care_screen.dart
│                   ├── puppy_details_screen.dart
│                   ├── puppy_list_screen.dart
│                   └── puppy_weight_tracker_screen.dart
```

---

## 6. Verification & Quality Assurance Highlights

1. **State Isolation & Memory Safety**: All Riverpod providers use appropriate caching and invalidation logic to keep counts and lists fresh across tabs without unnecessary re-renders.
2. **Error & Feedback System**: Reusable `AppFeedbackSnackbar` provides consistent gold/red/green notifications for network operations, field validation, and save events.
3. **Hardware Permissions Handling**: Robust permission checks (`PermissionService`) before accessing device cameras and photo galleries.
4. **Data Integrity & Cascades**: Foreign keys with `ON DELETE CASCADE` and `ON DELETE SET NULL` prevent orphaned data when deleting animals or pregnancies.
5. **Cross-Platform PDF Handling**: High-resolution vector PDF rendering with printing and native OS sharing support on both iOS and Android.

---
*Documentation compiled and verified for Animal Birthday Predictor (ABP).*
