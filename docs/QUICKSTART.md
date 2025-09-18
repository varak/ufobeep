# UFOBeep Quick Start

**Last Updated**: September 17, 2025
**Current Status**: Universal Translation System + Detail Page Improvements

## 📁 Project Structure
```
/home/mike/D/ufobeep/
├── api/          # FastAPI backend
├── app/          # Flutter mobile app  
├── web/          # Next.js web app
├── scripts/      # Deployment scripts
├── docs/         # Documentation (newly organized!)
└── deploy.sh     # Main deployment script
```

## 🚀 Local Development

### API Server
```bash
cd api
source venv/bin/activate
uvicorn app.main:app --reload --port 8000
# http://localhost:8000
# Docs: http://localhost:8000/docs
```

### Web Application
```bash
cd web
npm install
npm run dev
# http://localhost:3000
```

### Mobile App
```bash
cd app
flutter pub get
flutter run                    # Run on connected device
flutter run -d all            # Run on all devices
flutter build apk --release   # Build release APK
```

## 📦 Production Deployment

### Quick Deploy Script
```bash
./deploy.sh         # Deploy everything (recommended)
./deploy.sh api     # API backend only
./deploy.sh web     # Website only
./deploy.sh apk     # Mobile APK to all devices
./deploy.sh moto    # Deploy to Moto device only
./deploy.sh tablet  # Deploy to tablet only  
./deploy.sh pixel   # Deploy to Pixel only
```

### Production Services
Both services managed by systemd:
```bash
# API Service
sudo systemctl status ufobeep-api
sudo systemctl restart ufobeep-api
sudo journalctl -u ufobeep-api -f

# Web Service
sudo systemctl status ufobeep-web
sudo systemctl restart ufobeep-web
sudo journalctl -u ufobeep-web -f
```

## 🌐 Production URLs

### Primary URLs
- **API**: https://ufobeep.com/api
- **Website**: https://ufobeep.com
- **APK Download**: https://ufobeep.com/downloads/ufobeep-alpha.apk
- **Admin**: https://ufobeep.com/admin

### New Short URL System
- **Short URLs**: https://ufobeep.com/ehf3 (auto-detects language)
- **Language-specific**: https://ufobeep.com/ehf3/es (explicit Spanish)
- **Canonical URLs**: https://ufobeep.com/beep/es/enhanced-sighting-description-ehf3

## 🔑 SSH Access
```bash
ssh -p 322 mike@ufobeep.com
cd /home/ufobeep/ufobeep
```

## 📱 Device Testing

### Connected Devices
```bash
adb devices
# Expected active devices:
# HT75D0202593      device    (Moto - primary tester)
# ZY22K6LB7J        device    (Pixel - secondary tester) 
# Y5SSW8MZDIU45995  device    (Claude's Phone - witness tester)
```

### Deploy to Specific Devices
```bash
./deploy.sh moto pixel           # Multiple devices
./deploy.sh moto                 # Single device
adb -s HT75D0202593 install -r app/build/app/outputs/flutter-apk/app-debug.apk
```

## 🧪 Testing & Health Checks

### API Health
```bash
# Local - Test both endpoint families
curl http://localhost:8000/health
curl http://localhost:8000/beep?limit=5
curl http://localhost:8000/alerts?limit=5

# Production - Test both endpoint families
curl https://ufobeep.com/api/health
curl https://ufobeep.com/api/beep?limit=5
curl https://ufobeep.com/api/alerts?limit=5

# Test short URL redirection
curl -I https://ufobeep.com/ehf3
curl -I https://ufobeep.com/ehf3/es
```

### New URL Architecture Testing
```bash
# Test language detection
curl -H "Accept-Language: es-ES,es;q=0.9" -I https://ufobeep.com/ehf3

# Test canonical redirects
curl -I https://ufobeep.com/beep/en/old-slug-ehf3

# Test web API compatibility layer
curl https://ufobeep.com/api/beep?limit=5
```

### Flutter Testing
```bash
cd app
flutter test
flutter analyze
flutter doctor
```

### Web Testing
```bash
cd web
npm run lint
npm run build
```

## 🗄️ Database Access
```bash
# Production (from SSH)
PGPASSWORD=ufopostpass psql -h localhost -U ufobeep_user -d ufobeep_db

# Common queries
SELECT COUNT(*) FROM alerts;
SELECT COUNT(*) FROM users;
SELECT * FROM alerts ORDER BY created_at DESC LIMIT 5;
```

## 🔥 Recent Completions (September 17, 2025)
1. **✅ Universal Translation System**: All 22 languages work without English fallbacks
2. **✅ T+ Time Format**: Consistent aerospace time notation (T+1h30m) across platforms
3. **✅ Detail Page Fixes**: Reporter display, share link, and I See It Too button logic corrected
4. **✅ Translation Key Coverage**: 28+ new keys for weather/location/satellite sections
5. **✅ Web Component Consistency**: Unified approach between mobile and web components

## 🔥 Current Sprint Focus
1. **Multi-media upload bug** - Gallery allows multi-select but beep creation fails
2. **Share-to-beep** - Test external app sharing
3. **DND/Quiet hours** - Complete implementation
4. **Language settings** - i18n support
5. **Units settings** - Apply metric/imperial throughout app

## 🌍 New Architecture Features

### URL Structure
- **Dual Endpoint Support**: Both `/beep` and `/alerts` APIs available
- **Smart Short URLs**: Language-aware URL shortening
- **Automatic Language Detection**: Browser language detection with 20+ supported languages
- **Canonical Redirects**: SEO-friendly URL normalization

### Multi-language Support
- **Supported Languages**: es, de, fr, pt, ru, ja, zh, it, ar, ko, tr, hi, pl, cs, nl, sv, da, no, fi, el, he
- **URL Patterns**: `/{shortId}`, `/{shortId}/{lang}`, `/beep/{locale}/{slug}`
- **Middleware**: Next.js middleware handles language detection and URL rewriting

## 📚 Key Documentation
- **[ENDPOINTS.md](ENDPOINTS.md)** - Updated API documentation with dual endpoint support
- **[SPRINT_TASK_LIST.md](SPRINT_TASK_LIST.md)** - Active 5-week sprint plan
- **[MASTER_PLAN_v16.md](MASTER_PLAN_v16.md)** - Current implementation status
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Detailed deployment guide
- **archive/completed_fixes/** - Resolved issues and fixes

## 🎯 Play Store Readiness Checklist
- [ ] Fix critical multi-media bug
- [ ] Complete settings implementation
- [ ] Test on multiple devices and Android versions
- [ ] Generate release signing keys
- [ ] Create store listings in multiple languages
- [ ] Implement language-specific sharing platforms