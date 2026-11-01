# ID-CASH User App — Flutter foundation

This branch introduces the ID-CASH customer registration and login Flutter UI and HTTP client. It does not replace the already-installed prototype automatically.

## Getting started

Install Flutter, run `flutter create . --platforms=android` to generate standard Android scaffolding, then `flutter pub get` and `flutter run --dart-define=IDC_API_BASE_URL=https://YOUR-TEST-BACKEND`.

Never include Twilio API credentials or JWT signing secrets in the app. Use HTTPS except for local development.

**Integration status:** The Flutter API client has request contracts for `/api/auth/otp/request`, `/api/auth/otp/verify`, `/api/auth/register`, and `/api/auth/login`. The backend has internal authentication functions, but these HTTP routes have **not** been mounted. Frontend requests will not work end-to-end until the backend routes are implemented and tested.

New accounts must remain restricted until identity verification. The User App must not initiate agent withdrawals.
