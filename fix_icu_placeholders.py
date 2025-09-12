#!/usr/bin/env python3
"""
Fix ICU placeholder issues in Flutter ARB files.
The problem: Automated translations are translating placeholder names like {distance} -> {απόσταση}
The solution: Keep English placeholder names but translate surrounding text
"""

import json
import os
import re
from pathlib import Path

def fix_arb_file(file_path):
    """Fix ICU placeholder issues in a single ARB file"""
    
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    changes_made = False
    
    # Common problematic patterns and their fixes
    fixes = {
        # alertDistance fixes - should be {distance} not translated versions
        'alertDistance': [
            (r'\{απόσταση\}', '{distance}'),     # Greek
            (r'\{etäisyys\}', '{distance}'),     # Finnish
            (r'\{거리\}', '{distance}'),          # Korean
            (r'\{odległość\}', '{distance}'),    # Polish
            (r'\{distância\}', '{distance}'),    # Portuguese
            (r'\{afstand\}', '{distance}'),      # Dutch/Danish
            (r'\{entfernung\}', '{distance}'),   # German
        ],
        
        # alertDirection fixes - should be {bearing} not translated versions  
        'alertDirection': [
            (r'\{ουσία\}', '{bearing}'),         # Greek
            (r'\{łożysko\}', '{bearing}'),       # Polish  
            (r'\{包含\}', '{bearing}'),           # Chinese
        ],
        
        # reportedBy fixes - should be {username} not translated versions
        'reportedBy': [
            (r'\{όνομα χρήστη\}', '{username}'),           # Greek
            (r'\{käyttäjätunnus\}', '{username}'),         # Finnish
            (r'\{nom d\'utilisateur\}', '{username}'),     # French
            (r'\{nazwa użytkownika\}', '{username}'),      # Polish
            (r'\{nome de utilizador\}', '{username}'),     # Portuguese
            (r'\{ användarnamn\}', '{username}'),          # Swedish
            (r'\{användarnamn\}', '{username}'),           # Swedish alt
        ],
        
        # reportedAt fixes - should be {time} not "time Ago"
        'reportedAt': [
            (r'\{time Ago\}', '{time}'),         # Multiple languages
            (r'\{Ago', '{time}'),                # Incomplete pattern
        ]
    }
    
    # Apply fixes
    for key, patterns in fixes.items():
        if key in data and isinstance(data[key], str):
            original = data[key]
            for pattern, replacement in patterns:
                data[key] = re.sub(pattern, replacement, data[key])
            
            if data[key] != original:
                print(f"  Fixed {key}: '{original}' -> '{data[key]}'")
                changes_made = True
    
    # Additional cleanup for malformed patterns
    for key, value in data.items():
        if isinstance(value, str) and key != '@@locale':
            original = value
            
            # Fix incomplete braces or malformed ICU syntax
            value = re.sub(r'\{[^}]*$', '', value)  # Remove unclosed braces at end
            value = re.sub(r'^[^{]*\}', '', value)   # Remove unmatched closing braces at start
            
            # Remove any remaining translated placeholder names that don't match English
            # Keep only known good placeholder names: distance, bearing, username, time
            good_placeholders = r'\{(distance|bearing|username|time|alertTitle|description)\}'
            
            # Find all placeholder-like patterns
            placeholders = re.findall(r'\{[^}]+\}', value)
            for placeholder in placeholders:
                if not re.match(good_placeholders, placeholder):
                    # Remove problematic placeholders entirely rather than risk more errors
                    value = value.replace(placeholder, '').strip()
                    print(f"  Removed bad placeholder '{placeholder}' from {key}")
            
            if value != original:
                data[key] = value
                changes_made = True
    
    # Write back the fixed data
    if changes_made:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        return True
    
    return False

def main():
    """Fix all ARB files in the Flutter app"""
    arb_dir = Path('/home/mike/D/ufobeep/app/lib/l10n')
    
    if not arb_dir.exists():
        print(f"Error: ARB directory not found: {arb_dir}")
        return
    
    total_fixed = 0
    
    # Process all .arb files except English (which should be correct)
    for arb_file in arb_dir.glob('app_*.arb'):
        if arb_file.name == 'app_en.arb':
            continue  # Skip English source file
            
        print(f"Processing {arb_file.name}...")
        if fix_arb_file(arb_file):
            total_fixed += 1
            print(f"  ✓ Fixed {arb_file.name}")
        else:
            print(f"  - No changes needed for {arb_file.name}")
    
    print(f"\nFixed {total_fixed} ARB files")
    
    if total_fixed > 0:
        print("\nRun 'flutter build apk' to test the fixes")

if __name__ == '__main__':
    main()