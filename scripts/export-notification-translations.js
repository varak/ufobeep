#!/usr/bin/env node

/**
 * Export push notification translations from ARB files to JSON for backend consumption
 * Creates a simple lookup table for fast notification translation
 */

const fs = require('fs');
const path = require('path');

// Languages supported
const LANGUAGES = {
  'en': 'English',
  'es': 'Spanish',
  'de': 'German',
  'fr': 'French',
  'pt': 'Portuguese',
  'it': 'Italian',
  'ru': 'Russian',
  'ja': 'Japanese',
  'zh': 'Chinese',
  'ar': 'Arabic',
  'nl': 'Dutch',
  'pl': 'Polish',
  'cs': 'Czech',
  'tr': 'Turkish',
  'ko': 'Korean',
  'hi': 'Hindi',
  'sv': 'Swedish',
  'da': 'Danish',
  'no': 'Norwegian',
  'fi': 'Finnish',
  'el': 'Greek',
  'he': 'Hebrew'
};

// Push notification keys we need to extract
const NOTIFICATION_KEYS = [
  'pushNotificationUfoAlert',
  'pushNotificationAnomalyAlert',
  'pushNotificationNearby',
  'pushNotificationInYourArea',
  'pushNotificationCommented',
  'pushNotificationCommentedOn',
  'pushNotificationGeneric',
  'pushNotificationNewSighting'
];

function extractNotificationTranslations() {
  const translations = {};

  console.log('📱 Extracting push notification translations...');

  for (const [langCode, langName] of Object.entries(LANGUAGES)) {
    const arbPath = path.join(__dirname, `../app/lib/l10n/app_${langCode}.arb`);

    if (!fs.existsSync(arbPath)) {
      console.log(`⚠️  Missing ARB file for ${langName} (${langCode})`);
      continue;
    }

    try {
      const arbContent = fs.readFileSync(arbPath, 'utf8');
      const arbData = JSON.parse(arbContent);

      translations[langCode] = {};

      for (const key of NOTIFICATION_KEYS) {
        if (arbData[key]) {
          translations[langCode][key] = arbData[key];
        } else {
          console.log(`⚠️  Missing key '${key}' in ${langCode}`);
          // Fallback to English if missing
          translations[langCode][key] = arbData[key] || `[MISSING: ${key}]`;
        }
      }

      console.log(`✅ Extracted ${Object.keys(translations[langCode]).length} notification keys for ${langName}`);

    } catch (error) {
      console.log(`❌ Failed to process ${langName} ARB file: ${error.message}`);
    }
  }

  return translations;
}

function exportToBackend(translations) {
  const outputPath = path.join(__dirname, '../api/notification_translations.json');

  const exportData = {
    version: '1.0.0',
    generated: new Date().toISOString(),
    languages: Object.keys(translations),
    translations: translations
  };

  fs.writeFileSync(outputPath, JSON.stringify(exportData, null, 2));
  console.log(`📄 Exported to: ${outputPath}`);
  console.log(`🌍 ${Object.keys(translations).length} languages × ${NOTIFICATION_KEYS.length} keys = ${Object.keys(translations).length * NOTIFICATION_KEYS.length} translations`);
}

function main() {
  console.log('🌍 UFOBeep Push Notification Translation Exporter');
  console.log('================================================');

  const translations = extractNotificationTranslations();
  exportToBackend(translations);

  console.log('');
  console.log('✨ Export complete!');
  console.log('Backend can now use fast lookups for multilingual push notifications');
}

if (require.main === module) {
  main();
}

module.exports = { extractNotificationTranslations, exportToBackend };