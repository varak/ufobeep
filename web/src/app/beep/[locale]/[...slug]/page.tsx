'use client'

import { notFound } from 'next/navigation'
import { useEffect, useState } from 'react'
import { useParams, useSearchParams, useRouter } from 'next/navigation'
import { getAlertSlug } from '@/utils/slug'
import { useClientTranslations } from '@/hooks/useClientTranslations'
import { AlertTitleUtils } from '@/utils/alert-title-utils'
import AlertHero from '@/components/alert-detail/AlertHero'
import AlertDetails from '@/components/alert-detail/AlertDetails'
import EnrichmentData from '@/components/alert-detail/EnrichmentData'
import AlertComments from '@/components/AlertComments'

interface PageParams {
  locale: string
  slug: string[]
}

interface Alert {
  id: string
  title: string
  description: string
  location: {
    name: string
    latitude: number
    longitude: number
  }
  created_at: string
  alert_level: string
  witness_count: number
  total_confirmations: number
  source?: string
  reporter_username?: string
  enrichment?: {
    geocoding?: {
      latitude: number
      longitude: number
      location: string
      display_name: string
    }
    location_raw?: string
    mufon_case_id?: string
    classification?: {
      type: string
      keywords?: string[]
      confidence?: number
    }
    occurred_at?: string
    external_url?: string
    [key: string]: any
  }
  enrichment_data?: {
    [key: string]: any
  }
  media_files: Array<{
    id?: string
    type: string
    url: string
    thumbnail_url: string
    web_url?: string
    preview_url?: string
    filename?: string
  }>
  distance_km?: number
}


function getEnrichedLocation(alert: Alert, t: any): string {
  // Try enrichment_data geocoding first (primary data source)
  if (alert.enrichment_data?.geocoding?.display_name) {
    return alert.enrichment_data.geocoding.display_name
  }

  if (alert.enrichment_data?.geocoding?.location) {
    return alert.enrichment_data.geocoding.location
  }

  // Try enrichment geocoding (fallback)
  if (alert.enrichment?.geocoding?.location) {
    return alert.enrichment.geocoding.location
  }

  // Try raw location from enrichment
  if (alert.enrichment?.location_raw) {
    return alert.enrichment.location_raw
  }

  // Parse location from description for MUFON reports
  if (alert.description && alert.description.includes('📍 Location:')) {
    const locationMatch = alert.description.match(/📍 Location: ([^\n]+)/)
    if (locationMatch && locationMatch[1].trim()) {
      return locationMatch[1].trim()
    }
  }

  // Fall back to basic location name
  if (alert.location?.name && alert.location.name !== 'Unknown Location') {
    return alert.location.name
  }

  return t('unknownLocation')
}

function getClassifiedTitle(alert: Alert, t: any): string {
  return AlertTitleUtils.getContextualTitle(alert)
}

