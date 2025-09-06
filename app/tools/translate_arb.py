#!/usr/bin/env python3
import json, re, time, sys, urllib.request

LT_URL = 'http://localhost:5000/translate'

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
    keys = [k for k in base.keys() if not k.startswith('@') and k != '@@locale']

    for lang in TARGETS:
        out = {}
        out['@@locale'] = lang
        for k in keys:
            val = base.get(k)
            if not isinstance(val, str):
                out[k] = val
                continue
            # Protect placeholders
            safe, toks = protect_placeholders(val)
            try:
                t = translate(safe, lang, source='en')
                if not t:
                    t = val
            except Exception as e:
                t = val
            t = restore_placeholders(t, toks)
            out[k] = t
            time.sleep(0.05)
        # Copy metadata blocks as-is
        for k, v in base.items():
            if k.startswith('@'):
                out[k] = v
        dst = f'{ARB_DIR}/app_{lang}.arb'
        with open(dst, 'w', encoding='utf-8') as f:
            json.dump(out, f, ensure_ascii=False, indent=2)
        print(f'Wrote {dst}')

if __name__ == '__main__':
    main()

