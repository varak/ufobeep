# UFOBeep Quick Start

## Project Structure
```
/home/mike/D/ufobeep/
├── api/          # FastAPI backend
├── app/          # Flutter mobile app  
├── web/          # Next.js web app
├── scripts/      # Deployment scripts
├── docs/         # Documentation
└── deploy.sh     # Main deployment script
```

## Local Development

### API
```bash
cd api
source venv/bin/activate
uvicorn app.main:app --reload
# http://localhost:8000
```

### Web
```bash
cd web
npm install
npm run dev
# http://localhost:3000
```

### Mobile
```bash
cd app
flutter pub get
flutter run
# Or build APK:
flutter build apk --release
```

## Production Deployment

### Quick Deploy
```bash
./deploy.sh         # Deploy everything
./deploy.sh api     # API only
./deploy.sh web     # Web only
./deploy.sh apk     # Mobile only
```

### Production Services
Both services managed by systemd:
- API: `systemctl status ufobeep-api`
- Web: `systemctl status ufobeep-web`

### URLs
- API: https://api.ufobeep.com
- Web: https://ufobeep.com
- APK: https://ufobeep.com/downloads/ufobeep-latest.apk

## SSH Access
```bash
ssh -p 322 mike@ufobeep.com
```

## Key Features
- Real-time UFO alerts with location tracking
- Multi-media evidence upload (photos/videos)
- MUFON integration for reporting
- Enrichment data (ISS, satellites, aircraft)
- BlackSky satellite imagery (coming soon)

## Testing Devices
Connect 3+ devices via ADB:
```bash
adb devices
adb connect 192.168.0.49:43413  # Moto wireless
```

## Documentation
- [Master Plan](MASTER_PLAN_v13.md) - Roadmap and features
- [Endpoints](ENDPOINTS.md) - API documentation
- [Deployment](DEPLOYMENT.md) - Detailed deployment guide
- [Contributing](CONTRIBUTING.md) - Git workflow
- [CI](CI.md) - GitHub Actions setup