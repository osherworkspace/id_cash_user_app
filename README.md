# ID-CASH User App — first-launch onboarding and authentication foundation

The User App now has a four-screen first-time experience using the original ID-CASH promotional artwork, in this exact order:

1. Facial verification at an ID-CASH agent
2. IDC Number and passcode withdrawals
3. ID-CASH username transfers
4. Airtime, data and bill payments

Use **Skip**, **Next**, and **Get started**. Successful completion is persisted locally, so subsequent launches open the Welcome / Create account / Log in screen.

## Add the exact uploaded artwork

Extract the user-provided `idcash_onboarding_assets.zip` and copy `user/assets/images/*` into this repository's `assets/images/` directory **before a real branded APK build**. Required files:

- `assets/images/brand_logo.png`
- `assets/images/app_icon.png`
- `assets/images/onboarding_face.png`
- `assets/images/onboarding_idc.png`
- `assets/images/onboarding_send.png`
- `assets/images/onboarding_services.png`

GitHub code-writing tools in this environment do not accept raw image uploads. The Flutter CI creates **transparent stand-in PNGs solely to test compilation**; these are not the branded uploaded images. Never release a CI-generated debug build as a fully branded app until the originals have been copied into the source tree.

## Local run

Install Flutter and Android SDK. Run `flutter create . --platforms=android --project-name=id_cash_user_app`, `flutter pub get`, then `flutter run --dart-define=IDC_API_BASE_URL=https://YOUR-TEST-BACKEND`.

Backend API contracts: `POST /api/auth/otp/request`, `/api/auth/otp/verify`, `/api/auth/register`, `/api/auth/login`. Corresponding backend code is in ID-CASH Backend PR #11, with database-backed OTP safeguards, restricted registration and login.

No Twilio or JWT secrets belong in the Flutter app. Account creation remains restricted until identity verification. The User App does not initiate agent withdrawals.
