'use client'

import { notFound } from 'next/navigation'
import { useEffect, useState } from 'react'
import { useParams, useSearchParams } from 'next/navigation'
import { generateCleanShortIdFromAlert } from '@/utils/slug'
import { useClientTranslations } from '@/hooks/useClientTranslations'
import AlertHero from '@/components/alert-detail/AlertHero'
import AlertDetails from '@/components/alert-detail/AlertDetails'
import EnrichmentData from '@/components/alert-detail/EnrichmentData'

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
  media_files?: Array<{
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

function getClassifiedTitle(alert: Alert, t: any): string {
  // For MUFON reports, use classification-based title
  if (alert.reporter_username === 'MUFON' && alert.enrichment?.classification?.type) {
    const classificationType = alert.enrichment.classification.type.toLowerCase()
    const classificationName = t(`mufon.classifications.${classificationType}`, classificationType)
    return t('mufon.titleFormat', { classification: classificationName })
  }
  
  // For NUFORC reports (future)
  if (alert.reporter_username === 'NUFORC' && alert.enrichment?.classification?.type) {
    const classificationType = alert.enrichment.classification.type.toLowerCase()
    const classificationName = t(`nuforc.classifications.${classificationType}`, classificationType)
    return t('nuforc.titleFormat', { classification: classificationName })
  }
  
  // For UFOBeep reports, use original title
  return alert.title || t('ufobeep.reportType')
}

function getEnrichedLocation(alert: Alert, t: any): string {
  // Try enrichment geocoding first
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

export default function AlertDetailPage() {
  const params = useParams()
  const searchParams = useSearchParams()
  const [alert, setAlert] = useState<Alert | null>(null)
  const [loading, setLoading] = useState(true)
  const locale = (params?.locale as string) || 'en'
  const { t } = useClientTranslations('beep-detail', locale)
  
  // Get openImage parameter for direct image linking
  const openImageParam = searchParams.get('openImage')
  const openImageIndex = openImageParam ? parseInt(openImageParam, 10) : undefined
  
  useEffect(() => {
    async function fetchAlert() {
      try {
        const slug = params?.slug as string[]
        if (!slug) return
        
        const fullSlug = slug.join('/')
        // Extract the last part which should be the short ID
        const slugParts = fullSlug.split('-')
        const shortId = slugParts[slugParts.length - 1]
        
        // Search through alerts to find one that generates the same short ID
        let found = false
        let offset = 0
        const limit = 100
        let targetAlert = null
        
        while (!found && offset < 500) { // Search up to 500 alerts
          const res = await fetch(`/api/beep?limit=${limit}&offset=${offset}&verified_only=false`)
          if (!res.ok) break
          
          const data = await res.json()
          if (data.success && (data.data?.beeps || data.data?.alerts)) {
            // Support both beeps and alerts for backend compatibility
            const beepsList = data.data?.beeps || data.data?.alerts || []
            
            // Find beep whose ID generates the same clean short ID
            const matchingBeep = beepsList.find((b: any) => 
              generateCleanShortIdFromAlert(b.id) === shortId
            )
            
            if (matchingBeep) {
              targetAlert = matchingBeep
              found = true
              break
            }
            
            // If we got fewer beeps than the limit, we've reached the end
            if (beepsList.length < limit) break
            offset += limit
          } else {
            break
          }
        }
        
        if (targetAlert) {
          // Enhance the alert with classified title and enriched location
          const enhancedAlert = {
            ...targetAlert,
            title: getClassifiedTitle(targetAlert, t),
            location: {
              latitude: targetAlert.location?.latitude || 0,
              longitude: targetAlert.location?.longitude || 0,
              name: getEnrichedLocation(targetAlert, t)
            }
          }
          setAlert(enhancedAlert)
        }
      } catch (error) {
        console.error('Error fetching alert:', error)
        setAlert(null)
      } finally {
        setLoading(false)
      }
    }
    
    fetchAlert()
  }, [params, t])
  
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

  return (
    <main className="min-h-screen py-8 px-4 md:px-8">
      <div className="max-w-4xl mx-auto">
        <div className="mb-8">
          <a 
            href={`/beep/${locale}`}
            className="text-brand-primary hover:text-brand-primary-light transition-colors mb-4 inline-block"
          >
            {t('backToBeeps')}
          </a>
        </div>
        
        {/* Hero Section with Media Gallery */}
        <AlertHero alert={alert} openImageIndex={openImageIndex} />
        
        {/* Details Section */}
        <AlertDetails alert={alert} locale={locale} />
        
        {/* Enrichment Data (if available) */}
        {alert.enrichment && Object.keys(alert.enrichment).length > 0 && (
          <EnrichmentData alert={alert} />
        )}
      </div>
    </main>
  )
}