#!/usr/bin/env python3
"""
Force-set time-ago strings in all ARBs to safe, short forms with correct ICU placeholders.
This prevents placeholder mangling from MT and keeps UI consistent until hand-tuned per language.
"""
import json, glob

ARB_DIR = 'lib/l10n'

def main():
    paths = sorted(glob.glob(f'{ARB_DIR}/app_*.arb'))
    for p in paths:
        with open(p, 'r', encoding='utf-8') as f:
            data = json.load(f)
        # Ensure placeholders exist and are correct; keep short forms for now
        data['timeJustNow'] = data.get('timeJustNow', 'Just now')
        data['timeDaysAgo'] = '{count}d ago'
        data['timeHoursAgo'] = '{count}h ago'
        data['timeMinutesAgo'] = '{count}m ago'
        # Metadata blocks for placeholders (keep or add)
        data['@timeDaysAgo'] = {"placeholders": {"count": {"type": "int", "example": "2"}}}
        data['@timeHoursAgo'] = {"placeholders": {"count": {"type": "int", "example": "5"}}}
        data['@timeMinutesAgo'] = {"placeholders": {"count": {"type": "int", "example": "12"}}}
        with open(p, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print('Updated', p)

if __name__ == '__main__':
    main()

