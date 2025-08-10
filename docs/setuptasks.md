# UFOBeep Production Setup Tasks

## 🎯 **CRITICAL UNDERSTANDING**

**Why the mobile app shows "no changes":** The UFOBeep app has sophisticated offline-first architecture that automatically serves cached/fallback content when the backend API is unreachable. This is NOT a bug - it's by design for offline functionality.

**Root Issue:** Backend infrastructure (API, database, Redis) is NOT deployed on production server, causing the mobile app to operate in cached/offline mode.

---

## 📋 **PRODUCTION DEPLOYMENT CHECKLIST**

### **Phase 1: Environment Configuration**
- [ ] **Copy environment template**
  ```bash
  cd /home/mike/D/ufobeep
  cp .env.example .env
  ```

- [ ] **Configure production .env file** (critical values):
  ```bash
  # Domain Configuration
  API_BASE_URL=https://api.ufobeep.com
  NODE_ENV=production
  
  # Database (secure passwords!)
  DATABASE_URL=postgresql://ufobeep_user:SECURE_PASSWORD@localhost:5432/ufobeep_prod
  
  # Security (generate secure values!)
  JWT_SECRET=your_secure_32_character_jwt_secret_here
  ENCRYPTION_KEY=your_secure_32_character_encryption_key
  
  # External APIs (required for functionality)
  OPENWEATHER_API_KEY=your_openweather_api_key_here
  OPENSKY_CLIENT_ID=your_opensky_username_here
  OPENSKY_CLIENT_SECRET=your_opensky_password_here
  
  # Optional but recommended
  HUGGINGFACE_API_TOKEN=your_huggingface_token_here
  ```

### **Phase 2: Docker Services Deployment**
- [ ] **Start all Docker services**
  ```bash
  docker-compose up -d
  ```

- [ ] **Verify services are running**
  ```bash
  docker-compose ps
  # Should show: ufobeep-api, ufobeep-db, ufobeep-redis, ufobeep-minio
  ```

- [ ] **Check service health**
  ```bash
  # API health check (should return 200)
  curl http://localhost:8000/health
  
  # Database connectivity
  docker-compose exec db psql -U postgres -d ufobeep -c "SELECT version();"
  
  # Redis connectivity  
  docker-compose exec redis redis-cli ping
  ```

### **Phase 3: Database Initialization**
- [ ] **Run database migrations**
  ```bash
  docker-compose exec api alembic upgrade head
  ```

- [ ] **Verify database schema**
  ```bash
  docker-compose exec db psql -U postgres -d ufobeep -c "\\dt"
  # Should show tables: sightings, alerts, users, etc.
  ```

### **Phase 4: Nginx & SSL Configuration**
- [ ] **Install UFOBeep nginx configuration**
  ```bash
  sudo cp /home/mike/D/ufobeep/nginx/ufobeep.conf /etc/nginx/sites-available/
  sudo ln -sf /etc/nginx/sites-available/ufobeep.conf /etc/nginx/sites-enabled/
  ```

- [ ] **Test nginx configuration**
  ```bash
  sudo nginx -t
  ```

- [ ] **Set up SSL certificates**
  ```bash
  sudo certbot --nginx -d ufobeep.com -d api.ufobeep.com
  ```

- [ ] **Reload nginx**
  ```bash
  sudo systemctl reload nginx
  ```

### **Phase 5: API Connectivity Verification**
- [ ] **Test API health endpoint**
  ```bash
  curl https://api.ufobeep.com/health
  # Should return: {"status": "healthy", "timestamp": "..."}
  ```

- [ ] **Test API sightings endpoint**
  ```bash
  curl https://api.ufobeep.com/api/v1/sightings
  # Should return JSON response (empty array initially is OK)
  ```

- [ ] **Check API logs for errors**
  ```bash
  docker-compose logs api
  ```

### **Phase 6: Mobile App Configuration** 
- [ ] **Update Flutter app environment** (in `/home/mike/D/ufobeep/app/lib/config/environment.dart`):
  ```dart
  static const String apiBaseUrl = 'https://api.ufobeep.com';
  ```

