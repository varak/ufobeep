'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import Image from 'next/image'

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
  verification_score: number
}

export default function AlertsPage() {
  const [alerts, setAlerts] = useState<Alert[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [currentPage, setCurrentPage] = useState(1)
  const [hasMore, setHasMore] = useState(true)
  const alertsPerPage = 9

  useEffect(() => {
    fetchAlerts(currentPage)
  }, [currentPage])

  const fetchAlerts = async (page: number) => {
    setLoading(true)
    try {
      const offset = (page - 1) * alertsPerPage
      const response = await fetch(`https://api.ufobeep.com/alerts?limit=${alertsPerPage + 1}&offset=${offset}&verified_only=false`)
      const data = await response.json()
      
      if (data.success && data.data?.alerts) {
        const fetchedAlerts = data.data.alerts
        setHasMore(fetchedAlerts.length > alertsPerPage)
        setAlerts(fetchedAlerts.slice(0, alertsPerPage))
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

  const formatLocation = (location: Alert['location']) => {
    return location.name || `${location.latitude.toFixed(4)}, ${location.longitude.toFixed(4)}`
  }

  const generateSlug = (title: string, location: string, date: string) => {
    const titlePart = title.toLowerCase()
      .replace(/[^a-z0-9\s]/g, '')
      .replace(/\s+/g, '-')
      .substring(0, 30)
    
    const locationPart = location.split(',')[0].toLowerCase()
      .replace(/[^a-z0-9\s]/g, '')
      .replace(/\s+/g, '-')
      .substring(0, 20)
    
    const datePart = new Date(date).toISOString().split('T')[0]
    
    return `${titlePart}-${locationPart}-${datePart}`.replace(/--+/g, '-').replace(/^-|-$/g, '')
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
            <p className="text-text-secondary mb-6">{error}</p>
            
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6 mb-8 max-w-2xl mx-auto text-left">
              <h3 className="text-lg font-semibold text-brand-primary mb-4">Troubleshooting Tips:</h3>
              <ul className="space-y-2 text-sm text-text-secondary">
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary">•</span>
                  <span>Check your internet connection</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary">•</span>
                  <span>Try switching from WiFi to mobile data (or vice versa)</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary">•</span>
                  <span>Corporate/school networks may block API requests</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary">•</span>
                  <span>Disable ad blockers or security extensions temporarily</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary">•</span>
                  <span>Try refreshing the page or using a different browser</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary">•</span>
                  <span>Try viewing the website on your phone instead</span>
                </li>
              </ul>
            </div>
            
            <button 
              onClick={() => fetchAlerts(1)}
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
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
          <div className="bg-dark-surface border border-dark-border rounded-lg p-6 text-center">
            <div className="text-3xl text-brand-primary mb-2">{alerts.length}</div>
            <div className="text-text-secondary">Recent Reports</div>
          </div>
          <div className="bg-dark-surface border border-dark-border rounded-lg p-6 text-center">
            <div className="text-3xl text-green-400 mb-2">
              {alerts.filter(a => a.media_files && a.media_files.length > 0).length}
            </div>
            <div className="text-text-secondary">With Photos</div>
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
            {alerts.map((alert) => {
              return (
              <Link key={alert.id} href={`/alerts/${alert.id}`}>
                <div className="bg-dark-surface border border-dark-border rounded-lg overflow-hidden hover:border-brand-primary transition-all duration-300 hover:shadow-lg cursor-pointer group">
                  {/* Thumbnail Image */}
                  {alert.media_files && alert.media_files.length > 0 ? (
                    <div className="h-48 bg-gray-800 relative overflow-hidden">
                      <Image 
                        src={`${alert.media_files[0].url}?thumbnail=true&width=400&height=300`}
                        alt={alert.title}
                        fill
                        className="object-cover group-hover:scale-105 transition-transform duration-300"
                        onError={(e) => {
                          const target = e.target as HTMLImageElement;
                          target.src = `data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100"><rect width="100" height="100" fill="%23374151"/><text x="50" y="50" text-anchor="middle" dy="0.3em" fill="%239CA3AF" font-family="Arial" font-size="12">📸</text></svg>`;
                        }}
                      />
                      <div className="absolute top-2 right-2 bg-black bg-opacity-50 text-white text-xs px-2 py-1 rounded">
                        📸 {alert.media_files.length}
                      </div>
                    </div>
                  ) : (
                    <div className="h-48 bg-gray-800 flex items-center justify-center">
                      <div className="text-4xl text-gray-500">👁️</div>
                    </div>
                  )}

                  <div className="p-4">
                    {/* Alert Level Badge */}
                    <div className="flex justify-between items-start mb-3">
                      <span className={`px-2 py-1 rounded text-xs font-semibold uppercase ${getAlertLevelColor(alert.alert_level)}`}>
                        {alert.alert_level}
                      </span>
                    </div>

                    {/* Title & Description */}
                    <h3 className="text-lg font-semibold text-text-primary mb-2 group-hover:text-brand-primary transition-colors line-clamp-1">
                      {alert.title}
                    </h3>
                    <p className="text-text-secondary text-sm mb-4 line-clamp-2">
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
                        <span>{formatLocation(alert.location)}</span>
                      </div>
                    </div>

                    {/* Click indicator */}
                    <div className="mt-4 pt-3 border-t border-dark-border text-center">
                      <span className="text-brand-primary text-sm group-hover:underline">
                        View Details →
                      </span>
                    </div>
                  </div>
                </div>
              </Link>
              )
            })}
          </div>
        )}
        
        {/* Pagination */}
        {!loading && !error && alerts.length > 0 && (
          <div className="flex justify-center items-center space-x-4 mt-12">
            <button
              onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
              disabled={currentPage === 1}
              className="flex items-center space-x-2 px-6 py-3 bg-dark-surface border border-dark-border rounded-lg hover:bg-dark-hover transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span>←</span>
              <span>Previous</span>
            </button>
            
            <div className="flex items-center space-x-2">
              <span className="text-text-secondary">Page</span>
              <span className="bg-brand-primary text-text-inverse px-3 py-1 rounded font-semibold">{currentPage}</span>
            </div>
            
            <button
              onClick={() => setCurrentPage(prev => prev + 1)}
              disabled={!hasMore}
              className="flex items-center space-x-2 px-6 py-3 bg-dark-surface border border-dark-border rounded-lg hover:bg-dark-hover transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span>Next</span>
              <span>→</span>
            </button>
          </div>
        )}
      </div>
      
      {/* Footer */}
      <footer className="bg-dark-background border-t border-dark-border mt-16">
        <div className="max-w-6xl mx-auto px-4 md:px-8 py-12">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            {/* Brand */}
            <div className="md:col-span-1">
              <div className="flex items-center space-x-2 mb-4">
                <span className="text-2xl">🛸</span>
                <span className="text-xl font-bold text-text-primary">UFOBeep</span>
              </div>
              <p className="text-text-secondary text-sm">
                A community platform for reporting and tracking UFO sightings and anomalous phenomena worldwide.
              </p>
            </div>
            
            {/* Navigation */}
            <div>
              <h3 className="font-semibold text-text-primary mb-4">Navigate</h3>
              <ul className="space-y-2 text-sm">
                <li><Link href="/" className="text-text-secondary hover:text-brand-primary transition-colors">Home</Link></li>
                <li><Link href="/alerts" className="text-text-secondary hover:text-brand-primary transition-colors">Recent Alerts</Link></li>
                <li><Link href="/app" className="text-text-secondary hover:text-brand-primary transition-colors">Download App</Link></li>
              </ul>
            </div>
            
            {/* Legal */}
            <div>
              <h3 className="font-semibold text-text-primary mb-4">Legal</h3>
              <ul className="space-y-2 text-sm">
                <li><Link href="/privacy" className="text-text-secondary hover:text-brand-primary transition-colors">Privacy Policy</Link></li>
                <li><Link href="/terms" className="text-text-secondary hover:text-brand-primary transition-colors">Terms of Service</Link></li>
                <li><Link href="/safety" className="text-text-secondary hover:text-brand-primary transition-colors">Safety Guidelines</Link></li>
              </ul>
            </div>
            
            {/* Community */}
            <div>
              <h3 className="font-semibold text-text-primary mb-4">Community</h3>
              <ul className="space-y-2 text-sm">
                <li><span className="text-text-secondary">Matrix Chat (Coming Soon)</span></li>
                <li><span className="text-text-secondary">API Access (Coming Soon)</span></li>
                <li><span className="text-text-secondary">Researcher Portal (Coming Soon)</span></li>
              </ul>
            </div>
          </div>
          
          <div className="border-t border-dark-border mt-8 pt-8 flex flex-col md:flex-row justify-between items-center">
            <p className="text-text-tertiary text-sm">
              © 2025 UFOBeep. Made with 🛸 for the truth seekers.
            </p>
            <div className="flex items-center space-x-6 mt-4 md:mt-0">
              <span className="text-text-tertiary text-sm">
                {alerts.length} sightings on this page
              </span>
            </div>
          </div>
        </div>
      </footer>
    </main>
  )
}