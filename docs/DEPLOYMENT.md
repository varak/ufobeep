# UFOBeep Deployment Guide

## Quick Deploy

```bash
# Deploy everything (API, Web, Mobile)
./deploy.sh

# Deploy specific components
./deploy.sh api        # API only
./deploy.sh web        # Web only  
./deploy.sh apk        # Mobile only
./deploy.sh api web    # API and Web
```

## Production Services

Both API and Web are managed by systemd on production:

### API Service
- **Service**: `ufobeep-api.service`
- **Port**: 8000
- **URL**: https://api.ufobeep.com

```bash
# Check status
sudo systemctl status ufobeep-api

# Restart
sudo systemctl restart ufobeep-api

# View logs
sudo journalctl -u ufobeep-api -f
```

### Web Service (Next.js)
- **Service**: `ufobeep-web.service`
- **Port**: 3000
- **URL**: https://ufobeep.com

```bash
# Check status
sudo systemctl status ufobeep-web

# Restart
sudo systemctl restart ufobeep-web

# View logs
sudo journalctl -u ufobeep-web -f
tail -f /var/log/ufobeep-web.log
```

## Mobile Deployment

The deployment script automatically:
1. Checks for 3+ connected devices (required)
2. Installs APK to all connected devices
3. Uploads APK to production server

### Device Setup
```bash
# Connect devices via USB
adb devices

# Connect wireless device (Moto)
adb connect 192.168.0.49:43413
```

### Manual APK Build
```bash
cd app
flutter build apk --release
```

## SSH Access

```bash
# Connect to production
ssh -p 322 mike@ufobeep.com
```

## Service Configuration Files

### API Service (`/etc/systemd/system/ufobeep-api.service`)
```ini
[Unit]
Description=UFOBeep FastAPI Application
After=network.target

[Service]
Type=simple
User=ufobeep
WorkingDirectory=/var/www/ufobeep.com/html/api
ExecStart=/var/www/ufobeep.com/html/api/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

### Web Service (`/etc/systemd/system/ufobeep-web.service`)
```ini
[Unit]
Description=UFOBeep Next.js Web Application
After=network.target

[Service]
Type=simple
User=ufobeep
WorkingDirectory=/home/ufobeep/ufobeep/web
ExecStart=/usr/bin/npm run start
Restart=on-failure
Environment=NODE_ENV=production
Environment=PORT=3000
StandardOutput=append:/var/log/ufobeep-web.log
StandardError=append:/var/log/ufobeep-web.error.log

[Install]
WantedBy=multi-user.target
```

## Troubleshooting

### Service won't start
```bash
# Check service logs
sudo journalctl -u ufobeep-api -n 50
sudo journalctl -u ufobeep-web -n 50

# Check permissions
ls -la /var/www/ufobeep.com/html/api
ls -la /home/ufobeep/ufobeep/web
```

### Port conflicts
```bash
# Check what's using ports
sudo lsof -i :8000
sudo lsof -i :3000
```

### Reload systemd after config changes
```bash
sudo systemctl daemon-reload
sudo systemctl restart ufobeep-api
sudo systemctl restart ufobeep-web
```