- [ ] **Clear app cache and rebuild**
  ```bash
  cd /home/mike/D/ufobeep/app
  flutter clean
  flutter pub get
  flutter build apk --debug
  ```

- [ ] **Uninstall old app and install fresh build on device**
  ```bash
  adb -s 192.168.0.49:42199 uninstall com.ufobeep.app.debug
  adb -s 192.168.0.49:42199 install build/app/outputs/flutter-apk/app-debug.apk
  ```

### **Phase 7: Frontend Website Deployment**
- [ ] **Deploy Next.js web app to Vercel**
  ```bash
  cd /home/mike/D/ufobeep/web
  vercel --prod
  ```

- [ ] **Configure Vercel domain**
  - Point domain to ufobeep.com
  - Set environment variables for API_BASE_URL

### **Phase 8: Final Testing & Validation**
- [ ] **Test complete user flow**
  1. Open mobile app (should connect to live API, not cached data)
  2. Register new account
  3. Take photo and submit beep
  4. Verify beep appears in web interface
  5. Test real-time notifications

- [ ] **Monitor service health**
  ```bash
  # Check all services are healthy
  docker-compose ps
  
  # Monitor API logs
  docker-compose logs -f api
  
  # Check nginx access logs
  sudo tail -f /var/log/nginx/ufobeep-api.access.log
  ```

---

## 🚨 **TROUBLESHOOTING GUIDE**

### **Common Issues**

**Issue:** API returns 503/502 errors
**Solution:** 
```bash
# Check if services are running
docker-compose ps
# Restart services if needed
docker-compose down && docker-compose up -d
```

**Issue:** Database connection errors
**Solution:**
```bash
# Check database logs
docker-compose logs db
# Ensure DATABASE_URL in .env matches container settings
```

**Issue:** Mobile app still shows cached content
**Solution:**
```bash
# Verify API is accessible
curl https://api.ufobeep.com/health
# Clear app data completely
adb -s 192.168.0.49:42199 shell pm clear com.ufobeep.app.debug
```

**Issue:** SSL certificate errors
**Solution:**
```bash
# Renew certificates
sudo certbot renew
# Check certificate status
sudo certbot certificates
```

---

## 🔍 **VERIFICATION COMMANDS**

After completing setup, run these commands to verify everything works:

```bash
# 1. Service Health
curl https://api.ufobeep.com/health

# 2. Database Connectivity
docker-compose exec db psql -U postgres -d ufobeep -c "SELECT COUNT(*) FROM information_schema.tables;"

# 3. Redis Functionality
docker-compose exec redis redis-cli set test "hello" && docker-compose exec redis redis-cli get test

# 4. MinIO Storage
curl http://localhost:9000/minio/health/live

# 5. Complete API Test
curl -X POST https://api.ufobeep.com/api/v1/health \
  -H "Content-Type: application/json" \
  -d '{"test": true}'
```

---

## 📊 **SUCCESS METRICS**

Production deployment is successful when:
- ✅ All Docker services running (`docker-compose ps`)
- ✅ API health endpoint returns 200 (`curl https://api.ufobeep.com/health`)
- ✅ Database accessible and migrations applied
- ✅ Mobile app connects to live API (no "cached content" messages)
- ✅ Users can register, login, and submit beeps
- ✅ Website loads at https://ufobeep.com

---

## 📝 **NEXT STEPS AFTER PRODUCTION**

1. **Monitor Performance**: Set up proper logging and monitoring
2. **Backup Strategy**: Configure automated database backups
3. **Security Hardening**: Review and harden production security settings
4. **Load Testing**: Test system under load
5. **Mobile App Store Deployment**: Submit to App Store/Play Store

---

**Critical Note:** Once backend is deployed, the mobile app will automatically switch from offline/cached mode to live functionality. The "no changes" issue will resolve once the API is accessible.