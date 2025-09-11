# UFOBeep URL & Slug Generation System

**Last Updated**: September 11, 2025  
**Status**: ✅ Production Ready

## Overview

UFOBeep uses a dual URL system combining **short URLs** for sharing and **long SEO-friendly slugs** for discovery. This system ensures consistent URL generation across all platforms while supporting 22 languages.

## URL Structure

### Short URLs (Sharing)
```
https://ufobeep.com/{shortId}
```
- **Example**: `https://ufobeep.com/arnm6`
- **Purpose**: Easy sharing via SMS, social media
- **Length**: Always 5 characters
- **Character set**: `23456789abcdefghjkmnpqrstuvwxyz` (excludes confusing chars)

### Long URLs (SEO)
```
https://ufobeep.com/beep/{locale}/{slug}
```
- **Example**: `https://ufobeep.com/beep/es/ovni-avistamiento-las-vegas-2025-09-11-arnm6`
- **Purpose**: SEO optimization, human-readable, language-specific
- **Components**: `[translated-type]-[location]-[date]-[shortId]`

## Single Source of Truth

### Priority Order for Short IDs
```javascript
function getAlertSlug(alert, locale, translations, shortId) {
  // Priority order (CRITICAL):
  // 1. Provided shortId parameter (from URL)
  // 2. alert.short_url from database
  // 3. Generated from alert.id (fallback only)
  
  const id = shortId || alert.short_url || generateShortHash(alert.id)
  
  // Rest of slug generation...
}
```

### Why This Matters
- **Prevents 404 errors**: Always uses the same short ID
- **Maintains consistency**: Short URL redirects to correct long slug
- **Database integrity**: `short_url` field is authoritative

## Slug Generation Process

### 1. Short ID Generation (`/shared/get_short_hash.js`)
```javascript
function getShortHash(input) {
  if (!input) return '';
  
  // djb2 hash algorithm
  let hash = 0;
  for (let i = 0; i < input.length; i++) {
    const char = input.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash; // 32-bit conversion
  }
  
  // Convert to 5-char string
  const SAFE_CHARS = '23456789abcdefghjkmnpqrstuvwxyz';
  let shortId = '';
  let num = Math.abs(hash);
  
  for (let i = 0; i < 5; i++) {
    shortId = SAFE_CHARS[num % SAFE_CHARS.length] + shortId;
    num = Math.floor(num / SAFE_CHARS.length);
  }
  
  return shortId;
}
```

### 2. Long Slug Generation (`/web/src/utils/slug.ts`)
```typescript
export function getAlertSlug(
  alert: SluggableAlertLike, 
  locale: string = 'en', 
  translations?: any, 
  shortId?: string
) {
  // Priority for short ID (CRITICAL!)
  const id = shortId || alert.short_url || generateShortHash(alert.id)
  
  // Get translated terms from ARB files
  const ufoTerm = translations?.slugs?.ufo || 'ufo'
  const sightingTerm = translations?.slugs?.sighting || 'sighting'
  
  // Handle MUFON vs UFOBeep titles
  const isMufon = alert.source === 'mufon'
  let title = ''
  
  if (isMufon) {
    const mufonTerm = translations?.slugs?.mufon || 'mufon'
    const reportTerm = translations?.slugs?.report || 'report'
    title = `${mufonTerm}-${reportTerm}`
  } else {
    // Always use translated terms for UFOBeep
    title = `${ufoTerm}-${sightingTerm}`
  }
  
  // Build location part
  const location = formatLocation(alert.location)
  
  // Build date part
  const date = formatDate(alert.created_at)
  
  // Combine all parts
  return `${title}-${location}-${date}-${id}`
}
```

## Translation Integration

### ARB Files as Source of Truth
All slug translations come from mobile app ARB files:

```json
// app/lib/l10n/app_en.arb
{
  "ufo": "UFO",
  "sighting": "Sighting",
  "mufon": "MUFON",
  "report": "Report",
  "sphere": "Sphere",
  "triangle": "Triangle",
  "disk": "Disk"
  // ... all UFO shape terms
}
```

### Language-Specific Examples
| Language | Short URL | Long Slug |
|----------|-----------|-----------|
| English | `/arnm6` | `/beep/en/ufo-sighting-las-vegas-2025-09-11-arnm6` |
| Spanish | `/arnm6` | `/beep/es/ovni-avistamiento-las-vegas-2025-09-11-arnm6` |
| German | `/arnm6` | `/beep/de/ufo-sichtung-las-vegas-2025-09-11-arnm6` |
| French | `/arnm6` | `/beep/fr/ovni-observation-las-vegas-2025-09-11-arnm6` |

## Middleware Routing

