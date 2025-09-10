#!/usr/bin/env node

/**
 * Generate translation stubs for all supported languages
 * Usage: node scripts/generate-locale-stubs.js [specific-language]
 */

const fs = require('fs');
const path = require('path');

// Supported languages from your project
const SUPPORTED_LOCALES = [
  'ar', 'cs', 'da', 'de', 'el', 'es', 'fi', 'fr', 'he', 'hi', 
  'it', 'ja', 'ko', 'nl', 'no', 'pl', 'pt', 'ru', 'sv', 'tr', 'zh'
];

// Language-specific slug translations
const SLUG_TRANSLATIONS = {
  es: { ufo: 'ovni', sighting: 'avistamiento', report: 'reporte', mufon: 'mufon', unknown: 'desconocido' },
  de: { ufo: 'ufo', sighting: 'sichtung', report: 'bericht', mufon: 'mufon', unknown: 'unbekannt' },
  fr: { ufo: 'ovni', sighting: 'observation', report: 'rapport', mufon: 'mufon', unknown: 'inconnu' },
  pt: { ufo: 'ovni', sighting: 'avistamento', report: 'relatorio', mufon: 'mufon', unknown: 'desconhecido' },
  it: { ufo: 'ufo', sighting: 'avvistamento', report: 'rapporto', mufon: 'mufon', unknown: 'sconosciuto' },
  ru: { ufo: 'нло', sighting: 'наблюдение', report: 'отчет', mufon: 'mufon', unknown: 'неизвестный' },
  ja: { ufo: 'ufo', sighting: '目撃', report: '報告', mufon: 'mufon', unknown: '不明' },
  zh: { ufo: 'ufo', sighting: '目击', report: '报告', mufon: 'mufon', unknown: '未知' },
  ar: { ufo: 'يوفو', sighting: 'رؤية', report: 'تقرير', mufon: 'mufon', unknown: 'مجهول' },
  // Add more as needed - fallback to English if not specified
};

const BASE_DIR = path.join(__dirname, '../public/locales');
const EN_DIR = path.join(BASE_DIR, 'en');

function generateStubsForLanguage(locale) {
  console.log(`Generating stubs for: ${locale}`);
  
  const localeDir = path.join(BASE_DIR, locale);
  
  // Ensure locale directory exists
  if (!fs.existsSync(localeDir)) {
    fs.mkdirSync(localeDir, { recursive: true });
  }
  
  // Get all English files
  const enFiles = fs.readdirSync(EN_DIR).filter(f => f.endsWith('.json'));
  
  enFiles.forEach(filename => {
    const localePath = path.join(localeDir, filename);
    
    // Skip if file already exists and has content
    if (fs.existsSync(localePath)) {
      const existingContent = fs.readFileSync(localePath, 'utf8');
      if (existingContent.trim().length > 10) { // Has more than just "{}"
        console.log(`  - Skipping ${filename} (already exists with content)`);
        return;
      }
    }
    
    // Read English source
    const enContent = JSON.parse(fs.readFileSync(path.join(EN_DIR, filename), 'utf8'));
    
    // Create stub with English values and TODO comments
    let stub;
    
    if (filename === 'beeps.json' && SLUG_TRANSLATIONS[locale]) {
      // Special handling for beeps.json to include translated slugs
      stub = {
        ...createStubFromEnglish(enContent),
        slugs: SLUG_TRANSLATIONS[locale]
      };
    } else {
      stub = createStubFromEnglish(enContent);
    }
    
    // Write stub file
    fs.writeFileSync(localePath, JSON.stringify(stub, null, 2) + '\n');
    console.log(`  ✓ Created ${filename}`);
  });
}

function createStubFromEnglish(obj) {
  if (typeof obj === 'string') {
    return `TODO_${obj.toUpperCase().replace(/[^A-Z0-9]/g, '_').substring(0, 20)}`;
  }
  
  if (Array.isArray(obj)) {
    return obj.map(createStubFromEnglish);
  }
  
  if (obj && typeof obj === 'object') {
    const result = {};
    for (const [key, value] of Object.entries(obj)) {
      result[key] = createStubFromEnglish(value);
    }
    return result;
  }
  
  return obj;
}

// Main execution
const targetLocale = process.argv[2];

if (targetLocale) {
  if (!SUPPORTED_LOCALES.includes(targetLocale)) {
    console.error(`Unsupported locale: ${targetLocale}`);
    console.error(`Supported: ${SUPPORTED_LOCALES.join(', ')}`);
    process.exit(1);
  }
  generateStubsForLanguage(targetLocale);
} else {
  console.log('Generating stubs for all supported languages...\n');
  SUPPORTED_LOCALES.forEach(generateStubsForLanguage);
}

console.log('\n✅ Done! Remember to:');
console.log('1. Replace TODO_ placeholders with actual translations');
console.log('2. Test the URLs with new slug translations');
console.log('3. Add more specific slug terms to SLUG_TRANSLATIONS as needed');