#!/usr/bin/env node

/**
 * Generate comprehensive translation stubs with language-specific URL slugs
 * Including MUFON/NUFORC classifications for SEO-friendly URLs
 * Usage: node scripts/generate-comprehensive-locale-stubs.js [specific-language]
 */

const fs = require('fs');
const path = require('path');

// Supported languages
const SUPPORTED_LOCALES = [
  'ar', 'cs', 'da', 'de', 'el', 'es', 'fi', 'fr', 'he', 'hi', 
  'it', 'ja', 'ko', 'nl', 'no', 'pl', 'pt', 'ru', 'sv', 'tr', 'zh'
];

// Comprehensive slug translations for SEO-friendly URLs
const SLUG_TRANSLATIONS = {
  es: { 
    // Basic terms
    ufo: 'ovni', sighting: 'avistamiento', report: 'reporte', mufon: 'mufon', nuforc: 'nuforc', unknown: 'desconocido',
    // Classifications for URL slugs
    sphere: 'esfera', light: 'luz', disk: 'disco', triangle: 'triangulo', cigar: 'cigarro',
    oval: 'oval', cylinder: 'cilindro', rectangle: 'rectangulo', diamond: 'diamante',
    fireball: 'bola-fuego', flash: 'destello', formation: 'formacion', changing: 'cambiante',
    chevron: 'chevron', cone: 'cono', cross: 'cruz', egg: 'huevo', object: 'objeto'
  },
  de: { 
    ufo: 'ufo', sighting: 'sichtung', report: 'bericht', mufon: 'mufon', nuforc: 'nuforc', unknown: 'unbekannt',
    sphere: 'sphäre', light: 'licht', disk: 'scheibe', triangle: 'dreieck', cigar: 'zigarre',
    oval: 'oval', cylinder: 'zylinder', rectangle: 'rechteck', diamond: 'diamant',
    fireball: 'feuerball', flash: 'blitz', formation: 'formation', changing: 'wechselnd',
    chevron: 'chevron', cone: 'kegel', cross: 'kreuz', egg: 'ei', object: 'objekt'
  },
  fr: { 
    ufo: 'ovni', sighting: 'observation', report: 'rapport', mufon: 'mufon', nuforc: 'nuforc', unknown: 'inconnu',
    sphere: 'sphère', light: 'lumière', disk: 'disque', triangle: 'triangle', cigar: 'cigare',
    oval: 'ovale', cylinder: 'cylindre', rectangle: 'rectangle', diamond: 'diamant',
    fireball: 'boule-feu', flash: 'éclair', formation: 'formation', changing: 'changeant',
    chevron: 'chevron', cone: 'cône', cross: 'croix', egg: 'œuf', object: 'objet'
  },
  pt: { 
    ufo: 'ovni', sighting: 'avistamento', report: 'relatorio', mufon: 'mufon', nuforc: 'nuforc', unknown: 'desconhecido',
    sphere: 'esfera', light: 'luz', disk: 'disco', triangle: 'triangulo', cigar: 'charuto',
    oval: 'oval', cylinder: 'cilindro', rectangle: 'retangulo', diamond: 'diamante',
    fireball: 'bola-fogo', flash: 'flash', formation: 'formacao', changing: 'mudando',
    chevron: 'chevron', cone: 'cone', cross: 'cruz', egg: 'ovo', object: 'objeto'
  },
  it: { 
    ufo: 'ufo', sighting: 'avvistamento', report: 'rapporto', mufon: 'mufon', nuforc: 'nuforc', unknown: 'sconosciuto',
    sphere: 'sfera', light: 'luce', disk: 'disco', triangle: 'triangolo', cigar: 'sigaro',
    oval: 'ovale', cylinder: 'cilindro', rectangle: 'rettangolo', diamond: 'diamante',
    fireball: 'palla-fuoco', flash: 'lampo', formation: 'formazione', changing: 'cambiante',
    chevron: 'chevron', cone: 'cono', cross: 'croce', egg: 'uovo', object: 'oggetto'
  },
  ru: { 
    ufo: 'нло', sighting: 'наблюдение', report: 'отчет', mufon: 'mufon', nuforc: 'nuforc', unknown: 'неизвестный',
    sphere: 'сфера', light: 'свет', disk: 'диск', triangle: 'треугольник', cigar: 'сигара',
    oval: 'овал', cylinder: 'цилиндр', rectangle: 'прямоугольник', diamond: 'ромб',
    fireball: 'огненный-шар', flash: 'вспышка', formation: 'формация', changing: 'меняющийся',
    chevron: 'шеврон', cone: 'конус', cross: 'крест', egg: 'яйцо', object: 'объект'
  },
  ja: { 
    ufo: 'ufo', sighting: '目撃', report: '報告', mufon: 'mufon', nuforc: 'nuforc', unknown: '不明',
    sphere: '球体', light: '光', disk: '円盤', triangle: '三角', cigar: '葉巻',
    oval: '楕円', cylinder: '円筒', rectangle: '長方形', diamond: 'ダイヤ',
    fireball: '火球', flash: '閃光', formation: '編隊', changing: '変化',
    chevron: 'シェブロン', cone: '円錐', cross: '十字', egg: '卵', object: '物体'
  },
  zh: { 
    ufo: 'ufo', sighting: '目击', report: '报告', mufon: 'mufon', nuforc: 'nuforc', unknown: '未知',
    sphere: '球体', light: '光', disk: '圆盘', triangle: '三角', cigar: '雪茄',
    oval: '椭圆', cylinder: '圆柱', rectangle: '长方形', diamond: '钻石',
    fireball: '火球', flash: '闪光', formation: '编队', changing: '变化',
    chevron: '人字形', cone: '圆锥', cross: '十字', egg: '蛋', object: '物体'
  },
  ar: { 
    ufo: 'يوفو', sighting: 'رؤية', report: 'تقرير', mufon: 'mufon', nuforc: 'nuforc', unknown: 'مجهول',
    sphere: 'كرة', light: 'ضوء', disk: 'قرص', triangle: 'مثلث', cigar: 'سيجار',
    oval: 'بيضاوي', cylinder: 'اسطوانة', rectangle: 'مستطيل', diamond: 'ماس',
    fireball: 'كرة-نار', flash: 'وميض', formation: 'تشكيل', changing: 'متغير',
    chevron: 'شيفرون', cone: 'مخروط', cross: 'صليب', egg: 'بيضة', object: 'جسم'
  },
  nl: {
    ufo: 'ufo', sighting: 'waarneming', report: 'rapport', mufon: 'mufon', nuforc: 'nuforc', unknown: 'onbekend',
    sphere: 'bol', light: 'licht', disk: 'schijf', triangle: 'driehoek', cigar: 'sigaar',
    oval: 'ovaal', cylinder: 'cilinder', rectangle: 'rechthoek', diamond: 'diamant',
    fireball: 'vuurbal', flash: 'flits', formation: 'formatie', changing: 'veranderend',
    chevron: 'chevron', cone: 'kegel', cross: 'kruis', egg: 'ei', object: 'object'
  },
  pl: {
    ufo: 'ufo', sighting: 'obserwacja', report: 'raport', mufon: 'mufon', nuforc: 'nuforc', unknown: 'nieznany',
    sphere: 'kula', light: 'światło', disk: 'dysk', triangle: 'trójkąt', cigar: 'cygaro',
    oval: 'owal', cylinder: 'cylinder', rectangle: 'prostokąt', diamond: 'diament',
    fireball: 'kula-ognia', flash: 'błysk', formation: 'formacja', changing: 'zmieniający',
    chevron: 'chevron', cone: 'stożek', cross: 'krzyż', egg: 'jajko', object: 'obiekt'
  },
  cs: {
    ufo: 'ufo', sighting: 'pozorování', report: 'zpráva', mufon: 'mufon', nuforc: 'nuforc', unknown: 'neznámý',
    sphere: 'koule', light: 'světlo', disk: 'disk', triangle: 'trojúhelník', cigar: 'doutník',
    oval: 'ovál', cylinder: 'válec', rectangle: 'obdélník', diamond: 'diamant',
    fireball: 'ohnivá-koule', flash: 'záblesk', formation: 'formace', changing: 'měnící',
    chevron: 'chevron', cone: 'kužel', cross: 'kříž', egg: 'vejce', object: 'objekt'
  },
  // Add fallback for other languages - they'll use English terms
};

