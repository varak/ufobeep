# URL Architecture & Routing System

**Last Updated**: September 10, 2025  
**Implementation Status**: ✅ Production Ready

## Overview

UFOBeep implements a sophisticated URL architecture that supports:
- **Smart Short URLs** with automatic language detection
- **Multilingual routing** with 20+ supported languages  
- **SEO-friendly canonical URLs** with descriptive slugs
- **Backward compatibility** with existing API endpoints

## URL Structure

### 1. Short URLs (New)

**Format**: `/{short_id}` or `/{short_id}/{lang}`

**Examples**:
```
https://ufobeep.com/ehf3           # Auto-detects user language
https://ufobeep.com/ehf3/es        # Explicit Spanish
https://ufobeep.com/ehf3/fr        # Explicit French
```

**Behavior**:
- Short ID is 4-character alphanumeric generated from alert ID
- Automatic language detection from browser `Accept-Language` header
- Redirects to canonical localized URL: `/beep/{locale}/{descriptive-slug-shortid}`

### 2. Canonical URLs

**Format**: `/beep/{locale}/{descriptive-slug-shortid}`

**Examples**:
```
https://ufobeep.com/beep/es/enhanced-sighting-description-ehf3
https://ufobeep.com/beep/fr/observation-mystérieuse-ehf3
https://ufobeep.com/beep/en/triangle-formation-over-phoenix-ehf3
```

**Features**:
- SEO-friendly descriptive slugs
- Language-specific content
- Canonical URL for sharing and indexing
- Contains short ID at the end for technical routing

### 3. API Endpoints

**Backend API**:
```
/api/beep          # Primary endpoint family
/api/alerts        # Legacy compatibility endpoint family
```

**Frontend Web API**:
```
/api/beep          # Proxied to backend /beep endpoints
```

## Language Support

### Supported Languages (22 total)
```
es, de, fr, pt, ru, ja, zh, it, ar, ko, tr, hi, pl, cs, nl, sv, da, no, fi, el, he
```

### Language Detection Priority
1. **Explicit URL language**: `/ehf3/es` → Spanish
2. **Browser Accept-Language header**: Auto-detection from browser preferences  
3. **Default fallback**: English (`en`)

### Browser Language Detection Algorithm
```typescript
const acceptLanguage = request.headers.get('accept-language') || ''
const browserLanguages = acceptLanguage
  .split(',')
  .map(lang => lang.split(';')[0].split('-')[0].trim().toLowerCase())
  .filter(lang => lang.length === 2)

for (const browserLang of browserLanguages) {
  if (supportedLocales.includes(browserLang)) {
    return browserLang // First supported language wins
  }
}
return 'en' // Default fallback
```

## Middleware Implementation

### Next.js Middleware (`/web/src/middleware.ts`)

**Responsibilities**:
1. **Short URL Detection**: Matches `/{shortId}` and `/{shortId}/{lang}` patterns
2. **Language Processing**: Auto-detection or explicit language handling
3. **URL Rewriting**: Redirects to canonical URLs
4. **Performance**: Minimal processing overhead

**Pattern Matching**:
```typescript
const shortMatch = pathname.match(/^\/([a-z0-9]{4})$/)
const shortWithLangMatch = pathname.match(/^\/([a-z0-9]{4})\/([a-z]{2})$/)
```

**Matcher Configuration**:
```typescript
export const config = {
  matcher: [
    '/((?!api|_next/static|_next/image|favicon.ico|beep).*)',
  ]
}
```

## Technical Implementation

### Short ID Generation - Single Source of Truth

**⚠️ CRITICAL**: All platforms now use the shared canonical implementation at `shared/get_short_hash.js`

**Algorithm**: Generate 4-character alphanumeric ID from alert ID using safe characters
```javascript
// CANONICAL IMPLEMENTATION: shared/get_short_hash.js
function getShortHash(input) {
  if (!input) return '';
  
  // Generate hash using working web algorithm
  let hash = 0;
  for (let i = 0; i < input.length; i++) {
    const char = input.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash; // CRITICAL: Working web version algorithm
  }
  
  // Convert to base-29 using safe characters (no O,I,L,0,1,o,l,i)
  const SAFE_CHARS = '23456789abcdefghjkmnpqrstuvwxyz';
  let shortId = '';
  let num = Math.abs(hash);
  
  for (let i = 0; i < 4; i++) {
    shortId = SAFE_CHARS[num % SAFE_CHARS.length] + shortId;
    num = Math.floor(num / SAFE_CHARS.length);
  }
  
  return shortId;
}
```

**Platform Integration**:
- **Web**: `const { getShortHash } = require('../../../shared/get_short_hash.js')`
- **Mobile App**: Dart implementation matches shared algorithm exactly
- **mufon.sh**: `SHORT_ID=$(node shared/get_short_hash.js "$SIGHTING_ID")`
- **API**: Can call shared module for consistency
- **CLI**: `node shared/get_short_hash.js "UFO-2024-12345"` → `js4m`

### Slug Generation

