import { NextRequest, NextResponse } from 'next/server'
import { getAlertSlug } from './utils/slug'
import { getSlugTranslations } from './utils/translations'

export async function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname
  
  // Handle short URLs: /abc23 or /abc23/es (using safe chars: no o,0,i,1,l)
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
        if (data.success && data.data?.alert) {
          const alert = data.data.alert
          
          // Get translations for the target language
          const translations = getSlugTranslations(userLocale)
          
          // Use the proper getAlertSlug function with the known shortId and translations
          const longSlug = getAlertSlug(alert, userLocale, translations, shortId)
          
          if (longSlug) {
            // Redirect directly to long slug URL
            const redirectUrl = new URL(`/beep/${userLocale}/${longSlug}`, request.url)
            return NextResponse.redirect(redirectUrl)
          }
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
    '/((?!api|_next/static|_next/image|favicon.ico|beep).*)',
  ]
}