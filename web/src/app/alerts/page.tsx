'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import AlertCard from '../../components/AlertCard'

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
    is_primary: boolean
    upload_order: number
    display_priority: number
  }>
  verification_score: number
}

export default function AlertsPage() {
  const [allAlerts, setAllAlerts] = useState<Alert[]>([])
  const [alerts, setAlerts] = useState<Alert[]>([])
  const [filteredAlerts, setFilteredAlerts] = useState<Alert[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [currentPage, setCurrentPage] = useState(1)
  const [showPhotosOnly, setShowPhotosOnly] = useState(false)
  const alertsPerPage = 9

  useEffect(() => {
    // Fetch all alerts once on component mount
    fetchAllAlerts()
  }, [])

  useEffect(() => {
    // Update filtered alerts when filter changes
    if (allAlerts.length > 0) {
      const filtered = showPhotosOnly 
        ? allAlerts.filter(alert => alert.media_files && alert.media_files.length > 0)
        : allAlerts
      setFilteredAlerts(filtered)
      setCurrentPage(1) // Reset to first page when filter changes
    }
  }, [allAlerts, showPhotosOnly])

  useEffect(() => {
    // Update displayed alerts when page or filter changes
    if (filteredAlerts.length > 0) {
      updateDisplayedAlerts(currentPage)
    }
  }, [currentPage, filteredAlerts])

  const fetchAllAlerts = async () => {
    setLoading(true)
    try {
      // Since API offset doesn't work, fetch a large batch of recent alerts
      const response = await fetch(`https://api.ufobeep.com/alerts?limit=100&offset=0&verified_only=false`)
      const data = await response.json()
      
      if (data.success && data.data?.alerts) {
        // Filter out invalid coordinates (0,0 or null/undefined)
        const validAlerts = data.data.alerts.filter((alert: Alert) => 
          alert.location.latitude !== 0 || alert.location.longitude !== 0
        )
        setAllAlerts(validAlerts)
      } else {
        setError('Failed to load alerts')
      }
    } catch (err) {
      setError('Failed to connect to API')
    } finally {
      setLoading(false)
    }
  }

  const updateDisplayedAlerts = (page: number) => {
    const startIndex = (page - 1) * alertsPerPage
    const endIndex = startIndex + alertsPerPage
    setAlerts(filteredAlerts.slice(startIndex, endIndex))
  }

  const getTotalPages = () => Math.ceil(filteredAlerts.length / alertsPerPage)
  const hasMore = currentPage < getTotalPages()

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
              onClick={() => {
                setCurrentPage(1)
                fetchAllAlerts()
              }}
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
            <div className="text-3xl text-brand-primary mb-2">{allAlerts.length}</div>
            <div className="text-text-secondary">Total Reports</div>
          </div>
          <div 
            className={`bg-dark-surface border rounded-lg p-6 text-center cursor-pointer transition-all hover:scale-105 ${
              showPhotosOnly ? 'border-brand-primary bg-brand-primary/10' : 'border-dark-border hover:border-brand-primary/50'
            }`}
            onClick={() => setShowPhotosOnly(!showPhotosOnly)}
          >
            <div className="text-3xl text-green-400 mb-2">
              {allAlerts.filter(a => a.media_files && a.media_files.length > 0).length}
            </div>
            <div className={`text-sm ${showPhotosOnly ? 'text-brand-primary font-medium' : 'text-text-secondary'}`}>
              {showPhotosOnly ? '✓ Showing Photos Only' : 'With Photos (Click to Filter)'}
            </div>
          </div>
        </div>

        {/* Alerts Grid */}
        {alerts.length === 0 ? (
          <div className="text-center py-16">
            <div className="text-6xl mb-6">{showPhotosOnly ? '📷' : '🤔'}</div>
            <h2 className="text-2xl font-bold text-text-primary mb-4">
              {showPhotosOnly ? 'No Alerts with Photos' : 'No Alerts Yet'}
            </h2>
            <p className="text-text-secondary mb-8">
              {showPhotosOnly 
                ? 'Try viewing all alerts or check back later for photo reports!'
                : 'Be the first to report a sighting!'
              }
            </p>
            {showPhotosOnly ? (
              <button 
                onClick={() => setShowPhotosOnly(false)}
                className="bg-brand-primary text-text-inverse px-8 py-4 rounded-lg font-semibold hover:bg-brand-primary-dark transition-colors"
              >
                Show All Alerts
              </button>
            ) : (
              <Link href="/app">
                <button className="bg-brand-primary text-text-inverse px-8 py-4 rounded-lg font-semibold hover:bg-brand-primary-dark transition-colors">
                  Download App
                </button>
              </Link>
            )}
          </div>
        ) : (
          <div className="max-w-2xl mx-auto space-y-3">
            {alerts.map((alert) => (
              <AlertCard key={alert.id} alert={alert} />
            ))}
          </div>
        )}
        
        {/* Pagination */}
        {!loading && !error && alerts.length > 0 && (
          <div className="flex justify-center items-center space-x-4 mt-12">
            <button
              onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
              disabled={currentPage === 1}
              className="flex items-center space-x-2 px-6 py-3 bg-dark-surface border border-dark-border rounded-lg hover:bg-dark-surface-elevated transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span>←</span>
              <span>Previous</span>
            </button>
            
            <div className="flex items-center space-x-2">
              <span className="text-text-secondary">Page</span>
              <span className="bg-brand-primary text-text-inverse px-3 py-1 rounded font-semibold">{currentPage}</span>
              <span className="text-text-secondary">of {getTotalPages()}</span>
            </div>
            
            <button
              onClick={() => setCurrentPage(prev => prev + 1)}
              disabled={!hasMore}
              className="flex items-center space-x-2 px-6 py-3 bg-dark-surface border border-dark-border rounded-lg hover:bg-dark-surface-elevated transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
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
                Showing {alerts.length} of {filteredAlerts.length} sightings
                {showPhotosOnly && <span className="text-brand-primary ml-1">(photos only)</span>}
              </span>
            </div>
          </div>
        </div>
      </footer>
    </main>
  )
}