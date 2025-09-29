#!/bin/bash
# Smart Translation - Only translate NEW keys
# Compares English ARB with other languages and translates missing keys only

set -e

echo "🎯 Smart Translation - New Keys Only"
echo "===================================="
echo ""

# Check if LibreTranslate is running
if ! curl -s http://localhost:5000/languages > /dev/null 2>&1; then
    echo "❌ LibreTranslate not running on localhost:5000"
    echo "   Start it first or this won't work"
    exit 1
fi

ENGLISH_ARB="app/lib/l10n/app_en.arb"

if [ ! -f "$ENGLISH_ARB" ]; then
    echo "❌ English ARB not found: $ENGLISH_ARB"
    exit 1
fi

# Language codes
LANGUAGES="es de fr pt it ru ja zh ar nl pl cs tr ko hi sv da no fi el he"

echo "📖 Reading English ARB keys..."
# Extract all keys from English ARB (skip @metadata keys)
ENGLISH_KEYS=$(grep -oP '^\s*"[^@][^"]*"(?=:)' "$ENGLISH_ARB" | tr -d ' "' | sort)

total_new=0

for lang in $LANGUAGES; do
    ARB_FILE="app/lib/l10n/app_${lang}.arb"

    if [ ! -f "$ARB_FILE" ]; then
        echo "⚠️  $lang: ARB file not found, skipping"
        continue
    fi

    # Get existing keys in this language
    EXISTING_KEYS=$(grep -oP '^\s*"[^@][^"]*"(?=:)' "$ARB_FILE" | tr -d ' "' | sort)

    # Find missing keys (in English but not in target language)
    MISSING_KEYS=$(comm -23 <(echo "$ENGLISH_KEYS") <(echo "$EXISTING_KEYS"))

    # Also find keys with identical English values (bad translations)
    BAD_KEYS=""
    for key in $ENGLISH_KEYS; do
        if echo "$EXISTING_KEYS" | grep -q "^$key$"; then
            EN_VAL=$(grep -oP "\"$key\"\s*:\s*\"\K[^\"]*" "$ENGLISH_ARB" | head -1)
            LANG_VAL=$(grep -oP "\"$key\"\s*:\s*\"\K[^\"]*" "$ARB_FILE" | head -1)

            # If values are identical and key is not metadata, it needs re-translation
            if [ "$EN_VAL" == "$LANG_VAL" ] && [[ ! $key == @* ]]; then
                BAD_KEYS="$BAD_KEYS$key"$'\n'
            fi
        fi
    done

    # Combine missing and bad keys
    ALL_KEYS=$(echo -e "$MISSING_KEYS\n$BAD_KEYS" | grep -v "^$" | sort -u)

    if [ -z "$ALL_KEYS" ]; then
        echo "✅ $lang: No new or bad translations"
        continue
    fi

    count=$(echo "$ALL_KEYS" | wc -l)
    total_new=$((total_new + count))
    echo "🔄 $lang: Found $count keys to translate (new or bad)"

    MISSING_KEYS="$ALL_KEYS"

    # Translate each missing key
    for key in $MISSING_KEYS; do
        # Get English value for this key
        EN_VALUE=$(grep -oP "\"$key\"\s*:\s*\"\K[^\"]*" "$ENGLISH_ARB" | head -1)

        if [ -z "$EN_VALUE" ]; then
            echo "   ⚠️  Skipping $key (no value found)"
            continue
        fi

        # Skip metadata keys
        if [[ $key == @* ]]; then
            continue
        fi

        echo "   🔄 Translating \"$key\": \"$EN_VALUE\" → $lang..."

        # Translate via LibreTranslate
        TRANSLATED=$(curl -s -X POST http://localhost:5000/translate \
            -H "Content-Type: application/json" \
            -d "{\"q\":\"$EN_VALUE\",\"source\":\"en\",\"target\":\"$lang\",\"format\":\"text\"}" \
            | jq -r '.translatedText' 2>/dev/null || echo "$EN_VALUE")

        if [ -z "$TRANSLATED" ] || [ "$TRANSLATED" == "null" ]; then
            echo "   ⚠️  Translation failed, using English fallback"
            TRANSLATED="$EN_VALUE"
        fi

        # Check if key already exists (bad translation) or is new
        if grep -q "\"$key\":" "$ARB_FILE"; then
            # Update existing key
            sed -i "s|\"$key\": \".*\"|\"$key\": \"$TRANSLATED\"|" "$ARB_FILE"
        else
            # Add new key to ARB file (before the last closing brace)
            head -n -1 "$ARB_FILE" > "${ARB_FILE}.tmp"
            echo "  \"$key\": \"$TRANSLATED\"," >> "${ARB_FILE}.tmp"
            echo "}" >> "${ARB_FILE}.tmp"
            mv "${ARB_FILE}.tmp" "$ARB_FILE"
        fi

        echo "   ✅ \"$key\": \"$TRANSLATED\""
    done
done

echo ""
echo "📊 Summary: Translated $total_new new keys across all languages"
echo ""

if [ $total_new -gt 0 ]; then
    echo "🔧 Running placeholder fix..."
    node fix-placeholders.js

    echo ""
    echo "📱 Generating Flutter localizations..."
    cd app
    flutter gen-l10n
    cd ..

    echo ""
    echo "✨ Done! New translations added."
else
    echo "✨ All languages are up to date!"
fi