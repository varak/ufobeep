#!/usr/bin/env node

// Quick fix for critical broken translations using Azure Translator
require('dotenv').config({ path: '.env.azure' });

const CRITICAL_FIXES = {
  'skip': 'Skip',
  'chooseYourUsername': 'Choose Your Username',
  'weatherClear': 'Clear',
  'weatherClearSky': 'clear sky'
};

async function translateWithAzure(text, targetLang) {
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
      return data[0]?.translations[0]?.text || text;
    }
  } catch (error) {
    console.error(`Error translating "${text}":`, error.message);
  }
  return text;
}

async function main() {
  console.log('🔧 Fixing critical German translations with Azure...');

  for (const [key, englishText] of Object.entries(CRITICAL_FIXES)) {
    const german = await translateWithAzure(englishText, 'de');
    console.log(`${key}: "${englishText}" → "${german}"`);
    // Add small delay to avoid rate limiting
    await new Promise(resolve => setTimeout(resolve, 100));
  }
}

main().catch(console.error);