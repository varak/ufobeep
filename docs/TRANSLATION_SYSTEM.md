# UFOBeep Translation System

**Last Updated**: September 10, 2025  
**Status**: ✅ Production Ready with 22 Language Support

## Overview

UFOBeep implements a comprehensive translation system supporting 22 languages across both web and mobile platforms, with **language-specific SEO-friendly URLs** for optimal international reach.

## 🌍 Supported Languages

| Code | Language | RTL | URL Example |
|------|----------|-----|-------------|
| `en` | English | No | `/beep/en/ufo-sighting-phoenix-ehf3` |
| `es` | Spanish | No | `/beep/es/ovni-avistamiento-phoenix-ehf3` |
| `de` | German | No | `/beep/de/ufo-sichtung-phoenix-ehf3` |
| `fr` | French | No | `/beep/fr/ovni-observation-phoenix-ehf3` |
| `pt` | Portuguese | No | `/beep/pt/ovni-avistamento-phoenix-ehf3` |
| `it` | Italian | No | `/beep/it/ufo-avvistamento-phoenix-ehf3` |
| `ru` | Russian | No | `/beep/ru/нло-наблюдение-phoenix-ehf3` |
| `ja` | Japanese | No | `/beep/ja/ufo-目撃-phoenix-ehf3` |
| `zh` | Chinese | No | `/beep/zh/ufo-目击-phoenix-ehf3` |
| `ar` | Arabic | Yes | `/beep/ar/يوفو-رؤية-phoenix-ehf3` |
| `nl` | Dutch | No | `/beep/nl/ufo-waarneming-phoenix-ehf3` |
| `pl` | Polish | No | `/beep/pl/ufo-obserwacja-phoenix-ehf3` |
| `cs` | Czech | No | `/beep/cs/ufo-pozorování-phoenix-ehf3` |
| `tr` | Turkish | No | `/beep/tr/ufo-gözlem-phoenix-ehf3` |
| `ko` | Korean | No | `/beep/ko/ufo-목격-phoenix-ehf3` |
| `hi` | Hindi | No | `/beep/hi/ufo-दर्शन-phoenix-ehf3` |
| `sv` | Swedish | No | `/beep/sv/ufo-observation-phoenix-ehf3` |
| `da` | Danish | No | `/beep/da/ufo-observation-phoenix-ehf3` |
| `no` | Norwegian | No | `/beep/no/ufo-observasjon-phoenix-ehf3` |
| `fi` | Finnish | No | `/beep/fi/ufo-havainto-phoenix-ehf3` |
| `el` | Greek | No | `/beep/el/ufo-παρατήρηση-phoenix-ehf3` |
| `he` | Hebrew | Yes | `/beep/he/ufo-צפייה-phoenix-ehf3` |

## 🏗️ System Architecture

### Translation Sources
```
📂 Translation Sources
├── 🌐 Web Frontend
│   ├── web/public/locales/en/*.json (Master)
│   ├── web/public/locales/{lang}/*.json (Generated)
│   └── Translation files:
│       ├── beeps.json (Main beep interface)
│       ├── beep-detail.json (Alert details)
│       ├── common.json (Shared terms)
│       ├── navigation.json (Menu/nav)
│       └── meta.json (SEO metadata)
└── 📱 Mobile App
    ├── app/lib/l10n/app_en.arb (Master)
    ├── app/lib/l10n/app_{lang}.arb (Generated)
    └── app/lib/l10n/app_localizations*.dart (Flutter)
```

### URL Slug Translation
Language-specific classification terms are automatically translated for SEO-friendly URLs:

```json
{
  "slugs": {
    "ufo": "ovni",           // Spanish
    "sighting": "avistamiento",
    "sphere": "esfera",
    "triangle": "triangulo",
    "disk": "disco",
    "light": "luz",
    "fireball": "bola-fuego"
    // ... 20+ classification terms
  }
}
```

## 🚀 Quick Start

### Generate All Translations
```bash
# Run the master translation generator
./translate.sh

# Or manually:
node scripts/generate-all-translations.js
cd app && flutter gen-l10n
```

### Setup LibreTranslate (Production)
```bash
# On production server
./scripts/setup-libretranslate.sh

# Set environment variables
export LIBRETRANSLATE_URL=http://localhost:5000
export LIBRETRANSLATE_API_KEY=your_api_key
```

## 🔧 How It Works

### 1. Master Source Management
- **English is the source of truth** - all translations derive from English files
- No manual translation files - everything is generated consistently
- Single command regenerates all 22 languages

### 2. URL Generation Process
```javascript
// Input: English sighting data
{
  id: "293609d1...",
  title: "Sphere Sighting", 
  location: "Phoenix, Arizona"
}

// Output: Language-specific URLs
en: /beep/en/sphere-sighting-phoenix-2025-09-10-ehf3
es: /beep/es/esfera-avistamiento-phoenix-2025-09-10-ehf3
de: /beep/de/sphäre-sichtung-phoenix-2025-09-10-ehf3
```