**Algorithm**: Create SEO-friendly descriptive slug
```typescript
function getAlertSlug(alert: Alert, locale: string, t: any): string {
  // 1. Generate descriptive text from alert title/description
  // 2. Translate to target language using i18n
  // 3. Sanitize for URL (lowercase, hyphens, alphanumeric)
  // 4. Append short ID: `{description}-{shortId}`
}
```

### Frontend Routing

**Dynamic Route**: `/beep/[locale]/[...slug]/page.tsx`

**Slug Parsing Logic**:
```typescript
// Extract short ID from slug
let shortId
if (fullSlug.includes('-')) {
  const slugParts = fullSlug.split('-')
  shortId = slugParts[slugParts.length - 1] // Last part after last dash
} else {
  shortId = fullSlug // Direct short ID access
}
```

### Alert Lookup Process

1. **Extract short ID** from URL slug
2. **Search alerts** by generating short IDs until match found
3. **Canonical redirect** if current slug doesn't match expected slug
4. **Render alert detail** page with localized content

## API Compatibility

### Dual Endpoint System

**Primary (Beep)**:
```
GET  /beep              # List sightings
POST /beep              # Create sighting
GET  /beep/{id}         # Get sighting details
POST /beep/{id}/media   # Attach media
```

**Legacy (Alerts)**:
```
GET  /alerts            # List alerts (identical to /beep)
POST /alerts            # Create alert
GET  /alerts/{id}       # Get alert details
POST /alerts/{id}/media # Attach media
```

### Response Transformation

**Web Frontend**: Transforms `data.alerts` → `data.beeps` for consistency
**Mobile App**: Uses native `data.alerts` response format

## SEO & Performance

### SEO Benefits
- **Descriptive URLs**: Human-readable, keyword-rich URLs
- **Language-specific content**: Proper hreflang support
- **Canonical URLs**: Prevents duplicate content issues
- **Short URLs**: Easy sharing and social media integration

### Performance Optimizations
- **Middleware-level processing**: Fast pattern matching
- **Client-side caching**: Aggressive caching of alert data
- **Lazy loading**: Progressive content loading
- **CDN-friendly**: Static asset optimization

## Migration & Compatibility

### Backward Compatibility
- **API endpoints**: Both `/beep` and `/alerts` supported indefinitely
- **Old URLs**: Existing patterns continue to work
- **Mobile app**: No changes required to Flutter app

### Migration Strategy
1. **Phase 1**: Dual endpoint support (✅ Complete)
2. **Phase 2**: Short URL rollout (✅ Complete)  
3. **Phase 3**: SEO optimization (✅ Complete)
4. **Phase 4**: Single source of truth refactoring (✅ Complete - September 10, 2025)
5. **Phase 5**: Analytics and monitoring (🔄 In Progress)

## Monitoring & Analytics

### Key Metrics
- Short URL usage rates
- Language detection accuracy
- Canonical redirect performance
- User engagement by language

### Error Handling
- **404 handling**: Graceful fallback for invalid short IDs
- **Middleware errors**: Passthrough to normal Next.js routing
- **Language fallbacks**: Default to English for unsupported languages
- **Alert lookup failures**: Clear error messages and suggestions

## Configuration

### Environment Variables
```bash
NEXT_PUBLIC_API_URL=https://ufobeep.com/api
```

### Single Source of Truth Module
**Location**: `shared/get_short_hash.js`
**Purpose**: Canonical short URL hash generation across all platforms
**Usage**: CLI-compatible, require()-able, documented

**Critical Rules**:
- ⚠️ **NEVER modify the algorithm** - changes break URL consistency
- Use `hash & hash` (working web version), NOT `hash & 0xFFFFFFFF`
- Maintains same safe character set: `'23456789abcdefghjkmnpqrstuvwxyz'`
- All platforms must call this implementation for consistency

### Runtime Configuration
- Supported languages list in middleware
- Short ID generation parameters
- Canonical URL format templates

## Testing

### Test Cases
```bash
# Short URL redirection
curl -I https://ufobeep.com/ehf3
# Expected: 302 redirect to /beep/{locale}/description-ehf3

# Language-specific short URL
curl -I https://ufobeep.com/ehf3/es
# Expected: 302 redirect to /beep/es/descripción-ehf3

# Language detection
curl -H "Accept-Language: fr-FR,fr;q=0.9" -I https://ufobeep.com/ehf3
# Expected: 302 redirect to /beep/fr/observation-ehf3

# Invalid short ID
curl -I https://ufobeep.com/xxxx
# Expected: 404 or pass-through to normal routing
```

### Performance Testing
- **Middleware overhead**: < 5ms per request
- **Language detection**: < 1ms processing time
- **Alert lookup**: < 100ms average response time
- **Cache hit rates**: > 90% for repeat short URL access

## Future Enhancements

### Planned Features
- **Custom short URLs**: User-defined vanity URLs
- **QR code generation**: Automatic QR codes for short URLs
- **Analytics dashboard**: Usage tracking and insights
- **A/B testing**: URL format optimization
- **RSS feeds**: Language-specific content feeds

### Technical Debt
- **Alert lookup optimization**: Direct database lookup instead of API iteration
- **Caching layer**: Redis caching for short ID → alert ID mapping
- **Rate limiting**: Protect against short URL enumeration
- **Monitoring**: Comprehensive error tracking and performance monitoring