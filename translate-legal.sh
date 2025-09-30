#!/bin/bash
# One-time legal document translation
# Creates translated versions of Privacy Policy and Terms of Service

set -e

echo "📜 Legal Document Translation"
echo "============================="

# Check LibreTranslate
if ! curl -s http://localhost:5000/languages > /dev/null 2>&1; then
    echo "❌ LibreTranslate not running on localhost:5000"
    exit 1
fi

LEGAL_DIR="web/src/app"
LANGUAGES="es de fr pt it ru ja zh ar nl pl cs tr ko hi sv da no fi el he"

# Function to translate markdown file
translate_legal_doc() {
    local source_file=$1
    local doc_name=$2
    
    echo ""
    echo "📄 Translating $doc_name..."
    
    for lang in $LANGUAGES; do
        echo "  🔄 $lang..."
        
        # Read source file
        SOURCE_TEXT=$(cat "$source_file")
        
        # Translate via LibreTranslate
        TRANSLATED=$(curl -s -X POST http://localhost:5000/translate \
            -H "Content-Type: application/json" \
            -d "{\"q\":\"$SOURCE_TEXT\",\"source\":\"en\",\"target\":\"$lang\",\"format\":\"text\"}" \
            | jq -r '.translatedText')
        
        # Create language-specific directory
        mkdir -p "$LEGAL_DIR/$doc_name/$lang"
        
        # Save translated file with disclaimer
        cat > "$LEGAL_DIR/$doc_name/$lang/page.tsx" << DOCEOF
// Auto-translated from English
// In case of discrepancies, the English version is legally binding

$TRANSLATED

---
*This is a machine translation. The [English version](/en/$doc_name) is the official legal document.*
DOCEOF
        
        echo "    ✅ $lang saved"
    done
}

# Translate privacy policy
if [ -f "$LEGAL_DIR/privacy/page.tsx" ]; then
    translate_legal_doc "$LEGAL_DIR/privacy/page.tsx" "privacy"
fi

# Translate terms of service  
if [ -f "$LEGAL_DIR/terms/page.tsx" ]; then
    translate_legal_doc "$LEGAL_DIR/terms/page.tsx" "terms"
fi

echo ""
echo "✨ Legal translations complete!"
echo ""
echo "📁 Created:"
echo "   web/src/app/(legal)/privacy/{lang}/page.tsx (21 languages)"
echo "   web/src/app/(legal)/terms/{lang}/page.tsx (21 languages)"
