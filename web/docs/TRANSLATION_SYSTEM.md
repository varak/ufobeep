# UFOBeep Web Translation System

This document explains the 22-language translation system for the UFOBeep website.

## Overview

The UFOBeep website now supports all 22 languages that the mobile app supports, using a smart substitution system that syncs translations from the mobile app's `.arb` files.

## Supported Languages

All 22 languages from the mobile app:
- **ar** - Arabic (العربية)
- **cs** - Czech (Čeština) 
- **da** - Danish (Dansk)
- **de** - German (Deutsch)
- **el** - Greek (Ελληνικά)
- **en** - English (Default)
- **es** - Spanish (Español)
- **fi** - Finnish (Suomi)
- **fr** - French (Français)
- **he** - Hebrew (עברית)
- **hi** - Hindi (हिन्दी)
- **it** - Italian (Italiano)
- **ja** - Japanese (日本語)
- **ko** - Korean (한국어)
- **nl** - Dutch (Nederlands)
- **no** - Norwegian (Norsk)
- **pl** - Polish (Polski)
- **pt** - Portuguese (Português)
- **ru** - Russian (Русский)
- **sv** - Swedish (Svenska)
- **tr** - Turkish (Türkçe)
- **zh** - Chinese (中文)

## Translation System Architecture

### Single Codebase Approach
- **One website**: Single Next.js application serving all languages
- **Dynamic routing**: Same URLs work for all languages (e.g., `/alerts`)
- **Component-level translations**: Each component uses `useTranslation()` hook
- **Smart fallback**: Falls back to English if translation is missing

### File Structure
```
web/
├── public/locales/        # Translation files
│   ├── en/               # English (default)
│   │   ├── common.json   # Common UI elements
│   │   ├── alerts.json   # Alert-specific terms
│   │   └── navigation.json
│   ├── es/               # Spanish
│   │   ├── common.json
│   │   ├── alerts.json
│   │   └── navigation.json
│   └── [22 more languages...]
├── scripts/
│   └── sync-translations.js  # Auto-sync from mobile app
└── next-i18next.config.js   # i18n configuration
```

## Syncing Translations

### Automatic Sync from Mobile App
The translation sync script pulls translations from the mobile app's `.arb` files and converts them to web JSON format:

```bash
# Run translation sync
cd web/
npm run sync-translations

# Manual sync
node scripts/sync-translations.js
```

### What the Sync Does
1. Reads all 22 `.arb` files from `/app/lib/l10n/`
2. Maps mobile translation keys to web namespaces
3. Adds web-specific translations (like "witness report only")
4. Creates/updates JSON files in `/public/locales/`
5. Maintains translation consistency across platforms

## Using Translations in Components

### Basic Usage
```tsx
import { useTranslation } from 'next-i18next';

function AlertCard({ alert }) {
  const { t } = useTranslation('alerts');
  
  return (
    <div>
      <h3>{alert.title}</h3>
      {alert.reporter_username === 'MUFON' && (
        <span>({t('witnessReportOnly')})</span>
      )}
    </div>
  );
}
```

### Multiple Namespaces
```tsx
function MyComponent() {
  const { t } = useTranslation('common');
  const { t: tAlerts } = useTranslation('alerts');
  
  return (
    <div>
      <button>{t('save')}</button>
      <span>{tAlerts('witnesses')}</span>
    </div>
  );
}
```

### Page Setup
```tsx
// pages/alerts.tsx
import { getI18nProps } from '@/lib/i18n-config';

export async function getServerSideProps(context) {
  return {
    props: {
      ...(await getI18nProps(context, ['alerts'])),
    },
  };
}
```

## Translation Namespaces

### common.json
Basic UI elements used throughout the site:
- `ok`, `cancel`, `save`, `delete`
- `loading`, `error`, `tryAgain`
- `yes`, `no`, `back`, `next`

### alerts.json
Alert/sighting-specific terminology:
- `witnessReportOnly`, `reportOnly`, `beepOnly`
- `witnesses`, `witness`, `comments`, `comment`
- `imageOnly`, `videoOnly`

### navigation.json
Navigation and menu items:
- `home`, `alerts`, `map`, `profile`, `settings`

### meta.json
SEO and social sharing content:
- `appTagline`, `metaDescription`
- `ogTitle`, `ogDescription`

## Language Detection & Switching

### Automatic Detection
Next.js automatically detects user language from:
1. URL path (`/es/alerts`)
2. Accept-Language header
3. Stored cookie preference

### Manual Language Switching
Users can switch languages via:
- Language selector component
- URL modification (`/alerts` → `/es/alerts`)
- API preference setting

## Maintenance

### Adding New Translations
1. Add translation to mobile app `.arb` files
2. Run `npm run sync-translations`
3. Translations automatically appear on web

### Web-Specific Translations
For web-only content, modify the `WEB_SPECIFIC_TRANSLATIONS` object in `scripts/sync-translations.js`:

```javascript
WEB_SPECIFIC_TRANSLATIONS: {
  alerts: {
    en: {
      'witnessReportOnly': 'witness report only',
      // ... more keys
    },
    es: {
      'witnessReportOnly': 'solo reporte de testigo',
      // ... more keys  
    }
  }
}
```

## Performance

### Optimizations
- **Tree-shaking**: Only loads translations for current page
- **Static generation**: Pre-builds pages for all languages
- **Namespace splitting**: Loads only needed translation files
- **Fallback caching**: Caches fallback translations

### File Sizes
- Each namespace: ~1-3KB per language
- Total translations: ~200KB for all 22 languages
- Lazy loading: Only loads active language + fallback

## Quality Assurance

### Translation Quality
- Mobile app translations reviewed by native speakers
- Web inherits same quality through sync system
- Consistent terminology across mobile and web

### Testing
```bash
# Test translation loading
npm run dev
# Visit: http://localhost:3000/es/alerts

# Verify all languages work
for lang in es de fr ru ja zh; do
  curl -H "Accept-Language: $lang" http://localhost:3000/alerts
done
```

## Future Enhancements

### Planned Features
1. **Real-time translation API** using LibreTranslate
2. **Dynamic content translation** for NUFORC/MUFON reports  
3. **Regional variations** (e.g., es-ES vs es-MX)
4. **RTL language support** for Arabic and Hebrew
5. **Voice-over translations** for accessibility

### Integration with LibreTranslate
When LibreTranslate is deployed:
- Translate MUFON/NUFORC reports on-demand
- Auto-detect source language
- Cache popular translations
- Provide "Translate" buttons in UI

## Troubleshooting

### Common Issues
1. **Missing translations**: Check fallback to English working
2. **Wrong language loading**: Verify URL structure and headers
3. **Translation not updating**: Re-run sync script
4. **Mobile/web inconsistency**: Sync translations again

### Debug Commands
```bash
# Check translation files exist
ls -la public/locales/*/alerts.json

# Verify translations loaded
curl http://localhost:3000/api/debug/translations

# Test specific language
curl -H "Accept-Language: es" http://localhost:3000/alerts
```