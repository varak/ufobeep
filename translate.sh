#!/bin/bash

# UFOBeep Translation Generator
# Generates all language files consistently from English sources

set -e

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

# Run translation generator
echo "🔄 Generating all translations..."
node scripts/generate-all-translations.js

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