#!/usr/bin/env python3
"""
Fix ICU format errors in Flutter ARB translation files.
This script fixes placeholder names, syntax errors, and malformed placeholders.
"""

import os
import re
import json
import glob

# Mapping of placeholder names based on English ARB file analysis
PLACEHOLDER_MAPPINGS = {
    # Distance placeholders
    '{απόσταση}': '{distance}',
    '{etäisyys}': '{distance}',
    '{거리}': '{distance}',
    '{odległość}': '{distance}',
    '{distância}': '{distance}',
    '{distance}': '{distance}',  # Already correct
    
    # Bearing/Direction placeholders
    '{ουσία}': '{bearing}',
    '{łożysko}': '{bearing}',
    '{包含}': '{bearing}',
    '{bearing}': '{bearing}',  # Already correct
    '{ложisko}': '{bearing}',
    
    # Username placeholders
    '{όνομα χρήστη}': '{username}',
    '{käyttäjätunnus}': '{username}',
    '{nom d\'utilisateur}': '{username}',
    '{nazwa użytkownika}': '{username}',
    '{nome de utilizador}': '{username}',
    '{ användarnamn}': '{username}',  # Extra space
    '{username}': '{username}',  # Already correct
    '{όνομα χρήστη}': '{username}',
    '{用户名}': '{username}',
    '{имя пользователя}': '{username}',
    '{nom d\'utilisateur}': '{username}',
    
    # Time ago placeholders
    '{time Ago}': '{timeAgo}',
    '{Ago': '{timeAgo}',  # Missing closing brace
    '{ώρα} Πριν}': '{timeAgo}',  # Extra closing brace
    '{время} Аго': '{timeAgo}',
    '{time アゴ}': '{timeAgo}',
    '{hora Ago}': '{timeAgo}',
    '{tid Ago}': '{timeAgo}',
    '{timeAgo}': '{timeAgo}',  # Already correct
    
    # Direction placeholders
    '{κατεύθυνση}': '{direction}',
    '{方向}': '{direction}',
    '{направление}': '{direction}',
    '{direção}': '{direction}',
    '{směr}': '{direction}',
    '{direction}': '{direction}',  # Already correct
    '{Richtung anzeigen}': '{direction}',  # German with spaces
    
    # Count/Number placeholders
    '{καταμέτρηση}': '{count}',
    '{αριθμός}': '{count}',
    '{счет}': '{count}',
    '{計算}': '{count}',
    '{数}': '{count}',
    '{計数}': '{count}',
    '{tæller}': '{count}',
    '{räknat}': '{count}',
    '{räkna}': '{count}',
    '{počet}': '{count}',
    '{liczyć}': '{count}',
    '{count}': '{count}',  # Already correct
    
    # Speed placeholders
    '{ταχύτητα}': '{speed}',
    '{скорость}': '{speed}',
    '{velocidade}': '{speed}',
    '{vitesse}': '{speed}',
    '{prędkość}': '{speed}',
    '{nopeus}': '{speed}',
    '{hastighed}': '{speed}',
    '{speed}': '{speed}',  # Already correct
    '{ speed}': '{speed}',  # Extra space
    '{Speed}': '{speed}',   # Capital
    
    # Unit placeholders
    '{μονάδα}': '{unit}',
    '{единица}': '{unit}',
    '{unidade}': '{unit}',
    '{unité}': '{unit}',
    '{jednostka}': '{unit}',
    '{yksikkö}': '{unit}',
    '{enhed}': '{unit}',
    '{enhet}': '{unit}',
    '{unit}': '{unit}',  # Already correct
    
    # Percent placeholders
    '{%}': '{percent}',
    '{نسبة مئوية}': '{percent}',
    '{percent}': '{percent}',  # Already correct
    
    # Case number placeholders
    '{caseNumber}': '{caseNumber}',  # Already correct
    '{ caseNumber}': '{caseNumber}',  # Extra space
    '{numer sprawy}': '{caseNumber}',
    '{número do Caso}': '{caseNumber}',
    '{número do caso}': '{caseNumber}',
    '{numéro de cas}': '{caseNumber}',
    '{Case Number}': '{caseNumber}',
    '{ΥπόθεσηNumber}': '{caseNumber}',
    
    # Classification placeholders
    '{ταξινόμηση}': '{classification}',
    '{классификация}': '{classification}',
    '{classificação}': '{classification}',
    '{classification}': '{classification}',  # Already correct
    '{分類}': '{classification}',
    '{分类}': '{classification}',
    
    # Location name placeholders
    '{locationName}': '{locationName}',  # Already correct
    '{locatie} Naam}': '{locationName}',  # Dutch with extra brace
    '{位置} 名称]': '{locationName}',  # Chinese with wrong bracket
    '{τόπος} Όνομα}': '{locationName}',  # Greek with extra brace
    '{lokalizacja Nazwa}': '{locationName}',  # Polish
    '{localização Nome}': '{locationName}',  # Portuguese
    '{emplacement Nom}': '{locationName}',  # French
    '{sijainti Nimi}': '{locationName}',  # Finnish
    '{placering Navn}': '{locationName}',  # Danish
    '{umístění Název}': '{locationName}',  # Czech
    
    # Witness text placeholders
    '{witnessText}': '{witnessText}',  # Already correct
    '{getuigentekst}': '{witnessText}',  # Dutch
    '{证人文本}': '{witnessText}',  # Chinese
    '{Αυτόπτης μάρτυραςText}': '{witnessText}',  # Greek
    '{świadek Tekst}': '{witnessText}',  # Polish
    '{testemunhoTexto}': '{witnessText}',  # Portuguese
    '{texte du témoin}': '{witnessText}',  # French
    '{Todistajateksti}': '{witnessText}',  # Finnish
    '{ScriessText}': '{witnessText}',  # Danish (possibly garbled)
    '{witnesText}': '{witnessText}',  # Czech (missing s)
    
    # Current/total page placeholders
    '{currentPage}': '{currentPage}',  # Already correct
    '{current Page}': '{currentPage}',  # Space
    '{aktualna Page}': '{currentPage}',  # Polish
    '{corrente Página}': '{currentPage}',  # Portuguese
    '{nuværende Side}': '{currentPage}',  # Danish
    '{nykyinen Sivu}': '{currentPage}',  # Finnish
    '{aktuální Page}': '{currentPage}',  # Czech
    '{τρέχων Σελίδα}': '{currentPage}',  # Greek
    '{current Seite}': '{currentPage}',  # German
    '{current 페이지}': '{currentPage}',  # Korean
    '{当前 页面}': '{currentPage}',  # Chinese
    '{текущая}': '{currentPage}',  # Russian
    '{current}': '{currentPage}',  # Shortened
    
    '{totalPages}': '{totalPages}',  # Already correct
    '{totalsider}': '{totalPages}',  # Danish
    '{totalCoup}': '{totalPages}',  # French (garbled)
    '{σύνολο σελίδων}': '{totalPages}',  # Greek
    
    '{totalCount}': '{totalCount}',  # Already correct
    '{TotalCount}': '{totalCount}',  # Capital
    '{totaltal}': '{totalCount}',  # Danish
    '{toplam Ülke}': '{totalCount}',  # Turkish (garbled)
    '{총 금액}': '{totalCount}',  # Korean (garbled)
    
    # Other common fixes
    '{ }': '{ }',  # Preserve intentional spaces
    '{{': '{',     # Double opening braces
    '}}': '}',     # Double closing braces
}

