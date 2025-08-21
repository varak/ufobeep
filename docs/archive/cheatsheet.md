# UFOBeep API Infrastructure Cheatsheet (v12)

## Core Architecture Updates (v12)
- **Human-Readable IDs**: `cosmic-whisper-7823` user system
- **Witness Media Sharing**: Multiple users can upload to same alert
- **Viral Social Sharing**: Localized platforms (X, VK, WeChat)
- **Simple Moderation**: 3-flag auto-hide, no complex admin queues
- **No Matrix Chat**: Replaced with evidence-only witness system

## Server Architecture
- **Single FastAPI server** serving all endpoints
- **Production URL**: https://api.ufobeep.com
- **Local development**: `/home/mike/D/ufobeep`

## Core API Endpoints (v12 Updates)

### Unified Alerts System
```
POST   /alerts                         → Create new alert
GET    /alerts                         → List all alerts  
GET    /alerts/{id}                    → Get specific alert
POST   /alerts/{id}/media              → Upload media (multi-user)
DELETE /alerts/{id}/media/{file}       → Remove media
PATCH  /alerts/{id}                    → Update alert details
POST   /alerts/{id}/witness            → Confirm witness
```

### User System (NEW in v12)
```
POST   /users/generate-id              → Generate cosmic-whisper-7823
GET    /users/check-availability/{id}  → Check if ID available
POST   /users/register                 → Create user account
GET    /users/{id}/profile             → Get user profile
```

### Content Moderation (NEW in v12)
```
POST   /alerts/{id}/media/{file}/flag  → Flag inappropriate content
GET    /admin/moderation/flagged       → View flagged content
```

### Social Sharing (NEW in v12)
```
GET    /social/platforms/{locale}      → Get platforms for locale
POST   /social/share/{alert_id}        → Generate share URLs
```

## Mobile App Flow (v12 Updates)

### New User Registration Flow
```
1. Welcome Screen                    ← NEW
2. Username Generator Screen         ← NEW  
3. Basic Setup Screen               ← NEW
4. Home Screen (existing)
```

### Enhanced Witness System
```
1. User sees alert                  ← Existing
2. "I SEE IT TOO" + media upload   ← ENHANCED
3. Camera/Gallery selection         ← NEW
4. Upload with attribution          ← NEW
```

### Viral Sharing Flow
```
1. Successful beep                  ← Existing
2. Share modal appears              ← NEW
3. Platform selection (X/VK/WeChat) ← NEW
4. Pre-filled message sent         ← NEW
```

## Database Schema Updates (v12)

### Users Table (NEW)
```sql
users (
  id UUID PRIMARY KEY,
  human_id VARCHAR(50) UNIQUE,
  email VARCHAR(255) NULL,
  phone VARCHAR(20) NULL,
  preferences JSONB,
  created_at TIMESTAMP
)
```

### Media Attribution (ENHANCED)
```sql
media (
  id UUID,
  alert_id UUID,
  user_id UUID,              -- NEW: Attribution
  filename VARCHAR(255),
  uploaded_by_witness BOOLEAN -- NEW: Original vs witness
)
```

### Content Flags (NEW)
```sql
content_flags (
  id UUID,
  media_id UUID,
  flagged_by UUID,
  flag_type VARCHAR(50), -- NSFW, Spam, Unrelated
  created_at TIMESTAMP
)
```

## Current Phase Status (v12)

### ✅ COMPLETED PHASES
- **Phase 0**: Emergency alert foundation
- **Phase 1**: Witness network (basic)
- **Phase 1.5**: Alert preferences & quiet mode
- **Phase 2**: Media capture (single user)

### 🔴 v12 PRIORITY PHASES
- **Phase 3**: User registration & human IDs
- **Phase 4**: Witness media system
- **Phase 5**: Viral social sharing
- **Phase 6**: Enhanced enrichment

## Environment Configuration
- **Single .env file**: `/home/mike/D/ufobeep/.env`
- **New API keys needed**:
  - OpenSky Network (✅ configured)
  - Social platform APIs (varies)
  - Enhanced moderation services

## Storage Architecture
- **Media storage**: `/home/ufobeep/ufobeep/media/{alert_id}/`
- **Multi-user uploads**: `{alert_id}/{user_id}_{filename}`
- **Attribution tracking**: Media linked to human IDs

## Internationalization (v12)
- **Flutter**: Extend existing `.arb` files
- **Next.js**: Extend existing JSON files
- **Social platforms**: Locale-specific configurations
- **Share messages**: Templated with alert ID, location

## Testing Commands (v12 Updates)

```bash
# Test user registration
curl -X POST https://api.ufobeep.com/users/generate-id

# Test witness media upload
curl -X POST https://api.ufobeep.com/alerts/{id}/media \
  -H "X-User-ID: cosmic-whisper-7823" \
  -F "file=@witness_photo.jpg"

# Test content flagging
curl -X POST https://api.ufobeep.com/alerts/{id}/media/{file}/flag \
  -d '{"flag_type": "NSFW", "user_id": "stellar-phoenix-9876"}'
```

## Production Deployment

### Standard Deploy (v12)
```bash
# Deploy API with user system
ssh -p 322 ufobeep@ufobeep.com "cd /home/ufobeep/ufobeep && git pull origin main"
ssh -p 322 ufobeep@ufobeep.com "sudo systemctl restart ufobeep-api"

# Deploy Web with social sharing
ssh -p 322 ufobeep@ufobeep.com "cd /home/ufobeep/ufobeep/web && npm run build && pm2 restart all"

# Deploy Mobile with registration flow
cd /home/mike/D/ufobeep/app && flutter build apk --release
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk
```

## Key v12 Changes Summary
- **No Matrix chat** → Simple witness media sharing
- **Human-readable IDs** → `cosmic-whisper-7823` format
- **Multi-user media** → Witnesses can upload evidence  
- **Viral sharing** → Localized social platforms
- **Simple moderation** → 3-flag system, auto-restoration
- **Progressive registration** → Welcome → Username → Preferences

## Success Metrics (v12)
- **User adoption**: Human ID generation working
- **Evidence collection**: Multi-witness media uploads
- **Viral growth**: Social sharing conversion >5%
- **Content quality**: <1% flagged content
- **Speed preserved**: ≤3 seconds beep to alert