#!/usr/bin/env node

// Fix translated placeholder names to restore English ones for ICU compatibility
const fs = require('fs');
const path = require('path');

async function fixPlaceholdersInFile(langCode, englishArb) {
  const arbPath = path.join(__dirname, 'app/lib/l10n', `app_${langCode}.arb`);

  if (!fs.existsSync(arbPath)) {
    console.log(`❌ ${langCode}: File not found`);
    return 0;
  }

  const arb = JSON.parse(fs.readFileSync(arbPath, 'utf8'));
  let fixedCount = 0;

  console.log(`🔧 Fixing placeholders in ${langCode}...`);

  for (const [key, translatedText] of Object.entries(arb)) {
    if (key.startsWith('@') || key === '@@locale') continue;

    const englishText = englishArb[key];
    if (!englishText || typeof translatedText !== 'string') continue;

    // Extract English placeholders from the source
    const englishPlaceholders = englishText.match(/\{[^}]+\}/g) || [];

    if (englishPlaceholders.length === 0) continue; // No placeholders to fix

    // Extract current placeholders from translated text
    const translatedPlaceholders = translatedText.match(/\{[^}]+\}/g) || [];

    if (englishPlaceholders.length !== translatedPlaceholders.length) {
      console.log(`  ⚠️  Placeholder count mismatch for key "${key}"`);
      console.log(`      English: ${englishPlaceholders.join(', ')}`);
      console.log(`      ${langCode}: ${translatedPlaceholders.join(', ')}`);
      continue;
    }

    // Check if any placeholders were translated
    let needsFix = false;
    for (let i = 0; i < englishPlaceholders.length; i++) {
      if (englishPlaceholders[i] !== translatedPlaceholders[i]) {
        needsFix = true;
        break;
      }
    }

    if (needsFix) {
      let fixedText = translatedText;

      // Replace translated placeholders with English ones
      for (let i = 0; i < englishPlaceholders.length; i++) {
        const englishPlaceholder = englishPlaceholders[i];
        const translatedPlaceholder = translatedPlaceholders[i];

        if (englishPlaceholder !== translatedPlaceholder) {
          fixedText = fixedText.replace(translatedPlaceholder, englishPlaceholder);
          console.log(`    🔄 ${translatedPlaceholder} → ${englishPlaceholder}`);
        }
      }

      arb[key] = fixedText;
      fixedCount++;

      console.log(`  ✅ Fixed "${key}": ${translatedText}`);
      console.log(`       → ${fixedText}`);
      console.log(``);
    }
  }

  if (fixedCount > 0) {
    fs.writeFileSync(arbPath, JSON.stringify(arb, null, 2) + '\n');
    console.log(`✅ ${langCode}: Fixed ${fixedCount} placeholder issues`);
  } else {
    console.log(`✅ ${langCode}: No placeholder issues found`);
  }

  return fixedCount;
}

async function main() {
  console.log('🔧 Fixing translated placeholder names across ALL languages...\n');

  // Load English ARB as reference for correct placeholder names
  const englishPath = path.join(__dirname, 'app/lib/l10n/app_en.arb');
  if (!fs.existsSync(englishPath)) {
    console.error('❌ English ARB file not found!');
    return;
  }

  const englishArb = JSON.parse(fs.readFileSync(englishPath, 'utf8'));

  // All non-English languages
  const LANGUAGES = ['de', 'es', 'fr', 'it', 'pt', 'ru', 'ja', 'zh', 'ar', 'nl', 'pl', 'cs', 'tr', 'ko', 'hi', 'sv', 'da', 'no', 'fi', 'el', 'he'];

  let totalFixed = 0;

  for (const lang of LANGUAGES) {
    const fixed = await fixPlaceholdersInFile(lang, englishArb);
    totalFixed += fixed;
  }

  console.log(`\n🎉 Complete! Fixed ${totalFixed} placeholder issues across ${LANGUAGES.length} languages`);
  console.log('💡 Run flutter gen-l10n in app/ directory to test ICU compilation');
}

main().catch(console.error);