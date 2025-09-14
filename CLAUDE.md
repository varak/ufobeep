# UFOBeep Development Context

## Critical Workflow Rules
- Follow workflow phases in order: INIT → SELECT → REFINE → IMPLEMENT → COMMIT
- Get user confirmation or input at each STOP
- Iterate on refinement STOPs until user confirms
- Do not mention yourself in commit messages or add yourself as a committer
- Consult with the user in case of unexpected errors
- Do not forget to stage files you added, deleted, or modified in the IMPLEMENT phase
- **ALWAYS increment build number in app/pubspec.yaml (version: x.x.x+N) before building APK**

## ABSOLUTE PROHIBITIONS - NEVER DO THESE
- **NEVER use git reset --hard, git reset, git stash, or ANY destructive git commands without explicit user approval**
- **NEVER attempt to resolve merge conflicts automatically - ALWAYS ask user first**
- **NEVER make destructive changes to production systems without explicit approval**
- **NEVER override user warnings about not clobbering changes**
- **NEVER take git actions that could lose uncommitted work**
- **When encountering merge conflicts: STOP and ask user how to proceed**
- **NEVER manually add translations to specific language files (es/, de/, fr/, etc.) - ONLY add to English ARB file then run generation script**
- **NEVER edit individual language JSON files directly - this breaks translation consistency across all 22 languages**
- **ALWAYS add new translation keys to app/lib/l10n/app_en.arb ONLY, then run node scripts/generate-all-translations.js**
- **NEVER run node scripts/generate-all-translations.js directly - it always times out in CLI environment**
- **Instead: tell user to run translate.sh script which handles the timeout properly**

## Development Quick Start Context

**PROJECT**: UFOBeep - Flutter mobile app + Next.js web + FastAPI backend for UFO/anomaly sighting reports

**CURRENT STATUS (Production)**:
- ✅ Email collection system working on ufobeep.com/app
- ✅ PostgreSQL database with email_interests table (6 emails collected)
- ✅ API service cleaned up and running as systemd service
- ✅ Task 17 (app page) 95% complete
- 🟡 15/40 tasks complete, 10 partial, 17 todo

**PRIORITY DEVELOPMENT TASKS**:
- Task 07: Profile/Registration UI (prefs, range, language)
- Task 10: Beep (Capture/Upload) screen with preview & submit  
- Task 22: Create sighting endpoint + mobile client wiring
- Task 21: Upload presign endpoint for S3/file uploads
- Task 19: Legal pages (/privacy, /terms, /safety)
- Task 37: SEO (sitemap, robots.txt)

**PROJECT STRUCTURE**:
- `/app/` = Flutter mobile app
- `/web/` = Next.js website
- `/api/` = FastAPI backend  
- `/shared/` = Shared models/contracts
- `/docs/` = Task list and acceptance criteria

**KEY FILES**:
- `docs/task.md` - 40 sequential build tasks
- `docs/acceptance-criteria.md` - AC-1 to AC-6 requirements
- `app/lib/main.dart` - Flutter entry point
- `api/app/main.py` - FastAPI server
- `web/src/app/page.tsx` - Next.js homepage

**PRODUCTION DATABASE**:
- PostgreSQL: localhost, ufobeep_db, user: ufobeep_user, pass: ufopostpass
- Tables: email_interests (working), others TBD

**RECENT CHANGES**:
- Fixed email submission system with proper JSON responses
- Eliminated 5 competing API processes → 1 systemd service
- Updated EmailNotifySignup component
- Added startup script and service management

**DEVELOPMENT WORKFLOW**:
1. Work on features locally (this machine)
2. Test mobile app in simulator/device
3. Test API endpoints locally
4. Deploy to production when ready
5. Follow git workflow with descriptive commits

**ACCEPTANCE CRITERIA FOCUS**:
- AC-1: User registration and profile setup
- AC-2: Capture and report sighting (photo/video + metadata)
- AC-3: Browse and filter alerts
- AC-4: View alert details and join chat
- AC-5: Compass navigation (standard mode)
- AC-6: Pilot mode navigation

**WHEN STARTING DEVELOPMENT**: Check git status, review current task priorities, set up local dev environment for Flutter/Next.js/FastAPI testing.

## Memory Notes
- Production API running on port 8000 with systemd service
- Email form working and collecting addresses
- Mobile app has basic structure but needs core features
- Focus on user registration and sighting capture next
- don't add yourself as an author or mention yourself in commit messages
- dont include yourself in commits message or as an author
- don't mention yourself or add yourself in commit messages
- scp -P322 /home/mike/D/ufobeep/add_enrichment_column.py ufobeep@ufobeep.com:/home/ufobeep/  is the correct command, please include the port when giving me examples
- dont add yourself in git messages
- don't add yourself or mention yourself in commit messages or commits
- don't add yourself or mention yourself in commit messages or commits
- production machine ssh is port 322
- production hostname is ufobeep.com user ufobeep
- CRITICAL: NEVER start development servers on production! Only use production mode
- NEVER use `next dev` or development mode on production server
- Always use `NODE_ENV=production npm start` for Next.js production
- Development servers cause white pages, 404s, and stability issues

  Production Server Access:

  - SSH: ssh -p 322 ufobeep@ufobeep.com
  - Project path: /home/ufobeep/ufobeep
  - API service: sudo systemctl restart ufobeep-api

  Local Development:

  - Project root: /home/mike/D/ufobeep
  - Mobile app path: /home/mike/D/ufobeep/app
  - API path: /home/mike/D/ufobeep/api

  Key Configuration:

  - MinIO bucket: ufobeep-media (created on production)
  - API endpoints: Working at http://localhost:8000/media/*
  - Database credentials:
    - Database: ufobeep_db
    - User: ufobeep_user
    - Password: ufopostpass
    - Host: localhost:5432

  Git Workflow:

  - Deploy pattern: git push → ssh -p 322 ufobeep@ufobeep.com "cd /home/ufobeep/ufobeep && git pull origin main && cd web && npm run build"
  - Website deployment: After git pull, rebuild with `npm run build`
  - Kill any dev servers: `sudo pkill -f 'next dev'`
  - Start production: `NODE_ENV=production npm start`

  Current Status:

  - Alpha download section live at /app page
  - APK uploaded to /web/public/downloads/ufobeep-alpha.apk (219MB)
  - Website serving properly in production mode
  - All media serving working with HTTPS proxy and thumbnails
  - API error messages now include helpful troubleshooting tips
  - ✅ PUSH NOTIFICATIONS WORKING: Firebase singleton fix completed (Aug 29, 2025)
    - Fixed "The default Firebase app already exists" errors with idempotent initialization
    - Created singleton Firebase client pattern in api/app/core/firebase_client.py
    - Added FastAPI lifespan initialization for startup-only Firebase init
    - End-to-end beep → proximity → push notification flow verified working
    - Successfully delivered push notifications to 2 registered devices
    - Test endpoint /debug/fcm confirms Firebase messaging client available

  Mobile Testing:

  - ADB: Check current port with `adb devices`
  - APK path: ./app/build/app/outputs/flutter-apk/app-debug.apk
