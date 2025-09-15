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

// Extend Window interface for spiderfy functionality
declare global {
  interface Window {
    __ufobeepSpider?: {
      markers: any[]
      lines: any[]
    } | null
  }
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
  const hasSavedViewRef = useRef(false)
  const prevAlertsRef = useRef<Alert[]>([])
  const isGettingLocation = useRef(false)
  const [isMediaModalOpen, setIsMediaModalOpen] = useState(false)
  const [selectedMediaIndex, setSelectedMediaIndex] = useState(0)
  const [modalMediaFiles, setModalMediaFiles] = useState<any[]>([])
  const [mapErrorMessage, setMapErrorMessage] = useState<string | null>(null)
  const [debugEnabled, setDebugEnabled] = useState(false)
  const [debugCounts, setDebugCounts] = useState<{ mufon: number; ufobeep: number; other: number; total: number }>({ mufon: 0, ufobeep: 0, other: 0, total: 0 })

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

  // Source helpers (do NOT filter out unknown-source alerts)
  const isMufonAlert = (a: any) => {
    const src = (a?.source || '').toString().toLowerCase()
    const reporter = (a?.reporter_username || a?.username || '').toString()
    return src === 'mufon' || reporter === 'MUFON' || reporter === 'MUFON_Database'
  }
  const isNuforcAlert = (a: any) => {
    const src = (a?.source || '').toString().toLowerCase()
    const reporter = (a?.reporter_username || a?.username || '').toString()
    return src === 'nuforc' || reporter === 'NUFORC' || reporter === 'NUFORC_Database'
  }
  const isUfoBeepAlert = (a: any) => !isMufonAlert(a) && !isNuforcAlert(a)

  // Debug toggle from query param
  useEffect(() => {
    try {
      const sp = new URLSearchParams(window.location.search)
      if (sp.get('debug') === '1') setDebugEnabled(true)
    } catch {}
  }, [])

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
          const loader = () => {
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
                    enrichment_data: data.data.enrichment_data || data.data.enrichment
                  }
                  setFullAlert(fullData as any)
                }
              })
              .catch(err => console.error('Error loading alert details:', err))
              .finally(() => setLoading(false))
          }
          // Defer slightly if low-end to keep interactions smooth
          try {
            const c: any = (navigator as any).connection
            const saveData = !!c?.saveData
            const type = (c?.effectiveType || '').toLowerCase()
            const cores = (navigator as any).hardwareConcurrency || 4
            const low = saveData || type === '2g' || type === 'slow-2g' || type === '3g' || cores <= 4
            if (low && 'requestIdleCallback' in window) {
              ;(window as any).requestIdleCallback(loader, { timeout: 300 })
            } else if (low) {
              setTimeout(loader, 150)
            } else {
              loader()
            }
          } catch {
            loader()
          }
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

      // Try to parse a variety of common date formats
      const normalizeDate = (d: any): Date | null => {
        if (!d) return null
        if (d instanceof Date && !isNaN(d.getTime())) return d
        // Numbers (epoch ms or seconds)
        if (typeof d === 'number') {
          const ms = d > 1e12 ? d : d * 1000
          const dt = new Date(ms)
          return isNaN(dt.getTime()) ? null : dt
        }
        if (typeof d === 'string') {
          // If string has date and time separated by space, convert to ISO-ish
          let s = d.trim()
          if (/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}(:\d{2})?$/.test(s)) {
            s = s.replace(' ', 'T') + 'Z'
          }
          const dt = new Date(s)
          return isNaN(dt.getTime()) ? null : dt
        }
        return null
      }

      const pickFirstDate = (obj: any, keys: string[]): Date | null => {
        if (!obj) return null
        for (const k of keys) {
          const v = obj[k]
          const dt = normalizeDate(v)
          if (dt) return dt
        }
        return null
      }

      const getSightingDate = (a: any): string => {
        const e = a?.enrichment || a?.enrichment_data
        // Prefer actual occurrence; include extra fallbacks for MUFON
        const dt = pickFirstDate(e, ['sighting_datetime', 'event_datetime', 'occurred_at', 'sighting_date', 'event_date'])
        return dt ? dt.toLocaleDateString() : ''
      }

      const getReportedDate = (a: any): string => {
        const e = a?.enrichment || a?.enrichment_data
        const dt = pickFirstDate(e, ['report_date', 'reported_at', 'submission_date']) || normalizeDate(a?.created_at)
        return dt ? dt.toLocaleDateString() : ''
      }

      return (
        <div className="text-sm w-80">
          <h4 className="font-semibold text-gray-900 mb-1">
            {(displayAlert.source === 'mufon' || displayAlert.username === 'MUFON_Database')
              ? (displayAlert.title ? AlertTitleUtils.getShortTitle(displayAlert as any) : 'MUFON Sighting')
              : 'UFOBeep UFO Alert'}
          </h4>

          {/* Media thumbnails */}
          {displayAlert.media_files && displayAlert.media_files.length > 0 && (
            <div className="flex gap-1 mb-2 overflow-x-auto">
              {(displayAlert.media_files.length > 0 ? displayAlert.media_files.slice(0, 4) : []).map((media, index) => (
                <div
                  key={index}
                  className="relative flex-shrink-0 w-16 h-16 bg-gray-100 rounded overflow-hidden cursor-pointer hover:ring-2 hover:ring-blue-500 transition-all"
                  onClick={() => handleMediaClick(index)}
                >
                  <img
                    src={media.thumbnail_url || media.web_url || media.url}
                    alt={`Media ${index + 1}`}
                    className="w-full h-full object-cover"
                    loading="lazy"
                    decoding="async"
                    referrerPolicy="no-referrer"
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

          {(getSightingDate(displayAlert) || getReportedDate(displayAlert)) && (
            <div className="text-xs text-gray-400 mt-1 space-y-0.5">
              {getSightingDate(displayAlert) && (
                <div>🕒 Sighted: {getSightingDate(displayAlert)}</div>
              )}
              {getReportedDate(displayAlert) && (
                <div>📝 Reported: {getReportedDate(displayAlert)}</div>
              )}
            </div>
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

  // Load saved view if available
  useEffect(() => {
    try {
      const raw = typeof window !== 'undefined' && localStorage.getItem('ufobeep:map:view')
      if (raw) {
        const v = JSON.parse(raw)
        if (Array.isArray(v.center) && v.center.length === 2 && Number.isFinite(v.zoom)) {
          setMapCenter([Number(v.center[0]), Number(v.center[1])])
          setCurrentZoom(Number(v.zoom))
          hasSavedViewRef.current = true
        }
      }
    } catch {}
  }, [])

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
          if (hasSavedViewRef.current) return
          const user: [number, number] = [position.coords.latitude, position.coords.longitude]
          setExactUserLocation([Number(user[0]), Number(user[1])])
          // Center the map with a slight US bias for better initial context
          const biasedCoords = biasedCenter(user, US_CENTER, 0.6)
          setMapCenter([Number(biasedCoords[0]), Number(biasedCoords[1])])
        },
        (error) => {
          if (!hasSavedViewRef.current) {
            // Use provided center or US center as fallback
            setMapCenter([Number(center[0]), Number(center[1])])
          }
        },
        {
          timeout: 10000,
          enableHighAccuracy: true,
          maximumAge: 300000 // 5 minutes
        }
      )
    } else {
      // Use provided center or US center as fallback
      if (!hasSavedViewRef.current) {
        setMapCenter([Number(center[0]), Number(center[1])])
      }
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
          const index = new Supercluster({ radius: 90, maxZoom: 16, minPoints: 2 })
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
        // Move default Leaflet zoom controls away from overlays
        try { map.zoomControl.setPosition('bottomleft') } catch {}
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
          const index = new Supercluster({ radius: 90, maxZoom: 16, minPoints: 2 })
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
          try {
            const ctr = map.getCenter()
            localStorage.setItem('ufobeep:map:view', JSON.stringify({ center: [ctr.lat, ctr.lng], zoom: newZoom }))
          } catch {}
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
      // Use ceil so clusters break apart sooner as you zoom in
      const zoom = Math.ceil(map.getZoom() || 0)
      const clusters = index.getClusters(bbox, zoom)

      // Build jitter map for points sharing identical coordinates in this viewport
      const pointItems: Array<{id: string; lat: number; lng: number}> = []
      // Update debug counts by class within current bounds
      try {
        if (debugEnabled) {
          const b2 = map.getBounds()
          let mufon = 0, ufobeep = 0, other = 0, total = 0
          for (const a of alerts as any[]) {
            if (!isValidLatLng(a.location)) continue
            const la = Number(a.location.latitude), lo = Number(a.location.longitude)
            if (!b2.contains({ lat: la, lng: lo })) continue
            total++
            if (isMufonAlert(a)) mufon++
            else if (isUfoBeepAlert(a)) ufobeep++
            else other++
          }
          setDebugCounts({ mufon, ufobeep, other, total })
        }
      } catch {}

      clusters.forEach((c: any) => {
        if (!(c.properties && c.properties.cluster)) {
          const [lng, lat] = c.geometry.coordinates
          const id = String(c.properties?.id)
          pointItems.push({ id, lat, lng })
        }
      })
      const groups = new Map<string, Array<{id: string; lat: number; lng: number}>>()
      pointItems.forEach(p => {
        const key = `${p.lat.toFixed(5)},${p.lng.toFixed(5)}`
        const arr = groups.get(key) || []
        arr.push(p)
        groups.set(key, arr)
      })
      // Build overlap count per id for reliable click behavior
      const overlapCount = new Map<string, number>()
      groups.forEach((arr) => {
        arr.forEach(p => overlapCount.set(String(p.id), arr.length))
      })
      // No jitter by default; we'll spiderfy on click using these groups
      const jitterMap = new Map<string, [number, number]>()
      groups.forEach((arr, key) => {
        if (arr.length <= 1) return
        const [lat0Str, lng0Str] = key.split(',')
        const lat0 = parseFloat(lat0Str)
        const lng0 = parseFloat(lng0Str)
        const cosLat = Math.cos((lat0 * Math.PI) / 180)
        const degPerMeterLat = 1 / 111320
        const degPerMeterLng = 1 / (111320 * (cosLat || 1))
        // Determine if group contains any UFOBeep alerts
        let hasUfoBeep = false
        for (const p of arr) {
          const a = (alerts as any[]).find(x => String(x.id) === String(p.id))
          const src = (a?.source || '').toString().toLowerCase()
          if (['beep','ufobeep','ufo_beep','ufo-beep'].includes(src) || (a as any)?.b === 1) { hasUfoBeep = true; break }
        }
        // Scale jitter more at lower zooms so points separate sooner
        const zoomFactor = zoom < 16 ? (1 + (16 - zoom) * 0.3) : 1
        const base = hasUfoBeep ? 90 * zoomFactor : 24 * zoomFactor // meters
        const r = Math.min(hasUfoBeep ? 220 * zoomFactor : 100 * zoomFactor, base + arr.length * (hasUfoBeep ? 10 : 4) * zoomFactor)
        arr.forEach((p, i) => {
          const angle = (2 * Math.PI * i) / arr.length
          const dLat = (r * Math.sin(angle)) * degPerMeterLat
          const dLng = (r * Math.cos(angle)) * degPerMeterLng
          jitterMap.set(p.id, [lat0 + dLat, lng0 + dLng])
        })
      })

      clusters.forEach((c: any) => {
        const [lng, lat] = c.geometry.coordinates
        if (c.properties && c.properties.cluster) {
          const count = c.properties.point_count
          // For small clusters, expand in-place into jittered points so they are immediately clickable
          if (count <= 24) {
            try {
              const leaves = index.getLeaves(c.id, count, 0) as any[]
              const cosLat = Math.cos((lat * Math.PI) / 180)
              const degPerMeterLat = 1 / 111320
              const degPerMeterLng = 1 / (111320 * (cosLat || 1))
              // Two-ring layout for dense small clusters
              const rings = count <= 12 ? 1 : 2
              const perRing1 = rings === 1 ? count : Math.ceil(count / 2)
              const perRing2 = rings === 2 ? count - perRing1 : 0
              // Scale spread more at lower zooms (bigger separation when zoomed out)
              const zoomFactor = zoom < 16 ? (1 + (16 - zoom) * 0.25) : 1
              const baseR = 60 * zoomFactor // meters
              const ringR1 = Math.min(130 * zoomFactor, baseR + perRing1 * 5 * zoomFactor)
              const ringR2 = rings === 2 ? Math.min(160 * zoomFactor, ringR1 + 30 * zoomFactor + perRing2 * 3 * zoomFactor) : 0
              // Place first ring
              leaves.slice(0, perRing1).forEach((leaf, i) => {
                const angle = (2 * Math.PI * i) / perRing1
                const dLat = (ringR1 * Math.sin(angle)) * degPerMeterLat
                const dLng = (ringR1 * Math.cos(angle)) * degPerMeterLng
                const sLat = lat + dLat
                const sLng = lng + dLng
                const id = leaf.properties && leaf.properties.id
                const alert = (alerts as any[]).find(a => a.id === id)
                if (!alert || !isValidLatLng(alert.location)) return
                const m = createUfoMarker(L, alert, map, [sLat, sLng])
                const popup = L.popup({ maxWidth: 350, className: 'custom-popup' }).setContent(createPopupContentHelper(alert, L))
                m.bindPopup(popup)
                m.addTo(map)
                markersRef.current.push(m)
              })
              // Place second ring if needed
              if (rings === 2 && perRing2 > 0) {
                leaves.slice(perRing1).forEach((leaf, j) => {
                  const angle = (2 * Math.PI * j) / perRing2
                  const dLat = (ringR2 * Math.sin(angle)) * degPerMeterLat
                  const dLng = (ringR2 * Math.cos(angle)) * degPerMeterLng
                  const sLat = lat + dLat
                  const sLng = lng + dLng
                  const id = leaf.properties && leaf.properties.id
                  const alert = (alerts as any[]).find(a => a.id === id)
                  if (!alert || !isValidLatLng(alert.location)) return
                  const m = createUfoMarker(L, alert, map, [sLat, sLng])
                  const popup = L.popup({ maxWidth: 350, className: 'custom-popup' }).setContent(createPopupContentHelper(alert, L))
                  m.bindPopup(popup)
                  m.addTo(map)
                  markersRef.current.push(m)
                })
              }
            } catch (e) {
              console.error('Cluster inline expand failed', e)
            }
          } else {
            // Render a clickable cluster badge
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
            try { marker.bindTooltip('Zoom in to expand', { direction: 'top', offset: [0, -size/2], opacity: 0.8 }) } catch {}
          marker.on('click', () => {
            try {
              const nextZoom = Math.min(index.getClusterExpansionZoom(c.id) + 1, 18)
              map.flyTo([lat, lng], nextZoom, { duration: 0.6 })
            } catch {}
          })
            marker.addTo(map)
            markersRef.current.push(marker)
          }
        } else {
          // Individual point
          const id = c.properties && c.properties.id
          const alert = (alerts as any[]).find(a => a.id === id)
          if (!alert || !isValidLatLng(alert.location)) return
          const jitterPos = jitterMap.get(String(id)) as [number, number] | undefined
          const marker = createUfoMarker(L, alert, map, jitterPos)
          const popup = L.popup({ maxWidth: 350, className: 'custom-popup' }).setContent(createPopupContentHelper(alert, L))
          marker.bindPopup(popup)
          marker.on('click', () => {
            try {
              const countAtId = overlapCount.get(String(id)) || 1
              const z = Math.round(map.getZoom() || 0)
              const alreadySeparated = !!jitterPos
              if (countAtId > 1 && z < 18 && !alreadySeparated) {
                const targetZoom = Math.min(Math.max(15, z + 3), 18)
                map.flyTo([lat, lng], targetZoom, { duration: 0.45 })
                return
              }
              marker.openPopup()
            } catch {}
          })
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

  // Simplified: we no longer use MUFON shape icons
  const getUfoIcon = (_alert: Alert) => '📍'

  const createUfoMarker = (L: any, alert: Alert, map: any, pos?: [number, number]) => {
    const src = (alert as any).source ? (alert as any).source.toString().toLowerCase() : ''
    const flagB = (alert as any).b === 1 || (alert as any).is_ufobeep === true
    const isUfoBeep = flagB || src === 'ufobeep' || src === 'beep' || src === 'ufo_beep' || src === 'ufo-beep'

    if (isUfoBeep) {
      // UFOBeep markers: bright cyan UFO icon to stand out
      const lat = pos ? Number(pos[0]) : Number(alert.location.latitude)
      const lng = pos ? Number(pos[1]) : Number(alert.location.longitude)
      const html = `
        <div style="
          background: #00E5FF;
          border: 2px solid #ffffff;
          border-radius: 50%;
          width: 26px; height: 26px;
          display: flex; align-items: center; justify-content: center;
          color: #0b1020; font-size: 14px; box-shadow: 0 2px 6px rgba(0,0,0,0.45);
          text-shadow: 0 0 2px rgba(255,255,255,0.6);
        ">🛸</div>`
      const divIcon = L.divIcon({ html, className: 'beep-marker', iconSize: [26, 26], iconAnchor: [13, 13] })
      return L.marker([lat, lng], { icon: divIcon })
    } else {
      // Unified green dot for all non-UFOBeep
      const lat = pos ? Number(pos[0]) : Number(alert.location.latitude)
      const lng = pos ? Number(pos[1]) : Number(alert.location.longitude)
      return L.circleMarker(
        [lat, lng],
        {
          radius: 8,
          fillColor: '#39FF14',
          color: '#ffffff',
          weight: 2,
          opacity: 1,
          fillOpacity: 0.9
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
      <div className="absolute top-4 left-4 bg-dark-surface/90 backdrop-blur-sm p-3 rounded-lg border border-dark-border z-10" style={{ pointerEvents: 'none' }}>
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
            className="bg-dark-surface/90 hover:bg-dark-surface-elevated border border-dark-border text-xs md:text-sm text-text-primary px-3 py-2 md:py-2 rounded-lg"
            title="Go to my location"
          >
            ⦿ My location
          </button>
        )}
        {/* Speed mode toggle */}
        <button
          className="bg-dark-surface/90 hover:bg-dark-surface-elevated border border-dark-border text-xs md:text-sm text-text-primary px-3 py-2 md:py-2 rounded-lg"
          title="Toggle faster loading mode"
          onClick={() => {
            try {
              const cur = localStorage.getItem('ufobeep:perf') || 'auto'
              const next = cur === 'low' ? 'auto' : 'low'
              localStorage.setItem('ufobeep:perf', next)
              // Visual hint
              alert(next === 'low' ? 'Faster loading mode: ON' : 'Faster loading mode: AUTO')
            } catch {}
          }}
        >⚡ Speed</button>
        <div className="bg-dark-surface/90 backdrop-blur-sm p-2 rounded-lg border border-dark-border text-xs text-text-tertiary">
          Click & drag to pan • Scroll to zoom
        </div>
      </div>

      {/* Legend (two sets + cluster) */}
      <div className="absolute bottom-4 right-4 bg-dark-surface/90 backdrop-blur-sm p-3 rounded-lg border border-dark-border text-xs z-10" style={{ pointerEvents: 'none' }}>
        <div className="font-semibold text-text-primary mb-2">Legend</div>
        <div className="space-y-2">
          <div className="flex items-center gap-2">
            <div className="w-5 h-5 rounded-full flex items-center justify-center" style={{ background: '#00E5FF', border: '2px solid #fff', color: '#0b1020' }}>🛸</div>
            <span className="text-text-secondary">UFOBeep</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-4 h-4 rounded-full" style={{ background: '#39FF14', border: '2px solid #fff' }}></div>
            <span className="text-text-secondary">MUFON/Other</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-7 h-7 rounded-full flex items-center justify-center" style={{ background: 'rgba(57,255,20,0.15)', border: '2px solid #39FF14', color: '#fff' }}>#</div>
            <span className="text-text-secondary">Cluster (click to expand)</span>
          </div>
        </div>
      </div>

      {/* Debug overlay */}
      {debugEnabled && (
        <div className="absolute bottom-4 left-4 bg-dark-surface/90 backdrop-blur-sm p-2 md:p-3 rounded-lg border border-dark-border text-xs md:text-sm z-10 text-text-primary">
          <div className="font-semibold mb-1">Debug (viewport)</div>
          <div>MUFON: {debugCounts.mufon}</div>
          <div>UFOBeep: {debugCounts.ufobeep}</div>
          <div>Other: {debugCounts.other}</div>
          <div>Total: {debugCounts.total}</div>
          <button className="mt-2 bg-dark-surface-elevated border border-dark-border px-2 py-1 rounded" onClick={() => setDebugEnabled(false)}>Hide</button>
        </div>
      )}

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
