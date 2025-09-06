#!/usr/bin/env python3
import json, re, time, sys, urllib.request, urllib.error

import os

LT_CANDIDATES = [
  'http://localhost:5000/translate',
  'http://127.0.0.1:5000/translate',
  'http://host.docker.internal:5000/translate',
]
LT_URL = os.environ.get('LT_URL') or LT_CANDIDATES[0]

TARGETS = [
  'es','de','fr','pt','ru','ja','zh','it','tr','ar','pl','cs','ko','hi','sv','da','no','fi','el','nl','he'
]

ARB_DIR = 'lib/l10n'
SRC = f'{ARB_DIR}/app_en.arb'

PH_RE = re.compile(r"\{([a-zA-Z0-9_]+)\}")

def translate(text, target, source='en'):
    data = json.dumps({
        'q': text,
        'source': source,
        'target': target,
        'format': 'text'
    }).encode('utf-8')
    req = urllib.request.Request(LT_URL, data=data, headers={'Content-Type':'application/json'})
    with urllib.request.urlopen(req, timeout=15) as resp:
        body = resp.read()
        obj = json.loads(body)
        return obj.get('translatedText','')
    
def service_available():
    try:
        req = urllib.request.Request(LT_URL.replace('/translate','/languages'))
        with urllib.request.urlopen(req, timeout=2) as resp:
            return resp.status == 200
    except Exception:
        return False

def pick_available_url():
    global LT_URL
    # If current works, keep it
    if service_available():
        return LT_URL
    # Try fallbacks
    for cand in LT_CANDIDATES:
        try:
            req = urllib.request.Request(cand.replace('/translate','/languages'))
            with urllib.request.urlopen(req, timeout=2) as resp:
                if resp.status == 200:
                    LT_URL = cand
                    return LT_URL
        except Exception:
            continue
    return None

def protect_placeholders(s):
    tokens = []
    def repl(m):
        tokens.append(m.group(1))
        return f'__PH_{len(tokens)-1}__'
    return PH_RE.sub(repl, s), tokens

def restore_placeholders(s, tokens):
    for i, name in enumerate(tokens):
        s = s.replace(f'__PH_{i}__', '{'+name+'}')
    return s

def main():
    with open(SRC, 'r', encoding='utf-8') as f:
        base = json.load(f)
    # Collect keys to translate (skip metadata keys and @@locale)
    base_keys = [k for k in base.keys() if not k.startswith('@') and k != '@@locale']

    # Require LibreTranslate to be available; fail loudly if not.
    if not pick_available_url():
        sys.stderr.write(
            "ERROR: LibreTranslate service is not reachable.\n"
            f"Tried: {', '.join(LT_CANDIDATES)} or LT_URL={os.environ.get('LT_URL') or ''}\n"
            "Please start LibreTranslate (e.g., docker) on port 5000 and retry.\n"
        )
        sys.exit(1)
    use_service = True

    LANGUAGE_MAP = {'no': 'nb'}  # Map unsupported codes to closest available in LibreTranslate
    for lang in TARGETS:
        dst = f'{ARB_DIR}/app_{lang}.arb'
        prev = {}
        try:
            with open(dst, 'r', encoding='utf-8') as pf:
                prev = json.load(pf)
        except Exception:
            prev = {}

        out = dict(prev)  # start from previous to preserve any existing translations
        out['@@locale'] = lang

        added, updated = 0, 0
        for k in base_keys:
            val = base.get(k)
            if not isinstance(val, str):
                # Copy structured metadata (and keep same as base)
                if prev.get(k) != val:
                    updated += 1
                out[k] = val
                continue

            safe, toks = protect_placeholders(val)
            translated = prev.get(k)
            trans_code = LANGUAGE_MAP.get(lang, lang)
            try:
                t = translate(safe, trans_code, source='en')
                if not t:
                    raise RuntimeError('Empty translation response')
                translated = t
            except Exception as e:
                # Fail loudly if the service errors mid-run to avoid partial/incorrect outputs
                sys.stderr.write(f"ERROR: Translation failed for key '{k}' to '{lang}': {e}\n")
                sys.exit(2)

            translated = restore_placeholders(translated, toks)
            if k not in prev:
                added += 1
            elif prev.get(k) != translated:
                updated += 1
            out[k] = translated
            time.sleep(0.02 if use_service else 0)

        # Copy metadata placeholder blocks from base (but NOT @@locale)
        for mk, mv in base.items():
            if mk.startswith('@') and mk != '@@locale':
                out[mk] = mv

        # Atomic write to prevent partial/corrupt files
        tmp_path = dst + '.tmp'
        with open(tmp_path, 'w', encoding='utf-8') as f:
            json.dump(out, f, ensure_ascii=False, indent=2)
        os.replace(tmp_path, dst)
        print(f'Wrote {dst} (+{added} added, ~{updated} updated)')

if __name__ == '__main__':
    main()
