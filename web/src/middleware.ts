import { NextRequest, NextResponse } from 'next/server'

export function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname
  
  // Handle short beep URLs like /beep/abc4
  const beepShortMatch = pathname.match(/^\/beep\/([a-z0-9]{4})$/)
  if (beepShortMatch) {
    const shortId = beepShortMatch[1]
    
    // Detect user's preferred language
    const acceptLanguage = request.headers.get('accept-language') || ''
    const supportedLocales = ['es', 'de', 'fr', 'pt', 'ru', 'ja', 'zh', 'it', 'ar', 'ko', 'tr', 'hi', 'pl', 'cs', 'nl', 'sv', 'da', 'no', 'fi', 'el', 'he']
    
    const browserLanguages = acceptLanguage
      .split(',')
      .map(lang => lang.split(';')[0].split('-')[0].trim().toLowerCase())
      .filter(lang => lang.length === 2)
    
    let userLocale = 'en'
    for (const browserLang of browserLanguages) {
      if (supportedLocales.includes(browserLang)) {
        userLocale = browserLang
        break
      }
    }
    
    // Redirect to localized URL
    const redirectUrl = new URL(`/beep/${userLocale}/${shortId}`, request.url)
    return NextResponse.redirect(redirectUrl)
  }
  
  return NextResponse.next()
}

export const config = {
  matcher: [
    '/beep/:path*',
  ]
}