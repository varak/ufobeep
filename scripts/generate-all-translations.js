#!/usr/bin/env node

/**
 * UFOBeep Translation Generator
 * ============================
 * 
 * Generates consistent translations for both web and mobile app from English ARB source.
 * 
 * USAGE:
 *   node scripts/generate-all-translations.js [options]
 * 
 * OPTIONS:
 *   --english-only     Generate only English templates (fast, no translation)
 *   --language=es      Generate specific language only (e.g., --language=es)
 *   --no-translate     Generate all languages with English fallbacks (fast)
 *   --help            Show this help message
 * 
 * EXAMPLES:
 *   node scripts/generate-all-translations.js --english-only
 *   node scripts/generate-all-translations.js --language=es
 *   node scripts/generate-all-translations.js --no-translate
 *   node scripts/generate-all-translations.js  # Full translation (slow)
 * 
 * HOW IT WORKS:
 *   1. Reads English ARB file as single source of truth
 *   2. Organizes keys by namespace (common.json, navigation.json, etc.)
 *   3. Generates web JSON files and app ARB files
 *   4. Uses LibreTranslate for auto-translation (optional)
 *   5. Falls back to English if translation fails
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

// Command line options
const args = process.argv.slice(2);
const options = {
  englishOnly: args.includes('--english-only'),
  noTranslate: args.includes('--no-translate'),
  help: args.includes('--help'),
  language: args.find(arg => arg.startsWith('--language='))?.split('=')[1],
  timeout: parseInt(args.find(arg => arg.startsWith('--timeout='))?.split('=')[1]) || 30000
};

if (options.help) {
  console.log(`
UFOBeep Translation Generator
============================

USAGE:
  node scripts/generate-all-translations.js [options]

OPTIONS:
  --english-only       Generate only English templates (fast, no translation)
  --language=CODE      Generate specific language only (e.g., --language=es)
  --no-translate       Generate all languages with English fallbacks (fast)
  --timeout=MS         Translation timeout in milliseconds (default: 30000)
  --help               Show this help message

EXAMPLES:
  node scripts/generate-all-translations.js --english-only
  node scripts/generate-all-translations.js --language=es
  node scripts/generate-all-translations.js --no-translate
  node scripts/generate-all-translations.js --timeout=10000

WORKFLOW:
  1. Add new translation keys to app/lib/l10n/app_en.arb ONLY
  2. Run this script to generate all language files
  3. Review generated translations (especially new ones)
  4. Deploy updated files to production

KEY RULES:
  - NEVER edit individual language files manually
  - ONLY edit the English ARB file (app_en.arb)
  - This script maintains consistency across all 22 languages
  - Use --no-translate for fast updates without translation
`);
  process.exit(0);
}

class TranslationGenerator {
  constructor() {
    this.englishWebFiles = {};
    this.englishAppTerms = {};
    this.cache = new Map(); // Translation cache
    this.translateEnabled = false; // Will be set during init
  }

  async init() {
    console.log('📚 Loading English source files...');
    await this.loadEnglishSources();
    console.log('✅ English sources loaded\n');
    
    // Check LibreTranslate availability
    if (!options.noTranslate && !options.englishOnly) {
      try {
        const response = await fetch(`${LIBRETRANSLATE_URL}/languages`, { 
          signal: AbortSignal.timeout(5000) 
        });
        if (response.ok) {
          this.translateEnabled = true;
          console.log('✅ LibreTranslate connected - translations enabled\n');
        } else {
          this.translateEnabled = false;
          console.log('⚠️  LibreTranslate not available - copying English values\n');
        }
      } catch (error) {
        console.log('⚠️  LibreTranslate not available - copying English values\n');
        this.translateEnabled = false;
      }
    } else {
      console.log('⚡ Fast mode - copying English values to all languages\n');
    }
  }

  async loadEnglishSources() {
    // Load app ARB file as single source of truth
    const appEnFile = path.join(APP_LOCALES_DIR, 'app_en.arb');
    if (fs.existsSync(appEnFile)) {
      const content = JSON.parse(fs.readFileSync(appEnFile, 'utf8'));
      this.englishAppTerms = content;
      
      // Generate web locale files from ARB content - organize by namespace
      this.englishWebFiles = this.organizeArbByNamespace(content);
    }
  }

  organizeArbByNamespace(arbContent) {
    const organized = {
      'common.json': {},
      'navigation.json': {},
      'alerts.json': {},
      'pages.json': {},
      'forms.json': {},
      'errors.json': {},
      'meta.json': {},
      'beep-detail.json': {}
    };

    // Organize ARB terms by namespace based on key patterns
    for (const [key, value] of Object.entries(arbContent)) {
      if (key.startsWith('@') || key === '@@locale') continue; // Skip metadata
      
      // All component-used keys go to common.json to prevent namespace mismatches
      // Components use useClientTranslations('common', locale) consistently
      if (key.startsWith('recentUfoBeeps') || key.startsWith('nav')) {
        // Navigation keys should go to common.json, not navigation.json
        organized['common.json'][key] = value;
      } else if (key.includes('tab') || key.includes('menu')) {
        organized['navigation.json'][key] = value;
      } else if (key === 'ufobeepReportType' || key === 'beepOnly' || key === 'alertLevel' || key === 'backToBeeps' || key === 'alert') {
        // Critical component keys must go to common.json where components look for them
        organized['common.json'][key] = value;
      } else if (key.includes('alert') || key.includes('beep') || key.includes('ufoType') || key.includes('shape')) {
        organized['alerts.json'][key] = value;
      } else if (key.includes('error') || key.includes('failed') || key.includes('invalid')) {
        organized['errors.json'][key] = value;
      } else if (key.includes('title') || key.includes('subtitle') || key.includes('desc') || key.includes('meta')) {
        organized['meta.json'][key] = value;
      } else if (key.includes('form') || key.includes('input') || key.includes('submit') || key.includes('username')) {
        organized['forms.json'][key] = value;
      } else if (key.includes('page') || key.includes('welcome') || key.includes('setting')) {
        organized['pages.json'][key] = value;
      } else {
        // Default to common for basic terms
        organized['common.json'][key] = value;
      }
    }

    return organized;
  }

  async translateText(text, targetLang) {
    if (!text || text.length < 2 || options.noTranslate || !this.translateEnabled) {
      return text; // Return English text
    }
    
    const cacheKey = `${text}:${targetLang}`;
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey);
    }

    try {
      // Extract ICU placeholders to preserve them during translation
      const placeholders = [];
      let textToTranslate = text;
      
      // Find all ICU placeholders like {distance}, {bearing}, {username}, etc.
      const placeholderRegex = /\{[^}]+\}/g;
      const matches = text.match(placeholderRegex);
      
      if (matches) {
        matches.forEach((match, index) => {
          const placeholder = `__PLACEHOLDER_${index}__`;
          placeholders.push({ original: match, replacement: placeholder });
          textToTranslate = textToTranslate.replace(match, placeholder);
        });
      }

      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), options.timeout);

      const response = await fetch(`${LIBRETRANSLATE_URL}/translate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          q: textToTranslate,
          source: 'en', 
          target: targetLang,
          format: 'text'
        }),
        signal: controller.signal
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        return text; // Return English on HTTP error
      }

      const data = await response.json();
      let translated = data.translatedText || text;
      
      // Restore original placeholders in translated text
      placeholders.forEach(({ original, replacement }) => {
        translated = translated.replace(new RegExp(replacement, 'g'), original);
      });
      
      // Additional ICU format validation and cleanup
      translated = this.validateAndFixICUFormat(translated, text);
      
      this.cache.set(cacheKey, translated);
      return translated;
    } catch (error) {
      return text; // Return English on any error
    }
  }

  validateAndFixICUFormat(translated, original) {
    // Extract placeholder names from original English text
    const originalPlaceholders = (original.match(/\{([^}]+)\}/g) || [])
      .map(match => match.slice(1, -1)); // Remove { and }
    
    // Known valid ICU placeholder names that should be preserved
    const validPlaceholders = [
      'distance', 'bearing', 'username', 'time', 'timeAgo', 'alertTitle', 
      'description', 'count', 'percent', 'speed', 'unit', 'direction', 
      'caseNumber', 'witnessText', 'locationName', 'shortUrl', 'currentPage',
      'totalPages', 'totalCount', 'classification'
    ];
    
    // Replace any translated placeholder names with English equivalents
    let fixed = translated;
    
    // Find all placeholders in translated text
    const translatedPlaceholders = translated.match(/\{([^}]+)\}/g) || [];
    
    translatedPlaceholders.forEach(placeholder => {
      const placeholderName = placeholder.slice(1, -1);
      
      // If this placeholder name is not in our valid list and we have originals to map from
      if (!validPlaceholders.includes(placeholderName) && originalPlaceholders.length > 0) {
        // Try to map back to the correct English placeholder
        // For now, just use the first original placeholder as fallback
        const englishPlaceholder = `{${originalPlaceholders[0]}}`;
        fixed = fixed.replace(placeholder, englishPlaceholder);
      }
    });
    
    // Remove any malformed or incomplete placeholders
    fixed = fixed.replace(/\{[^}]*$/g, ''); // Remove unclosed braces at end
    fixed = fixed.replace(/^[^{]*\}/g, ''); // Remove unmatched closing braces at start
    
    // Clean up extra spaces around placeholders
    fixed = fixed.replace(/\s+\{/g, ' {').replace(/\}\s+/g, '} ');
    
    return fixed.trim();
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
        // Skip metadata fields but fix locale
        if (key.startsWith('@') || key === '@@locale') {
          if (key === '@@locale') {
            result[key] = targetLang;
          } else {
            result[key] = value;
          }
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
      translatedContent = await this.translateObject(this.englishAppTerms, targetLang);
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
    const targetLanguages = options.language 
      ? [options.language]
      : options.englishOnly 
        ? ['en'] 
        : Object.keys(LANGUAGES);

    console.log(`🚀 Generating translations for ${targetLanguages.length} language(s)...\n`);
    
    const results = { success: 0, failed: 0, skipped: 0 };
    
    for (const langCode of targetLanguages) {
      if (!LANGUAGES[langCode]) {
        console.error(`❌ Unknown language code: ${langCode}`);
        results.failed++;
        continue;
      }
      
      console.log(`📝 Processing ${langCode} (${LANGUAGES[langCode].name})`);
      
      try {
        await this.generateWebLocales(langCode);
        await this.generateAppLocales(langCode);
        console.log(`✅ Completed ${langCode}\n`);
        results.success++;
      } catch (error) {
        console.error(`❌ Failed to generate ${langCode}:`, error.message);
        console.error('Stack:', error.stack);
        results.failed++;
      }
      
      // Rate limiting for translation requests
      if (langCode !== 'en' && this.translateEnabled && !options.noTranslate) {
        await new Promise(resolve => setTimeout(resolve, 2000));
      }
    }
    
    console.log(`\n📊 Generation Results:`);
    console.log(`   ✅ Success: ${results.success}`);
    console.log(`   ❌ Failed: ${results.failed}`);
    console.log(`   ⏭️  Skipped: ${results.skipped}`);
    
    return results;
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