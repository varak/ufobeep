# CI Overview

We use GitHub Actions to keep code quality high.

## Flutter Workflow (`.github/workflows/flutter.yml`)
- Runs on every push/PR that touches `app/` or `docs/`
- Steps:
  1. Install Flutter
  2. Run `flutter pub get`
  3. Run `flutter analyze`
  4. Run `flutter test`
  5. Build debug APK and upload as artifact

## API Workflow (`.github/workflows/api.yml`)
- Runs on every push/PR that touches `api/` or `docs/`
- Steps:
  1. Install Python 3.11
  2. Install dev deps (`ruff`, `pytest`)
  3. Run `ruff .` (lint)
  4. Run `pytest -q`

## Why this matters
- Ensures the app always builds & tests before merging
- Prevents broken code from landing in `main`
- Produces debug APKs automatically for testing
