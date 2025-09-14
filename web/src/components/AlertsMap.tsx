'use client'

import { useEffect, useRef, useState } from 'react'
import { useParams } from 'next/navigation'
import { createRoot } from 'react-dom/client'
import { AlertTitleUtils } from '@/utils/alert-title-utils'
import { getAlertSlug } from '@/utils/slug'
import MediaGalleryModal from '@/components/MediaGalleryModal'
import Link from 'next/link'

interface Alert {
  id: string
  title: string | null
  description: string | null
  location: {
    latitude: number
    longitude: number
    name: string
  }
  alert_level: string
  created_at: string
  source?: string
  username?: string
  enrichment_data?: any
  media_files?: Array<{
    id: string
    type: string
    url: string
    thumbnail_url: string
    web_url?: string
    preview_url?: string
  }>
}

interface AlertsMapProps {
  alerts?: Alert[]
  center?: [number, number]
  zoom?: number
  height?: string
  showControls?: boolean
  onAlertClick?: (alert: Alert) => void
}

export default function AlertsMap({
  alerts = [],
  center = [39.8283, -98.5795], // Center of USA
  zoom = 4,
  height = '400px',
  showControls = true,
  onAlertClick
}: AlertsMapProps) {
  const mapRef = useRef<HTMLDivElement>(null)
  const [selectedAlert, setSelectedAlert] = useState<Alert | null>(null)
  const [mapError, setMapError] = useState(false)
  const params = useParams()

  // Get current language from URL or default to 'en'
  const currentLocale = (params?.locale as string) || 'en'
  const [hoveredAlert, setHoveredAlert] = useState<Alert | null>(null)
  const [mousePos, setMousePos] = useState({ x: 0, y: 0 })
  const [userLocation, setUserLocation] = useState<[number, number] | null>(null)
  const [mapInitialized, setMapInitialized] = useState(false)
  const [currentZoom, setCurrentZoom] = useState(zoom)
  const mapInstanceRef = useRef<any>(null)
  const markersRef = useRef<any[]>([])
  const prevAlertsRef = useRef<Alert[]>([])
  const isGettingLocation = useRef(false)
  const [isMediaModalOpen, setIsMediaModalOpen] = useState(false)
  const [selectedMediaIndex, setSelectedMediaIndex] = useState(0)
  const [modalMediaFiles, setModalMediaFiles] = useState<any[]>([])

  // Helper function to create React popup content - defined outside useEffect
  const createPopupContentHelper = (alert: Alert, L: any) => {
    const container = L.DomUtil.create('div')

    const PopupContent = () => {
      const [fullAlert, setFullAlert] = useState<Alert | null>(null)
      const [loading, setLoading] = useState(false)

      // Load full alert data on mount
      useEffect(() => {
        if (!alert.title) {
          // This is minimal data, need to fetch full details
          setLoading(true)
          fetch(`/api/beep/${alert.id}`)
            .then(res => res.json())
            .then(data => {
              if (data.success && data.data) {
                setFullAlert(data.data)
              }
            })
            .catch(err => console.error('Error loading alert details:', err))
            .finally(() => setLoading(false))
        } else {
          // Already have full data
          setFullAlert(alert)
        }
      }, [])

      const displayAlert = fullAlert || alert

      const truncateDescription = (desc: string | null, maxWords = 400) => {
        if (!desc) return ''
        // Remove the embedded location line from MUFON descriptions
        let cleanDesc = desc.replace(/📍\s*Location:\s*[^\n]+\n?/g, '').trim()
        const words = cleanDesc.split(' ')
        if (words.length <= maxWords) return cleanDesc
        return words.slice(0, maxWords).join(' ') + '...'
      }

      const handleMediaClick = (index: number) => {
        setIsMediaModalOpen(true)
        setSelectedMediaIndex(index)
        setModalMediaFiles(displayAlert.media_files || [])
      }

      if (loading) {
        return (
          <div className="text-sm w-80 p-4 text-center">
            <div className="text-gray-500">Loading...</div>
          </div>
        )
      }

      return (
        <div className="text-sm w-80">
          <h4 className="font-semibold text-gray-900 mb-1">
            {displayAlert.title ? AlertTitleUtils.getShortTitle(displayAlert) : 'UFO Sighting'}
          </h4>

          {/* Media thumbnails */}
          {displayAlert.media_files && displayAlert.media_files.length > 0 && (
            <div className="flex gap-1 mb-2 overflow-x-auto">
              {displayAlert.media_files.slice(0, 4).map((media, index) => (
                <div
                  key={index}
                  className="relative flex-shrink-0 w-16 h-16 bg-gray-100 rounded overflow-hidden cursor-pointer hover:ring-2 hover:ring-blue-500 transition-all"
                  onClick={() => handleMediaClick(index)}
                >
                  <img
                    src={media.web_url || media.thumbnail_url || media.url}
                    alt={`Media ${index + 1}`}
                    className="w-full h-full object-cover"
                    onError={(e) => {
                      const target = e.target as HTMLImageElement
                      target.style.display = 'none'
                      const parent = target.parentElement
                      if (parent) {
                        parent.innerHTML = '<div class="w-full h-full flex items-center justify-center bg-gray-200 text-gray-400 text-xs">🖼️</div>'
                      }
                    }}
                  />
                  {media.type === 'video' && (
                    <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                      <div className="bg-black/60 rounded-full p-1">
                        <svg className="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 20 20">
                          <path d="M6.3 4.1c0-.8.9-1.3 1.5-.9l8.4 4.9c.6.4.6 1.4 0 1.8L7.8 14.8c-.6.4-1.5-.1-1.5-.9V4.1z"/>
                        </svg>
                      </div>
                    </div>
                  )}
                </div>
              ))}
              {displayAlert.media_files.length > 4 && (
                <div className="flex-shrink-0 w-16 h-16 bg-gray-200 rounded flex items-center justify-center text-gray-600 text-xs">
                  +{displayAlert.media_files.length - 4}
                </div>
              )}
            </div>
          )}

          <p className="text-gray-600 text-xs mb-2">
            {truncateDescription(displayAlert.description)}
            {displayAlert.description && displayAlert.description.split(' ').length > 400 && (
              <span className="text-blue-600 cursor-pointer ml-1">see full report</span>
            )}
          </p>

          {displayAlert.location?.name && displayAlert.location.name !== 'Unknown Location' && (
            <p className="text-xs text-gray-500 mb-1">📍 {displayAlert.location.name}</p>
          )}

          <div className="text-xs text-gray-400 mt-1">
            {new Date(displayAlert.created_at).toLocaleDateString()}
          </div>

          <div className="mt-2">
            <a
              className="text-blue-600 underline text-xs"
              href={`/beep/${currentLocale}/${getAlertSlug({
                id: displayAlert.id || alert.id,
                title: displayAlert.title,
                created_at: displayAlert.created_at,
                location: displayAlert.location,
                reporter_username: displayAlert.username,
                description: displayAlert.description,
                source: displayAlert.source
              }, currentLocale)}`}
            >
              View details →
            </a>
          </div>
        </div>
      )
    }

    const root = createRoot(container)
    root.render(<PopupContent />)

    return container
  }

  // Get user's location on mount - only once
  useEffect(() => {
    if (isGettingLocation.current) return
    isGettingLocation.current = true
    
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const userCoords: [number, number] = [position.coords.latitude, position.coords.longitude]
          setUserLocation(userCoords)
        },
        (error) => {
          // Use provided center or US center as fallback
          setUserLocation(center)
        },
        {
          timeout: 10000,
          enableHighAccuracy: true,
          maximumAge: 300000 // 5 minutes
        }
      )
    } else {
      // Use provided center or US center as fallback
      setUserLocation(center)
    }
  }, [center]) // Include center in deps but guard with ref

  useEffect(() => {
    // Dynamically import Leaflet for client-side rendering
    const initMap = async () => {
      if (!mapRef.current || !userLocation) return

      // If map is already initialized, only update markers if alerts changed
      if (mapInitialized && mapInstanceRef.current) {
        const alertsChanged = JSON.stringify(alerts) !== JSON.stringify(prevAlertsRef.current)
        if (!alertsChanged) return
        
        // Just update markers without recreating the map
        const L = (await import('leaflet')).default
        
        // Clear existing markers
        markersRef.current.forEach(marker => {
          if (marker) marker.remove()
        })
        markersRef.current = []
        
        // Filter alerts by zoom level then add markers with UFO classification support
        const filteredAlerts = filterAlertsByZoom(alerts, mapInstanceRef.current.getZoom())
        filteredAlerts.forEach((alert) => {
          if (displayAlert.location.latitude === 0 && displayAlert.location.longitude === 0) return
          
          const marker = createUfoMarker(L, alert, mapInstanceRef.current)

          // Use React component popup
          const popup = L.popup({
            maxWidth: 350,
            className: 'custom-popup'
          }).setContent(createPopupContentHelper(alert, L))

          marker.bindPopup(popup)
          marker.on('click', () => {
            setSelectedAlert(alert)
            if (onAlertClick) onAlertClick(alert)
          })
          
          marker.addTo(mapInstanceRef.current)
          markersRef.current.push(marker)
        })
        
        prevAlertsRef.current = alerts
        return
      }
      
      prevAlertsRef.current = alerts

      try {
        // Dynamically import Leaflet
        const L = (await import('leaflet')).default
        
        // Fix Leaflet icon paths issue
        delete (L.Icon.Default.prototype as any)._getIconUrl
        L.Icon.Default.mergeOptions({
          iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
          iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
          shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
        })
        
        // Import Leaflet CSS
        if (typeof window !== 'undefined' && !document.querySelector('#leaflet-css')) {
          const link = document.createElement('link')
          link.id = 'leaflet-css'
          link.rel = 'stylesheet'
          link.href = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css'
          document.head.appendChild(link)
        }

        // Clear existing map if any
        if (mapInstanceRef.current) {
          mapInstanceRef.current.remove()
          mapInstanceRef.current = null
        }

        // Create map - center on user location with appropriate zoom
        const mapZoom = userLocation[0] === center[0] && userLocation[1] === center[1] ? zoom : 10
        const map = L.map(mapRef.current, {
          center: userLocation,
          zoom: mapZoom,
          zoomControl: true,
          attributionControl: true,
          preferCanvas: false
        })
        mapInstanceRef.current = map
        setMapInitialized(true) // Mark as initialized
        
        // Add user location marker if we have their actual location
        if (userLocation[0] !== center[0] || userLocation[1] !== center[1]) {
          L.marker(userLocation, {
            title: 'Your Location',
            zIndexOffset: 1000
          }).addTo(map).bindPopup('You are here')
        }

        // Add OpenStreetMap tile layer with proper settings
        const tileLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
          maxZoom: 19,
          attribution: '© OpenStreetMap contributors',
          crossOrigin: true,
          tileSize: 256,
          zoomOffset: 0
        })
        
        tileLayer.addTo(map)

        // Add zoom change listener to update markers based on zoom level
        map.on('zoomend', () => {
          const newZoom = map.getZoom()
          setCurrentZoom(newZoom)

          // Update markers based on new zoom level
          markersRef.current.forEach(marker => {
            if (marker) marker.remove()
          })
          markersRef.current = []

          // Re-add markers with new zoom filtering
          const filteredAlerts = filterAlertsByZoom(alerts, newZoom)
          filteredAlerts.forEach((alert) => {
            if (displayAlert.location.latitude === 0 && displayAlert.location.longitude === 0) return

            const marker = createUfoMarker(L, alert, map)

            const popup = L.popup({
              maxWidth: 350,
              className: 'custom-popup'
            }).setContent(createPopupContentHelper(alert, L))

            marker.bindPopup(popup)
            marker.on('click', () => {
              setSelectedAlert(alert)
              if (onAlertClick) onAlertClick(alert)
            })

            marker.addTo(map)
            markersRef.current.push(marker)
          })
        })

        // Force map to update its size
        setTimeout(() => {
          map.invalidateSize()
        }, 100)

        // Clear existing markers
        markersRef.current.forEach(marker => {
          if (marker) marker.remove()
        })
        markersRef.current = []

        // Filter alerts by zoom level then add markers for alerts (skip invalid coordinates) with UFO classification support
        const filteredAlerts = filterAlertsByZoom(alerts, currentZoom)
        filteredAlerts.forEach((alert) => {
          if (displayAlert.location.latitude === 0 && displayAlert.location.longitude === 0) {
            return // Skip invalid coordinates (0,0 fallback)
          }

          const marker = createUfoMarker(L, alert, map)

          // Add popup with React component
          const popup = L.popup({
            maxWidth: 350,
            className: 'custom-popup'
          }).setContent(createPopupContentHelper(alert, L))

          marker.bindPopup(popup)
          
          // Add click handler
          marker.on('click', () => {
            setSelectedAlert(alert)
            if (onAlertClick) onAlertClick(alert)
          })

          marker.addTo(map)
          markersRef.current.push(marker)
        })

        // Fit map to show all alerts with user-centric view
        if (alerts.length > 0) {
          const validAlerts = alerts.filter(a => a.location.latitude !== 0 && a.location.longitude !== 0)
          if (validAlerts.length > 0) {
            const latlngs = validAlerts.map(a => [a.location.latitude, a.location.longitude] as [number, number])
            
            // Include user location in bounds if we have their actual location
            if (userLocation[0] !== center[0] || userLocation[1] !== center[1]) {
              latlngs.push(userLocation)
            }
            
            // Create bounds that include all alerts and user location
            const bounds = L.latLngBounds(latlngs)
            
            // If bounds are very small (all points close together), ensure minimum zoom
            const boundsSizeLat = bounds.getNorth() - bounds.getSouth()
            const boundsSizeLng = bounds.getEast() - bounds.getWest()
            
            if (boundsSizeLat < 0.1 && boundsSizeLng < 0.1) {
              // All points are very close, use moderate zoom around the area
              map.setView(bounds.getCenter(), 12)
            } else {
              map.fitBounds(bounds, { padding: [20, 20] })
            }
          }
        }

      } catch (error) {
        setMapError(true)
      }
    }

    initMap()

    // Cleanup function
    return () => {
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove()
        mapInstanceRef.current = null
        setMapInitialized(false)
      }
    }

  }, [alerts, userLocation]) // Only re-run when alerts or user location changes

  // Handle window resize
  useEffect(() => {
    const handleResize = () => {
      if (mapInstanceRef.current) {
        mapInstanceRef.current.invalidateSize()
      }
    }

    window.addEventListener('resize', handleResize)
    return () => window.removeEventListener('resize', handleResize)
  }, [])

  const filterAlertsByZoom = (alerts: Alert[], zoomLevel: number) => {
    // Show ALL alerts when zoomed in, consolidate when zoomed out
    let maxAlerts: number
    if (zoomLevel >= 12) {
      maxAlerts = 10000 // Zoomed in - show ALL local alerts
    } else if (zoomLevel >= 8) {
      maxAlerts = 500 // Medium zoom - show many regional alerts
    } else if (zoomLevel >= 5) {
      maxAlerts = 200 // Zoomed out - show 200 alerts
    } else {
      maxAlerts = 100 // Very zoomed out - show 100 most recent alerts
    }

    // Sort by most recent and take only the limit
    const sortedAlerts = [...alerts].sort((a, b) =>
      new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
    )

    return sortedAlerts.slice(0, maxAlerts)
  }

  const getAlertColor = (level: string) => {
    switch (level?.toLowerCase()) {
      case 'critical': return '#ef4444'
      case 'high': return '#f97316'
      case 'medium': return '#eab308'
      case 'low': return '#22c55e'
      default: return '#39FF14'
    }
  }

  const getUfoIcon = (alert: Alert) => {
    // Check if this is a MUFON classified sighting
    if (alert.source === 'mufon' || alert.username === 'MUFON_Database') {
      // Try to get UFO classification from enrichment data
      if (alert.enrichment_data && alert.enrichment_data.ufo_classification) {
        const classification = alert.enrichment_data.ufo_classification
        if (classification.type) {
          const ufoType = classification.type.toLowerCase()
          
          // Return appropriate Unicode symbols for each UFO type
          switch (ufoType) {
            case 'triangle':
              return '△' // Triangle
            case 'disc':
            case 'saucer':
              return '●' // Disc/circle
            case 'sphere':
              return '○' // Sphere
            case 'cigar':
              return '─' // Horizontal line for cigar
            case 'light':
              return '☀' // Sun/light
            case 'formation':
              return '⋯' // Multiple dots for formation
            case 'boomerang':
              return '‹' // Angular shape
            case 'rectangle':
              return '▢' // Rectangle
            case 'diamond':
              return '◊' // Diamond
            default:
              return '?' // Unknown UFO type
          }
        }
      }
      // Default MUFON icon if no classification
      return '?'
    }
    
    // Regular UFO beep sightings use standard pin
    return '📍'
  }

  const createUfoMarker = (L: any, alert: Alert, map: any) => {
    const isClassifiedUfo = alert.source === 'mufon' || alert.username === 'MUFON_Database'
    
    if (isClassifiedUfo) {
      // Create custom HTML marker for UFO types
      const iconSymbol = getUfoIcon(alert)
      const color = getAlertColor(alert.alert_level)
      
      const customIcon = L.divIcon({
        html: `
          <div style="
            background: ${color}; 
            border: 2px solid white; 
            border-radius: 50%; 
            width: 24px; 
            height: 24px; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            font-size: 12px; 
            font-weight: bold;
            color: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.4);
          ">${iconSymbol}</div>
        `,
        className: 'ufo-marker',
        iconSize: [24, 24],
        iconAnchor: [12, 12]
      })
      
      return L.marker([displayAlert.location.latitude, displayAlert.location.longitude], { icon: customIcon })
    } else {
      // Use circle markers for regular beep sightings (existing behavior)
      return L.circleMarker(
        [displayAlert.location.latitude, displayAlert.location.longitude],
        {
          radius: 8,
          fillColor: getAlertColor(alert.alert_level),
          color: '#ffffff',
          weight: 2,
          opacity: 1,
          fillOpacity: 0.8
        }
      )
    }
  }

  return (
    <div className="relative rounded-lg overflow-hidden border border-dark-border bg-dark-surface">
      <div 
        ref={mapRef}
        style={{ height, minHeight: '320px' }}
        className="relative bg-dark-background z-0"
      />
      
      {/* Fallback when map fails to render */}
      {mapError && (
        <div className="absolute inset-0 flex items-center justify-center bg-dark-background">
          <div className="text-center">
            <div className="text-4xl mb-4">🗺️</div>
            <p className="text-text-secondary mb-2">Interactive map unavailable</p>
            <p className="text-text-tertiary text-sm">{alerts.length} sightings available</p>
          </div>
        </div>
      )}
      
      {/* Map overlay with real data */}
      <div className="absolute top-4 left-4 bg-dark-surface/90 backdrop-blur-sm p-3 rounded-lg border border-dark-border z-10">
        <div className="flex items-center gap-2 mb-2">
          <div className="w-2 h-2 bg-brand-primary rounded-full animate-pulse"></div>
          <span className="text-sm text-brand-primary font-medium">Live Sightings</span>
        </div>
        <div className="text-xs text-text-secondary">
          {alerts.length} active reports
        </div>
      </div>

      {/* Map instructions */}
      <div className="absolute top-4 right-4 bg-dark-surface/90 backdrop-blur-sm p-2 rounded-lg border border-dark-border z-10 text-xs text-text-tertiary">
        Click & drag to pan • Scroll to zoom
      </div>

      {/* Legend */}
      <div className="absolute bottom-4 right-4 bg-dark-surface/90 backdrop-blur-sm p-2 rounded-lg border border-dark-border text-xs z-10">
        <div className="space-y-1">
          <div className="flex items-center gap-2 group relative">
            <div className="w-2 h-2 rounded-full bg-red-500"></div>
            <span className="text-text-tertiary">Critical</span>
            <div className="absolute left-0 bottom-full mb-2 bg-dark-surface-elevated border border-dark-border p-2 rounded text-xs whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none z-20">
              Immediate threat or extraordinary phenomenon
            </div>
          </div>
          <div className="flex items-center gap-2 group relative">
            <div className="w-2 h-2 rounded-full bg-orange-500"></div>
            <span className="text-text-tertiary">High</span>
            <div className="absolute left-0 bottom-full mb-2 bg-dark-surface-elevated border border-dark-border p-2 rounded text-xs whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none z-20">
              Significant sighting with clear evidence
            </div>
          </div>
          <div className="flex items-center gap-2 group relative">
            <div className="w-2 h-2 rounded-full bg-yellow-500"></div>
            <span className="text-text-tertiary">Medium</span>
            <div className="absolute left-0 bottom-full mb-2 bg-dark-surface-elevated border border-dark-border p-2 rounded text-xs whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none z-20">
              Notable anomaly requiring investigation
            </div>
          </div>
          <div className="flex items-center gap-2 group relative">
            <div className="w-2 h-2 rounded-full bg-green-500"></div>
            <span className="text-text-tertiary">Low</span>
            <div className="absolute left-0 bottom-full mb-2 bg-dark-surface-elevated border border-dark-border p-2 rounded text-xs whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none z-20">
              Minor observation or distant object
            </div>
          </div>
        </div>
      </div>

      {/* Media Gallery Modal */}
      {isMediaModalOpen && modalMediaFiles.length > 0 && (
        <MediaGalleryModal
          isOpen={isMediaModalOpen}
          onClose={() => {
            setIsMediaModalOpen(false)
            setModalMediaFiles([])
          }}
          mediaFiles={modalMediaFiles}
          initialIndex={selectedMediaIndex}
          alertTitle={selectedAlert?.title || 'UFO Sighting'}
        />
      )}
    </div>
  )
}
