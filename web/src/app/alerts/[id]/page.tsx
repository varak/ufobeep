'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import AlertHero from '../../../components/alert-detail/AlertHero'
import AlertDetails from '../../../components/alert-detail/AlertDetails'
import EnrichmentData from '../../../components/alert-detail/EnrichmentData'
import WitnessAggregation from '../../../components/WitnessAggregation'
import InteractiveMap from '../../../components/InteractiveMap'

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
  enrichment?: {
    status: string
    weather?: {
      temperature: number
      condition: string
      description: string
      humidity: number
      pressure: number
      wind_speed: number
      visibility: number
      observation_quality: string
    }
    celestial?: any
    aircraft?: any
  }
  photo_analysis?: Array<{
    filename: string
    classification?: string
    matched_object?: string
    confidence?: number
    analysis_status: string
    analysis_error?: string
    processing_duration_ms?: number
  }>
}

interface AlertPageProps {
  params: { id: string }
}

export default function AlertPage({ params }: AlertPageProps) {
  const [alert, setAlert] = useState<Alert | null>(null)
  const [nearbySightings, setNearbySightings] = useState<Alert[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // Calculate distance between two coordinates using Haversine formula
  const calculateDistance = (lat1: number, lon1: number, lat2: number, lon2: number): number => {
    const R = 6371 // Earth's radius in kilometers
    const dLat = (lat2 - lat1) * Math.PI / 180
    const dLon = (lon2 - lon1) * Math.PI / 180
    const a = 
      Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
      Math.sin(dLon/2) * Math.sin(dLon/2)
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    return R * c
  }

  const fetchNearbySightings = (mainAlert: Alert, allAlerts: Alert[]) => {
    const nearby = allAlerts.filter(alert => {
      if (alert.id === mainAlert.id) return false // Exclude main alert
      
      const distance = calculateDistance(
        mainAlert.location.latitude,
        mainAlert.location.longitude,
        alert.location.latitude,
        alert.location.longitude
      )
      
      return distance <= 50 // Within 50km
    })
    
    // Sort by distance and take closest 10
    const sortedNearby = nearby
      .map(alert => ({
        ...alert,
        distance: calculateDistance(
          mainAlert.location.latitude,
          mainAlert.location.longitude,
          alert.location.latitude,
          alert.location.longitude
        )
      }))
      .sort((a, b) => a.distance - b.distance)
      .slice(0, 10)
    
    console.log(`Found ${sortedNearby.length} nearby sightings within 50km`)
    setNearbySightings(sortedNearby)
  }

  useEffect(() => {
    const fetchAlert = async () => {
      try {
        // Search through multiple pages to find the alert
        let foundAlert = null
        let currentOffset = 0
        const limit = 100
        const maxSearchPages = 10 // Search up to 1000 alerts
        
        for (let page = 0; page < maxSearchPages; page++) {
          console.log(`Searching for alert ${params.id} - page ${page + 1}`)
          
          const response = await fetch(`https://api.ufobeep.com/alerts?limit=${limit}&offset=${currentOffset}&verified_only=false`)
          
          if (!response.ok) {
            throw new Error(`Failed to fetch alerts: ${response.status}`)
          }
          
          const data = await response.json()
          
          if (!data.success || !data.data?.alerts) {
            throw new Error('Invalid API response structure')
          }
          
          // Find alert by matching ID in this batch
          foundAlert = data.data.alerts.find((alert: Alert) => alert.id === params.id)
          
          if (foundAlert) {
            console.log(`Found alert ${params.id} on page ${page + 1}`)
            setAlert(foundAlert)
            
            // Fetch nearby sightings within 50km
            fetchNearbySightings(foundAlert, data.data.alerts)
            break
          }
          
          // If we got fewer alerts than the limit, we've reached the end
          if (data.data.alerts.length < limit) {
            console.log(`Reached end of alerts at page ${page + 1}, alert ${params.id} not found`)
            break
          }
          
          currentOffset += limit
        }
        
        if (!foundAlert) {
          setError(`Alert not found. Searched through ${maxSearchPages * limit} recent alerts.`)
        }
        
      } catch (err) {
        console.error('Error fetching alert:', err)
        setError('Failed to load alert')
      } finally {
        setLoading(false)
      }
    }

    fetchAlert()
  }, [params.id])

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
            <Link href="/alerts">
              <button className="bg-brand-primary text-text-inverse px-6 py-3 rounded-lg hover:bg-brand-primary-dark transition-colors">
                ← Back to All Alerts
              </button>
            </Link>
          </div>
        </div>
      </main>
    )
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  const getCategoryIcon = (category: string) => {
    switch (category) {
      case 'ufo': return '🛸'
      case 'anomaly': return '⭐'
      default: return '❓'
    }
  }

  const getCategoryName = (category: string) => {
    switch (category) {
      case 'ufo': return 'UFO Sighting'
      case 'anomaly': return 'Anomalous Phenomenon'
      default: return 'Sighting'
    }
  }

  const getAlertLevelColor = (level: string) => {
    switch (level.toLowerCase()) {
      case 'critical': return 'text-red-400'
      case 'high': return 'text-orange-400'
      case 'medium': return 'text-yellow-400'
      case 'low': return 'text-green-400'
      default: return 'text-gray-400'
    }
  }

  const getWitnessCount = () => {
    // Use total_confirmations if available, otherwise fall back to witness_count
    return alert.total_confirmations || alert.witness_count || 1
  }

  const getWitnessEscalationLevel = (count: number) => {
    if (count >= 10) return { 
      level: 'emergency', 
      color: 'bg-red-500/20 text-red-300 border-red-500/30', 
      icon: '🚨',
      description: 'MASS SIGHTING - Multiple witnesses confirmed'
    }
    if (count >= 3) return { 
      level: 'urgent', 
      color: 'bg-orange-500/20 text-orange-300 border-orange-500/30', 
      icon: '⚠️',
      description: 'MULTIPLE WITNESSES - Escalated alert'
    }
    return { 
      level: 'normal', 
      color: 'bg-brand-primary/20 text-brand-primary border-brand-primary/30', 
      icon: '👁️',
      description: 'Witnessed sighting'
    }
  }

  const isVideoFile = (media: any) => {
    return media.type === 'video' || 
           media.url?.toLowerCase().includes('.mp4') ||
           media.url?.toLowerCase().includes('.mov')
  }

  return (
    <main className="min-h-screen py-8 px-4 md:px-8">
      <div className="max-w-4xl mx-auto">
        {/* Back button */}
        <Link 
          href="/alerts" 
          className="text-brand-primary hover:text-brand-primary-light transition-colors mb-6 inline-block"
        >
          ← Back to All Alerts
        </Link>

        {/* Hero Section */}
        <AlertHero alert={alert} />

        {/* Main content grid */}
        <div className="grid lg:grid-cols-3 gap-6">
          {/* Main content */}
          <div className="lg:col-span-2 space-y-6">
            {/* Alert details */}
            <AlertDetails alert={alert} />

            {/* Environmental data */}
            <EnrichmentData enrichment={alert.enrichment} />

            {/* Witness aggregation */}
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <WitnessAggregation sightingId={alert.id} />
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Location with map */}
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <div className="flex items-center gap-2 mb-4">
                <span className="text-brand-primary">🗺️</span>
                <h3 className="text-lg font-semibold text-brand-primary">Location</h3>
              </div>
              
              <div className="mb-4">
                <div className="text-text-secondary mb-2">{alert.location.name}</div>
                <div className="text-text-tertiary text-sm">
                  {alert.location.latitude.toFixed(4)}, {alert.location.longitude.toFixed(4)}
                </div>
              </div>
              
              <InteractiveMap
                sighting={alert}
                nearbySightings={nearbySightings}
                height="250px"
                showFullscreenButton={true}
              />
            </div>

            {/* Quick stats */}
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <div className="flex items-center gap-2 mb-4">
                <span className="text-brand-primary">📊</span>
                <h3 className="text-lg font-semibold text-brand-primary">Stats</h3>
              </div>
              
              <div className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-text-tertiary text-sm">Witnesses</span>
                  <span className="text-text-primary font-medium">{getWitnessCount()}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-text-tertiary text-sm">Media Files</span>
                  <span className="text-text-primary font-medium">{alert.media_files?.length || 0}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-text-tertiary text-sm">Status</span>
                  <span className="text-text-primary font-medium">Active</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  )
}