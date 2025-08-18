'use client'

import { useEffect, useState } from 'react'
import { notFound } from 'next/navigation'
import Link from 'next/link'
import ImageWithLoading from '../../../components/ImageWithLoading'
import WitnessAggregation from '../../../components/WitnessAggregation'

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
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

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

        {/* Witness Confirmation Status */}
        {(() => {
          const witnessCount = getWitnessCount()
          const escalation = getWitnessEscalationLevel(witnessCount)
          return (
            <div className={`mb-8 p-6 rounded-lg border ${escalation.color}`}>
              <div className="flex items-center gap-4">
                <div className="text-4xl">{escalation.icon}</div>
                <div className="flex-1">
                  <h2 className="text-2xl font-bold mb-1">
                    {witnessCount} Witness{witnessCount !== 1 ? 'es' : ''} Confirmed
                  </h2>
                  <p className="text-lg opacity-90">{escalation.description}</p>
                  <p className="text-sm opacity-70 mt-2">
                    Real-time confirmations from mobile app users who report seeing the same phenomenon
                  </p>
                </div>
              </div>
            </div>
          )
        })()}

        {/* Media Section */}
        <div className="mb-8">
          {alert.media_files && alert.media_files.length > 0 ? (
            <div className="bg-dark-surface border border-dark-border rounded-lg overflow-hidden">
              <div className="bg-dark-background relative cursor-pointer group">
{isVideoFile(alert.media_files[0]) ? (
                  <video 
                    controls 
                    className="w-full h-auto object-contain max-h-[600px]"
                    src={alert.media_files[0].url}
                    poster={alert.media_files[0].thumbnail_url}
                  >
                    <source src={alert.media_files[0].url} type="video/mp4" />
                    Your browser does not support video playback.
                  </video>
                ) : (
                  <a 
                    href={alert.media_files[0].url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="block"
                  >
                    <ImageWithLoading 
                      src={alert.media_files[0].url}
                      alt={alert.title}
                      width={1200}
                      height={900}
                      className="w-full h-auto object-contain group-hover:opacity-90 transition-opacity max-h-[600px]"
                    />
                    {/* Click to view full size overlay */}
                    <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-20 transition-all duration-300 flex items-center justify-center">
                      <div className="opacity-0 group-hover:opacity-100 transition-opacity bg-black bg-opacity-70 text-white px-4 py-2 rounded-lg">
                        <span className="text-sm font-medium">🔍 Click to view full size</span>
                      </div>
                    </div>
                  </a>
                )}
              </div>
              <div className="p-4 bg-dark-surface">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-text-tertiary">
                    {isVideoFile(alert.media_files[0]) ? 'Video attached • Use controls to play' : 'Media attached • Click image to view full size'}
                  </span>
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

            {/* Witness Aggregation - Phase 1 Task 7 */}
            <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <WitnessAggregation sightingId={alert.id} />
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

            {/* Photo Analysis */}
            {alert.photo_analysis && alert.photo_analysis.length > 0 && (
              <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h2 className="text-xl font-semibold text-text-primary mb-4">Photo Analysis</h2>
                <div className="space-y-4">
                  {alert.photo_analysis.map((analysis, index) => (
                    <div key={index} className="border border-dark-border rounded-lg p-4 bg-dark-background">
                      {/* Header with status */}
                      <div className="flex items-center justify-between mb-3">
                        <div className="flex items-center gap-2">
                          <span className="text-lg">📸</span>
                          <span className="text-text-primary font-medium text-sm">Photo Analysis</span>
                        </div>
                        <div className="flex items-center gap-2">
                          <div className={`w-2 h-2 rounded-full ${
                            analysis.analysis_status === 'completed' ? 'bg-green-400' :
                            analysis.analysis_status === 'pending' ? 'bg-yellow-400' :
                            'bg-red-400'
                          }`}></div>
                          <span className={`text-sm font-medium ${
                            analysis.analysis_status === 'completed' ? 'text-green-400' :
                            analysis.analysis_status === 'pending' ? 'text-yellow-400' :
                            'text-red-400'
                          }`}>
                            {analysis.analysis_status === 'completed' ? 'Star/Planet Detection Complete' :
                             analysis.analysis_status === 'pending' ? 'Star/Planet Detection Pending...' :
                             'Star/Planet Detection Failed'}
                          </span>
                        </div>
                      </div>

                      {/* Analysis Results */}
                      {analysis.analysis_status === 'completed' && analysis.classification && (
                        <div className="space-y-2">
                          <div className="flex items-center gap-3">
                            <div className="text-2xl">
                              {analysis.classification === 'planet' ? '🪐' :
                               analysis.classification === 'satellite' ? '🛰️' : 
                               '❓'}
                            </div>
                            <div>
                              {analysis.matched_object ? (
                                <>
                                  <div className="text-text-primary font-semibold text-lg">
                                    {analysis.matched_object}
                                  </div>
                                  <div className="text-text-secondary text-sm capitalize">
                                    {analysis.classification} detected
                                  </div>
                                </>
                              ) : (
                                <div className="text-text-secondary">
                                  {analysis.classification === 'inconclusive' 
                                    ? 'No celestial objects detected' 
                                    : analysis.classification === 'unknown'
                                    ? 'Analysis inconclusive'
                                    : `Unidentified ${analysis.classification}`}
                                </div>
                              )}
                            </div>
                          </div>
                          
                          {analysis.confidence && (
                            <div className="flex items-center gap-2 text-sm">
                              <span className="text-text-tertiary">Confidence:</span>
                              <span className={`font-semibold ${
                                analysis.confidence > 0.8 ? 'text-green-400' :
                                analysis.confidence > 0.5 ? 'text-yellow-400' :
                                'text-red-400'
                              }`}>
                                {Math.round(analysis.confidence * 100)}%
                              </span>
                            </div>
                          )}
                          
                          {analysis.processing_duration_ms && (
                            <div className="text-text-tertiary text-xs">
                              Analysis completed in {(analysis.processing_duration_ms / 1000).toFixed(1)}s
                            </div>
                          )}
                        </div>
                      )}

                      {/* Error Message */}
                      {analysis.analysis_status === 'failed' && analysis.analysis_error && (
                        <div className="text-red-400 text-sm">
                          {analysis.analysis_error}
                        </div>
                      )}

                      {/* Pending State */}
                      {analysis.analysis_status === 'pending' && (
                        <div className="text-text-secondary text-sm">
                          Analyzing photo for planets, stars, and satellites...
                        </div>
                      )}
                    </div>
                  ))}
                </div>
                
                <div className="mt-4 p-3 bg-dark-background rounded border border-dark-border">
                  <p className="text-text-tertiary text-xs">
                    Automated identification of planets, moons, and satellites using plate-solving technology and astronomical databases.
                  </p>
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
                    <span>👥</span> Witnesses
                  </span>
                  <span className="text-text-primary font-medium">{getWitnessCount()}</span>
                </div>
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