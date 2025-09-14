'use client'

import Link from 'next/link'
import { useEffect, useMemo, useState } from 'react'
import { useRouter, usePathname, useSearchParams } from 'next/navigation'
import AlertHero from './alert-detail/AlertHero'
import AlertDetails from './alert-detail/AlertDetails'
import EnrichmentData from './alert-detail/EnrichmentData'
import AlertComments from './AlertComments'
import { getAlertSlug } from '@/utils/slug'
import { useGeolocation } from '@/utils/geolocation'

interface Alert {
  id: string
  title: string
  description: string
  category: string
  created_at: string
  location: {
    latitude: number
    longitude: number
    name: string
  }
  alert_level: string
  witness_count: number
  total_confirmations: number
  media_files: Array<{
    id: string
    type: string
    url: string
    thumbnail_url: string
    web_url?: string
    preview_url?: string
  }>
  source?: string
  reporter_username?: string
  enrichment?: any
  photo_analysis?: any
  distance_km?: number
}

export default function AlertDetailClient({ params }: { params: { id: string; slug?: string[] } }) {
  const router = useRouter()
  const pathname = usePathname()
  const search = useSearchParams()
  const [alert, setAlert] = useState<Alert | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [translated, setTranslated] = useState<string | null>(null)
  const [translating, setTranslating] = useState(false)
  const { position: userLocation, loading: locationLoading, error: locationError } = useGeolocation()
  const userLang = useMemo(() => {
    if (typeof window === 'undefined') return 'en'
    return (navigator.language || 'en').split('-')[0]
  }, [])

  // Parse openImage URL parameter for auto-opening specific image
  const openImageIndex = useMemo(() => {
    const openImageParam = search.get('openImage')
    if (openImageParam !== null) {
      const index = parseInt(openImageParam, 10)
      return isNaN(index) ? undefined : index
    }
    return undefined
  }, [search])

  useEffect(() => {
    const fetchAlert = async () => {
      try {
        // Search through multiple pages to find the alert (keeps existing behavior)
        let foundAlert: Alert | null = null
        let currentOffset = 0
        const limit = 100
        const maxSearchPages = 10

        for (let page = 0; page < maxSearchPages; page++) {
          let url = `/api/beep?limit=${limit}&offset=${currentOffset}`
          
          // Add user location to request if available
          if (userLocation) {
            url += `&latitude=${userLocation.latitude}&longitude=${userLocation.longitude}`
          }
          
          const response = await fetch(url)
          if (!response.ok) break
          const data = await response.json()
          const alerts: Alert[] = data?.data?.beeps || []
          foundAlert = alerts.find(a => a.id === params.id) || null
          if (foundAlert) break
          if (alerts.length < limit) break
          currentOffset += limit
        }

        if (!foundAlert) {
          setError('Alert not found')
        } else {
          setAlert(foundAlert)
          setTranslated(null)
        }
      } catch (e) {
        setError('Failed to load alert')
      } finally {
        setLoading(false)
      }
    }
    fetchAlert()
  }, [params.id, userLocation])

  // Scroll to top when alert detail page loads (unless opening a specific image)
  useEffect(() => {
    if (!loading && alert && openImageIndex === undefined) {
      window.scrollTo({ top: 0, behavior: 'smooth' })
    }
  }, [loading, alert, openImageIndex])

  // Client-side redirect to canonical slug URL once we have the alert
  useEffect(() => {
    if (!alert) return
    const expectedSlug = getAlertSlug({
      id: alert.id,
      title: alert.title,
      created_at: alert.created_at,
      location: alert.location,
      reporter_username: alert.reporter_username,
      description: alert.description,
      source: alert.source
    })
    const currentSlug = Array.isArray(params.slug) && params.slug.length > 0 ? params.slug[0] : ''
    if (expectedSlug && expectedSlug !== currentSlug) {
      const qs = search?.toString()
      const url = `/beep/${alert.id}/${expectedSlug}${qs ? `?${qs}` : ''}`
      router.replace(url)
    }
  }, [alert, params.slug, router, search])

  const handleTranslate = async () => {
    if (!alert?.description) return
    setTranslating(true)
    try {
      const { translateText } = await import('@/lib/translate')
      const target = userLang || 'en'
      const out = await translateText(alert.description, target, { source: 'auto', format: 'text' })
      setTranslated(out || '')
    } catch (e) {
      setTranslated(null)
    } finally {
      setTranslating(false)
    }
  }

  if (loading) {
    return (
      <main className="min-h-screen py-8 px-4 md:px-8">
        <div className="max-w-4xl mx-auto">
          <div className="text-center">
            <div className="text-6xl mb-6">🛸</div>
            <p className="text-text-secondary mb-4">Loading alert details...</p>
            <p className="text-text-tertiary text-sm">Searching through recent UFO sightings for alert {params.id}</p>
          </div>
        </div>
      </main>
    )
  }

  if (error || !alert) {
    return (
      <main className="min-h-screen py-8 px-4 md:px-8">
        <div className="max-w-4xl mx-auto">
          <div className="text-center">
            <div className="text-6xl mb-6">⚠️</div>
            <h1 className="text-2xl font-bold text-text-primary mb-4">Alert Not Found</h1>
            <p className="text-text-secondary mb-8">{error || 'The requested UFO sighting alert could not be found.'}</p>
            <Link href="/beep">
              <button className="bg-brand-primary text-text-inverse px-6 py-3 rounded-lg hover:bg-brand-primary-dark transition-colors">
                ← Back to All Alerts
              </button>
            </Link>
          </div>
        </div>
      </main>
    )
  }

  return (
    <main className="min-h-screen py-8 px-4 md:px-8">
      <div className="max-w-4xl mx-auto">
        <Link href={`/beep#alert-${alert.id}`} className="text-brand-primary hover:text-brand-primary-light transition-colors mb-6 inline-block">
          ← Back to All Alerts
        </Link>

        <AlertHero alert={alert} openImageIndex={openImageIndex} />

        <div className="space-y-6">
          <AlertDetails alert={alert} />

          {alert.reporter_username !== 'MUFON' && (
            <EnrichmentData enrichment={alert.enrichment} alert={alert} />
          )}

          {alert.reporter_username !== 'MUFON' && (
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <div className="flex items-center gap-2 mb-4">
                <span className="text-brand-primary">👥</span>
                <h2 className="text-lg font-semibold text-brand-primary">Witnesses</h2>
              </div>
              <div className="text-2xl font-bold text-text-primary mb-2">
                {(alert.total_confirmations || alert.witness_count || 1)} {(alert.total_confirmations || alert.witness_count || 1) === 1 ? 'Witness' : 'Witnesses'}
              </div>
              <div className="text-text-secondary text-sm">
                {(alert.total_confirmations || alert.witness_count || 1) === 1 ? 'Single observer report' : 'Multiple confirmations from nearby users'}
              </div>
            </div>
          )}

          <AlertComments alertId={alert.id} />
        </div>
      </div>
    </main>
  )
}
