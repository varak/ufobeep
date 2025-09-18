# UFOBeep Translation System

**Last Updated**: September 17, 2025
**Status**: ✅ Production Ready with 22 Language Support

## Recent Critical Updates (Sept 17, 2025)

### 🔥 Major Fixes Implemented
1. **Fixed Alert Detail Reporter Display**: Mobile and web now consistently show "Reported by" field in Details section using `alert.username`
2. **Implemented T+ Time Format**: Consistent aerospace/military time notation (T+1h30m) across mobile and web detail pages
3. **Fixed Translation System**: Removed English fallbacks, made AlertTitleUtils require translation function for all 22 languages
4. **Fixed "I See It Too" Button Logic**: Properly hides button for user's own beeps using correct username field comparison
5. **Enhanced Detail Page Layout**: Moved share link and reporter info into Details section for cleaner mobile/web consistency
6. **Added Comprehensive Translation Keys**: 28+ new keys for weather, location, satellite, and aircraft sections with full translation coverage

## Overview

UFOBeep implements a comprehensive translation system supporting 22 languages across both web and mobile platforms, with **language-specific SEO-friendly URLs** and **ARB files as the single source of truth**.

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

### Single Source of Truth: ARB Files
```
📂 Translation Architecture (NEW)
├── 🎯 Single Source of Truth
│   └── app/lib/l10n/app_en.arb (Master English ARB)
├── 📱 Mobile App
│   ├── app/lib/l10n/app_{lang}.arb (Generated from master)
│   └── app/lib/l10n/app_localizations*.dart (Flutter)
└── 🌐 Web Frontend  
    ├── web/public/locales/{lang}/beep.json (Generated from ARB)
    ├── web/public/locales/{lang}/common.json
    ├── web/public/locales/{lang}/alerts.json
    └── web/src/translations/static-translations.json (Build-time)
```

### Key Changes from Previous Architecture
- **ARB Files are Master**: All translations now derive from mobile app ARB files
- **Unified Translation Pipeline**: Single generation process for both web and mobile
- **Consistent Naming**: `beep.json` (not `beeps.json`) for namespace consistency
- **Static Generation**: Web translations compiled at build-time for Edge Runtime compatibility

## 🔧 How It Works

### 1. Translation Generation Pipeline
```javascript
// New unified generation process
1. Read app/lib/l10n/app_en.arb (master source)
2. Read web/public/locales/en/*.json (web-specific terms)
3. Merge translations with ARB as priority
4. Generate translations via LibreTranslate
5. Output to both ARB and JSON formats
6. Compile static translations for Edge Runtime
```

### 2. URL Slug Generation with `short_url` Priority
```javascript
// Fixed slug generation logic
function getAlertSlug(alert, locale, translations, shortId) {
  // Priority order:
  // 1. Provided shortId parameter
  // 2. alert.short_url from database
  // 3. Generated from alert.id
  
  const id = shortId || alert.short_url || generateShortHash(alert.id)
  
  // Generate language-specific slug
  const ufoTerm = translations.slugs.ufo // "ovni" for Spanish
  const sightingTerm = translations.slugs.sighting // "avistamiento" for Spanish
  
  return `${ufoTerm}-${sightingTerm}-${location}-${date}-${id}`
}
```

### 3. Component Translation Loading
```javascript
// Fixed namespace: 'beep' not 'beeps'
const { t } = useClientTranslations('beep', locale)

// Fetches from: /locales/es/beep.json
// Not from: /locales/es/beeps.json (old, incorrect)
```

## 📝 File Structure Updates

### Naming Convention (IMPORTANT)
- **URL Path**: `/beep/[locale]` (singular)
- **Translation Namespace**: `'beep'` (singular)  
- **Translation File**: `beep.json` (singular)
- ❌ **NOT**: `beeps.json` or `'beeps'` namespace

### Web Translation Files
```
web/public/locales/{lang}/
├── beep.json         # Main beep interface (was beeps.json)
├── alerts.json       # Alert-related translations
├── common.json       # Common UI terms
├── navigation.json   # Navigation elements
├── meta.json        # SEO metadata
├── errors.json      # Error messages
└── forms.json       # Form fields
```

### Mobile ARB Files (Master Source)
```
app/lib/l10n/
├── app_en.arb       # Master English source
├── app_es.arb       # Spanish (generated)
├── app_de.arb       # German (generated)
└── ... (22 total languages)
```

## 🚀 Quick Start

### Generate All Translations
```bash
# Use the unified generation script
cd /home/mike/D/ufobeep
node scripts/generate-all-translations.js

# This will:
# 1. Read ARB files as source
# 2. Generate web JSON files
# 3. Create static translation bundle
# 4. Update Flutter localizations
```