const BASE_DIR = path.join(__dirname, '../public/locales');
const EN_DIR = path.join(BASE_DIR, 'en');

function generateStubsForLanguage(locale) {
  console.log(`Generating comprehensive stubs for: ${locale}`);
  
  const localeDir = path.join(BASE_DIR, locale);
  
  if (!fs.existsSync(localeDir)) {
    fs.mkdirSync(localeDir, { recursive: true });
  }
  
  // Generate beeps.json with comprehensive slugs
  generateBeepsJson(locale, localeDir);
  
  // Generate beep-detail.json with classifications
  generateBeepDetailJson(locale, localeDir);
  
  // Generate other stub files
  generateOtherStubs(locale, localeDir);
}

function generateBeepsJson(locale, localeDir) {
  const filePath = path.join(localeDir, 'beeps.json');
  
  // Skip if already exists with substantial content
  if (fs.existsSync(filePath)) {
    const existing = fs.readFileSync(filePath, 'utf8');
    if (existing.length > 100) {
      console.log(`  - Skipping beeps.json (already exists)`);
      return;
    }
  }
  
  const enContent = JSON.parse(fs.readFileSync(path.join(EN_DIR, 'beeps.json'), 'utf8'));
  const slugs = SLUG_TRANSLATIONS[locale] || SLUG_TRANSLATIONS['es']; // Fallback to Spanish
  
  const localized = {
    ...enContent,
    slugs: {
      // Basic terms
      ufo: slugs.ufo,
      sighting: slugs.sighting,
      report: slugs.report,
      mufon: slugs.mufon,
      nuforc: slugs.nuforc,
      unknown: slugs.unknown,
      // Classifications for URL generation
      sphere: slugs.sphere,
      light: slugs.light,
      disk: slugs.disk,
      triangle: slugs.triangle,
      cigar: slugs.cigar,
      oval: slugs.oval,
      cylinder: slugs.cylinder,
      rectangle: slugs.rectangle,
      diamond: slugs.diamond,
      fireball: slugs.fireball,
      flash: slugs.flash,
      formation: slugs.formation,
      changing: slugs.changing,
      chevron: slugs.chevron,
      cone: slugs.cone,
      cross: slugs.cross,
      egg: slugs.egg,
      object: slugs.object
    }
  };
  
  // Replace text content with TODO markers for translation
  const stub = createTranslationStub(localized, ['slugs']);
  
  fs.writeFileSync(filePath, JSON.stringify(stub, null, 2) + '\n');
  console.log(`  ✓ Created beeps.json with ${Object.keys(stub.slugs).length} slug translations`);
}

