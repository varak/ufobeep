#!/usr/bin/env node

/**
 * Comprehensive translation generator for both web and mobile app
 * Generates all language files consistently from English sources
 * Usage: node scripts/generate-all-translations.js
 */

const fs = require('fs');
const path = require('path');

// Master language configuration
const LANGUAGES = {
  'en': { name: 'English', rtl: false },
  'es': { name: 'Spanish', rtl: false },
  'de': { name: 'German', rtl: false },
  'fr': { name: 'French', rtl: false },
  'pt': { name: 'Portuguese', rtl: false },
  'it': { name: 'Italian', rtl: false },
  'ru': { name: 'Russian', rtl: false },
  'ja': { name: 'Japanese', rtl: false },
  'zh': { name: 'Chinese', rtl: false },
  'ar': { name: 'Arabic', rtl: true },
  'nl': { name: 'Dutch', rtl: false },
  'pl': { name: 'Polish', rtl: false },
  'cs': { name: 'Czech', rtl: false },
  'tr': { name: 'Turkish', rtl: false },
  'ko': { name: 'Korean', rtl: false },
  'hi': { name: 'Hindi', rtl: false },
  'sv': { name: 'Swedish', rtl: false },
  'da': { name: 'Danish', rtl: false },
  'no': { name: 'Norwegian', rtl: false },
  'fi': { name: 'Finnish', rtl: false },
  'el': { name: 'Greek', rtl: false },
  'he': { name: 'Hebrew', rtl: true },
};

// Project directories
const WEB_LOCALES_DIR = path.join(__dirname, '../web/public/locales');
const APP_LOCALES_DIR = path.join(__dirname, '../app/lib/l10n');

// LibreTranslate settings
const LIBRETRANSLATE_URL = process.env.LIBRETRANSLATE_URL || 'http://localhost:5000';

class TranslationGenerator {
  constructor() {
    this.englishWebFiles = {};
    this.englishAppTerms = {};
    this.cache = new Map(); // Translation cache
  }

  async init() {
    console.log('📚 Loading English source files...');
    await this.loadEnglishSources();
    console.log('✅ English sources loaded\n');
  }

  async loadEnglishSources() {
    // Load web locale files
    const webEnDir = path.join(WEB_LOCALES_DIR, 'en');
    if (fs.existsSync(webEnDir)) {
      const files = fs.readdirSync(webEnDir).filter(f => f.endsWith('.json'));
      for (const file of files) {
        const content = JSON.parse(fs.readFileSync(path.join(webEnDir, file), 'utf8'));
        this.englishWebFiles[file] = content;
      }
    }

    // Load app locale file  
    const appEnFile = path.join(APP_LOCALES_DIR, 'app_en.arb');
    if (fs.existsSync(appEnFile)) {
      const content = JSON.parse(fs.readFileSync(appEnFile, 'utf8'));
      this.englishAppTerms = content;
    }
  }

