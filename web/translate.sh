#!/bin/bash

# UFOBeep Translation Generator
# Generates translations for all languages from English master files

set -e

echo "🌐 UFOBeep Translation Generator"
echo "================================="

# Directories
EN_DIR="./public/locales/en"
LOCALES_DIR="./public/locales"

# Check if English directory exists
if [ ! -d "$EN_DIR" ]; then
    echo "❌ English locales directory not found: $EN_DIR"
    exit 1
fi

# Languages to translate to (excluding English)
LANGUAGES=(
    "ar" "cs" "da" "de" "el" "es" "fi" "fr" "he" "hi"
    "it" "ja" "ko" "nl" "no" "pl" "pt" "ru" "sv" "tr" "zh"
)

# Translation function using node-translate-api (would need to be installed)
# For now, we'll copy English keys and mark them for manual translation
translate_file() {
    local source_file="$1"
    local target_file="$2"
    local lang="$3"

    echo "  📝 Processing $(basename "$source_file")..."

    # For now, copy the English file and mark keys for translation
    # In a real implementation, you would use a translation service here
    cp "$source_file" "$target_file"

    # Mark as needing translation (placeholder approach)
    # sed -i "s/: \"/: \"[$lang] /g" "$target_file"

    echo "  ✅ Created $(basename "$target_file")"
}

# Generate translations for each language
for lang in "${LANGUAGES[@]}"; do
    echo ""
    echo "🔤 Generating translations for: $lang"

    # Create language directory if it doesn't exist
    mkdir -p "$LOCALES_DIR/$lang"

    # Process each JSON file in the English directory
    for en_file in "$EN_DIR"/*.json; do
        if [ -f "$en_file" ]; then
            filename=$(basename "$en_file")
            target_file="$LOCALES_DIR/$lang/$filename"

            translate_file "$en_file" "$target_file" "$lang"
        fi
    done
done

echo ""
echo "🎉 Translation generation complete!"
echo "📋 Summary:"
echo "   Languages: ${#LANGUAGES[@]}"
echo "   Files per language: $(find "$EN_DIR" -name "*.json" | wc -l)"
echo ""
echo "ℹ️  Note: Currently copying English text as placeholders."
echo "   For production, integrate with a translation service like:"
echo "   - Google Translate API"
echo "   - DeepL API"
echo "   - Azure Translator"
echo ""
echo "🚀 Ready to build and deploy!"