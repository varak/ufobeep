import { redirect } from 'next/navigation'
import { headers } from 'next/headers'
import { generateCleanShortIdFromAlert } from '@/utils/slug'

interface PageParams {
  id: string
}

export default async function ShortBeepRedirect({ params }: { params: PageParams }) {
  const shortId = params.id
  
  // If the short ID contains invalid characters (o,0,i,1,l), it's an old-style URL
  // Try to find the alert anyway
  if (!/^[23456789abcdefghjkmnpqrstuvwxyz]+$/.test(shortId)) {
    // Old-style short ID, search by prefix
    const alert = await findAlertByPrefix(shortId)
    if (alert) {
      const userLocale = detectUserLocale()
      const cleanShortId = generateCleanShortIdFromAlert(alert.id)
      redirect(`/beep/${userLocale}/${cleanShortId}`)
    }
  }
  
  // For clean short IDs, redirect to default locale
  const userLocale = detectUserLocale()
  redirect(`/beep/${userLocale}/${shortId}`)
}

function detectUserLocale(): string {
  const headersList = headers()
  const acceptLanguage = headersList.get('accept-language') || ''
  
  const supportedLocales = ['es', 'de', 'fr', 'pt', 'ru', 'ja', 'zh', 'it', 'ar', 'ko', 'tr', 'hi', 'pl', 'cs', 'nl', 'sv', 'da', 'no', 'fi', 'el', 'he']
  
  const browserLanguages = acceptLanguage
    .split(',')
    .map(lang => lang.split(';')[0].split('-')[0].trim().toLowerCase())
    .filter(lang => lang.length === 2)
  
  for (const browserLang of browserLanguages) {
    if (supportedLocales.includes(browserLang)) {
      return browserLang
    }
  }
  
  return 'en'
}

async function findAlertByPrefix(shortId: string): Promise<any | null> {
  try {
    const limit = 100
    let offset = 0
    
    for (let page = 0; page < 5; page++) { // Search first 500 alerts
      const baseUrl = process.env.NEXT_PUBLIC_SITE_BASE_URL || 'https://ufobeep.com'
      const res = await fetch(`${baseUrl}/api/alerts?limit=${limit}&offset=${offset}&verified_only=false`, { cache: 'no-store' })
      if (!res.ok) break
      
      const data = await res.json()
      const alerts = data?.data?.alerts || []
      
      const foundAlert = alerts.find((alert: any) => alert.id?.startsWith(shortId))
      if (foundAlert) return foundAlert
      
      if (alerts.length < limit) break
      offset += limit
    }
    
    return null
  } catch (error) {
    console.error('Error finding alert by prefix:', error)
    return null
  }
}