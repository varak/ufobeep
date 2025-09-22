import { NextRequest, NextResponse } from 'next/server'
import { getAlertSlug } from './utils/slug'
import { getSlugTranslations } from './utils/translations'

export async function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname
  
  // Handle /beep redirect to user's language
  if (pathname === '/beep') {
    // Detect user's preferred language from browser
    const acceptLanguage = request.headers.get('accept-language') || ''
    const supportedLocales = ['es', 'de', 'fr', 'pt', 'ru', 'ja', 'zh', 'it', 'ar', 'ko', 'tr', 'hi', 'pl', 'cs', 'nl', 'sv', 'da', 'no', 'fi', 'el', 'he']
    let userLocale = 'en'
    
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
    
    const redirectUrl = new URL(`/beep/${userLocale}`, request.url)
    return NextResponse.redirect(redirectUrl)
  }
  
  // Handle short URLs: /abc23 or /abc23/es (using safe chars: no o,0,i,1,l)
  // Exclude legal pages from short URL matching
  if (pathname === '/terms' || pathname === '/privacy' || pathname === '/safety') {
    return NextResponse.next()
  }

  const shortMatch = pathname.match(/^\/([23456789abcdefghjkmnpqrstuvwxyz]{5})$/)
  const shortWithLangMatch = pathname.match(/^\/([23456789abcdefghjkmnpqrstuvwxyz]{5})\/([a-z]{2})$/)
  
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
    
    try {
      // Fetch alert data directly in middleware to generate proper slug
      const apiUrl = `https://ufobeep.com/api/beep/${shortId}`
      const response = await fetch(apiUrl)
      
      if (response.ok) {
        const data = await response.json()
        if (data.success && data.data) {
          const alert = data.data
          
          // Generate the full slug URL
          const title = (alert.title || 'ufo-sighting')
            .toLowerCase()
            .replace(/[^a-z0-9\s]/g, '')
            .replace(/\s+/g, '-')
            .substring(0, 30)
          
          const location = (alert.location?.name || 'unknown')
            .split(',')[0]
            .toLowerCase()
            .replace(/[^a-z0-9\s]/g, '')
            .replace(/\s+/g, '-')
            .substring(0, 20)
          
          const date = new Date(alert.created_at || Date.now()).toISOString().split('T')[0]
          
          const longSlug = `${title}-${location}-${date}-${shortId}`
            .replace(/--+/g, '-')
            .replace(/^-|-$/g, '')
          
          const redirectUrl = new URL(`/beep/${userLocale}/${longSlug}`, request.url)
          return NextResponse.redirect(redirectUrl)
        }
      }
    } catch (error) {
      console.error('Error fetching alert in middleware:', error)
    }
    
    // Fallback: redirect to short slug if API fails
    const redirectUrl = new URL(`/beep/${shortId}/${userLocale}`, request.url)
    return NextResponse.redirect(redirectUrl)
  }
  
  return NextResponse.next()
}

export const config = {
  matcher: [
    '/((?!api|_next/static|_next/image|favicon.ico).*)',
  ]
}