# UFOBeep Quick Facts

## Project Structure
```
/home/mike/D/ufobeep/          # Project root
├── api/                       # FastAPI backend
├── app/                       # Flutter mobile app  
├── web/                       # Next.js website
└── docs/                      # Documentation
```

## Production URLs
- **Website**: https://ufobeep.com
- **API**: https://api.ufobeep.com  
- **Admin**: https://api.ufobeep.com/admin
- **SSH**: `ssh -p 322 ufobeep@ufobeep.com`

## Key Commands
```bash
# Deploy website
git push && ssh -p 322 ufobeep@ufobeep.com "cd /home/ufobeep/ufobeep && git pull && cd web && npm run build && pm2 restart all"

# Restart API
ssh -p 322 ufobeep@ufobeep.com "sudo systemctl restart ufobeep-api"

# Deploy APK wirelessly to beta testers
./scripts/distribute-beta.sh

# Deploy APK via USB to connected devices
cd app && flutter build apk --release
adb devices  # Check connected devices
adb -s DEVICE_ID install -r build/app/outputs/flutter-apk/app-release.apk

# Test anonymous beep
curl -X POST https://api.ufobeep.com/beep/anonymous -H "Content-Type: application/json" -d '{"device_id":"test","location":{"latitude":36.24,"longitude":-115.24},"description":"test"}'
```

## Current Issues
- **Anonymous beep with media**: ✅ FIXED in v0.8.1 APK (deployed to all 4 devices)
- **Witness aggregation**: Database missing confirmation_data column (fixed), datetime error remains
- **Beta testing**: Ready to distribute to wipodotcom@gmail.com after testing

## File Paths
- **API venv**: `/home/ufobeep/ufobeep/api/venv/`
- **Media storage**: `/home/ufobeep/ufobeep/media/`
- **Database**: PostgreSQL on production server
- **Service files**: `/etc/systemd/system/ufobeep-api.service`

## Firebase APK Distribution
- **Project**: ufobeep (346511467728)
- **Beta group**: "beta-testers" 
- **Console**: https://console.firebase.google.com/u/1/project/ufobeep/appdistribution
- **Script**: `./scripts/distribute-beta.sh` (builds APK, uploads wirelessly to all devices)