export default function AlertDetailPage() {
  const params = useParams()
  const searchParams = useSearchParams()
  const router = useRouter()
  const [alert, setAlert] = useState<Alert | null>(null)
  const [loading, setLoading] = useState(true)
  // Detect locale with priority: localStorage → URL → browser → 'en'
  const getEffectiveLocale = () => {
    if (typeof window === 'undefined') {
      return (params?.locale as string) || 'en'
    }
    
    // Check localStorage preference first
    const storedLocale = localStorage.getItem('preferred-language')
    if (storedLocale) {
      const validLocales = ['en', 'es', 'de', 'fr', 'pt', 'ru', 'ja', 'zh', 'it', 'ar', 'ko', 'tr', 'hi', 'pl', 'cs', 'nl', 'sv', 'da', 'no', 'fi', 'el', 'he']
      if (validLocales.includes(storedLocale)) return storedLocale
    }
    
    // Fall back to URL locale
    const urlLocale = (params?.locale as string)
    if (urlLocale) return urlLocale
    
    // Final fallback to browser detection
    const browserLang = navigator.language.split('-')[0].toLowerCase()
    const validLocales = ['en', 'es', 'de', 'fr', 'pt', 'ru', 'ja', 'zh', 'it', 'ar', 'ko', 'tr', 'hi', 'pl', 'cs', 'nl', 'sv', 'da', 'no', 'fi', 'el', 'he']
    return validLocales.includes(browserLang) ? browserLang : 'en'
  }
  
  const locale = getEffectiveLocale()
  const { t } = useClientTranslations('common', locale)
  
  // Get openImage parameter for direct image linking
  const openImageParam = searchParams.get('openImage')
  const openImageIndex = openImageParam ? parseInt(openImageParam, 10) : undefined
  
  useEffect(() => {
    async function fetchAlert() {
      try {
        const slug = params?.slug as string[]
        if (!slug || slug.length === 0) {
          // No slug provided - this should be handled by /beep/[locale]/page.tsx
          // But if we get here, redirect to the locale listing page
          return
        }
        
        const fullSlug = slug.join('/')
        // Extract the short ID - either the last part after splitting on '-', or the whole slug if it's just the short ID
        let shortId
        if (fullSlug.includes('-')) {
          const slugParts = fullSlug.split('-')
          shortId = slugParts[slugParts.length - 1]
        } else {
          // If there are no dashes, this is likely just the short ID
          shortId = fullSlug
        }
        
        // Search for beep by short URL in all beeps
        let targetAlert = null
        
        try {
          // Call backend API directly - supports both UUID and short URL automatically
          const res = await fetch(`/api/beep/${shortId}`)
          if (res.ok) {
            const data = await res.json()
            if (data.success && data.data) {
              targetAlert = data.data
            }
          }
        } catch (error) {
          console.error('Error fetching beep by short URL:', error)
        }
        
        if (targetAlert) {
          setAlert(targetAlert)
        }
      } catch (error) {
        console.error('Error fetching alert:', error)
        setAlert(null)
      } finally {
        setLoading(false)
      }
    }
    
    fetchAlert()
  }, [params])

  // Scroll to top when page loads
  useEffect(() => {
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }, [])

  // Client-side redirect to canonical slug URL once we have the alert  
  useEffect(() => {
    if (!alert) return
    
    const currentSlug = params?.slug as string[]
    if (!currentSlug) return
    
    const fullSlug = currentSlug.join('/')
    
    // Create enhanced alert for slug generation without causing re-renders
    const tempEnhancedAlert = {
      ...alert,
      title: AlertTitleUtils.getContextualTitle(alert),
      location: {
        latitude: alert.location?.latitude || 0,
        longitude: alert.location?.longitude || 0,
        name: getEnrichedLocation(alert, t)
      }
    }
    
    // Generate expected slug
    const expectedSlug = getAlertSlug(tempEnhancedAlert, locale, t)
    
    // If current slug doesn't match expected slug, redirect
    if (expectedSlug && expectedSlug !== fullSlug) {
      const qs = searchParams?.toString()
      const url = `/beep/${locale}/${expectedSlug}${qs ? `?${qs}` : ''}`
      router.replace(url)
    }
  }, [alert, params?.slug, router, searchParams, locale])
  
  if (loading) {
    return (
      <main className="min-h-screen py-8 px-4 md:px-8">
        <div className="max-w-4xl mx-auto text-center">
          <div className="text-6xl mb-6">🛸</div>
          <p className="text-text-secondary">{t('loadingDetails')}</p>
        </div>
      </main>
    )
  }

  if (!alert) {
    notFound()
  }

  // Enhance the alert with classified title and enriched location for display
  const enhancedAlert = {
    ...alert,
    title: getClassifiedTitle(alert, t),
    location: {
      latitude: alert.location?.latitude || 0,
      longitude: alert.location?.longitude || 0,
      name: getEnrichedLocation(alert, t)
    },
    media_files: alert.media_files || [],
    enrichment_data: alert.enrichment_data // Ensure enrichment_data is preserved
  }

  return (
    <main className="min-h-screen py-8 px-4 md:px-8">
      <div className="max-w-4xl mx-auto">
        <div className="mb-8">
          <a 
            href={`/beep/${locale}#alert-${enhancedAlert.id}`}
            className="text-brand-primary hover:text-brand-primary-light transition-colors mb-4 inline-block"
          >
            {t('backToBeeps')}
          </a>
        </div>
        
        {/* Hero Section with Media Gallery */}
        <AlertHero alert={enhancedAlert} openImageIndex={openImageIndex} locale={locale} />
        
        {/* Details Section */}
        <AlertDetails alert={enhancedAlert} locale={locale} />
        
        {/* Enrichment Data */}
        <EnrichmentData alert={enhancedAlert} enrichment={enhancedAlert.enrichment_data} />

        {/* Comments Section for all reports */}
        <AlertComments alertId={enhancedAlert.id} locale={locale} />
      </div>
    </main>
  )
}