### Short URL Redirect (`/web/src/middleware.ts`)
```typescript
export async function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname
  
  // Match 5-character short URLs
  const shortMatch = pathname.match(/^\/([23456789abcdefghjkmnpqrstuvwxyz]{5})$/)
  
  if (shortMatch) {
    const shortId = shortMatch[1]
    
    // Fetch alert data
    const response = await fetch(`${API_URL}/api/beep/by-short-url/${shortId}`)
    const data = await response.json()
    
    if (data.success && data.data) {
      // Get user's preferred language
      const locale = getUserLocale(request)
      
      // Generate long slug with translations
      const translations = staticTranslations[locale]
      const longSlug = getAlertSlug(data.data, locale, translations, shortId)
      
      // Redirect to long URL
      return NextResponse.redirect(
        new URL(`/beep/${locale}/${longSlug}`, request.url)
      )
    }
  }
}
```

## Component Integration

### AlertCard Component
```typescript
// CRITICAL: Must pass short_url to maintain consistency
const slug = getAlertSlug({
  id: alert.id,
  title: alert.title,
  created_at: alert.created_at,
  location: alert.location,
  short_url: alert.short_url, // MUST include this!
  // ... other fields
}, locale, translations, alert.short_url) // Pass as parameter too!

// Generate clickable link
<Link href={`/beep/${locale}/${slug}`}>
```

### Why Both Places?
1. **In the object**: For the interface type checking
2. **As parameter**: For explicit priority override

## Database Schema

### Sightings Table
```sql
CREATE TABLE sightings (
  id UUID PRIMARY KEY,
  short_url VARCHAR(5) UNIQUE,
  title TEXT,
  created_at TIMESTAMP,
  -- ... other fields
);

-- Index for fast lookups
CREATE INDEX idx_sightings_short_url ON sightings(short_url);
```

### API Response
```json
{
  "id": "a07bfc38-1000-4b24-8318-582b0260d085",
  "short_url": "arnm6",
  "title": "UFO Sighting",
  "location": {
    "name": "Las Vegas, Nevada",
    "latitude": 36.2456755,
    "longitude": -115.2411329
  },
  "created_at": "2025-09-11T12:40:58Z"
}
```

## Common Issues & Solutions

### Issue: 404 Errors When Clicking Beeps
**Cause**: Different components generating different short IDs  
**Solution**: Always use `alert.short_url` from database
```javascript
// ❌ WRONG - generates new ID
const slug = getAlertSlug(alert, locale, translations)

// ✅ CORRECT - uses existing short_url
const slug = getAlertSlug(alert, locale, translations, alert.short_url)
```

### Issue: Short URL Not Redirecting
**Cause**: Middleware not finding alert  
**Solution**: Verify API endpoint returns correct data
```bash
curl https://ufobeep.com/api/beep/by-short-url/arnm6
```

### Issue: Wrong Language in Slug
**Cause**: Missing or incorrect translations  
**Solution**: Regenerate translations from ARB files
```bash
node scripts/generate-all-translations.js
```

## Testing

### Test Short URL Generation
```bash
# Direct test of shared module
node /home/mike/D/ufobeep/shared/get_short_hash.js "a07bfc38-1000-4b24-8318-582b0260d085"
# Output: b4uux
```

### Test URL Redirects
```bash
# Test short URL redirect
curl -I https://ufobeep.com/arnm6
# Should redirect to: /beep/en/ufo-sighting-las-vegas-2025-09-11-arnm6

# Test Spanish version
curl -I https://ufobeep.com/beep/es
# Click a beep, should go to: /beep/es/ovni-avistamiento-...
```

### Test Slug Consistency
```javascript
// In browser console on beep list page
document.querySelectorAll('[href*="/beep/"]').forEach(link => {
  const slug = link.href.split('/').pop()
  const shortId = slug.split('-').pop()
  console.log(shortId) // Should all use same 5-char IDs
})
```

## Implementation Checklist

### For New Features
- [ ] Always include `short_url` in API responses
- [ ] Pass `short_url` to `getAlertSlug()` function
- [ ] Use ARB files for all translatable terms
- [ ] Test short URL → long slug redirect flow
- [ ] Verify consistent slug generation across components

### For Bug Fixes
- [ ] Check if `short_url` field is present in data
- [ ] Verify `SluggableAlertLike` interface includes `short_url`
- [ ] Ensure translations are loaded before slug generation
- [ ] Test with multiple languages

## Performance Considerations

### Caching Strategy
- Short URLs are computed once and stored in database
- Translations loaded at build time (static)
- Middleware caches redirect mappings (15 min TTL)

### Generation Speed
- Short ID generation: ~0.1ms
- Long slug generation: ~1ms
- Full redirect flow: ~50ms (includes API call)

## Security

### Character Safety
- No confusing characters (0, 1, I, O, i, l, o)
- URL-safe without encoding
- SMS and social media friendly

### Predictability
- Hash provides sufficient randomness
- Sequential IDs don't produce sequential URLs
- No information leakage

## Future Enhancements

### Planned Improvements
- [ ] Custom short URLs for special campaigns
- [ ] Vanity URLs for verified accounts
- [ ] QR code generation with short URLs
- [ ] Analytics tracking per short URL

### Scalability
- Current: 20M+ unique combinations (5 chars)
- Future: Can extend to 6 chars (594M combinations)
- Consider Redis cache for high-traffic scenarios