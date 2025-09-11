# UFOBeep Shared Slug Generation System

**Last Updated**: September 11, 2025  
**Status**: ✅ Production Ready - Single Source of Truth Implementation

## 🎯 Overview

UFOBeep now uses a unified slug generation system that serves as the **single source of truth** for creating SEO-friendly URLs across all platforms. This system uses ARB files for translations and includes UFO shape data in multilingual slugs.

## 🏗️ Architecture

```
📂 Single Source Implementation
├── 🎯 Core Generator
│   └── shared/generate_slug.js (Single source of truth)
├── 📱 Mobile App
│   └── Uses API short_url field + web translations
├── 🌐 Web Frontend  
│   └── web/src/utils/slug.ts (Calls shared generator)
├── 🤖 MUFON Import
│   └── mufon.sh (Calls shared generator)
└── 🔮 Future NUFORC
    └── Will use same shared generator
```

## 🚀 Key Features

### ✅ Shape Translation Integration
- **Dynamic ARB Lookup**: No hardcoded mappings
- **Multilingual Shapes**: `sphere` → `esfera` (Spanish), `kugel` (German)
- **URL Safe**: Removes accents (`triángulo` → `triangulo`)

### ✅ Platform Consistency
- **Web Frontend**: Uses shared generator via TypeScript wrapper
- **MUFON Script**: Calls shared generator with classification data
- **Future NUFORC**: Will use same system for consistency

### ✅ Translation Priority
- **ARB Files**: Single source of truth from mobile app
- **Shape Keys**: Uses `shapeSphere`, `shapeTriangle`, etc.
- **22 Languages**: Supports all UFOBeep languages

## 📝 Usage Examples

### CLI Usage
```bash
# English MUFON sphere report
node shared/generate_slug.js '{"id":"test","location":"Las Vegas, NV","created_at":"2025-09-11T12:40:58Z","source":"mufon","short_url":"arnm6","shape":"sphere"}' en
# Output: mufon-sphere-report-las-vegas-2025-09-11-arnm6

# Spanish MUFON sphere report  
node shared/generate_slug.js '{"id":"test","location":"Las Vegas, NV","created_at":"2025-09-11T12:40:58Z","source":"mufon","short_url":"arnm6","shape":"sphere"}' es
# Output: mufon-esfera-informe-las-vegas-2025-09-11-arnm6

# UFOBeep triangle sighting
node shared/generate_slug.js '{"id":"test","location":"Phoenix, AZ","created_at":"2025-09-11T12:40:58Z","source":"ufobeep","short_url":"b4uux","shape":"triangle"}' en  
# Output: triangle-ufo-sighting-phoenix-2025-09-11-b4uux
```

### MUFON Integration
```bash
# mufon.sh automatically calls shared generator
./mufon.sh 2025-09-11

# Internally generates slugs like:
# English: mufon-sphere-report-las-vegas-2025-09-11-arnm6
# Spanish: mufon-esfera-informe-las-vegas-2025-09-11-arnm6
# German: mufon-kugel-bericht-las-vegas-2025-09-11-arnm6
```

### Web Frontend
```typescript
// AlertCard.tsx now uses shared generator
const slug = getAlertSlug({
  id: alert.id,
  short_url: alert.short_url, // CRITICAL: Uses existing short_url
  shape: alert.shape,         // NEW: Shape data included
  // ... other fields
}, locale, translations, alert.short_url)

// Generates: /beep/es/mufon-esfera-informe-las-vegas-2025-09-11-arnm6
```

## 🔧 Implementation Details

### Shared Generator (`shared/generate_slug.js`)