- don't mention or add yourself to commit messages
- no this is not a test/development setup, we test in production here. DO NOT SETUP TEST/DEVELOPMENT use real shit live.!!
- make sure what you think is already in place isn't just a stub that doesnt work
- make sure what you think is already in place isn't just a stub that doesnt work
- don't refrence or add yourself to commits
- production is on ssh port 322
- do not attempt any quick fix this will just create more problems in the future
- do not start dev servers
- NEVER put dev servers and put stuff in dev server mode, it just causes problems on production
- dont mention yourself in commits, proceed.
- dont mention/add yourself in commits
- dont add or mention yourself in commits
- next time i say test it now i mean I want to make sure my phone is hooked up to wireless debug, push/pull the changes along w the restarts as outlined in the 
  masterplan, push to my phone and test
- I need you to evaluate against docs/Master Plan 10
- don't mention yourself in these commits

# Documentation Maintenance Instructions
ALWAYS keep docs updated when making changes:

## Doc Update Triggers
- **New/changed API endpoint** → Update `docs/ENDPOINTS.md`
- **Deployment process changes** → Update `docs/DEPLOYMENT.md`
- **Major features/architecture** → Update `docs/MASTER_PLAN_v13.md`
- **Dev setup/commands** → Update `docs/QUICKSTART.md`
- **GitHub Actions changes** → Update `docs/CI.md`

## Quick Production Reference
- **Deploy**: `./deploy.sh [api|web|apk|all]` (requires 3+ devices for APK)
- **Deploy to specific device**: `./deploy.sh moto` or `./deploy.sh tablet` or `./deploy.sh pixel`
- **API Service**: `sudo systemctl restart ufobeep-api`
- **Web Service**: `sudo systemctl restart ufobeep-web` (NO PM2!)
- **SSH**: `ssh -p 322 mike@ufobeep.com`
- **Logs**: `sudo journalctl -u ufobeep-[api|web] -f`

## IMPORTANT: Mobile Deployment
- **ALWAYS use the deploy script**: `cd /home/mike/D/ufobeep && ./deploy.sh moto` (or other device)
- **Deploy script location**: `/home/mike/D/ufobeep/deploy.sh`
- **What it does**: Commits changes, builds APK, installs to device, uploads to server
- **DO NOT manually build/install APK** - use the deploy script instead
- **Available targets**: moto, tablet, pixel, samsung, or blank for all devices

## FIXED ISSUES
- **Authentication Token Persistence** (Aug 28, 2025) - Commit `7b23b0e6`
  - Root cause: Dual Dio HTTP client instances causing auth header confusion
  - Solution: Eliminated instance `_dio`, use only static `ApiClient.dio`
  - Fixed endpoint path: `/me` → `/users/me`
  - Users now stay logged in across app restarts ✅
  - Documentation: `docs/AUTHENTICATION_FIX.md`

# CRITICAL RULE: NEVER SKIP DOCS UPDATES
- ALWAYS update documentation when making changes
- NEVER skip updating docs to "save time" or for any reason
- Documentation is as important as the code itself
- If file is locked/modified, wait and try again - don't skip!
- do not delete shit from the database without using a tool to make sure you dont orphan data
- NEVER USE GIT STASH - it will lose changes! Always commit production changes first, then pull.

# Translation System - CRITICAL RULES
**NEVER HARDCODE TRANSLATIONS IN ANY FILE**
- ONLY use ARB files as single source of truth for all translations
- NEVER edit JSON translation files directly - they are auto-generated
- NEVER add hardcoded strings to components - always use ARB keys
- When translations are missing/broken: ADD to English ARB, then regenerate

**Translation Workflow:**
1. Add/fix keys in `/app/lib/l10n/app_en.arb` (English master)
2. Run `node scripts/generate-all-translations.js` to generate all languages
3. Run `npm run sync-translations` in web/ to sync to website
4. Never skip step 2 - placeholder translations like "# key #" need proper generation

**Common Issues:**
- Spanish showing "# beep only #" = placeholder needs translation generation
- Missing shape translations = missing ARB keys, need generation
- Hardcoded fallbacks = DELETE and use ARB keys onlyNEVER use English language fallbacks in translations - ALWAYS ensure each language has proper translations in its own language. Use non-null assertions (!) not nullable access (?) with fallbacks.
