
const fs = require('fs');
const path = require('path');

async function translateText(text, targetLang) {
  if (!text || text.length < 2) return text;
  
  try {
    const response = await fetch('http://localhost:5000/translate', {
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
    return data.translatedText || text;
  } catch (error) {
    console.warn('Translation failed:', text);
    return text;
  }
}

async function main() {
  const englishArb = JSON.parse(fs.readFileSync('./app/lib/l10n/app_en.arb', 'utf8'));
  const targetLang = 'hi';
  const arbPath = `./app/lib/l10n/app_${targetLang}.arb`;
  
  console.log('Translating to', targetLang);
  
  const translated = { '@@locale': targetLang };
  
  for (const [key, value] of Object.entries(englishArb)) {
    if (key.startsWith('@') || key === '@@locale') {
      translated[key] = value;
    } else if (typeof value === 'string') {
      translated[key] = await translateText(value, targetLang);
      console.log(`${key}: ${value} -> ${translated[key]}`);
      await new Promise(r => setTimeout(r, 500)); // Rate limit
    }
  }
  
  fs.writeFileSync(arbPath, JSON.stringify(translated, null, 2));
  console.log('Done!');
}

if (typeof fetch === 'undefined') {
  global.fetch = require('node-fetch');
}

main().catch(console.error);