### 3. Translation Pipeline
1. **Load English sources** (web JSON + app ARB files)
2. **Connect to LibreTranslate** for automatic translation  
3. **Generate web locale files** with optimized URL slugs
4. **Generate Flutter ARB files** for mobile app
5. **Create config files** for both platforms
6. **Generate Flutter localizations** with `flutter gen-l10n`

## 📝 File Structure

### Web Locales (`web/public/locales/{lang}/`)
```json
// beeps.json - Main interface
{
  "title": "Recent UFO Beeps",
  "loadingBeeps": "Loading recent beeps...",
  "slugs": {
    "ufo": "ufo",
    "sighting": "sighting",
    "sphere": "sphere",
    "triangle": "triangle"
  }
}

// beep-detail.json - Alert details  
{
  "witnesses": "Witnesses",
  "confirmations": "Confirmations",
  "mufon": {
    "classifications": {
      "sphere": "Sphere",
      "triangle": "Triangle"
    }
  }
}
```

### Mobile App Locales (`app/lib/l10n/`)
```json
// app_en.arb - Flutter ARB format
{
  "@@locale": "en",
  "alertsTitle": "Nearby Alerts",
  "viewAlert": "View alert",
  "reportedBy": "Reported by {username}",
  "@reportedBy": {
    "placeholders": {
      "username": {"type": "String"}
    }
  }
}
```

## 🎯 SEO Benefits

### Language-Specific URLs
- **Better Search Rankings**: `/beep/es/ovni-esfera-madrid-ehf3` ranks better in Spanish searches
- **User Experience**: URLs make sense to native speakers
- **Social Sharing**: More appealing when shared on social media

### Classification Coverage
Translated terms for all MUFON/NUFORC classifications:
- **Shapes**: sphere → esfera, triangle → triangulo, disk → disco
- **Phenomena**: fireball → bola-fuego, flash → destello
- **Descriptors**: formation → formacion, changing → cambiante

## ⚡ Performance

### Caching Strategy
- **Translation Cache**: Avoids re-translating identical terms
- **Rate Limiting**: Prevents overwhelming LibreTranslate
- **Batch Processing**: Efficient multi-language generation

### Production Deployment
```bash
# Build and deploy all languages
./translate.sh
cd web && npm run build
./deploy.sh web

# Mobile app includes all languages automatically
flutter build apk --release
```

## 🛠️ Development

### Adding New Translation Keys

1. **Add to English source files**:
```json
// web/public/locales/en/beeps.json
{
  "newFeature": "New Feature Title",
  "slugs": {
    "newClassification": "new-classification"  
  }
}
```

2. **Regenerate all languages**:
```bash
./translate.sh
```

3. **Deploy**:
```bash
git add . && git commit -m "Add new translation keys"
./deploy.sh
```

### Testing Translations
```bash
# Test specific language
node scripts/generate-all-translations.js es

# Test URL generation  
curl https://ufobeep.com/beep/es/ovni-esfera-madrid-ehf3

# Test mobile app
cd app && flutter test
```

## 🔍 Troubleshooting

### LibreTranslate Issues
```bash
# Check service status
curl http://localhost:5000/languages

# Restart service
sudo systemctl restart libretranslate

# Check logs
sudo journalctl -u libretranslate -f
```

### Missing Translations
```bash
# Force regenerate all files
rm -rf web/public/locales/*/
rm -rf app/lib/l10n/app_*.arb
./translate.sh
```

### URL Generation Problems
```bash
# Check slug generation
node -e "console.log(require('./web/src/utils/slug.js').getAlertSlug(...))"

# Test middleware routing
curl -I https://ufobeep.com/ehf3/es
```

## 📊 Current Status

### Implementation Status
- ✅ **22 Language Support**: All major languages covered
- ✅ **SEO-Friendly URLs**: Language-specific classification terms
- ✅ **Consistent Generation**: Single source, all platforms
- ✅ **Production Ready**: LibreTranslate integration working
- ✅ **Mobile Integration**: Flutter i18n fully implemented

### Analytics Impact
- 🎯 **International Reach**: URLs discoverable in all languages
- 📈 **SEO Performance**: Localized content improves rankings
- 👥 **User Engagement**: Native language experience increases usage

## 🚀 Future Enhancements

### Planned Features
- **Real-time Translation**: Translate user comments/descriptions
- **Regional Customization**: Localized date/time formats
- **Voice Recognition**: Multi-language voice beep reports
- **Cultural Adaptations**: Region-specific UFO terminology

### Technical Improvements
- **Translation Quality**: Human review workflow
- **Performance**: CDN caching for locale files
- **Automation**: CI/CD integration for continuous translation updates