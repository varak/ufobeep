# UFOBeep Documentation

**Last Updated**: September 10, 2025  
**Status**: Production Ready with 22-Language Support

## 📋 Active Development
- **[SPRINT_TASK_LIST.md](SPRINT_TASK_LIST.md)** - 5-week sprint plan for Play Store release
  - Week 1: Critical bug fixes (multi-media, share-to-beep)
  - Week 2: Settings functionality (DND, units, languages)
  - Week 3: Sharing features & UI polish
  - Week 4: Map improvements & diagnostics
  - Week 5: Play Store preparation

## 🚀 Quick References
- **[QUICKSTART.md](QUICKSTART.md)** - Development environment setup
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Deploy scripts and procedures
- **[ENDPOINTS.md](ENDPOINTS.md)** - API endpoint documentation with dual `/beep` and `/alerts` support
- **[URL_ARCHITECTURE.md](URL_ARCHITECTURE.md)** - Smart short URLs with 22-language support
- **[TRANSLATION_SYSTEM.md](TRANSLATION_SYSTEM.md)** - Multi-language translation system

## 📖 Master Plans
- **[MASTER_PLAN_v16.md](MASTER_PLAN_v16.md)** - Current implementation status
  - ✅ Sprint A: Multi-Media Alerts (COMPLETED)
  - ✅ Sprint B: Comments + Follows + Push (COMPLETED)
  - 🔄 Sprint C: Share Cards + Sleep/DND (IN PROGRESS)
  - ⏳ Sprint D: Map & Operations (PENDING)

## 🔐 Configuration
- **[SECRETS.md](SECRETS.md)** - Environment variables and API keys
- **[CI.md](CI.md)** - Continuous integration setup (TODO)
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines (TODO)

## 📁 Archive Structure
```
archive/
├── completed_fixes/     # Resolved bugs and fixes
│   ├── AUTHENTICATION_FIX.md
│   ├── COMMENTS_SYSTEM_FIX.md
│   └── WITNESS_CONFIRMATION_*.md
├── old_plans/          # Previous master plans
│   ├── MASTER_PLAN_v13-v15.md
│   └── MP13-15_*.md
└── legacy/             # Initial development docs
    ├── acceptance-criteria.md
    ├── bugs-and-issues.md
    └── production-setup-guide.md
```

## 🎯 Recent Achievements 
1. ✅ **Language-Specific URLs** - 22 languages with SEO-friendly slugs
2. ✅ **Smart Short URLs** - `/ehf3` auto-detects language, redirects to `/beep/es/ovni-avistamiento-ehf3`
3. ✅ **Dual API Support** - Both `/beep` and `/alerts` endpoints for compatibility
4. ✅ **Translation System** - Automated generation of all language files
5. ✅ **Web Interface** - Fixed beeps display and infinite loading issues

## 🎯 Current Focus
1. **LibreTranslate Integration** - Automated translation on production
2. **Real-time Translation** - Dynamic translation of alert details
3. **Play Store Launch** - Multi-language app store listings

## 🌐 Multi-Language URLs
- **English**: https://ufobeep.com/beep/en
- **Spanish**: https://ufobeep.com/beep/es  
- **German**: https://ufobeep.com/beep/de
- **French**: https://ufobeep.com/beep/fr
- **Smart Short URLs**: https://ufobeep.com/ehf3 (auto-detects language)

## 🔧 Quick Commands
```bash
# Generate all translations (22 languages)
./translate.sh

# Deploy to production  
./deploy.sh

# Deploy APK to devices
./deploy.sh moto tablet pixel
```

## 📞 Support
- **Production**: https://ufobeep.com
- **API**: https://ufobeep.com/api  
- **GitHub**: [github.com/varak/ufobeep](https://github.com/varak/ufobeep)