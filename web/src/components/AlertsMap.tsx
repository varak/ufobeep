'use client'

import { useEffect, useRef, useState } from 'react'
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
  short_url?: string
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
  disableGeolocation?: boolean
  locale?: string
}

// US-biased centering for better geolocation experience
const US_CENTER: [number, number] = [39.5, -98.35]; // continental US centroid

function biasedCenter(
  user: [number, number],
  toward: [number, number] = US_CENTER,
  weightUser = 0.7 // 70% user, 30% US
): [number, number] {
  const lat = user[0] * weightUser + toward[0] * (1 - weightUser);
  const lng = user[1] * weightUser + toward[1] * (1 - weightUser);
  return [lat, lng];
}

export default function AlertsMap({
  alerts = [],
  center = [39.8283, -98.5795], // Center of USA
  zoom = 5.5, // Slightly closer view to fit most of the US
  height = '400px',
  showControls = true,
  onAlertClick,
  disableGeolocation = false,
  locale = 'en'
}: AlertsMapProps) {
  const mapRef = useRef<HTMLDivElement>(null)
  const [selectedAlert, setSelectedAlert] = useState<Alert | null>(null)
  const [mapError, setMapError] = useState(false)

  // Use provided locale or default to 'en'
  const currentLocale = locale || 'en'
  const [hoveredAlert, setHoveredAlert] = useState<Alert | null>(null)
  const [mousePos, setMousePos] = useState({ x: 0, y: 0 })
  // Keep user's exact geolocation separate from the map center we choose
  const [exactUserLocation, setExactUserLocation] = useState<[number, number] | null>(null)
  const [mapCenter, setMapCenter] = useState<[number, number] | null>(null)
  const [mapInitialized, setMapInitialized] = useState(false)
  const [currentZoom, setCurrentZoom] = useState(zoom)
  const mapInstanceRef = useRef<any>(null)
  const markersRef = useRef<any[]>([])
  const clusterIndexRef = useRef<any>(null)
  const featuresRef = useRef<any[]>([])
  const prevAlertsRef = useRef<Alert[]>([])
  const isGettingLocation = useRef(false)
  const [isMediaModalOpen, setIsMediaModalOpen] = useState(false)
  const [selectedMediaIndex, setSelectedMediaIndex] = useState(0)
  const [modalMediaFiles, setModalMediaFiles] = useState<any[]>([])
  const [mapErrorMessage, setMapErrorMessage] = useState<string | null>(null)

  // Validate coordinates defensively to avoid runtime errors
  const isValidLatLng = (loc?: { latitude: any; longitude: any }) => {
    if (!loc || loc.latitude == null || loc.longitude == null) return false
    const lat = Number(loc.latitude)
    const lng = Number(loc.longitude)
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) return false
    if (Math.abs(lat) > 90 || Math.abs(lng) > 180) return false
    // Skip placeholder (0,0)
    if (lat === 0 && lng === 0) return false
    return true
  }

  const asNumLatLng = (loc: { latitude: any; longitude: any }): [number, number] => {
    return [Number(loc.latitude), Number(loc.longitude)]
  }

  // Helper function to create React popup content - defined outside useEffect
  const createPopupContentHelper = (alert: Alert, L: any) => {
    const container = L.DomUtil.create('div')

    const PopupContent = () => {
      const [fullAlert, setFullAlert] = useState<Alert | null>(null)
      const [loading, setLoading] = useState(false)

      // Load full alert data on mount
      useEffect(() => {
        // Check if we have minimal data (only has id and location)
        const isMinimal = !alert.title && !alert.description && alert.location

        if (isMinimal) {
          // This is minimal data, need to fetch full details
          setLoading(true)
          // Use frontend API route
          fetch(`/api/beep/${alert.id}`)
            .then(res => res.json())
            .then(data => {
              if (data.success && data.data) {
                // Map the response to match our Alert interface
                const fullData = {
                  ...alert,
                  title: data.data.title,
                  description: data.data.description,
                  created_at: data.data.created_at,
                  location: data.data.location,  // Always use the full location from API
                  media_files: data.data.media_files?.files || data.data.media_files || [],
                  username: data.data.username,
                  source: data.data.source,
                  short_url: data.data.short_url,
                  enrichment: data.data.enrichment || data.data.enrichment_data || alert.enrichment
                }
                setFullAlert(fullData)
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

      const truncateDescription = (desc: string | null, maxWords = 220) => {
        if (!desc) return ''
        // Remove the embedded location line from MUFON descriptions
        let cleanDesc = desc.replace(/📍\s*Location:\s*[^\n]+\n?/g, '').trim()
        const words = cleanDesc.split(' ')
        if (words.length <= maxWords) return cleanDesc
        return words.slice(0, maxWords).join(' ') + '...'
      }

      const getEnrichedLocation = (alert: any): string => {
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
          const locationMatch = alert.description.match(/📍 Location: ([^\n]+)/)
          if (locationMatch && locationMatch[1].trim()) {
            return locationMatch[1].trim()
          }
        }

        // Fall back to basic location name
        if (alert.location?.name && alert.location.name !== 'Unknown Location') {
          return alert.location.name
        }

        return ''
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

      const isValidDate = (d: any) => {
        if (!d) return false
        const dt = new Date(d as any)
        return !isNaN(dt.getTime())
      }

      const getDisplayDate = (a: any): string => {
        const enriched = a?.enrichment || a?.enrichment_data
        // Prefer event occurrence date (MUFON or enriched cases)
        const firstChoice = enriched?.sighting_datetime || enriched?.event_datetime || enriched?.occurred_at
        const secondChoice = enriched?.report_date || enriched?.reported_at
        const fallback = a?.created_at
        const chosen = firstChoice || secondChoice || fallback
        if (isValidDate(chosen)) return new Date(chosen).toLocaleDateString()
        return ''
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

          {getEnrichedLocation(displayAlert) && (
            <p className="text-xs text-gray-500 mb-1">📍 {getEnrichedLocation(displayAlert)}</p>
          )}

          <p className="text-gray-600 text-xs mb-1">
            {truncateDescription(displayAlert.description)}
            {displayAlert.description && displayAlert.description.split(' ').length > 220 && (
              <a
                href={`/${displayAlert.short_url}`}
                className="text-blue-600 cursor-pointer ml-1">see full report</a>
            )}
          </p>

          {getDisplayDate(displayAlert) && (
            <div className="text-xs text-gray-400 mt-1">{getDisplayDate(displayAlert)}</div>
          )}

          <div className="mt-2">
            <a
              className="text-blue-600 underline text-xs"
              href={`/${displayAlert.short_url}`}
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

    if (disableGeolocation) {
      // Just use the provided center without geolocation
      setMapCenter([Number(center[0]), Number(center[1])])
      return
    }

    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const user: [number, number] = [position.coords.latitude, position.coords.longitude]
          setExactUserLocation([Number(user[0]), Number(user[1])])
          // Center the map with a slight US bias for better initial context
          const biasedCoords = biasedCenter(user, US_CENTER, 0.6)
          setMapCenter([Number(biasedCoords[0]), Number(biasedCoords[1])])
        },
        (error) => {
          // Use provided center or US center as fallback
          setMapCenter([Number(center[0]), Number(center[1])])
        },
        {
          timeout: 10000,
          enableHighAccuracy: true,
          maximumAge: 300000 // 5 minutes
        }
      )
    } else {
      // Use provided center or US center as fallback
      setMapCenter([Number(center[0]), Number(center[1])])
    }
  }, [center, disableGeolocation]) // Include center and disableGeolocation in deps

  useEffect(() => {
    // Dynamically import Leaflet for client-side rendering
    const initMap = async () => {
      if (!mapRef.current || !mapCenter) return

      // If map is already initialized, only update markers if alerts changed
      if (mapInitialized && mapInstanceRef.current) {
        const alertsChanged = JSON.stringify(alerts) !== JSON.stringify(prevAlertsRef.current)
        if (!alertsChanged) return
        
        // Rebuild supercluster index and re-render
        try {
          const leafletModule = await import('leaflet')
          const L: any = (leafletModule as any).default || leafletModule
          const { default: Supercluster } = await import('supercluster')
          const features = alerts
            .filter(a => isValidLatLng(a.location))
            .map(a => ({
              type: 'Feature',
              geometry: { type: 'Point', coordinates: [Number(a.location.longitude), Number(a.location.latitude)] },
              properties: { id: a.id }
            }))
          featuresRef.current = features
          const index = new Supercluster({ radius: 60, maxZoom: 16, minPoints: 2 })
          index.load(features as any)
          clusterIndexRef.current = index
          renderClusters(L, mapInstanceRef.current)
        } catch (e) {
          console.error('Cluster rebuild failed', e)
        }
        
        prevAlertsRef.current = alerts
        return
      }
      
      prevAlertsRef.current = alerts

      try {
        // Dynamically import Leaflet
        console.log('[AlertsMap] loading leaflet (init path)')
        const leafletModule2 = await import('leaflet')
        const L: any = (leafletModule2 as any).default || leafletModule2
        console.log('[AlertsMap] leaflet loaded (init path)')
        
        // Do not mutate Leaflet default icon internals; we avoid default markers entirely

        // Clear existing map if any
        if (mapInstanceRef.current) {
          mapInstanceRef.current.remove()
          mapInstanceRef.current = null
        }

        // Create map without center first to avoid LatLng parsing issues
        const mapZoom = mapCenter[0] === center[0] && mapCenter[1] === center[1] ? zoom : 5.5
        try { console.log('[AlertsMap] creating map instance') } catch {}
        const map = L.map(mapRef.current, {
          zoomControl: true,
          attributionControl: true,
          preferCanvas: false,
          zoomSnap: 0.5,
          zoomDelta: 0.5
        })
        try { console.log('[AlertsMap] setView', mapCenter, mapZoom) } catch {}
        // Now set the view with sanitized numeric coordinates and hard fallback
        try {
          const hasArrayCenter = Array.isArray(mapCenter) && mapCenter.length === 2
          const centerLat = hasArrayCenter ? Number(mapCenter[0]) : 0
          const centerLng = hasArrayCenter ? Number(mapCenter[1]) : 0
          const safeLat = Number.isFinite(centerLat) ? centerLat : 0
          const safeLng = Number.isFinite(centerLng) ? centerLng : 0
          const safeZoom = Number.isFinite(Number(mapZoom)) ? Number(mapZoom) : 5
          map.setView([safeLat, safeLng], safeZoom)
          try { console.log('[AlertsMap] after setView') } catch {}
        } catch (e) {
          console.error('[AlertsMap] setView failed, falling back to [0,0],2', e)
          setMapErrorMessage('setView failed')
          map.setView([0, 0], 2)
        }
        mapInstanceRef.current = map
        setMapInitialized(true) // Mark as initialized

        // Add user location marker ONLY at the exact geolocation (no bias)
        if (exactUserLocation && (exactUserLocation[0] !== 0 || exactUserLocation[1] !== 0)) {
          try { console.log('[AlertsMap] add user location marker at', exactUserLocation) } catch {}
          const userMarker = L.circleMarker([Number(exactUserLocation[0]), Number(exactUserLocation[1])], {
            radius: 7,
            fillColor: '#3b82f6',
            color: '#ffffff',
            weight: 2,
            opacity: 1,
            fillOpacity: 0.9
          }).addTo(map)
          userMarker.bindPopup('You are here')
          try { console.log('[AlertsMap] user location marker added') } catch {}
        }

        // Add OpenStreetMap tile layer with proper settings
        const tileLayer = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
          maxZoom: 19,
          attribution: '© OpenStreetMap contributors',
          crossOrigin: true,
          tileSize: 256,
          zoomOffset: 0
        })
        try {
          tileLayer.addTo(map)
        } catch (e) {
          console.error('[AlertsMap] tileLayer.addTo failed', e)
          setMapErrorMessage('tile layer failed')
          throw e
        }
        
        // Debug breadcrumbs to isolate production failures
        try { console.log('[AlertsMap] init: tile layer added') } catch {}

        // Build cluster index and render, then listen to zoom/pan
        try {
          const { default: Supercluster } = await import('supercluster')
          const features = alerts
            .filter(a => isValidLatLng(a.location))
            .map(a => ({
              type: 'Feature',
              geometry: { type: 'Point', coordinates: [Number(a.location.longitude), Number(a.location.latitude)] },
              properties: { id: a.id }
            }))
          featuresRef.current = features
          const index = new Supercluster({ radius: 60, maxZoom: 16, minPoints: 2 })
          index.load(features as any)
          clusterIndexRef.current = index
          renderClusters(L, map)
        } catch (e) {
          console.error('Cluster init failed', e)
        }

        const rerender = () => {
          const newZoom = map.getZoom()
          setCurrentZoom(newZoom)
          renderClusters(L, map)
        }
        map.on('zoomend', rerender)
        map.on('moveend', rerender)

        // Force map to update its size
        setTimeout(() => {
          try { console.log('[AlertsMap] invalidateSize') } catch {}
          map.invalidateSize()
        }, 100)

        // Initial markers rendered by clustering above

        // Fit map to show all alerts
        if (alerts.length > 0) {
          const validAlerts = alerts.filter(a => isValidLatLng(a.location))
          if (validAlerts.length > 0) {
            const latlngs = validAlerts.map(a => [Number(a.location.latitude), Number(a.location.longitude)] as [number, number])

            // Include user location in bounds if we have their actual location
            if (exactUserLocation) {
              latlngs.push([Number(exactUserLocation[0]), Number(exactUserLocation[1])])
            }

            // Create bounds that include all alerts and user location
            let bounds: any
            try {
              bounds = L.latLngBounds(latlngs)
            } catch (e) {
              console.error('[AlertsMap] latLngBounds failed for', latlngs.length, 'points', e)
              setMapErrorMessage('bounds failed')
              throw e
            }
            try { console.log('[AlertsMap] bounds ready, points=', latlngs.length) } catch {}

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
        console.error('Map initialization error:', error)
        setMapError(true)
        setMapErrorMessage(error instanceof Error ? error.message : String(error))
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

  }, [alerts, mapCenter, exactUserLocation]) // Only re-run when alerts or center changes

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

  // Render clusters or points based on current view
  const renderClusters = (L: any, map: any) => {
    try {
      // Clear existing markers
      markersRef.current.forEach(m => { try { m.remove() } catch {} })
      markersRef.current = []

      const index = clusterIndexRef.current
      if (!index) return

      const b = map.getBounds()
      const bbox: [number, number, number, number] = [b.getWest(), b.getSouth(), b.getEast(), b.getNorth()]
      const zoom = Math.round(map.getZoom() || 0)
      const clusters = index.getClusters(bbox, zoom)

      clusters.forEach((c: any) => {
        const [lng, lat] = c.geometry.coordinates
        if (c.properties && c.properties.cluster) {
          const count = c.properties.point_count
          const size = count < 10 ? 28 : count < 50 ? 32 : count < 250 ? 38 : 44
          const html = `
            <div style="
              background: rgba(57,255,20,0.15);
              border: 2px solid #39FF14;
              color: #fff;
              width: ${size}px; height: ${size}px;
              border-radius: 50%;
              display: flex; align-items: center; justify-content: center;
              box-shadow: 0 2px 6px rgba(0,0,0,0.4);
              font-weight: 700; font-size: 12px;"
            >${count}</div>`
          const divIcon = L.divIcon({ html, className: 'cluster-marker', iconSize: [size, size], iconAnchor: [size/2, size/2] })
          const marker = L.marker([lat, lng], { icon: divIcon })
          marker.on('click', () => {
            const nextZoom = Math.min(index.getClusterExpansionZoom(c.id), 18)
            map.flyTo([lat, lng], nextZoom, { duration: 0.6 })
          })
          marker.addTo(map)
          markersRef.current.push(marker)
        } else {
          // Individual point
          const id = c.properties && c.properties.id
          const alert = (alerts as any[]).find(a => a.id === id)
          if (!alert || !isValidLatLng(alert.location)) return
          const marker = createUfoMarker(L, alert, map)
          const popup = L.popup({ maxWidth: 350, className: 'custom-popup' }).setContent(createPopupContentHelper(alert, L))
          marker.bindPopup(popup)
          marker.addTo(map)
          markersRef.current.push(marker)
        }
      })
    } catch (e) {
      console.error('renderClusters failed', e)
    }
  }

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
      
      return L.marker([Number(alert.location.latitude), Number(alert.location.longitude)], { icon: customIcon })
    } else {
      // Use circle markers for regular beep sightings (existing behavior)
      return L.circleMarker(
        [Number(alert.location.latitude), Number(alert.location.longitude)],
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
            {mapErrorMessage && (
              <p className="text-text-tertiary text-xs mt-2">{mapErrorMessage}</p>
            )}
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
      <div className="absolute top-4 right-4 flex gap-2 items-center z-10">
        {/* Recenter to my location (if available) */}
        {exactUserLocation && (
          <button
            onClick={() => {
              if (mapInstanceRef.current && exactUserLocation) {
                try {
                  mapInstanceRef.current.flyTo([Number(exactUserLocation[0]), Number(exactUserLocation[1])], Math.max(mapInstanceRef.current.getZoom() || 5.5, 8), { duration: 0.8 })
                } catch {}
              }
            }}
            className="bg-dark-surface/90 hover:bg-dark-surface-elevated border border-dark-border text-xs text-text-primary px-3 py-2 rounded-lg"
            title="Go to my location"
          >
            ⦿ My location
          </button>
        )}
        <div className="bg-dark-surface/90 backdrop-blur-sm p-2 rounded-lg border border-dark-border text-xs text-text-tertiary">
          Click & drag to pan • Scroll to zoom
        </div>
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
