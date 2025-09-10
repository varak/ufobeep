#!/usr/bin/env node

/**
 * Auto-translate all locale files from English using LibreTranslate
 * Usage: node scripts/auto-translate-locales.js [specific-language]
 */

const fs = require('fs');
const path = require('path');

// LibreTranslate configuration
const LIBRETRANSLATE_URL = process.env.LIBRETRANSLATE_URL || 'http://localhost:5000';
const LIBRETRANSLATE_API_KEY = process.env.LIBRETRANSLATE_API_KEY || '';

// Language mapping: locale code -> LibreTranslate language code
const LANGUAGE_MAPPING = {
  'es': 'es',   // Spanish
  'de': 'de',   // German  
  'fr': 'fr',   // French
  'pt': 'pt',   // Portuguese
  'it': 'it',   // Italian
  'ru': 'ru',   // Russian
  'ja': 'ja',   // Japanese
  'zh': 'zh',   // Chinese
  'ar': 'ar',   // Arabic
  'nl': 'nl',   // Dutch
  'pl': 'pl',   // Polish
  'cs': 'cs',   // Czech
  'tr': 'tr',   // Turkish
  'ko': 'ko',   // Korean
  'hi': 'hi',   // Hindi
  'sv': 'sv',   // Swedish
  'da': 'da',   // Danish
  'no': 'no',   // Norwegian
  'fi': 'fi',   // Finnish
  'el': 'el',   // Greek
  'he': 'he',   // Hebrew
};

// English slug terms that need language-specific translations for URLs
const ENGLISH_SLUG_TERMS = {
  // Basic terms
  ufo: 'UFO',
  sighting: 'sighting', 
  report: 'report',
  mufon: 'MUFON',
  nuforc: 'NUFORC',
  unknown: 'unknown',
  // Classifications
  sphere: 'sphere',
  light: 'light',
  disk: 'disk', 
  triangle: 'triangle',
  cigar: 'cigar',
  oval: 'oval',
  cylinder: 'cylinder',
  rectangle: 'rectangle',
  diamond: 'diamond',
  fireball: 'fireball',
  flash: 'flash',
  formation: 'formation',
  changing: 'changing',
  chevron: 'chevron',
  cone: 'cone',
  cross: 'cross',
  egg: 'egg',
  object: 'object'
};

const BASE_DIR = path.join(__dirname, '../public/locales');
const EN_DIR = path.join(BASE_DIR, 'en');

async function translateText(text, targetLang) {
  try {
    const response = await fetch(`${LIBRETRANSLATE_URL}/translate`, {
      method: 'POST',
      body: JSON.stringify({
        q: text,
        source: 'en',
        target: targetLang,
        format: 'text',
        api_key: LIBRETRANSLATE_API_KEY
      }),
      headers: {
        'Content-Type': 'application/json'
      }
    });

    const data = await response.json();
    if (data.translatedText) {
      return data.translatedText;
    } else {
      console.warn(`⚠️  Translation failed for "${text}" to ${targetLang}:`, data);
      return text; // Fallback to original
    }
  } catch (error) {
    console.error(`❌ Error translating "${text}" to ${targetLang}:`, error.message);
    return text; // Fallback to original
  }
}

async function translateSlugTerms(targetLang) {
  const translatedSlugs = {};
  
  console.log(`  📝 Translating ${Object.keys(ENGLISH_SLUG_TERMS).length} slug terms...`);
  
  for (const [key, englishTerm] of Object.entries(ENGLISH_SLUG_TERMS)) {
    // Don't translate proper nouns
    if (['mufon', 'nuforc'].includes(key)) {
      translatedSlugs[key] = englishTerm.toLowerCase();
    } else {
      const translated = await translateText(englishTerm, targetLang);
      // Clean for URL slug usage (lowercase, no spaces, basic chars only)
      translatedSlugs[key] = translated
        .toLowerCase()
        .replace(/\s+/g, '-')
        .replace(/[^a-z0-9\-]/g, '')
        .replace(/--+/g, '-')
        .replace(/^-|-$/g, '');
    }
    
    // Small delay to avoid rate limiting
    await new Promise(resolve => setTimeout(resolve, 100));
  }
  
  return translatedSlugs;
}