  async translateText(text, targetLang) {
    if (!text || text.length < 2) return text;
    
    const cacheKey = `${text}:${targetLang}`;
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey);
    }

    try {
      const response = await fetch(`${LIBRETRANSLATE_URL}/translate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          q: text,
          source: 'en', 
          target: targetLang,
          format: 'text'
        })
      });

      const data = await response.json();
      const translated = data.translatedText || text;
      
      this.cache.set(cacheKey, translated);
      return translated;
    } catch (error) {
      console.warn(`⚠️  Translation failed: ${text.substring(0, 30)}...`);
      return text;
    }
  }

  async translateObject(obj, targetLang, depth = 0) {
    if (typeof obj === 'string') {
      return await this.translateText(obj, targetLang);
    }
    
    if (Array.isArray(obj)) {
      const result = [];
      for (const item of obj) {
        result.push(await this.translateObject(item, targetLang, depth + 1));
      }
      return result;
    }
    
    if (obj && typeof obj === 'object') {
      const result = {};
      for (const [key, value] of Object.entries(obj)) {
        // Skip metadata fields
        if (key.startsWith('@') || key === '@@locale') {
          result[key] = value;
        } else {
          result[key] = await this.translateObject(value, targetLang, depth + 1);
        }
      }
      return result;
    }
    
    return obj;
  }

  async generateWebLocales(targetLang) {
    console.log(`  🌐 Generating web locales for ${targetLang}...`);
    
    const localeDir = path.join(WEB_LOCALES_DIR, targetLang);
    if (!fs.existsSync(localeDir)) {
      fs.mkdirSync(localeDir, { recursive: true });
    }

    for (const [filename, content] of Object.entries(this.englishWebFiles)) {
      const outputPath = path.join(localeDir, filename);
      
      let translatedContent;
      if (targetLang === 'en') {
        translatedContent = content;
      } else {
        translatedContent = await this.translateObject(content, targetLang);
        
        // Special handling for slugs - ensure URL-safe format
        if (translatedContent.slugs) {
          const cleanSlugs = {};
          for (const [key, value] of Object.entries(translatedContent.slugs)) {
            cleanSlugs[key] = this.makeUrlSafe(value);
          }
          translatedContent.slugs = cleanSlugs;
        }
      }
      
      fs.writeFileSync(outputPath, JSON.stringify(translatedContent, null, 2) + '\n');
    }
  }

  async generateAppLocales(targetLang) {
    console.log(`  📱 Generating app locales for ${targetLang}...`);
    
    const outputPath = path.join(APP_LOCALES_DIR, `app_${targetLang}.arb`);
    
    let translatedContent;
    if (targetLang === 'en') {
      translatedContent = this.englishAppTerms;
    } else {
      translatedContent = { 
        "@@locale": targetLang,
        ...await this.translateObject(this.englishAppTerms, targetLang)
      };
    }
    
    fs.writeFileSync(outputPath, JSON.stringify(translatedContent, null, 2) + '\n');
  }

  makeUrlSafe(text) {
    return text
      .toLowerCase()
      .replace(/\s+/g, '-')           // spaces to hyphens
      .replace(/[^a-z0-9\-]/g, '')    // only alphanumeric and hyphens
      .replace(/--+/g, '-')           // multiple hyphens to single
      .replace(/^-|-$/g, '');         // trim hyphens
  }

  async generateAllLanguages() {
    console.log(`🚀 Generating translations for ${Object.keys(LANGUAGES).length} languages...\n`);
    
    for (const langCode of Object.keys(LANGUAGES)) {
      console.log(`📝 Processing ${langCode} (${LANGUAGES[langCode].name})`);
      
      try {
        await this.generateWebLocales(langCode);
        await this.generateAppLocales(langCode);
        console.log(`✅ Completed ${langCode}\n`);
      } catch (error) {
        console.error(`❌ Failed to generate ${langCode}:`, error.message);
      }
      
      // Rate limiting
      if (langCode !== 'en') {
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    }
  }

  generateConfigFiles() {
    console.log('⚙️  Generating configuration files...');
    
    // Generate web locale configuration
    const webLocaleConfig = {
      supportedLocales: LANGUAGES,
      defaultLocale: 'en',
      fallbackLocale: 'en'
    };
    
    fs.writeFileSync(
      path.join(__dirname, '../web/src/config/locales.js'), 
      `// Auto-generated locale configuration
export const supportedLocales = ${JSON.stringify(LANGUAGES, null, 2)};
export const defaultLocale = 'en';
export const fallbackLocale = 'en';

export function getLocaleDisplayName(locale) {
  return supportedLocales[locale]?.name || locale;
}

export function isRTLLocale(locale) {
  return supportedLocales[locale]?.rtl || false;
}
`);

    // Generate Flutter app configuration
    const flutterConfig = Object.keys(LANGUAGES).map(code => `  ${code}.arb`).join('\n');
    
    const l10nYaml = `arb-dir: lib/l10n
template-arb-file: app_en.arb  
output-localization-file: app_localizations.dart
output-class: AppLocalizations
${flutterConfig}`;

    fs.writeFileSync(path.join(__dirname, '../app/l10n.yaml'), l10nYaml);
    
    console.log('✅ Configuration files generated');
  }
}

// Main execution
async function main() {
  const generator = new TranslationGenerator();
  
  try {
    // Check LibreTranslate connection
    const response = await fetch(`${LIBRETRANSLATE_URL}/languages`);
    if (!response.ok) throw new Error('Connection failed');
    console.log('✅ LibreTranslate connected\n');
  } catch (error) {
    console.error('❌ LibreTranslate not available. Generating English-only templates.');
    console.error('Set LIBRETRANSLATE_URL to enable auto-translation\n');
  }

  await generator.init();
  await generator.generateAllLanguages();
  generator.generateConfigFiles();
  
  console.log('🎉 Translation generation complete!');
  console.log('\n📝 Next steps:');
  console.log('1. Review generated translations');
  console.log('2. Run `flutter gen-l10n` in app directory');
  console.log('3. Test language switching');
  console.log('4. Deploy updated files');
}

// Node.js fetch polyfill
if (typeof fetch === 'undefined') {
  try {
    global.fetch = require('node-fetch');
  } catch (error) {
    console.warn('⚠️  Install node-fetch for auto-translation: npm install node-fetch');
  }
}

main().catch(console.error);