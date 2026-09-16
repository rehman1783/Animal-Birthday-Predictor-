# Google Play Console Setup & App Publishing Guide
**App Name:** Animal Birthday Predictor (ABP Pro)
**Version:** 1.1.0 (Build 2)
**Package Name:** `io.supabase.animalbirthdaypredictor`

---

## Overview
This guide provides step-by-step instructions for setting up the Google Play Console account and preparing Animal Birthday Predictor for publication on the Google Play Store.

---

## Step 1: Create a Google Play Developer Account
1. Go to the [Google Play Console](https://play.google.com/console/signup).
2. Sign in with the primary Google Account associated with your stud/business.
3. Select Account Type:
   - **Organization / Business Account** (Recommended for corporate stud management & commercial credibility). You will need a D-U-N-S Number (Dun & Bradstreet).
   - **Individual Account** (If publishing as an independent developer).
4. Pay the one-time $25 USD registration fee.
5. Complete identity verification (Upload official photo ID or business registration documents).

---

## Step 2: Create a New Application
1. Click **Create app** in the Play Console header.
2. Fill in the initial app details:
   - **App name:** `Animal Birthday Predictor`
   - **Default language:** `English (US)` or `English (UK)`
   - **App or game:** `App`
   - **Free or Paid:** `Free` (with optional in-app purchases for certificate top-up packs).
3. Accept the Developer Declarations and click **Create app**.

---

## Step 3: Configure Store Listing & Brand Assets
In the left sidebar under **Grow** -> **Store presence** -> **Main store listing**:

1. **Short description** (Up to 80 chars):
   > Professional equine foaling predictor, 45-day scan records & PDF certificates.
2. **Full description** (Up to 4,000 chars):
   > Animal Birthday Predictor (ABP Pro) is the professional stud management and gestation tracking solution engineered for equine breeders, stud masters, and canine professionals.
   > 
   > Key Features:
   > • 340-Day Equine Gestation & 45-Day Ultrasound Milestone Tracking
   > • Embryo Transfer (ET) & ICSI Recipient/Donor Mare Identification
   > • Official High-Resolution PDF Certificates with Watermarks & Seals
   > • Entitlement System with 5 Free Starter Certificate Credits
   > • Multi-Device Cloud Sync with Offline Capabilities
3. **Graphics & Media Assets:**
   - **App Icon:** `512 x 512 px` (High-res PNG, feature the official gold ABP crest).
   - **Feature Graphic:** `1024 x 500 px` (JPEG/PNG showing dark navy & gold executive interface).
   - **Phone Screenshots:** At least 2 screenshots (minimum 1080px resolution) showcasing the Dashboard, 45-Day Scan Certificate, and Breeding Records.
   - **7-inch & 10-inch Tablet Screenshots:** Recommended for tablet users in stud farm offices.

---

## Step 4: Data Safety & Content Rating
1. Navigate to **App content** in the Play Console sidebar.
2. **Privacy Policy URL:** Enter your hosted privacy policy URL (e.g. `https://your-domain.com/website/privacy.html`).
3. **App Access:** Select "All functionality is available without special access restrictions" or provide demo credentials for testing (`testuser@abp.app` / password).
4. **Target Audience:** Select **18 and over** (Professional breeding platform).
5. **Content Rating Questionnaire:** Complete the IARC rating questionnaire (select Business/Productivity; standard rating: PEGI 3 / Everyone).
6. **Data Safety Section:** Declare that the app collects Email, Name, and User IDs over encrypted HTTPS for account management and security.

---

## Step 5: Build & Upload Android App Bundle (.aab)
1. In your local development workspace, build the production release bundle:
   ```bash
   flutter build appbundle --release
   ```
2. The compiled `.aab` file will be generated at:
   `build/app/outputs/bundle/release/app-release.aab`
3. In Play Console, go to **Testing** -> **Internal testing** or **Production**.
4. Click **Create new release**, upload `app-release.aab`, and enter release notes:
   > **What's New in v1.1.0:**
   > • Professional Equine Design & Corporate Gold Crest Logo
   > • 45-Day Ultrasound Milestone & Embryo Transfer (ET) Support
   > • High-resolution PDF Certificates with Security Watermark & Signature Block
   > • Certificate Quota Management System (5 Free Starter Credits)

---

## Step 6: Review & Publish
1. Check the **App overview** dashboard to ensure all required setup steps have green checkmarks.
2. Click **Start rollout to Production** (or Internal Testing).
3. Google review typically takes 24 to 72 hours for initial release.
