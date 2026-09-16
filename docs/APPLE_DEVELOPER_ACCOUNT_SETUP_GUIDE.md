# Apple Developer Program Setup & App Store Publishing Guide
**App Name:** Animal Birthday Predictor (ABP Pro)
**Version:** 1.1.0 (Build 2)
**Bundle Identifier:** `io.supabase.animalbirthdaypredictor`

---

## Overview
This guide outlines the complete process for enrolling in the Apple Developer Program, setting up App Store Connect, configuring signing certificates, and submitting Animal Birthday Predictor for iOS review.

---

## Step 1: Enroll in the Apple Developer Program
1. Visit the [Apple Developer Program Enrollment](https://developer.apple.com/programs/enroll/).
2. Sign in with an Apple ID (enforce Two-Factor Authentication).
3. Select Entity Type:
   - **Company / Organization** (Recommended for corporate stud management). Requires D-U-N-S Number, legal entity verification, and legal binding authority.
   - **Individual / Sole Proprietor** (Published under individual owner's name).
4. Pay the annual fee ($99 USD / year).
5. Identity verification will be processed by Apple (1-3 business days for Organizations).

---

## Step 2: Register Bundle Identifier & App ID
1. Log into [Apple Developer Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list).
2. Click **+** to add a new Identifier -> Select **App IDs**.
3. Description: `Animal Birthday Predictor`
4. Bundle ID: Select **Explicit** -> Enter `io.supabase.animalbirthdaypredictor`.
5. Capabilities to enable:
   - **Associated Domains** (For deep linking e.g. `applinks:abp.app`).
   - **In-App Purchase** (For certificate credit pack top-ups).
   - **Sign In with Apple** (If offering social auth).
6. Save and register the App ID.

---

## Step 3: Create App Record in App Store Connect
1. Navigate to [App Store Connect](https://appstoreconnect.apple.com).
2. Go to **My Apps** -> Click **+** -> **New App**.
3. Platform: **iOS**
4. Name: `Animal Birthday Predictor`
5. Primary Language: `English (US)` or `English (UK)`
6. Bundle ID: Select `io.supabase.animalbirthdaypredictor`.
7. SKU: `ABP-PRO-2026-EQUINE`
8. User Access: `Full Access`.

---

## Step 4: Configure App Store Information & Metadata
In App Store Connect under **App Information** & **Version 1.1.0**:

1. **Category:** `Business` (Primary) / `Medical` or `Utilities` (Secondary).
2. **Privacy Policy URL:** Enter `https://your-domain.com/website/privacy.html`.
3. **Subtitle** (30 chars max):
   > Equine Foaling & Scan Predictor
4. **Promotional Text** (170 chars max):
   > Professional stud management app for equine foaling, 45-day ultrasound scan records, and official PDF certificates.
5. **Description:**
   > Animal Birthday Predictor (ABP Pro) is an executive stud management platform designed specifically for Thoroughbred breeders, equine stud masters, and veterinary professionals.
   > 
   > Key Features:
   > • 340-Day Equine Gestation & 45-Day Ultrasound Milestone Tracking
   > • Embryo Transfer (ET) & ICSI Recipient/Donor Mare Identification
   > • High-Resolution Vector PDF Certificates with Guilloche Security Seals
   > • Entitlement System with 5 Free Starter Certificate Credits
   > • Multi-Device Cloud Sync with Offline Capabilities
6. **Support URL:** Enter `https://your-domain.com/website/support.html`.
7. **App Store Screenshots:**
   - 6.7" Display (iPhone 15 Pro Max / 14 Pro Max): At least 3 screenshots (1290 x 2796 px).
   - 6.5" Display (iPhone 11 Pro Max / XS Max): At least 3 screenshots (1242 x 2688 px).
   - 12.9" iPad Display (6th Gen): Recommended for iPad users in stud offices.

---

## Step 5: Configure App Privacy Questionnaire
Under **General** -> **App Privacy**:
1. Click **Get Started**.
2. Declare data collection:
   - **Contact Info:** Email Address, Name (Used for Account Functionality).
   - **User Content:** Animal / Breeding Records (Used for App Functionality).
   - **Identifiers:** User ID (Used for Account & Entitlement Management).
3. Specify that no data is used for tracking across third-party apps.

---

## Step 6: Build & Upload iOS Archive (.ipa)
On macOS with Xcode installed:
1. Open terminal in project root:
   ```bash
   flutter build ipa --release
   ```
2. Open Xcode -> Window -> **Organizer**.
3. Select the built archive -> Click **Distribute App** -> Choose **App Store Connect**.
4. Select **Upload** and follow prompts to automatically sign and upload the build.

---

## Step 7: App Review Submission
1. In App Store Connect under **Version 1.1.0**, scroll to **Build** and select the uploaded build.
2. Complete **App Review Information**:
   - Provide a test account credentials (`testuser@abp.app` / password).
   - Add Notes for Reviewer:
     > Animal Birthday Predictor is a B2B professional stud management tool for equine and canine breeders. 45-day scan certificates and foaling calculations can be tested using the provided test account.
3. Click **Submit for Review**.
4. Apple review typically takes 24 to 48 hours.