### Deploy Changes
```bash
# Deploy web with new translations
./deploy.sh web

# Deploy mobile app
cd app && flutter build apk
./deploy.sh apk
```

## 🐛 Recent Fixes

### 1. 404 Error Fix (AlertCard Component)
```javascript
// BEFORE (broken):
const slug = getAlertSlug({
  id: alert.id,
  // ... other fields
}, locale, translations)
// Generated new ID each time, causing mismatches

// AFTER (fixed):
const slug = getAlertSlug({
  id: alert.id,
  short_url: alert.short_url, // Added this field
  // ... other fields  
}, locale, translations, alert.short_url) // Pass short_url as parameter
// Uses existing short_url, preventing 404s
```

### 2. Language Switcher URL Pattern Fix
```javascript
// BEFORE (broken):
href={lang.code === 'en' ? '/beep' : `/${lang.code}/beep`}
// Generated: /es/beep (incorrect)

// AFTER (fixed):  
href={`/beep/${lang.code}`}
// Generates: /beep/es (correct)
```

### 3. Translation Namespace Fix
```javascript
// BEFORE (inconsistent):
const { t } = useClientTranslations('beeps', locale)
// Looking for beeps.json

// AFTER (consistent):
const { t } = useClientTranslations('beep', locale)  
// Looking for beep.json
```

## 🔍 Troubleshooting

### Common Issues and Solutions

#### Translations Not Loading
```bash
# Check if beep.json exists (not beeps.json)
ls web/public/locales/es/beep.json

# If missing, regenerate
node scripts/generate-all-translations.js
```

#### 404 Errors on Beep Links
```bash
# Verify short_url is being passed
grep -r "getAlertSlug" web/src/components/

# Check SluggableAlertLike interface includes short_url
grep "SluggableAlertLike" web/src/utils/slug.ts
```

#### Language Switcher Wrong URLs
```bash
# Check SimpleLangLinks component
grep "buildLangUrl" web/src/components/SimpleLangLinks.tsx

# Verify it uses /beep/[locale] pattern
```

### Testing Translations
```bash
# Test Spanish translation loading
curl https://ufobeep.com/beep/es
# Should show "Beeps UFO Recientes" as title

# Test German  
curl https://ufobeep.com/beep/de
# Should show German translations

# Check translation file exists
curl https://ufobeep.com/locales/es/beep.json
```

## 📊 Current Status

### ✅ Completed (Sept 17, 2025)
- **Universal Translation System**: All 22 languages work consistently without English fallbacks
- **T+ Time Format**: Aerospace/military time notation (T+1h30m) implemented across all platforms
- **Reporter Display Fix**: "Reported by" field correctly shows in Details section using alert.username
- **I See It Too Logic**: Button properly hidden for user's own beeps using username comparison
- **Detail Page Layout**: Share link and reporter info integrated into Details section
- **Translation Key Coverage**: 28+ new keys added for weather, location, satellite, aircraft sections
- **AlertTitleUtils Fixed**: Now requires translation function, eliminates English fallbacks
- **Web Component Consistency**: Removed duplicate inline sections, uses only proper card components

### 🔄 In Progress
- **Documentation Updates**: Updating all docs to reflect new architecture
- **Testing**: Verifying all language pages load translations correctly

## 🚀 Future Enhancements

### Immediate Priorities
- [ ] Add translation caching to reduce API calls
- [ ] Implement translation fallback chain (requested → English → key)
- [ ] Add translation completeness monitoring
- [ ] Create translation update webhook for real-time updates

### Long-term Goals
- [ ] AI-powered context-aware translations
- [ ] User-submitted translation corrections
- [ ] Regional dialect support (Mexican Spanish vs Spain Spanish)
- [ ] Voice interface multi-language support

## 📝 Developer Notes

### Adding New Translation Keys
1. **Always add to English ARB first**: `app/lib/l10n/app_en.arb`
2. **Run generation script**: `node scripts/generate-all-translations.js`
3. **Test locally**: Check `/beep/es` shows new translations
4. **Deploy**: Use `./deploy.sh web` for web changes

### Critical Files to Remember
- `web/src/utils/slug.ts` - Contains slug generation logic
- `web/src/components/AlertCard.tsx` - Uses translations for UI
- `web/src/hooks/useClientTranslations.ts` - Loads translation files
- `scripts/generate-all-translations.js` - Master generation script
- `app/lib/l10n/app_en.arb` - Single source of truth

### Never Do This
- ❌ Don't create `beeps.json` files (use `beep.json`)
- ❌ Don't hardcode translations in components
- ❌ Don't use fallbacks that hide missing translations
- ❌ Don't edit non-English files directly (always generate)
- ❌ Don't use different slug generation methods in different places