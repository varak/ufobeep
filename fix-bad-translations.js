#!/usr/bin/env node

// Smart correction script to fix worst LibreTranslate translations with Azure
require('dotenv').config({ path: '.env.azure' });
const fs = require('fs');
const path = require('path');

// Detect bad translations patterns
const BAD_TRANSLATION_PATTERNS = [
  // Known bad LibreTranslate outputs
  'Skip user information',
  'Skip user',
  '__PLACEHOLDER_0_',
  '__PLACEHOLDER_1_',
  '__PLACEHOLDER_2_',

  // Translated placeholder names (ICU errors)
  /\{[^\}]*[^a-zA-Z0-9_\}][^\}]*\}/,  // Non-ASCII characters in placeholders
  /\{avstånd\}/,     // Swedish translated placeholder
  /\{ρουλεμάν\}/,    // Greek translated placeholder
  /\{bäring\}/,      // Swedish translated placeholder
  /\{असर\}/,         // Hindi translated placeholder
  /\{दिशा\}/,        // Hindi translated placeholder
  /\{direção\}/,     // Portuguese translated placeholder
  /\{速度\}/,        // Chinese translated placeholder
  /\{单位\}/,        // Chinese translated placeholder
  /\{عد\}/,          // Arabic translated placeholder
  /\{λεπτά\}/,       // Greek translated placeholder
  /\{ώρες\}/,        // Greek translated placeholder
  /\{時間\}/,        // Japanese translated placeholder
  /\{användarnamn\}/, // Swedish translated placeholder
  /\{φάση\}/,        // Greek translated placeholder
  /\{चरण\}/,         // Hindi translated placeholder
  /\{位相\}/,        // Japanese translated placeholder

  // English words that shouldn't appear in foreign languages
  /\bSkip\b/,
  /\bMedia\b/,
  /\bOK\b/,
  /\bCancel\b/,
  /\bSave\b/,
  /\bDelete\b/,
  /\bEdit\b/,
  /\bBack\b/,
  /\bNext\b/,
  /\bDone\b/,
  /\bYes\b/,
  /\bNo\b/,
];

// Known correct translations to avoid re-translating
const KEEP_TRANSLATIONS = [
  'UFOBeep', // Brand name stays English
  'MUFON',   // Organization name stays English
  'GPS',     // Technical term stays English
  'API',     // Technical term stays English
];

async function translateWithAzure(text, targetLang) {
  console.log(`    🔄 Azure translating "${text}" to ${targetLang}...`);
  try {
    const response = await fetch(`${process.env.AZURE_TRANSLATOR_ENDPOINT}translate?api-version=3.0&to=${targetLang}`, {
      method: 'POST',
      headers: {
        'Ocp-Apim-Subscription-Key': process.env.AZURE_TRANSLATOR_KEY,
        'Ocp-Apim-Subscription-Region': process.env.AZURE_TRANSLATOR_REGION,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify([{ Text: text }])
    });

    if (response.ok) {
      const data = await response.json();
      const result = data[0]?.translations[0]?.text || text;
      console.log(`    ✅ Result: "${result}"`);
      return result;
    } else {
      console.log(`    ❌ Azure API error: ${response.status}`);
    }
  } catch (error) {
    console.log(`    ❌ Error: ${error.message}`);
  }
  return text;
}

function isBadTranslation(germanText, englishText) {
  // Skip if it's a term we want to keep in English
  if (KEEP_TRANSLATIONS.some(term => englishText.includes(term))) {
    return false;
  }

  // Check for known bad patterns
  return BAD_TRANSLATION_PATTERNS.some(pattern => {
    if (typeof pattern === 'string') {
      return germanText.includes(pattern);
    } else {
      return pattern.test(germanText);
    }
  });
}

async function fixLanguageFile(langCode, englishArb) {
  const arbPath = path.join(__dirname, 'app/lib/l10n', `app_${langCode}.arb`);

  if (!fs.existsSync(arbPath)) {
    console.log(`❌ ${langCode}: File not found`);
    return;
  }

  const arb = JSON.parse(fs.readFileSync(arbPath, 'utf8'));
  let fixedCount = 0;

  console.log(`🔍 Checking ${langCode}...`);

  for (const [key, germanText] of Object.entries(arb)) {
    if (key.startsWith('@') || key === '@@locale') continue;

    const englishText = englishArb[key];
    if (!englishText || typeof germanText !== 'string') continue;

    if (isBadTranslation(germanText, englishText)) {
      console.log(`  🔧 Found bad translation for key "${key}"`);
      console.log(`      LibreTranslate: "${germanText}"`);
      console.log(`      English source: "${englishText}"`);

      const betterTranslation = await translateWithAzure(englishText, langCode);

      // Restore English placeholder names (Azure sometimes translates them)
      let fixedTranslation = betterTranslation;
      const englishPlaceholders = englishText.match(/\{[^}]+\}/g) || [];
      const translatedPlaceholders = betterTranslation.match(/\{[^}]+\}/g) || [];

      // Replace translated placeholders with original English ones
      if (englishPlaceholders.length === translatedPlaceholders.length) {
        for (let i = 0; i < englishPlaceholders.length; i++) {
          fixedTranslation = fixedTranslation.replace(translatedPlaceholders[i], englishPlaceholders[i]);
        }
      }

      arb[key] = fixedTranslation;
      fixedCount++;

      console.log(`      ✅ Fixed to: "${betterTranslation}"`);
      console.log(``);

      // Rate limiting
      await new Promise(resolve => setTimeout(resolve, 150));
    }
  }

  if (fixedCount > 0) {
    fs.writeFileSync(arbPath, JSON.stringify(arb, null, 2) + '\n');
    console.log(`✅ ${langCode}: Fixed ${fixedCount} bad translations`);
  } else {
    console.log(`✅ ${langCode}: No bad translations found`);
  }

  return fixedCount;
}

async function main() {
  console.log('🔧 Finding and fixing bad LibreTranslate translations with Azure for ALL languages...\n');

  // Load English ARB as reference
  const englishPath = path.join(__dirname, 'app/lib/l10n/app_en.arb');
  if (!fs.existsSync(englishPath)) {
    console.error('❌ English ARB file not found!');
    return;
  }

  const englishArb = JSON.parse(fs.readFileSync(englishPath, 'utf8'));

  // Languages to fix (all except English)
  const LANGUAGES = ['de', 'es', 'fr', 'it', 'pt', 'ru', 'ja', 'zh', 'ar', 'nl', 'pl', 'cs', 'tr', 'ko', 'hi', 'sv', 'da', 'no', 'fi', 'el', 'he'];

  let totalFixed = 0;

  for (const lang of LANGUAGES) {
    const fixed = await fixLanguageFile(lang, englishArb);
    totalFixed += fixed;

    // Delay between languages to avoid rate limiting
    if (fixed > 0) {
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }

  console.log(`\n🎉 Complete! Fixed ${totalFixed} bad translations across ${LANGUAGES.length} languages`);
  console.log('💡 Run flutter gen-l10n in app/ directory to update localizations');
}

main().catch(console.error);