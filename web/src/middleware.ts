import { NextRequest, NextResponse } from 'next/server'

export function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname
  
  // Handle short URLs: /abc4 or /abc4/es
  const shortMatch = pathname.match(/^\/([a-z0-9]{4})$/)
  const shortWithLangMatch = pathname.match(/^\/([a-z0-9]{4})\/([a-z]{2})$/)
  
  if (shortMatch || shortWithLangMatch) {
    const shortId = shortMatch ? shortMatch[1] : shortWithLangMatch![1]
    let userLocale = 'en'
    
    if (shortWithLangMatch) {
      // Explicit language provided in URL
      userLocale = shortWithLangMatch[2]
    } else {
      // Detect user's preferred language from browser
      const acceptLanguage = request.headers.get('accept-language') || ''
      const supportedLocales = ['es', 'de', 'fr', 'pt', 'ru', 'ja', 'zh', 'it', 'ar', 'ko', 'tr', 'hi', 'pl', 'cs', 'nl', 'sv', 'da', 'no', 'fi', 'el', 'he']
      
      const browserLanguages = acceptLanguage
        .split(',')
        .map(lang => lang.split(';')[0].split('-')[0].trim().toLowerCase())
        .filter(lang => lang.length === 2)
      
      for (const browserLang of browserLanguages) {
        if (supportedLocales.includes(browserLang)) {
          userLocale = browserLang
          break
        }
      }
    }
    
    // Redirect to localized long URL (existing structure)
    const redirectUrl = new URL(`/beep/${userLocale}/${shortId}`, request.url)
    return NextResponse.redirect(redirectUrl)
  }
  
  return NextResponse.next()
}

export const config = {
  matcher: [
    '/((?!api|_next/static|_next/image|favicon.ico|beep).*)',
  ]
}