def fix_malformed_placeholders(content):
    """Fix various malformed placeholder patterns."""
    
    # Fix patterns with extra closing braces
    content = re.sub(r'\{([^}]+)\}\s*\}', r'{\1}', content)
    
    # Fix patterns with missing closing braces at end of line
    content = re.sub(r'\{([^}]+)$', r'{\1}', content, flags=re.MULTILINE)
    
    # Fix patterns with spaces inside braces but keep the structure
    # Pattern: {word word} -> {wordWord} or {word_word}
    def fix_spaced_placeholders(match):
        placeholder = match.group(1)
        # Convert spaces to empty string or underscore based on context
        if ' ' in placeholder:
            # For common patterns, use camelCase
            words = placeholder.split()
            if len(words) == 2:
                return '{' + words[0] + words[1].capitalize() + '}'
            else:
                # Use underscore for more complex cases
                return '{' + '_'.join(words) + '}'
        return match.group(0)
    
    # Apply spaced placeholder fixes
    content = re.sub(r'\{([^}]+)\}', fix_spaced_placeholders, content)
    
    return content

def fix_arb_file(file_path):
    """Fix ICU format errors in a single ARB file."""
    print(f"Processing: {file_path}")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Apply all placeholder mappings
    for old_placeholder, new_placeholder in PLACEHOLDER_MAPPINGS.items():
        if old_placeholder in content:
            content = content.replace(old_placeholder, new_placeholder)
            print(f"  Fixed: {old_placeholder} -> {new_placeholder}")
    
    # Fix malformed placeholders
    content = fix_malformed_placeholders(content)
    
    # Additional pattern fixes for specific cases found in grep results
    
    # Fix Chinese subtitle formatting issues
    content = re.sub(r'\{\\\\fn黑体.*?\}', '{count}', content)
    
    # Fix Hebrew colon issue
    content = re.sub(r'\{ס\}', '{bearing}', content)
    
    # Fix Arabic image count
    content = re.sub(r'\{الصور \}', '{count}', content)
    
    # Fix specific malformed patterns from grep results
    replacements = [
        ('Pagina} van', 'currentPage} of'),
        ('Page} di', 'currentPage} of'),
        ('Page} of', 'currentPage} of'),
        ('Página} de', 'currentPage} of'),
        ('Sivu} of', 'currentPage} of'),
        ('Seite} von', 'currentPage} of'),
        ('페이지} 의', 'currentPage} of'),
        ('Страница} {totalPages}', 'currentPage} of {totalPages}'),
        ('のページ}', 'currentPage}'),
        ('Namn }', 'locationName}'),
        ('Ad}', 'locationName}'),
        ('Navn}', 'locationName}'),
        ('Nome}', 'locationName}'),
        ('Nom}', 'locationName}'),
        ('Nimi}', 'locationName}'),
        ('Název}', 'locationName}'),
        ('Όνομα}', 'locationName}'),
        ('नाम', 'locationName}'),
    ]
    
    for old, new in replacements:
        content = content.replace(old, new)
    
    # Save the file if changes were made
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  ✅ Fixed ICU errors in {os.path.basename(file_path)}")
        return True
    else:
        print(f"  ✓ No changes needed for {os.path.basename(file_path)}")
        return False

def main():
    """Fix ICU format errors in all ARB files."""
    l10n_dir = '/home/mike/D/ufobeep/app/lib/l10n'
    arb_files = glob.glob(os.path.join(l10n_dir, '*.arb'))
    
    if not arb_files:
        print(f"No ARB files found in {l10n_dir}")
        return
    
    print(f"Found {len(arb_files)} ARB files to process")
    
    fixed_count = 0
    for arb_file in sorted(arb_files):
        if fix_arb_file(arb_file):
            fixed_count += 1
    
    print(f"\n✅ Fixed ICU errors in {fixed_count} out of {len(arb_files)} ARB files")
    
    if fixed_count > 0:
        print("\n🔧 Next steps:")
        print("1. Test Flutter build: cd /home/mike/D/ufobeep/app && flutter build apk")
        print("2. Check for remaining ICU errors")
        print("3. Commit the fixes if build succeeds")

if __name__ == '__main__':
    main()