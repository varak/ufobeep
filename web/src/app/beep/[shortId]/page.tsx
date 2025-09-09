'use client'

import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import { generateCleanShortIdFromAlert, getAlertSlug } from '@/utils/slug'
import { useClientTranslations } from '@/hooks/useClientTranslations'

interface Alert {
  id: string
  title: string
  description: string
  location: {
    latitude: number
    longitude: number
    name: string
  }
  created_at: string
  reporter_username?: string
  source?: string
  enrichment?: {
    classification?: {
      type: string
      confidence?: number
    }
    geocoding?: {
      latitude: number
      longitude: number
      location: string
      display_name: string
    }
    location_raw?: string
    mufon_case_id?: string
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
  // For MUFON reports, use classification-based title only if confidence is high enough
  if (alert.reporter_username === 'MUFON' && 
      alert.enrichment?.classification?.type && 
      (alert.enrichment?.classification?.confidence || 0) >= 0.75) {
    const classificationType = alert.enrichment.classification.type.toLowerCase()
    const classificationName = t(`mufon.classifications.${classificationType}`, classificationType)
    return t('mufon.titleFormat', { classification: classificationName })
  }
  
  // For NUFORC reports (future)
  if (alert.reporter_username === 'NUFORC' && 
      alert.enrichment?.classification?.type &&
      (alert.enrichment?.classification?.confidence || 0) >= 0.75) {
    const classificationType = alert.enrichment.classification.type.toLowerCase()
    const classificationName = t(`nuforc.classifications.${classificationType}`, classificationType)
    return t('nuforc.titleFormat', { classification: classificationName })
  }
  
  // For MUFON/NUFORC without high confidence classification, use generic title
  if (alert.reporter_username === 'MUFON') {
    return t('mufon.genericTitle', 'MUFON Sighting Report')
  }
  if (alert.reporter_username === 'NUFORC') {
    return t('nuforc.genericTitle', 'NUFORC Sighting Report')
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
    const locationMatch = alert.description.match(/📍 Location: ([^\\n]+)/)
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

export default function ShortUrlRedirect() {
  const params = useParams()
  const router = useRouter()
  const [loading, setLoading] = useState(true)
  const shortId = params?.shortId as string
  
  // Detect user's preferred language
  const userLang = typeof window !== 'undefined' 
    ? (navigator.language || 'en').split('-')[0] 
    : 'en'
  const locale = ['en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'ja', 'ko', 'zh'].includes(userLang) 
    ? userLang 
    : 'en'
    
  const { t } = useClientTranslations('beep-detail', locale)

  useEffect(() => {
    async function findAndRedirect() {
      if (!shortId) return

      try {
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
            },
            media_files: targetAlert.media_files || []
          }

          // Generate proper slug and redirect
          const properSlug = getAlertSlug(enhancedAlert, locale, t)
          const redirectUrl = `/beep/${locale}/${properSlug}`
          
          // Preserve any query parameters
          const urlParams = new URLSearchParams(window.location.search)
          const queryString = urlParams.toString()
          const finalUrl = queryString ? `${redirectUrl}?${queryString}` : redirectUrl
          
          router.replace(finalUrl)
        } else {
          // Alert not found, redirect to main beep page
          router.replace(`/beep/${locale}`)
        }
      } catch (error) {
        console.error('Error finding alert:', error)
        router.replace(`/beep/${locale}`)
      }
    }
    
    findAndRedirect()
  }, [shortId, router, locale, t])

  // Show loading state
  return (
    <main className="min-h-screen py-8 px-4 md:px-8">
      <div className="max-w-4xl mx-auto text-center">
        <div className="text-6xl mb-6">🛸</div>
        <p className="text-text-secondary">Redirecting to full alert details...</p>
      </div>
    </main>
  )
}