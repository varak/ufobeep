// Simple client for LibreTranslate-compatible services
// Configure with NEXT_PUBLIC_TRANSLATE_URL (defaults to http://localhost:5000)

export interface TranslateOptions {
  source?: string
  format?: 'text' | 'html'
}

export async function translateText(q: string, target: string, opts: TranslateOptions = {}) {
  const base = process.env.NEXT_PUBLIC_TRANSLATE_URL || 'http://localhost:5000'
  const url = `${base.replace(/\/$/, '')}/translate`
  const body = {
    q,
    source: opts.source || 'auto',
    target,
    format: opts.format || 'text',
  }
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
  if (!res.ok) {
    throw new Error(`Translate failed: ${res.status}`)
  }
  const data = await res.json()
  // LibreTranslate returns { translatedText }
  return (data?.translatedText as string) || ''
}

