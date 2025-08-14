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

  useEffect(() => {
    // Load real OpenStreetMap tiles instead of canvas
    if (!mapRef.current || alerts.length === 0) return

    const renderMap = async () => {
      if (!mapRef.current) return

      try {
        // Clear existing content
        mapRef.current.innerHTML = ''

        // Calculate center from alerts
        let centerLat = 39.8283
        let centerLng = -98.5795
        let zoom = 4

        if (alerts.length > 0) {
          const lats = alerts.map(a => a.location.latitude)
          const lngs = alerts.map(a => a.location.longitude)
          centerLat = lats.reduce((a, b) => a + b, 0) / lats.length
          centerLng = lngs.reduce((a, b) => a + b, 0) / lngs.length
          zoom = 6
        }

        // Create map container with iframe for OpenStreetMap
        const mapFrame = document.createElement('iframe')
        mapFrame.style.width = '100%'
        mapFrame.style.height = '100%'
        mapFrame.style.border = 'none'
        mapFrame.style.borderRadius = '8px'
        
        // Use OpenStreetMap embed with markers
        const markers = alerts.map(alert => 
          `mlat=${alert.location.latitude}&mlon=${alert.location.longitude}`
        ).join('&')
        
        mapFrame.src = `https://www.openstreetmap.org/export/embed.html?bbox=${centerLng-1},${centerLat-1},${centerLng+1},${centerLat+1}&layer=mapnik&marker=${centerLat},${centerLng}`
        
        mapRef.current.appendChild(mapFrame)

        // Create overlay for our custom markers
        const overlay = document.createElement('div')
        overlay.style.position = 'absolute'
        overlay.style.top = '0'
        overlay.style.left = '0'
        overlay.style.width = '100%'
        overlay.style.height = '100%'
        overlay.style.pointerEvents = 'auto'
        overlay.style.zIndex = '10'

        // Add our custom markers to overlay
        alerts.forEach((alert, index) => {
          const marker = document.createElement('div')
          marker.style.position = 'absolute'
          marker.style.width = '16px'
          marker.style.height = '16px'
          marker.style.borderRadius = '50%'
          marker.style.backgroundColor = getAlertColor(alert.alert_level)
          marker.style.border = '2px solid white'
          marker.style.boxShadow = '0 2px 4px rgba(0,0,0,0.3)'
          marker.style.cursor = 'pointer'
          marker.style.zIndex = '100'
          
          // Simple positioning calculation (this is approximate)
          const markerX = ((alert.location.longitude - (centerLng - 1)) / 2) * 100
          const markerY = (((centerLat + 1) - alert.location.latitude) / 2) * 100
          
          marker.style.left = `${Math.max(0, Math.min(95, markerX))}%`
          marker.style.top = `${Math.max(0, Math.min(95, markerY))}%`
          
          marker.addEventListener('click', () => {
            setSelectedAlert(alert)
            if (onAlertClick) onAlertClick(alert)
          })

          marker.addEventListener('mouseenter', (e) => {
            setHoveredAlert(alert)
            setMousePos({ x: e.clientX, y: e.clientY })
          })

          marker.addEventListener('mouseleave', () => {
            setHoveredAlert(null)
          })

          overlay.appendChild(marker)
        })

        mapRef.current.appendChild(overlay)

      } catch (error) {
        console.error('Error loading map:', error)
        setMapError(true)
      }
    }

    // Add slight delay to ensure container is rendered
    const timeoutId = setTimeout(renderMap, 100)
    
    return () => clearTimeout(timeoutId)

  }, [alerts])

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
        className="relative cursor-pointer bg-dark-background"
      />
      
      {/* Fallback when map fails to render */}
      {mapError && (
        <div className="absolute inset-0 flex items-center justify-center bg-dark-background">
          <div className="text-center">
            <div className="text-4xl mb-4">🗺️</div>
            <p className="text-text-secondary mb-2">Map unavailable</p>
            <p className="text-text-tertiary text-sm">{alerts.length} sightings available</p>
          </div>
        </div>
      )}
      
      {/* Map overlay with real data */}
      <div className="absolute top-4 left-4 bg-dark-surface/90 backdrop-blur-sm p-3 rounded-lg border border-dark-border">
        <div className="flex items-center gap-2 mb-2">
          <div className="w-2 h-2 bg-brand-primary rounded-full animate-pulse"></div>
          <span className="text-sm text-brand-primary font-medium">Live Sightings</span>
        </div>
        <div className="text-xs text-text-secondary">
          {alerts.length} active reports
        </div>
      </div>

      {/* Controls */}
      {showControls && (
        <div className="absolute top-4 right-4 flex flex-col gap-2">
          <button className="p-2 bg-dark-surface/90 backdrop-blur-sm border border-dark-border rounded-md hover:bg-dark-border transition-colors">
            <svg className="w-4 h-4 text-text-secondary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
          </button>
          <button className="p-2 bg-dark-surface/90 backdrop-blur-sm border border-dark-border rounded-md hover:bg-dark-border transition-colors">
            <svg className="w-4 h-4 text-text-secondary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 12H4" />
            </svg>
          </button>
        </div>
      )}

      {/* Selected alert popup */}
      {selectedAlert && (
        <div className="absolute bottom-4 left-4 right-4 bg-dark-surface-elevated border border-dark-border rounded-lg p-4 shadow-xl">
          <button 
            onClick={() => setSelectedAlert(null)}
            className="absolute top-2 right-2 text-text-tertiary hover:text-text-primary"
          >
            ✕
          </button>
          <h4 className="font-semibold text-text-primary mb-1">{selectedAlert.title}</h4>
          <p className="text-sm text-text-secondary mb-2">{selectedAlert.description}</p>
          <div className="flex items-center justify-between text-xs">
            <span className="text-text-tertiary">{selectedAlert.location.name}</span>
            <span className={`font-medium ${getAlertColor(selectedAlert.alert_level)}`}>
              {selectedAlert.alert_level?.toUpperCase()}
            </span>
          </div>
        </div>
      )}

      {/* Legend */}
      <div className="absolute bottom-4 right-4 bg-dark-surface/90 backdrop-blur-sm p-2 rounded-lg border border-dark-border text-xs">
        <div className="space-y-1">
          <div className="flex items-center gap-2 group relative">
            <div className="w-2 h-2 rounded-full bg-red-500"></div>
            <span className="text-text-tertiary">Critical</span>
            <div className="absolute left-0 bottom-full mb-2 bg-dark-surface-elevated border border-dark-border p-2 rounded text-xs whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none z-10">
              Immediate threat or extraordinary phenomenon
            </div>
          </div>
          <div className="flex items-center gap-2 group relative">
            <div className="w-2 h-2 rounded-full bg-orange-500"></div>
            <span className="text-text-tertiary">High</span>
            <div className="absolute left-0 bottom-full mb-2 bg-dark-surface-elevated border border-dark-border p-2 rounded text-xs whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none z-10">
              Significant sighting with clear evidence
            </div>
          </div>
          <div className="flex items-center gap-2 group relative">
            <div className="w-2 h-2 rounded-full bg-yellow-500"></div>
            <span className="text-text-tertiary">Medium</span>
            <div className="absolute left-0 bottom-full mb-2 bg-dark-surface-elevated border border-dark-border p-2 rounded text-xs whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none z-10">
              Notable anomaly requiring investigation
            </div>
          </div>
          <div className="flex items-center gap-2 group relative">
            <div className="w-2 h-2 rounded-full bg-green-500"></div>
            <span className="text-text-tertiary">Low</span>
            <div className="absolute left-0 bottom-full mb-2 bg-dark-surface-elevated border border-dark-border p-2 rounded text-xs whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none z-10">
              Minor observation or distant object
            </div>
          </div>
        </div>
      </div>

      {/* Hover tooltip */}
      {hoveredAlert && (
        <div 
          className="fixed bg-dark-surface-elevated border border-dark-border p-3 rounded-lg shadow-xl text-sm z-50 pointer-events-none"
          style={{
            left: mousePos.x + 10,
            top: mousePos.y - 10,
            transform: 'translate(0, -100%)'
          }}
        >
          <h4 className="font-semibold text-text-primary mb-1">{hoveredAlert.title}</h4>
          <p className="text-text-secondary text-xs mb-2">{hoveredAlert.location.name}</p>
          <div className="flex items-center gap-2">
            <span className={`text-xs font-medium ${hoveredAlert.alert_level === 'critical' ? 'text-red-400' : hoveredAlert.alert_level === 'high' ? 'text-orange-400' : hoveredAlert.alert_level === 'medium' ? 'text-yellow-400' : 'text-green-400'}`}>
              {hoveredAlert.alert_level?.toUpperCase()}
            </span>
            <span className="text-text-tertiary text-xs">•</span>
            <span className="text-text-tertiary text-xs">
              {new Date(hoveredAlert.created_at).toLocaleDateString()}
            </span>
          </div>
        </div>
      )}
    </div>
  )
}