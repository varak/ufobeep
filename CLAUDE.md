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