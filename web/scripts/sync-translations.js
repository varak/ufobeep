#!/usr/bin/env node

/**
 * Translation Sync Script for UFOBeep Web
 * 
 * This script syncs translations from the Flutter mobile app (.arb files)
 * to the Next.js web app (JSON files), providing a substitution system
 * for easy translation management across all 22 supported languages.
 * 
 * Usage:
 *   node scripts/sync-translations.js
 *   npm run sync-translations
 */

const fs = require('fs');
const path = require('path');

// Configuration
const MOBILE_L10N_DIR = '../app/lib/l10n';
const WEB_LOCALES_DIR = './public/locales';

// Language mapping (mobile app code => web locale code)
const LANGUAGE_MAPPING = {
  'ar': 'ar',  // Arabic
  'cs': 'cs',  // Czech  
  'da': 'da',  // Danish
  'de': 'de',  // German
  'el': 'el',  // Greek
  'en': 'en',  // English
  'es': 'es',  // Spanish
  'fi': 'fi',  // Finnish
  'fr': 'fr',  // French
  'he': 'he',  // Hebrew
  'hi': 'hi',  // Hindi
  'it': 'it',  // Italian
  'ja': 'ja',  // Japanese
  'ko': 'ko',  // Korean
  'nl': 'nl',  // Dutch
  'no': 'no',  // Norwegian
  'pl': 'pl',  // Polish
  'pt': 'pt',  // Portuguese
  'ru': 'ru',  // Russian
  'sv': 'sv',  // Swedish
  'tr': 'tr',  // Turkish
  'zh': 'zh',  // Chinese
};

// Translation key mapping (mobile => web namespaces)
const KEY_MAPPINGS = {
  // Common namespace
  common: {
    'appName': 'appName',
    'ok': 'ok',
    'cancel': 'cancel',
    'close': 'close',
    'save': 'save',
    'delete': 'delete',
    'edit': 'edit',
    'yes': 'yes',
    'no': 'no',
    'back': 'back',
    'next': 'next',
    'loading': 'loading',
    'error': 'errorGeneric',
    'tryAgain': 'retry',
    'search': 'search',
    'filter': 'filter',
    'date': 'date',
    'time': 'time',
    'location': 'location',
    'description': 'description',
    'share': 'share',
    'copy': 'copy',
    'refresh': 'refresh',
    'unknown': 'unknown',
    'continue': 'continue',
    'confirm': 'confirm',
    'submit': 'submit',
  },
  
  // Alerts namespace  
  alerts: {
    'witnessReportOnly': 'witnessReportOnly',
    'reportOnly': 'reportOnly', 
    'beepOnly': 'beepOnly',
    'imageOnly': 'imageOnly',
    'videoOnly': 'videoOnly',
    'witnesses': 'witnesses',
    'witness': 'witness',
    'comments': 'comments',
    'comment': 'comment',
  },

  // Navigation namespace
  navigation: {
    'home': 'home',
    'alerts': 'alerts',
    'map': 'map',
    'profile': 'profile',
    'settings': 'settings',
  },

  // Meta namespace (SEO/OG tags)
  meta: {
    'appTagline': 'appTagline',
    'metaDescription': 'metaDescription',
    'ogTitle': 'ogTitle',
    'ogDescription': 'ogDescription',
  }
};

// Custom translations for web-specific content
const WEB_SPECIFIC_TRANSLATIONS = {
  alerts: {
    en: {
      'witnessReportOnly': 'witness report only',
      'reportOnly': 'Report Only',
      'beepOnly': 'beep only',
      'imageOnly': 'image only',
      'videoOnly': 'video only',
      'witnesses': 'witnesses',
      'witness': 'witness',
      'comments': 'comments',
      'comment': 'comment',
    },
    es: {
      'witnessReportOnly': 'solo reporte de testigo',
      'reportOnly': 'Solo Reporte',
      'beepOnly': 'solo beep',
      'imageOnly': 'solo imagen',
      'videoOnly': 'solo video',
      'witnesses': 'testigos',
      'witness': 'testigo',
      'comments': 'comentarios',
      'comment': 'comentario',
    },
    de: {
      'witnessReportOnly': 'nur Zeugenbericht',
      'reportOnly': 'Nur Bericht',
      'beepOnly': 'nur Beep',
      'imageOnly': 'nur Bild',
      'videoOnly': 'nur Video',
      'witnesses': 'Zeugen',
      'witness': 'Zeuge',
      'comments': 'Kommentare',
      'comment': 'Kommentar',
    },
    fr: {
      'witnessReportOnly': 'rapport de témoin seulement',
      'reportOnly': 'Rapport Seulement',
      'beepOnly': 'beep seulement',
      'imageOnly': 'image seulement',
      'videoOnly': 'vidéo seulement',
      'witnesses': 'témoins',
      'witness': 'témoin',
      'comments': 'commentaires',
      'comment': 'commentaire',
    },
    ru: {
      'witnessReportOnly': 'только отчет свидетеля',
      'reportOnly': 'Только Отчет',
      'beepOnly': 'только сигнал',
      'imageOnly': 'только изображение',
      'videoOnly': 'только видео',
      'witnesses': 'свидетели',
      'witness': 'свидетель',
      'comments': 'комментарии',
      'comment': 'комментарий',
    },
    ja: {
      'witnessReportOnly': '目撃者の報告のみ',
      'reportOnly': 'レポートのみ',
      'beepOnly': 'ビープのみ',
      'imageOnly': '画像のみ',
      'videoOnly': '動画のみ',
      'witnesses': '目撃者',
      'witness': '目撃者',
      'comments': 'コメント',
      'comment': 'コメント',
    },
    zh: {
      'witnessReportOnly': '仅目击者报告',
      'reportOnly': '仅报告',
      'beepOnly': '仅蜂鸣',
      'imageOnly': '仅图片',
      'videoOnly': '仅视频',
      'witnesses': '目击者',
      'witness': '目击者',
      'comments': '评论',
      'comment': '评论',
    }
  }
};

function readArbFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf-8');
    return JSON.parse(content);
  } catch (error) {
    console.warn(`Warning: Could not read ${filePath}:`, error.message);
    return {};
  }
}

function writeJsonFile(filePath, data) {
  const dir = path.dirname(filePath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2) + '\n');
}

function translateWebSpecificKeys(namespace, langCode, arbData) {
  const result = {};
  
  // Use web-specific translations if available
  if (WEB_SPECIFIC_TRANSLATIONS[namespace] && WEB_SPECIFIC_TRANSLATIONS[namespace][langCode]) {
    Object.assign(result, WEB_SPECIFIC_TRANSLATIONS[namespace][langCode]);
  }
  
  // Fill in any missing keys from mobile translations or fallback
  const keyMappings = KEY_MAPPINGS[namespace] || {};
  for (const [webKey, mobileKey] of Object.entries(keyMappings)) {
    if (!result[webKey]) {
      result[webKey] = arbData[mobileKey] || webKey; // fallback to key name
    }
  }
  
  return result;
}

function syncTranslations() {
  console.log('🌐 Syncing translations from mobile app to web...');
  console.log(`📱 Mobile l10n dir: ${MOBILE_L10N_DIR}`);
  console.log(`🌍 Web locales dir: ${WEB_LOCALES_DIR}`);
  
  let processedLanguages = 0;
  let createdFiles = 0;
  
  // Process each language
  for (const [mobileCode, webCode] of Object.entries(LANGUAGE_MAPPING)) {
    const mobileFilePath = path.resolve(MOBILE_L10N_DIR, `app_${mobileCode}.arb`);
    const arbData = readArbFile(mobileFilePath);
    
    if (Object.keys(arbData).length === 0) {
      continue;
    }
    
    console.log(`\n📝 Processing ${mobileCode} → ${webCode}...`);
    
    // Create web locale directory
    const webLocaleDir = path.resolve(WEB_LOCALES_DIR, webCode);
    if (!fs.existsSync(webLocaleDir)) {
      fs.mkdirSync(webLocaleDir, { recursive: true });
    }
    
    // Process each namespace
    for (const [namespace, keyMappings] of Object.entries(KEY_MAPPINGS)) {
      const webData = {};
      
      // Map mobile keys to web keys
      for (const [webKey, mobileKey] of Object.entries(keyMappings)) {
        if (arbData[mobileKey]) {
          webData[webKey] = arbData[mobileKey];
        }
      }
      
      // Add web-specific translations
      if (namespace === 'alerts') {
        const webSpecific = translateWebSpecificKeys(namespace, mobileCode, arbData);
        Object.assign(webData, webSpecific);
      }
      
      // Write namespace file
      if (Object.keys(webData).length > 0) {
        const outputPath = path.resolve(webLocaleDir, `${namespace}.json`);
        writeJsonFile(outputPath, webData);
        console.log(`  ✓ Created ${namespace}.json (${Object.keys(webData).length} keys)`);
        createdFiles++;
      }
    }
    
    processedLanguages++;
  }
  
  console.log(`\n🎉 Translation sync complete!`);
  console.log(`   Languages processed: ${processedLanguages}/22`);
  console.log(`   Files created/updated: ${createdFiles}`);
  console.log(`\n💡 Usage in React components:`);
  console.log(`   import { useTranslation } from 'next-i18next';`);
  console.log(`   const { t } = useTranslation('alerts');`);
  console.log(`   <span>{t('witnessReportOnly')}</span>`);
}

// Run the sync
if (require.main === module) {
  syncTranslations();
}

module.exports = { syncTranslations };