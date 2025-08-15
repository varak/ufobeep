'use client'

import { useEffect, useRef, useState } from 'react'

interface Alert {
  id: string
  title: string
  description: string
  location: {
    latitude: number
    longitude: number
    name: string
  }
  alert_level: string
  created_at: string
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
  const [hoveredAlert, setHoveredAlert] = useState<Alert | null>(null)
  const [mousePos, setMousePos] = useState({ x: 0, y: 0 })
  const [userLocation, setUserLocation] = useState<[number, number] | null>(null)
  const mapInstanceRef = useRef<any>(null)
  const markersRef = useRef<any[]>([])

  // Get user's location on mount
  useEffect(() => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const userCoords: [number, number] = [position.coords.latitude, position.coords.longitude]
          console.log('Got user location:', userCoords, 'Las Vegas is approximately [36.1699, -115.1398]')
          setUserLocation(userCoords)
        },
        (error) => {
          console.log('Could not get user location:', error)
          console.log('Falling back to center:', center)
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
      console.log('Geolocation not supported, using center:', center)
      // Use provided center or US center as fallback
      setUserLocation(center)
    }
  }, [center])

  useEffect(() => {
    // Dynamically import Leaflet for client-side rendering
    const initMap = async () => {
      if (!mapRef.current || !userLocation) return

      try {
        // Dynamically import Leaflet
        const L = (await import('leaflet')).default
        
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
        }

        // Create map - center on user location with appropriate zoom
        const mapZoom = userLocation[0] === center[0] && userLocation[1] === center[1] ? zoom : 10
        console.log('Creating map with center:', userLocation, 'zoom:', mapZoom)
        console.log('Is this user location different from default center?', userLocation[0] !== center[0] || userLocation[1] !== center[1])
        const map = L.map(mapRef.current).setView(userLocation, mapZoom)
        mapInstanceRef.current = map
        
        // Add user location marker if we have their actual location
        if (userLocation[0] !== center[0] || userLocation[1] !== center[1]) {
          console.log('Adding "You are here" marker at:', userLocation)
          L.marker(userLocation, {
            title: 'Your Location',
            zIndexOffset: 1000
          }).addTo(map).bindPopup('You are here')
        } else {
          console.log('Using default center, no user location marker')
        }

        // Add OpenStreetMap tile layer
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
          maxZoom: 18,
          attribution: '© OpenStreetMap contributors'
        }).addTo(map)

        // Clear existing markers
        markersRef.current.forEach(marker => {
          if (marker) marker.remove()
        })
        markersRef.current = []

        // Add markers for alerts (skip invalid coordinates)
        alerts.forEach((alert) => {
          if (alert.location.latitude === 0 && alert.location.longitude === 0) {
            return // Skip invalid coordinates (0,0 fallback)
          }

          const marker = L.circleMarker(
            [alert.location.latitude, alert.location.longitude],
            {
              radius: 8,
              fillColor: getAlertColor(alert.alert_level),
              color: '#ffffff',
              weight: 2,
              opacity: 1,
              fillOpacity: 0.8
            }
          )

          // Add popup
          const popupContent = `
            <div class="text-sm">
              <h4 class="font-semibold text-gray-900 mb-1">${alert.title}</h4>
              <p class="text-gray-600 text-xs mb-2">${alert.description}</p>
              <div class="flex items-center justify-between text-xs">
                <span class="text-gray-500">${alert.location.name}</span>
                <span class="font-medium" style="color: ${getAlertColor(alert.alert_level)}">${alert.alert_level?.toUpperCase()}</span>
              </div>
              <div class="text-xs text-gray-400 mt-1">${new Date(alert.created_at).toLocaleDateString()}</div>
            </div>
          `

          marker.bindPopup(popupContent)
          
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
        console.error('Error loading map:', error)
        setMapError(true)
      }
    }

    initMap()

    // Cleanup function
    return () => {
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove()
        mapInstanceRef.current = null
      }
    }

  }, [alerts, userLocation, center, zoom])

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

  const getAlertColor = (level: string) => {
    switch (level?.toLowerCase()) {
      case 'critical': return '#ef4444'
      case 'high': return '#f97316'
      case 'medium': return '#eab308'
      case 'low': return '#22c55e'
      default: return '#39FF14'
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
    </div>
  )
}