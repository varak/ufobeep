#!/bin/bash
echo "🧹 Cleaning up old MUFON files with hardcoded credentials..."

# List of main files to keep (production scripts)
KEEP_FILES=(
    "mufon_simple_extraction.py"
    "mufon_proper_extraction.py" 
    "production_mufon_login.py"
    "import_mufon_fixed.py"
    "ufo_classifier.py"
)

# Files to keep for reference/working data
KEEP_DATA=(
    "mufon_simple_2025_01_26.json"
    "mufon_simple_2025_01_25.json"
    "storage_state.json"
)

cd /home/ufobeep/ufobeep/mufon_clicker

echo "📊 Current file count: $(ls -la *.py 2>/dev/null | wc -l)"
echo "🔒 Files with hardcoded credentials: $(find . -name '*.py' -exec grep -l 'ufobeep123pass\|varak' {} \; 2>/dev/null | wc -l)"

# Remove files with hardcoded credentials except the ones we want to keep
for file in *.py; do
    if [[ -f "$file" ]]; then
        # Check if file should be kept
        keep_file=false
        for keep in "${KEEP_FILES[@]}"; do
            if [[ "$file" == "$keep" ]]; then
                keep_file=true
                break
            fi
        done
        
        if [[ "$keep_file" == false ]]; then
            # Check if file has hardcoded credentials
            if grep -q "ufobeep123pass\|varak" "$file" 2>/dev/null; then
                echo "🗑️  Removing: $file"
                rm "$file"
            fi
        else
            echo "✅ Keeping: $file"
        fi
    fi
done

# Clean up old JSON files except recent working ones
for file in *.json; do
    if [[ -f "$file" ]]; then
        keep_file=false
        for keep in "${KEEP_DATA[@]}"; do
            if [[ "$file" == "$keep" ]]; then
                keep_file=true
                break
            fi
        done
        
        if [[ "$keep_file" == false ]]; then
            echo "🗑️  Removing old data: $file"
            rm "$file"
        else
            echo "✅ Keeping data: $file"
        fi
    fi
done

echo "✨ Cleanup complete!"
echo "📊 Remaining Python files: $(ls -la *.py 2>/dev/null | wc -l)"
echo "🔒 Files with credentials: $(find . -name '*.py' -exec grep -l 'ufobeep123pass\|varak' {} \; 2>/dev/null | wc -l)"
