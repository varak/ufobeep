# UFOBeep Development Context

## Critical Workflow Rules
- Follow workflow phases in order: INIT → SELECT → REFINE → IMPLEMENT → COMMIT
- Get user confirmation or input at each STOP
- Iterate on refinement STOPs until user confirms
- Do not mention yourself in commit messages or add yourself as a committer
- Consult with the user in case of unexpected errors
- Do not forget to stage files you added, deleted, or modified in the IMPLEMENT phase

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