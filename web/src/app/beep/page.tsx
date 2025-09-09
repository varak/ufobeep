'use client'

import { useEffect, useState, Suspense } from 'react'
import Link from 'next/link'
import { useRouter, useSearchParams } from 'next/navigation'
import AlertCard from '../../components/AlertCard'
import { useGeolocation } from '../../utils/geolocation'

interface Alert {
  id: string
  title: string
  description: string
  category: string
  created_at: string
  occurred_at?: string
  source?: string
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
  reporter_username?: string | null
  is_verified?: boolean
  distance?: number
  distance_km?: number
  comment_count?: number
}

function AlertsPageContent() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const [alerts, setAlerts] = useState<Alert[]>([])
  const [totalAlerts, setTotalAlerts] = useState<number>(0)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const alertsPerPage = 9
  const { position: userLocation, loading: locationLoading, error: locationError } = useGeolocation()
  
  // Get URL parameters
  const currentPage = parseInt(searchParams.get('page') || '1', 10)
  const showPhotosOnly = searchParams.get('photos') === 'true'
  const showBeepsOnly = searchParams.get('beeps') === 'true'

  // Update URL with new parameters
  const updateUrlParams = (params: { page?: number; photos?: boolean; beeps?: boolean }) => {
    const newParams = new URLSearchParams(searchParams.toString())
    
    if (params.page !== undefined) {
      if (params.page === 1) {
        newParams.delete('page')
      } else {
        newParams.set('page', params.page.toString())
      }
    }
    
    if (params.photos !== undefined) {
      if (params.photos) {
        newParams.set('photos', 'true')
      } else {
        newParams.delete('photos')
      }
    }
    
    if (params.beeps !== undefined) {
      if (params.beeps) {
        newParams.set('beeps', 'true')
      } else {
        newParams.delete('beeps')
      }
    }
    
    const queryString = newParams.toString()
    const newUrl = queryString ? `/beep?${queryString}` : '/beep'
    router.replace(newUrl)
  }

  useEffect(() => {
    // Fetch alerts for current page when page, filters, or location change
    fetchAlertsPage(currentPage)
  }, [currentPage, showPhotosOnly, showBeepsOnly, userLocation])

  useEffect(() => {
    // Handle anchor scrolling after alerts are loaded
    if (alerts.length > 0 && typeof window !== 'undefined') {
      const hash = window.location.hash
      if (hash.startsWith('#alert-')) {
        const alertId = hash.substring(7) // Remove '#alert-' prefix
        const element = document.getElementById(`alert-${alertId}`)
        if (element) {
          setTimeout(() => {
            element.scrollIntoView({ behavior: 'smooth', block: 'center' })
          }, 100) // Small delay to ensure DOM is fully rendered
        }
      }
    }
  }, [alerts])

  const fetchAlertsPage = async (page: number) => {
    setLoading(true)
    try {
      const offset = (page - 1) * alertsPerPage
      let url = `/api/alerts?limit=${alertsPerPage}&offset=${offset}&verified_only=false`
      
      // Add user location to request if available
      if (userLocation) {
        url += `&latitude=${userLocation.latitude}&longitude=${userLocation.longitude}`
      }
      
      const response = await fetch(url)
      const data = await response.json()
      
      if (data.success && data.data?.alerts) {
        // Filter out invalid coordinates (0,0 or null/undefined) except for MUFON alerts
        const validAlerts = data.data.alerts.filter((alert: Alert) => 
          alert.location.latitude !== 0 || alert.location.longitude !== 0 || alert.reporter_username === 'MUFON' || alert.reporter_username === 'MUFON_Database'
        )
        
        // For server-side pagination, we set the alerts directly
        setAlerts(validAlerts)
        
        // Store total count from API response
        if (data.data.total !== undefined) {
          setTotalAlerts(data.data.total)
        }
      } else {
        setError('Failed to load alerts')
      }
    } catch (err) {
      setError('Failed to connect to API')
    } finally {
      setLoading(false)
    }
  }

  const getTotalPages = () => Math.ceil(totalAlerts / alertsPerPage)
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

        {/* Filters */}
        <div className="mb-6">
          <div className="flex flex-wrap items-center justify-center gap-3">
            {/* UFOBeep Only toggle */}
            <button
              type="button"
              onClick={() => updateUrlParams({ beeps: !showBeepsOnly, page: 1 })}
              aria-pressed={showBeepsOnly}
              className={`inline-flex items-center gap-2 px-4 py-2 rounded-full border text-sm transition-colors ${
                showBeepsOnly
                  ? 'border-brand-primary bg-brand-primary/15 text-brand-primary'
                  : 'border-dark-border bg-dark-surface text-text-secondary hover:text-text-primary hover:border-brand-primary/50'
              }`}
            >
              <span>🔔</span>
              <span>UFOBeep Only</span>
            </button>

            {/* Media Only toggle */}
            <button
              type="button"
              onClick={() => updateUrlParams({ photos: !showPhotosOnly, page: 1 })}
              aria-pressed={showPhotosOnly}
              className={`inline-flex items-center gap-2 px-4 py-2 rounded-full border text-sm transition-colors ${
                showPhotosOnly
                  ? 'border-brand-primary bg-brand-primary/15 text-brand-primary'
                  : 'border-dark-border bg-dark-surface text-text-secondary hover:text-text-primary hover:border-brand-primary/50'
              }`}
            >
              <span>📸</span>
              <span>With Media</span>
            </button>

            {/* Clear filters */}
            {(showBeepsOnly || showPhotosOnly) && (
              <button
                type="button"
                onClick={() => updateUrlParams({ beeps: false, photos: false, page: 1 })}
                className="inline-flex items-center gap-2 px-3 py-2 rounded-md text-sm text-text-tertiary hover:text-text-secondary"
                aria-label="Clear filters"
              >
                ✖ Clear
              </button>
            )}
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
                updateUrlParams({ page: 1 })
                fetchAlertsPage(1)
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
          <p className="text-xl text-text-secondary max-w-2xl mx-auto mb-3">
            Live UFOBeep community reports & MUFON database sightings
          </p>
          <p className="text-sm text-text-tertiary max-w-3xl mx-auto">
            This feed combines real-time UFOBeep &quot;beeps&quot; from our mobile app users with historical reports from the MUFON (Mutual UFO Network) database. 
            Use the filters below to view only UFOBeep originals or browse the complete collection.
          </p>
        </div>


        {/* Alerts Grid */}
        {alerts.length === 0 ? (
          <div className="text-center py-16">
            <div className="text-6xl mb-6">
              {showBeepsOnly ? '🔔' : showPhotosOnly ? '🎥' : '🤔'}
            </div>
            <h2 className="text-2xl font-bold text-text-primary mb-4">
              {showBeepsOnly 
                ? 'No UFOBeep Beeps Yet' 
                : showPhotosOnly 
                  ? 'No Alerts with Media' 
                  : 'No Alerts Yet'}
            </h2>
            <p className="text-text-secondary mb-8">
              {showBeepsOnly
                ? 'Be the first to report a UFOBeep sighting! Download the app to beep.'
                : showPhotosOnly 
                  ? 'Try viewing all alerts or check back later for media reports!'
                  : 'Be the first to report a sighting!'
              }
            </p>
            {(showPhotosOnly || showBeepsOnly) ? (
              <button 
                onClick={() => updateUrlParams({ photos: false, beeps: false, page: 1 })}
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
              <div key={alert.id} id={`alert-${alert.id}`}>
                <AlertCard alert={alert} />
              </div>
            ))}
          </div>
        )}
        
        {/* Bottom filter tiles removed (moved to top segmented control) */}

        {/* Enhanced Pagination */}
        {!loading && !error && alerts.length > 0 && getTotalPages() > 1 && (
          <div className="mt-8 mb-8">
            {/* Pagination Controls */}
            <div className="flex items-center justify-center space-x-2">
              {/* First Page Button */}
              <button
                onClick={() => updateUrlParams({ page: 1 })}
                disabled={currentPage === 1}
                className="px-3 py-2 bg-dark-surface border border-dark-border rounded-lg hover:bg-dark-surface-elevated transition-colors disabled:opacity-50 disabled:cursor-not-allowed text-text-secondary"
                title="First Page"
              >
                ««
              </button>

              {/* Previous Button */}
              <button
                onClick={() => updateUrlParams({ page: Math.max(currentPage - 1, 1) })}
                disabled={currentPage === 1}
                className="px-4 py-2 bg-dark-surface border border-dark-border rounded-lg hover:bg-dark-surface-elevated transition-colors disabled:opacity-50 disabled:cursor-not-allowed text-text-primary"
              >
                ← Previous
              </button>

              {/* Page Numbers */}
              <div className="flex items-center space-x-1">
                {/* Show first page if not visible */}
                {currentPage > 3 && (
                  <>
                    <button
                      onClick={() => updateUrlParams({ page: 1 })}
                      className="px-3 py-2 bg-dark-surface border border-dark-border rounded hover:bg-dark-surface-elevated transition-colors text-text-secondary"
                    >
                      1
                    </button>
                    {currentPage > 4 && <span className="text-text-tertiary px-2">...</span>}
                  </>
                )}

                {/* Pages around current page */}
                {Array.from({ length: getTotalPages() }, (_, i) => i + 1)
                  .filter(page => Math.abs(page - currentPage) <= 2)
                  .map(page => (
                    <button
                      key={page}
                      onClick={() => updateUrlParams({ page })}
                      className={`px-3 py-2 border rounded transition-colors ${
                        page === currentPage
                          ? 'bg-brand-primary border-brand-primary text-white font-semibold'
                          : 'bg-dark-surface border-dark-border hover:bg-dark-surface-elevated text-text-secondary'
                      }`}
                    >
                      {page}
                    </button>
                  ))}

                {/* Show last page if not visible */}
                {currentPage < getTotalPages() - 2 && (
                  <>
                    {currentPage < getTotalPages() - 3 && <span className="text-text-tertiary px-2">...</span>}
                    <button
                      onClick={() => updateUrlParams({ page: getTotalPages() })}
                      className="px-3 py-2 bg-dark-surface border border-dark-border rounded hover:bg-dark-surface-elevated transition-colors text-text-secondary"
                    >
                      {getTotalPages()}
                    </button>
                  </>
                )}
              </div>

              {/* Next Button */}
              <button
                onClick={() => updateUrlParams({ page: currentPage + 1 })}
                disabled={!hasMore}
                className="px-4 py-2 bg-dark-surface border border-dark-border rounded-lg hover:bg-dark-surface-elevated transition-colors disabled:opacity-50 disabled:cursor-not-allowed text-text-primary"
              >
                Next →
              </button>

              {/* Last Page Button */}
              <button
                onClick={() => updateUrlParams({ page: getTotalPages() })}
                disabled={currentPage === getTotalPages()}
                className="px-3 py-2 bg-dark-surface border border-dark-border rounded-lg hover:bg-dark-surface-elevated transition-colors disabled:opacity-50 disabled:cursor-not-allowed text-text-secondary"
                title="Last Page"
              >
                »»
              </button>
            </div>

            {/* Showing results info */}
            <div className="text-center text-text-tertiary text-sm mt-4">
              Showing {((currentPage - 1) * alertsPerPage) + 1} - {Math.min(currentPage * alertsPerPage, totalAlerts)} of {totalAlerts} alerts
              {showBeepsOnly && <span className="text-brand-primary ml-1"> (UFOBeep beeps only)</span>}
              {showPhotosOnly && <span className="text-brand-primary ml-1"> (media only)</span>}
            </div>
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
                <li><Link href="/beep" className="text-text-secondary hover:text-brand-primary transition-colors">Recent Alerts</Link></li>
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
                <li><span className="text-text-secondary">Comments System ✓</span></li>
                <li><span className="text-text-secondary">Real-time Updates ✓</span></li>
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
                Showing {alerts.length} of {totalAlerts} sightings
                {showBeepsOnly && <span className="text-brand-primary ml-1">(UFOBeep beeps only)</span>}
                {showPhotosOnly && <span className="text-brand-primary ml-1">(media only)</span>}
              </span>
            </div>
          </div>
        </div>
      </footer>
    </main>
  )
}

export default function AlertsPage() {
  return (
    <Suspense fallback={
      <main className="min-h-screen py-8 px-4 md:px-8">
        <div className="max-w-6xl mx-auto">
          <div className="text-center">
            <div className="text-6xl mb-6">🛸</div>
            <p className="text-text-secondary">Loading recent alerts...</p>
          </div>
        </div>
      </main>
    }>
      <AlertsPageContent />
    </Suspense>
  )
}
