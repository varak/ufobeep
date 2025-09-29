#!/bin/bash

# UFOBeep Translation Pipeline
# Generates translations with LibreTranslate + Azure corrections for high quality

set -e

echo "🌍 UFOBeep High-Quality Translation Pipeline"
echo "============================================"
echo ""

# Check for --fix-only flag
if [[ "$1" == "--fix-only" ]]; then
  echo "📝 Step 1: Skipping LibreTranslate (--fix-only mode)"
  echo "   Using existing translation files for Azure corrections"
elif [ ! -f "app/lib/l10n/app_de.arb" ] || [ ! -f "app/lib/l10n/app_es.arb" ]; then
  echo "📝 Step 1: Generating base translations with LibreTranslate..."
  ./translate.sh
else
  echo "📝 Step 1: Using existing LibreTranslate files (found app_de.arb, app_es.arb)"
  echo "   💡 Use --fix-only to skip this check, or delete app/lib/l10n/app_*.arb to regenerate"
fi

# Step 2: Fix bad translations with Azure Translator
echo ""
echo "🔧 Step 2: Correcting bad translations with Azure Translator..."
node fix-bad-translations.js

# Step 3: Fix translated placeholder names (critical final cleanup)
echo ""
echo "🔧 Step 3: Fixing translated placeholder names..."
node fix-placeholders.js

# Step 4: Generate Flutter localizations
echo ""
echo "📱 Step 4: Generating Flutter localizations..."
cd app
flutter gen-l10n
cd ..

echo ""
echo "✨ High-quality translation pipeline complete!"
echo ""
echo "🎉 Ready for Google Play international release!"
echo "   • 22 languages with LibreTranslate base + Azure corrections"
echo "   • Fixed problematic translations like 'Skip user information'"
echo "   • Professional quality for international users"