```javascript
/**
 * SINGLE SOURCE OF TRUTH for slug generation
 * Used by web frontend, mufon.sh, and future NUFORC scripts
 */

// Dynamic ARB shape lookup (no hardcoding!)
const getShapeTranslation = (shape) => {
  const shapeInput = shape.toLowerCase();
  
  // Look through all translation keys to find shape matches
  for (const key in translations) {
    if (key.startsWith('shape')) {
      const arbShapeName = key.replace('shape', '').toLowerCase();
      if (arbShapeName === shapeInput) {
        return makeUrlSafe(translations[key]);
      }
    }
  }
  return shape; // fallback
};

// Priority order for short IDs
const id = shortId || alert.short_url || getShortHash(alert.id);

// Shape-aware title generation
if (isMufon && alert.shape) {
  title = `${mufonTerm}-${shapeTranslation}-${reportTerm}`;
} else if (alert.shape) {
  title = `${shapeTranslation}-${ufoTerm}-${sightingTerm}`;
}
```

### MUFON Integration (`mufon.sh`)

```python
# Classify UFO type
classification = classifier.classify(long_description, short_description)

# Prepare slug data with shape
alert_data_for_slug = {
    "id": alert_id,
    "source": "mufon",
    "shape": classification['type'] if classification['confidence'] >= 0.3 else None,
    # ... other fields
}

# Generate slug using shared generator
result = subprocess.run([
    "node", "/home/mike/D/ufobeep/shared/generate_slug.js", 
    json.dumps(alert_data_for_slug), "en"
], capture_output=True, text=True, timeout=10)

english_slug = result.stdout.strip()
# Store in enrichment_data["seo_slug_en"]
```

### Web Frontend Integration (`web/src/utils/slug.ts`)

```typescript
export function getAlertSlug(alert: SluggableAlertLike, locale: string = 'en', translations?: any, shortId?: string) {
  // Use the shared slug generator for consistency
  const { generateAlertSlug } = require('../../../shared/generate_slug.js')
  
  const alertData = {
    id: alert.id,
    created_at: alert.created_at,
    location: alert.location,
    source: alert.source || (alert.reporter_username === 'MUFON' ? 'mufon' : 'ufobeep'),
    short_url: (alert as any).short_url,
    shape: (alert as any).shape // NEW: Shape data included
  }
  
  return generateAlertSlug(alertData, locale, shortId)
}
```

## 🧪 Testing

### Shape Translation Tests
```bash
# Test all major shapes work
for shape in sphere triangle disc light cigar; do
  echo "Testing $shape:"
  node shared/generate_slug.js "{\"shape\":\"$shape\",\"source\":\"mufon\",\"location\":\"Test\",\"created_at\":\"2025-09-11T12:00:00Z\",\"short_url\":\"test1\"}" es
done

# Expected outputs:
# sphere: mufon-esfera-informe-test-2025-09-11-test1
# triangle: mufon-triangulo-informe-test-2025-09-11-test1  
# disc: mufon-disco-informe-test-2025-09-11-test1
# light: mufon-luz-informe-test-2025-09-11-test1
# cigar: mufon-cigarro-informe-test-2025-09-11-test1
```

### MUFON Integration Test
```bash
# Test with real MUFON data (requires credentials)
./mufon.sh yesterday

# Should log lines like:
# 🔗 Generated English slug: mufon-sphere-report-las-vegas-2025-09-11-arnm6
# 📤 ALERT DETAILS:
#    SEO Slug: mufon-sphere-report-las-vegas-2025-09-11-arnm6
```

### Web Frontend Test
1. Visit `/beep/es` (Spanish beep list)
2. Click any MUFON beep with shape data
3. URL should show: `/beep/es/mufon-[shape]-informe-[location]-[date]-[id]`
4. Verify shape is translated (sphere → esfera, triangle → triángulo)

## 🌍 Multilingual Support

### ARB Shape Keys
The system uses these ARB keys for shape translations:

| Classifier Output | ARB Key | English | Spanish | German |
|------------------|---------|---------|---------|--------|
| `sphere` | `shapeSphere` | sphere | esfera | kugel |
| `triangle` | `shapeTriangle` | triangle | triángulo | dreieck |
| `disc` | `shapeDisc` | disc | disco | scheibe |
| `light` | `shapeLight` | light | luz | licht |
| `cigar` | `shapeCigar` | cigar | cigarro | zigarre |

### URL Examples by Language

| Language | Example Slug |
|----------|--------------|
| English | `mufon-sphere-report-las-vegas-2025-09-11-arnm6` |
| Spanish | `mufon-esfera-informe-las-vegas-2025-09-11-arnm6` |
| German | `mufon-kugel-bericht-las-vegas-2025-09-11-arnm6` |
| French | `mufon-sphere-rapport-las-vegas-2025-09-11-arnm6` |
| Russian | `mufon-сфера-отчет-las-vegas-2025-09-11-arnm6` |

## 🔧 Troubleshooting

### Issue: Shape Not Translated
**Cause**: ARB file missing shape key or incorrect mapping  
**Solution**: Check ARB file has `shape[ShapeName]` key
```bash
# Check if shape exists in ARB
grep "shapeSphere" app/lib/l10n/app_es.arb
# Should show: "shapeSphere": "esfera"
```

### Issue: Slug Generation Fails
**Cause**: Invalid JSON or missing required fields  
**Solution**: Verify JSON format and required fields
```bash
# Test with minimal valid data
node shared/generate_slug.js '{"id":"test","created_at":"2025-09-11T12:00:00Z","location":"Test","source":"ufobeep"}' en
```

### Issue: MUFON Slugs Wrong Format
**Cause**: mufon.sh not calling shared generator correctly  
**Solution**: Check mufon.sh logs for slug generation errors
```bash
grep "Generated English slug" mufon_log.txt
```

## 📊 Current Status

### ✅ Completed Features
- **Shared Generator**: Single source of truth implementation
- **Shape Translation**: Dynamic ARB-based shape translation
- **MUFON Integration**: Full integration with classification data
- **Web Frontend**: Updated to use shared generator
- **22 Languages**: All languages supported with proper translations
- **URL Safety**: Accent removal and special character handling

### 🔄 In Progress
- **Edge Runtime**: Resolving Node.js API warnings in Next.js Edge Runtime
- **Testing**: Comprehensive end-to-end testing across all platforms

### 🔮 Future Enhancements
- **NUFORC Integration**: Will use same shared generator
- **Custom Shapes**: Easy addition of new UFO shapes via ARB files
- **Caching**: Slug generation caching for improved performance
- **Analytics**: Track slug generation performance and usage

## 🚀 Deployment

### Production Checklist
- [x] **Shared generator deployed**: `/home/mike/D/ufobeep/shared/generate_slug.js`
- [x] **ARB files updated**: All 22 languages with shape translations
- [x] **Web frontend updated**: Uses shared generator
- [x] **MUFON script updated**: Calls shared generator with classification
- [x] **Edge Runtime compatible**: Web builds successfully (with warnings)

### Monitoring
- **Slug Generation**: Check mufon.sh logs for successful slug generation
- **Web Performance**: Monitor slug generation performance in web frontend
- **Translation Coverage**: Verify all shapes have translations in all languages

## 💡 Developer Notes

### Adding New Shapes
1. **Add to mufon.sh classifier**: Add pattern to `classification_patterns`
2. **Add to ARB files**: Add `shape[NewShape]` key to `app_en.arb`
3. **Generate translations**: Run `node scripts/generate-all-translations.js`
4. **Test**: Verify new shape generates correct slugs

### Important Patterns
- **Always use existing short_url**: Prevents 404 errors from ID mismatches
- **Include shape data**: Enhances SEO with descriptive URLs
- **Use ARB as source**: Never hardcode translations
- **Test multiple languages**: Verify translations work correctly

This shared slug generation system now provides consistent, multilingual, shape-aware SEO URLs across all UFOBeep platforms!