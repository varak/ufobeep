'use client'

import { useEffect, useRef } from 'react'

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

interface LeafletMapProps {
  alerts?: Alert[]
  height?: string
  onAlertClick?: (alert: Alert) => void
}

export default function LeafletMap({ 
  alerts = [], 
  height = '320px',
  onAlertClick
}: LeafletMapProps) {
  const mapRef = useRef<HTMLDivElement>(null)
  const mapInstanceRef = useRef<any>(null)

  useEffect(() => {
    // Only run on client side
    if (typeof window === 'undefined' || !mapRef.current) return

    const initializeMap = async () => {
      // Dynamically import Leaflet to avoid SSR issues
      const L = (await import('leaflet')).default

      // Import Leaflet CSS
      if (!document.querySelector('link[href*="leaflet.css"]')) {
        const link = document.createElement('link')
        link.rel = 'stylesheet'
        link.href = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css'
        document.head.appendChild(link)
      }

      // Clear existing map
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove()
      }

      // Calculate center point
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

      // Create map
      const map = L.map(mapRef.current).setView([centerLat, centerLng], zoom)

      // Add OpenStreetMap tiles with dark theme filter (same as Flutter app)
      L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        maxZoom: 19,
        className: 'dark-tiles'
      }).addTo(map)

      // Add markers for alerts
      alerts.forEach((alert) => {
        const color = getAlertColor(alert.alert_level)
        
        // Create custom icon
        const customIcon = L.divIcon({
          className: 'custom-marker',
          html: `
            <div style="
              background-color: ${color};
              width: 16px;
              height: 16px;
              border-radius: 50%;
              border: 2px solid white;
              box-shadow: 0 2px 4px rgba(0,0,0,0.3);
              position: relative;
            ">
              <div style="
                position: absolute;
                top: -8px;
                left: -8px;
                width: 32px;
                height: 32px;
                border-radius: 50%;
                background-color: ${color};
                opacity: 0.3;
                animation: pulse 2s infinite;
              "></div>
            </div>
          `,
          iconSize: [16, 16],
          iconAnchor: [8, 8]
        })

        const marker = L.marker([alert.location.latitude, alert.location.longitude], {
          icon: customIcon
        }).addTo(map)

        // Add click handler
        marker.on('click', () => {
          if (onAlertClick) {
            onAlertClick(alert)
          }
        })

        // Add popup
        marker.bindPopup(`
          <div style="color: #000; min-width: 200px;">
            <h4 style="margin: 0 0 8px 0; font-weight: 600;">${alert.title}</h4>
            <p style="margin: 0 0 8px 0; font-size: 12px; opacity: 0.8;">${alert.location.name}</p>
            <p style="margin: 0 0 8px 0; font-size: 12px;">${alert.description.substring(0, 100)}${alert.description.length > 100 ? '...' : ''}</p>
            <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 8px;">
              <span style="
                background: ${color};
                color: white;
                padding: 2px 6px;
                border-radius: 4px;
                font-size: 10px;
                font-weight: 600;
                text-transform: uppercase;
              ">${alert.alert_level}</span>
              <span style="font-size: 10px; opacity: 0.6;">
                ${new Date(alert.created_at).toLocaleDateString()}
              </span>
            </div>
          </div>
        `)
      })

      mapInstanceRef.current = map

      // Add pulse animation CSS and dark theme filter
      if (!document.querySelector('#map-styles')) {
        const style = document.createElement('style')
        style.id = 'map-styles'
        style.textContent = `
          @keyframes pulse {
            0% {
              transform: scale(0.8);
              opacity: 0.3;
            }
            50% {
              transform: scale(1.2);
              opacity: 0.1;
            }
            100% {
              transform: scale(0.8);
              opacity: 0.3;
            }
          }
          
          /* Dark theme filter for OpenStreetMap tiles (same as Flutter app) */
          .dark-tiles {
            filter: brightness(0.2) contrast(1.2) sepia(0.1) hue-rotate(180deg);
          }
        `
        document.head.appendChild(style)
      }
    }

    initializeMap()

    return () => {
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove()
        mapInstanceRef.current = null
      }
    }
  }, [alerts, onAlertClick])

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
    <div className="relative">
      <div 
        ref={mapRef}
        style={{ height, width: '100%' }}
        className="rounded-lg overflow-hidden"
      />
      
      {/* Legend */}
      <div className="absolute bottom-4 right-4 bg-dark-surface-elevated bg-opacity-90 backdrop-blur-sm p-2 rounded-lg border border-dark-border text-xs">
        <div className="space-y-1">
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 rounded-full bg-red-500"></div>
            <span className="text-text-tertiary">Critical</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 rounded-full bg-orange-500"></div>
            <span className="text-text-tertiary">High</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 rounded-full bg-yellow-500"></div>
            <span className="text-text-tertiary">Medium</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 rounded-full bg-green-500"></div>
            <span className="text-text-tertiary">Low</span>
          </div>
        </div>
      </div>

      {/* Loading overlay */}
      {alerts.length === 0 && (
        <div className="absolute inset-0 flex items-center justify-center bg-dark-background rounded-lg">
          <div className="text-center">
            <div className="text-4xl mb-4">🗺️</div>
            <p className="text-text-secondary">Loading map...</p>
          </div>
        </div>
      )}
    </div>
  )
}