function generateBeepDetailJson(locale, localeDir) {
  const filePath = path.join(localeDir, 'beep-detail.json');
  
  if (fs.existsSync(filePath)) {
    console.log(`  - Skipping beep-detail.json (already exists)`);
    return;
  }
  
  const enContent = JSON.parse(fs.readFileSync(path.join(EN_DIR, 'beep-detail.json'), 'utf8'));
  const stub = createTranslationStub(enContent);
  
  fs.writeFileSync(filePath, JSON.stringify(stub, null, 2) + '\n');
  console.log(`  ✓ Created beep-detail.json`);
}

function generateOtherStubs(locale, localeDir) {
  const enFiles = fs.readdirSync(EN_DIR).filter(f => 
    f.endsWith('.json') && f !== 'beeps.json' && f !== 'beep-detail.json'
  );
  
  enFiles.forEach(filename => {
    const filePath = path.join(localeDir, filename);
    
    if (fs.existsSync(filePath)) {
      console.log(`  - Skipping ${filename} (already exists)`);
      return;
    }
    
    const enContent = JSON.parse(fs.readFileSync(path.join(EN_DIR, filename), 'utf8'));
    const stub = createTranslationStub(enContent);
    
    fs.writeFileSync(filePath, JSON.stringify(stub, null, 2) + '\n');
    console.log(`  ✓ Created ${filename}`);
  });
}

function createTranslationStub(obj, preserveKeys = []) {
  if (typeof obj === 'string') {
    return `TODO_TRANSLATE_${obj.toUpperCase().replace(/[^A-Z0-9]/g, '_').substring(0, 30)}`;
  }
  
  if (Array.isArray(obj)) {
    return obj.map(item => createTranslationStub(item, preserveKeys));
  }
  
  if (obj && typeof obj === 'object') {
    const result = {};
    for (const [key, value] of Object.entries(obj)) {
      if (preserveKeys.includes(key)) {
        result[key] = value; // Keep translated values
      } else {
        result[key] = createTranslationStub(value, preserveKeys);
      }
    }
    return result;
  }
  
  return obj;
}

// Main execution
const targetLocale = process.argv[2];

if (targetLocale) {
  if (!SUPPORTED_LOCALES.includes(targetLocale)) {
    console.error(`Unsupported locale: ${targetLocale}`);
    console.error(`Supported: ${SUPPORTED_LOCALES.join(', ')}`);
    process.exit(1);
  }
  generateStubsForLanguage(targetLocale);
} else {
  console.log('Generating comprehensive stubs for all supported languages...\n');
  SUPPORTED_LOCALES.forEach(generateStubsForLanguage);
}

console.log('\n✅ Done! Generated language-specific URL slugs including:');
console.log('   • Basic terms: ufo, sighting, report');
console.log('   • Classifications: sphere, light, disk, triangle, etc.');  
console.log('   • 20+ classification types for SEO-friendly URLs');
console.log('\n📝 Next steps:');
console.log('1. Replace TODO_TRANSLATE_ placeholders with actual translations');
console.log('2. Test URLs like: /beep/es/ovni-esfera-madrid-2025-09-10-ehf3');
console.log('3. Verify slug generation in getAlertSlug() function');
console.log('4. Update slug.ts to use new classification terms if needed');