async function translateObject(obj, targetLang, keyPath = '') {
  if (typeof obj === 'string') {
    // Skip placeholder strings and very short strings
    if (obj.startsWith('TODO_') || obj.length < 2) {
      return obj;
    }
    
    return await translateText(obj, targetLang);
  }
  
  if (Array.isArray(obj)) {
    const translated = [];
    for (const item of obj) {
      translated.push(await translateObject(item, targetLang, keyPath));
      await new Promise(resolve => setTimeout(resolve, 50)); // Rate limiting
    }
    return translated;
  }
  
  if (obj && typeof obj === 'object') {
    const translated = {};
    for (const [key, value] of Object.entries(obj)) {
      const newKeyPath = keyPath ? `${keyPath}.${key}` : key;
      
      // Special handling for slugs - use our optimized slug translations
      if (newKeyPath === 'slugs' && targetLang in LANGUAGE_MAPPING) {
        console.log(`  🔗 Using optimized slug translations for ${targetLang}`);
        translated[key] = await translateSlugTerms(LANGUAGE_MAPPING[targetLang]);
      } else {
        translated[key] = await translateObject(value, LANGUAGE_MAPPING[targetLang], newKeyPath);
      }
      
      await new Promise(resolve => setTimeout(resolve, 50)); // Rate limiting
    }
    return translated;
  }
  
  return obj;
}

async function translateLocaleFiles(locale) {
  console.log(`🌐 Auto-translating files for: ${locale}`);
  
  if (!(locale in LANGUAGE_MAPPING)) {
    console.error(`❌ Language ${locale} not supported by LibreTranslate`);
    return;
  }
  
  const localeDir = path.join(BASE_DIR, locale);
  if (!fs.existsSync(localeDir)) {
    fs.mkdirSync(localeDir, { recursive: true });
  }
  
  // Get all English files
  const enFiles = fs.readdirSync(EN_DIR).filter(f => f.endsWith('.json'));
  
  for (const filename of enFiles) {
    const localePath = path.join(localeDir, filename);
    const enPath = path.join(EN_DIR, filename);
    
    // Skip if already exists and has substantial content (unless forced)
    if (fs.existsSync(localePath)) {
      const existingContent = fs.readFileSync(localePath, 'utf8');
      if (existingContent.length > 100 && !existingContent.includes('TODO_')) {
        console.log(`  - Skipping ${filename} (already translated)`);
        continue;
      }
    }
    
    console.log(`  📄 Translating ${filename}...`);
    
    try {
      const enContent = JSON.parse(fs.readFileSync(enPath, 'utf8'));
      const translatedContent = await translateObject(enContent, locale);
      
      fs.writeFileSync(localePath, JSON.stringify(translatedContent, null, 2) + '\n');
      console.log(`  ✅ Completed ${filename}`);
      
      // Longer delay between files to avoid overwhelming the service
      await new Promise(resolve => setTimeout(resolve, 1000));
      
    } catch (error) {
      console.error(`❌ Error translating ${filename} for ${locale}:`, error.message);
    }
  }
  
  console.log(`🎉 Completed translations for ${locale}\n`);
}

async function main() {
  // Check LibreTranslate connection
  try {
    console.log('🔍 Checking LibreTranslate connection...');
    const response = await fetch(`${LIBRETRANSLATE_URL}/languages`);
    const languages = await response.json();
    console.log(`✅ Connected to LibreTranslate with ${languages.length} languages available\n`);
  } catch (error) {
    console.error('❌ Cannot connect to LibreTranslate:', error.message);
    console.error('Make sure LibreTranslate is running and LIBRETRANSLATE_URL is set correctly');
    process.exit(1);
  }
  
  const targetLocale = process.argv[2];
  
  if (targetLocale) {
    if (!(targetLocale in LANGUAGE_MAPPING)) {
      console.error(`❌ Unsupported locale: ${targetLocale}`);
      console.error(`Supported locales: ${Object.keys(LANGUAGE_MAPPING).join(', ')}`);
      process.exit(1);
    }
    await translateLocaleFiles(targetLocale);
  } else {
    console.log('🌍 Auto-translating all supported languages...\n');
    for (const locale of Object.keys(LANGUAGE_MAPPING)) {
      await translateLocaleFiles(locale);
    }
  }
  
  console.log('✨ Auto-translation complete!');
  console.log('📝 Next steps:');
  console.log('1. Review translations for accuracy');
  console.log('2. Test language-specific URLs');  
  console.log('3. Deploy updated locale files');
}

// Handle fetch for Node.js environments without built-in fetch
if (typeof fetch === 'undefined') {
  console.log('Installing node-fetch for translation requests...');
  try {
    global.fetch = require('node-fetch');
  } catch (error) {
    console.error('❌ Please install node-fetch: npm install node-fetch');
    process.exit(1);
  }
}

main().catch(console.error);