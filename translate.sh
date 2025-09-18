#!/bin/bash

# UFOBeep Translation Generator
# Generates all language files consistently from English sources

set -e

# Show help if requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "🌍 UFOBeep Translation Generator"
    echo "================================"
    echo ""
    echo "USAGE:"
    echo "  ./translate.sh [options]"
    echo ""
    echo "OPTIONS:"
    echo "  --help, -h           Show this help message"
    echo "  --language=LANG      Generate specific language only (e.g., --language=fr)"
    echo "  --english-only       Generate only English templates (fast, no translation)"
    echo "  --no-translate       Generate all languages with English fallbacks (fast)"
    echo ""
    echo "EXAMPLES:"
    echo "  ./translate.sh                    # Generate all 22 languages (full translation)"
    echo "  ./translate.sh --language=fr      # Generate French only"
    echo "  ./translate.sh --language=de      # Generate German only"
    echo "  ./translate.sh --english-only     # Generate English templates only"
    echo "  ./translate.sh --no-translate     # All languages with English fallbacks"
    echo ""
    echo "SUPPORTED LANGUAGES:"
    echo "  en, es, de, fr, pt, it, ru, ja, zh, ar, nl, pl, cs, tr, ko, hi, sv, da, no, fi, el, he"
    echo ""
    echo "WHAT IT DOES:"
    echo "  1. Reads English ARB file as single source of truth"
    echo "  2. Generates translations via LibreTranslate (if available)"
    echo "  3. Syncs mobile ARB keys to web JSON files automatically"
    echo "  4. Updates Flutter localizations"
    echo ""
    exit 0
fi

echo "🌍 UFOBeep Translation Generator"
echo "================================"

# Check if LibreTranslate is running
if curl -s http://localhost:5000/languages > /dev/null 2>&1; then
    echo "✅ LibreTranslate is running"
else
    echo "⚠️  LibreTranslate not running. Install with: ./scripts/setup-libretranslate.sh"
    echo "   Continuing with English-only templates..."
fi

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Run translation generator with any passed arguments
echo "🔄 Generating translations..."
node scripts/generate-all-translations.js "$@"

# Generate Flutter app localizations
if [ -d "app" ]; then
    echo "📱 Generating Flutter localizations..."
    cd app
    flutter gen-l10n
    cd ..
fi

echo ""
echo "✨ Translation generation complete!"
echo ""
echo "📁 Generated files:"
echo "   • web/public/locales/{lang}/*.json (22 languages)"
echo "   • app/lib/l10n/app_{lang}.arb (22 languages)"
echo "   • app/lib/l10n/app_localizations*.dart (Flutter)"
echo ""
echo "🌐 Language-specific URLs now available:"
echo "   • /beep/es/ovni-esfera-madrid-2025-09-10-ehf3"
echo "   • /beep/de/ufo-sphäre-berlin-2025-09-10-ehf3" 
echo "   • /beep/fr/ovni-sphère-paris-2025-09-10-ehf3"
echo ""
echo "🚀 Ready to deploy!"