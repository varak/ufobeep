'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'

interface Alert {
  id: string
  title: string
  description: string
  category: string
  created_at: string
  public_latitude: number
  public_longitude: number
  alert_level: string
  media_files: string[]
  verification_score: number
}

export default function AlertsPage() {
  const [alerts, setAlerts] = useState<Alert[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchAlerts()
  }, [])

  const fetchAlerts = async () => {
    try {
      const response = await fetch('https://api.ufobeep.com/alerts?limit=50&offset=0&verified_only=false')
      const data = await response.json()
      
      if (data.success && data.data) {
        setAlerts(data.data)
      } else {
        setError('Failed to load alerts')
      }
    } catch (err) {
      setError('Failed to connect to API')
    } finally {
      setLoading(false)
    }
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  const formatDistance = (lat: number, lon: number) => {
    // Simple distance calculation (you could enhance this)
    return `${lat.toFixed(4)}, ${lon.toFixed(4)}`
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

  if (loading) {
    return (
      <main className="min-h-screen py-8 px-4 md:px-8">
        <div className="max-w-6xl mx-auto">
          <div className="text-center">
            <div className="text-6xl mb-6">🛸</div>
            <p className="text-text-secondary">Loading recent alerts...</p>
          </div>
        </div>
      </main>
    )
  }

  if (error) {
    return (
      <main className="min-h-screen py-8 px-4 md:px-8">
        <div className="max-w-6xl mx-auto">
          <div className="text-center">
            <div className="text-6xl mb-6">⚠️</div>
            <h1 className="text-2xl font-bold text-text-primary mb-4">Unable to Load Alerts</h1>
            <p className="text-text-secondary mb-8">{error}</p>
            <button 
              onClick={fetchAlerts}
              className="bg-brand-primary text-text-inverse px-6 py-3 rounded-lg hover:bg-brand-primary-dark transition-colors"
            >
              Try Again
            </button>
          </div>
        </div>
      </main>
    )
  }

  return (
    <main className="min-h-screen py-8 px-4 md:px-8">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="text-center mb-12">
          <Link 
            href="/" 
            className="text-brand-primary hover:text-brand-primary-light transition-colors mb-4 inline-block"
          >
            ← Back to Home
          </Link>
          
          <div className="text-6xl mb-6">🛸</div>
          <h1 className="text-4xl md:text-5xl font-bold text-text-primary mb-4">
            Recent UFO Alerts
          </h1>
          <p className="text-xl text-text-secondary max-w-2xl mx-auto">
            Latest sightings and anomaly reports from around the world
          </p>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
          <div className="bg-dark-surface border border-dark-border rounded-lg p-6 text-center">
            <div className="text-3xl text-brand-primary mb-2">{alerts.length}</div>
            <div className="text-text-secondary">Total Alerts</div>
          </div>
          <div className="bg-dark-surface border border-dark-border rounded-lg p-6 text-center">
            <div className="text-3xl text-green-400 mb-2">
              {alerts.filter(a => a.verification_score > 0.5).length}
            </div>
            <div className="text-text-secondary">Verified</div>
          </div>
          <div className="bg-dark-surface border border-dark-border rounded-lg p-6 text-center">
            <div className="text-3xl text-orange-400 mb-2">
              {alerts.filter(a => a.alert_level === 'high' || a.alert_level === 'critical').length}
            </div>
            <div className="text-text-secondary">High Priority</div>
          </div>
        </div>

        {/* Alerts Grid */}
        {alerts.length === 0 ? (
          <div className="text-center py-16">
            <div className="text-6xl mb-6">🤔</div>
            <h2 className="text-2xl font-bold text-text-primary mb-4">No Alerts Yet</h2>
            <p className="text-text-secondary mb-8">Be the first to report a sighting!</p>
            <Link href="/app">
              <button className="bg-brand-primary text-text-inverse px-8 py-4 rounded-lg font-semibold hover:bg-brand-primary-dark transition-colors">
                Download App
              </button>
            </Link>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {alerts.map((alert) => (
              <Link key={alert.id} href={`/alerts/${alert.id}`}>
                <div className="bg-dark-surface border border-dark-border rounded-lg p-6 hover:border-brand-primary transition-all duration-300 hover:shadow-lg cursor-pointer group">
                  {/* Alert Level Badge */}
                  <div className="flex justify-between items-start mb-4">
                    <span className={`px-3 py-1 rounded-full text-xs font-semibold uppercase ${getAlertLevelColor(alert.alert_level)} bg-opacity-20`}>
                      {alert.alert_level}
                    </span>
                    {alert.media_files && alert.media_files.length > 0 && (
                      <div className="text-brand-primary">
                        📸 {alert.media_files.length}
                      </div>
                    )}
                  </div>

                  {/* Title & Description */}
                  <h3 className="text-lg font-semibold text-text-primary mb-2 group-hover:text-brand-primary transition-colors">
                    {alert.title}
                  </h3>
                  <p className="text-text-secondary text-sm mb-4 line-clamp-3">
                    {alert.description}
                  </p>

                  {/* Metadata */}
                  <div className="space-y-2 text-xs text-text-tertiary">
                    <div className="flex items-center gap-2">
                      <span>📅</span>
                      <span>{formatDate(alert.created_at)}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span>📍</span>
                      <span>{formatDistance(alert.public_latitude, alert.public_longitude)}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span>🏷️</span>
                      <span className="capitalize">{alert.category}</span>
                    </div>
                    {alert.verification_score > 0 && (
                      <div className="flex items-center gap-2">
                        <span>✅</span>
                        <span>Score: {(alert.verification_score * 100).toFixed(0)}%</span>
                      </div>
                    )}
                  </div>

                  {/* Click indicator */}
                  <div className="mt-4 pt-4 border-t border-dark-border text-center">
                    <span className="text-brand-primary text-sm group-hover:underline">
                      View Details →
                    </span>
                  </div>
                </div>
              </Link>
            ))}
          </div>
        )}
      </div>
    </main>
  )
}