'use client'

import { useEffect, useState } from 'react'
import { notFound } from 'next/navigation'
import Link from 'next/link'
import ImageWithLoading from '../../../components/ImageWithLoading'

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
  media_files: Array<{
    id: string
    type: string
    url: string
    thumbnail_url: string
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
}

interface AlertPageProps {
  params: { id: string }
}

export default function AlertPage({ params }: AlertPageProps) {
  const [alert, setAlert] = useState<Alert | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchAlert = async () => {
      try {
        // Fetch all recent alerts and find one matching the ID
        const response = await fetch('https://api.ufobeep.com/alerts?limit=100&offset=0&verified_only=false')
        
        if (!response.ok) {
          throw new Error(`Failed to fetch alerts: ${response.status}`)
        }
        
        const data = await response.json()
        
        if (!data.success || !data.data?.alerts) {
          throw new Error('Invalid API response structure')
        }
        
        // Find alert by matching ID
        const foundAlert = data.data.alerts.find((alert: Alert) => alert.id === params.id)
        
        if (!foundAlert) {
          setError('Alert not found')
        } else {
          setAlert(foundAlert)
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
            <p className="text-text-secondary">Loading alert details...</p>
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

  return (
    <main className="min-h-screen py-8 px-4 md:px-8">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <Link 
            href="/alerts" 
            className="text-brand-primary hover:text-brand-primary-light transition-colors mb-4 inline-block"
          >
            ← Back to All Alerts
          </Link>
          
          <div className="flex items-start justify-between flex-wrap gap-4">
            <div className="flex-1">
              <div className="flex items-center gap-3 mb-4">
                <span className="text-3xl">{getCategoryIcon(alert.category)}</span>
                <div>
                  <span className="bg-dark-surface text-brand-primary px-3 py-1 rounded-full text-sm font-semibold">
                    {getCategoryName(alert.category)}
                  </span>
                  <span className={`px-3 py-1 rounded-full text-xs font-semibold uppercase ${getAlertLevelColor(alert.alert_level)} ml-2`}>
                    {alert.alert_level}
                  </span>
                </div>
              </div>
              <h1 className="text-3xl md:text-4xl font-bold text-text-primary mb-2">
                {alert.title}
              </h1>
              <p className="text-text-secondary">
                {alert.location.name} • {formatDate(alert.created_at)}
              </p>
            </div>
          </div>
        </div>

        {/* Media Section */}
        <div className="mb-8">
          {alert.media_files && alert.media_files.length > 0 ? (
            <div className="bg-dark-surface border border-dark-border rounded-lg overflow-hidden">
              <div className="bg-dark-background relative cursor-pointer group min-h-[400px] max-h-[600px] border-2 border-red-500">
                <a 
                  href={alert.media_files[0].url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="block w-full h-full"
                >
                  <ImageWithLoading 
                    src={`${alert.media_files[0].thumbnail_url}?thumbnail=true`}
                    alt={alert.title}
                    fill
                    className="object-cover group-hover:opacity-90 transition-opacity border-4 border-blue-500"
                    sizes="(max-width: 768px) 95vw, (max-width: 1200px) 75vw, 60vw"
                  />
                  {/* Click to view full size overlay */}
                  <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-20 transition-all duration-300 flex items-center justify-center">
                    <div className="opacity-0 group-hover:opacity-100 transition-opacity bg-black bg-opacity-70 text-white px-4 py-2 rounded-lg">
                      <span className="text-sm font-medium">🔍 Click to view full size</span>
                    </div>
                  </div>
                </a>
              </div>
              <div className="p-4 bg-dark-surface">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-text-tertiary">Media attached • Click image to view full size</span>
                  <span className="text-brand-primary">{alert.media_files.length} file{alert.media_files.length > 1 ? 's' : ''}</span>
                </div>
              </div>
            </div>
          ) : (
            <div className="bg-dark-surface border border-dark-border rounded-lg p-8 text-center">
              <div className="text-6xl mb-4">👁️</div>
              <p className="text-text-secondary">No media attached to this sighting</p>
              <p className="text-text-tertiary text-sm mt-2">Witness provided description only</p>
            </div>
          )}
        </div>

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-6">
            {/* Description */}
            <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h2 className="text-xl font-semibold text-text-primary mb-4">Description</h2>
              <p className="text-text-secondary leading-relaxed">
                {alert.description}
              </p>
            </section>

            {/* Add Media Section */}
            <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h2 className="text-xl font-semibold text-text-primary mb-4">Additional Media</h2>
              <p className="text-text-secondary mb-4">
                Have additional photos or videos of this sighting? Help the community by adding more evidence.
              </p>
              <button
                onClick={() => {
                  window.alert('Coming soon! Media upload for web users will be available in a future update. For now, use the mobile app to submit additional media.')
                }}
                className="bg-brand-primary text-text-inverse px-6 py-3 rounded-lg hover:bg-brand-primary-dark transition-colors font-medium"
              >
                📷 Add Media
              </button>
              <p className="text-text-tertiary text-sm mt-2">
                Currently available for: Original submitter, administrators, and users within weather visibility range
              </p>
            </section>

            {/* Environmental Data */}
            {alert.enrichment && alert.enrichment.weather && (
              <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h2 className="text-xl font-semibold text-text-primary mb-4">Environmental Context</h2>
                
                <div className="mb-6">
                  <h3 className="text-lg font-medium text-brand-primary mb-3 flex items-center gap-2">
                    🌤️ Weather Conditions
                  </h3>
                  <div className="grid sm:grid-cols-3 gap-4">
                    <div>
                      <p className="text-text-tertiary text-sm">Temperature</p>
                      <p className="text-text-primary">{alert.enrichment.weather.temperature}°C</p>
                    </div>
                    <div>
                      <p className="text-text-tertiary text-sm">Conditions</p>
                      <p className="text-text-primary">{alert.enrichment.weather.condition}</p>
                    </div>
                    <div>
                      <p className="text-text-tertiary text-sm">Visibility</p>
                      <p className="text-text-primary">{alert.enrichment.weather.visibility} km</p>
                    </div>
                    <div>
                      <p className="text-text-tertiary text-sm">Wind Speed</p>
                      <p className="text-text-primary">{alert.enrichment.weather.wind_speed} m/s</p>
                    </div>
                    <div>
                      <p className="text-text-tertiary text-sm">Humidity</p>
                      <p className="text-text-primary">{alert.enrichment.weather.humidity}%</p>
                    </div>
                    <div>
                      <p className="text-text-tertiary text-sm">Pressure</p>
                      <p className="text-text-primary">{alert.enrichment.weather.pressure} hPa</p>
                    </div>
                  </div>
                  {alert.enrichment.weather.observation_quality && (
                    <div className="mt-3 p-3 bg-dark-background rounded border border-dark-border">
                      <p className="text-text-tertiary text-sm">
                        <strong>Observation Quality:</strong> {alert.enrichment.weather.observation_quality}
                      </p>
                    </div>
                  )}
                </div>
              </section>
            )}
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Location */}
            <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h3 className="text-lg font-semibold text-text-primary mb-4">Location</h3>
              <p className="text-text-secondary mb-4">{alert.location.name}</p>
              <p className="text-text-tertiary text-sm mb-4">
                {alert.location.latitude.toFixed(6)}, {alert.location.longitude.toFixed(6)}
              </p>
              
              <div className="bg-dark-background rounded-lg p-4 text-center">
                <div className="text-3xl mb-2">🗺️</div>
                <p className="text-text-tertiary text-sm">Interactive map coming soon</p>
              </div>
            </section>

            {/* Stats */}
            <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h3 className="text-lg font-semibold text-text-primary mb-4">Sighting Details</h3>
              <div className="space-y-4">
                <div className="flex justify-between items-center">
                  <span className="text-text-tertiary flex items-center gap-2">
                    <span>📸</span> Media Files
                  </span>
                  <span className="text-text-primary font-medium">{alert.media_files?.length || 0}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-text-tertiary flex items-center gap-2">
                    <span>🛡️</span> Status
                  </span>
                  <span className="text-text-primary font-medium">
                    {alert.enrichment?.status || 'Processing'}
                  </span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-text-tertiary flex items-center gap-2">
                    <span>⚡</span> Alert Level
                  </span>
                  <span className={`font-medium ${getAlertLevelColor(alert.alert_level)}`}>
                    {alert.alert_level}
                  </span>
                </div>
              </div>
            </section>
          </div>
        </div>
      </div>
    </main>
  )
}