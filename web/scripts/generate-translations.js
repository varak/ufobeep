#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

/**
 * Generate static translations for middleware use from ARB files
 * This runs at build time to avoid Edge Runtime file system limitations
 */

const ARB_PATH = path.join(__dirname, '../../app/lib/l10n');
const OUTPUT_PATH = path.join(__dirname, '../src/translations/static-translations.json');

// Languages to process (all supported locales)
const LOCALES = [
  'en', 'es', 'de', 'fr', 'pt', 'ru', 'ja', 'zh', 'it', 'ar', 
  'ko', 'tr', 'hi', 'pl', 'cs', 'nl', 'sv', 'da', 'no', 'fi', 'el', 'he'
];

// Keys we need for slug generation
const SLUG_KEYS = [
  'ufoSighting',
  'ufo',
  'sighting',
  'unknown',
  'report', 
  'mufon',
  'beepOnly',
  'reportOnly',
  // All UFO shape terms from MUFON
  'shapeTriangle',
  'shapeDisc', 
  'shapeDisk',
  'shapeSphere',
  'shapeCigar',
  'shapeLight',
  'shapeBoomerang',
  'shapeDiamond',
  'shapeRectangle',
  'shapeOval',
  'shapeCone',
  'shapeCross',
  'shapeCylinder',
  'shapeDumbbell',
  'shapeTeardrop',
  'shapeTicTac',
  'shapeBullet',
  'shapeSaturn',
  'shapeStarlike',
  'shapeBlimp',
  'shapeFireball',
  'shapeFormation',
  'shapeUnknown'
];

function loadArbFile(locale) {
  const arbPath = path.join(ARB_PATH, `app_${locale}.arb`);
  
  try {
    if (fs.existsSync(arbPath)) {
      const content = fs.readFileSync(arbPath, 'utf-8');
      return JSON.parse(content);
    } else {
      console.warn(`ARB file not found: ${arbPath}`);
      return {};
    }
  } catch (error) {
    console.error(`Error loading ARB file for ${locale}:`, error);
    return {};
  }
}

function generateStaticTranslations() {
  const translations = {};
  
  for (const locale of LOCALES) {
    const arbData = loadArbFile(locale);
    const slugTranslations = {};
    
    // Extract only the keys we need for slugs - NO FALLBACKS
    for (const key of SLUG_KEYS) {
      if (arbData[key]) {
        slugTranslations[key] = arbData[key];
      }
      // Skip missing keys - no fallbacks allowed
    }
    
    translations[locale] = slugTranslations;
    console.log(`✓ Generated slug translations for ${locale}: ${Object.keys(slugTranslations).length} terms`);
  }
  
  // Ensure output directory exists
  const outputDir = path.dirname(OUTPUT_PATH);
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }
  
  // Write static translations file
  fs.writeFileSync(OUTPUT_PATH, JSON.stringify(translations, null, 2));
  console.log(`✅ Static translations generated: ${OUTPUT_PATH}`);
  
  return translations;
}

// Run if called directly
if (require.main === module) {
  generateStaticTranslations();
}

module.exports = { generateStaticTranslations };