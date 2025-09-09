import { redirect } from 'next/navigation'
import { headers } from 'next/headers'
import { findAlertBySlug, getAlertSlug } from '@/utils/slug'

interface PageParams {
  id: string
}

export default async function ShortBeepRedirect({ params }: { params: PageParams }) {
  // Find alert by the 4-character ID
  const alert = await findAlertByIdHash(params.id)
  
  if (!alert) {
    // If not found, redirect to main alerts page with language detection
    const userLocale = detectUserLocale()
    redirect(`/beep/${userLocale}`)
  }

  // Generate the full slug and redirect to the proper SEO-friendly URL
  const fullSlug = getAlertSlug({
    id: alert.id,
    title: alert.title,
    created_at: alert.created_at,
    location: alert.location,
    reporter_username: alert.reporter_username,
    description: alert.description,
    source: alert.source
  })

  // Auto-detect user's preferred language and redirect accordingly
  const userLocale = detectUserLocale()
  redirect(`/beep/${userLocale}/${fullSlug}`)
}

function detectUserLocale(): string {
  const headersList = headers()
  const acceptLanguage = headersList.get('accept-language') || ''
  
  // Supported languages from our config
  const supportedLocales = ['es', 'de', 'fr', 'pt', 'ru', 'ja', 'zh', 'it', 'ar', 'ko', 'tr', 'hi', 'pl', 'cs', 'nl', 'sv', 'da', 'no', 'fi', 'el', 'he']
  
  // Parse Accept-Language header (e.g., "es-ES,es;q=0.9,en;q=0.8")
  const browserLanguages = acceptLanguage
    .split(',')
    .map(lang => lang.split(';')[0].split('-')[0].trim().toLowerCase())
    .filter(lang => lang.length === 2)
  
  // Find first supported language
  for (const browserLang of browserLanguages) {
    if (supportedLocales.includes(browserLang)) {
      return browserLang
    }
  }
  
  // Default to English
  return 'en'
}

async function findAlertByIdHash(idHash: string): Promise<any | null> {
  try {
    // Search through alerts to find one with matching ID prefix
    const limit = 100
    const maxSearchPages = 10
    let currentOffset = 0

    for (let page = 0; page < maxSearchPages; page++) {
      const baseUrl = process.env.NEXT_PUBLIC_SITE_BASE_URL || 'https://ufobeep.com'
      const res = await fetch(`${baseUrl}/api/alerts?limit=${limit}&offset=${currentOffset}&verified_only=false`, { cache: 'no-store' })
      if (!res.ok) break
      
      const data = await res.json()
      const alerts = data?.data?.alerts || []
      
      const foundAlert = alerts.find((alert: any) => alert.id?.startsWith(idHash))
      if (foundAlert) return foundAlert
      
      if (alerts.length < limit) break
      currentOffset += limit
    }
    
    return null
  } catch (error) {
    console.error('Error finding alert by ID hash:', error)
    return null
  }
}