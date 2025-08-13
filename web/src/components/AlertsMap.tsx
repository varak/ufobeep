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
    // Simple map implementation using canvas
    if (!mapRef.current) return

    const renderMap = () => {
      if (!mapRef.current) return

      console.log('Rendering map with', alerts.length, 'alerts')
      
      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d')
      if (!ctx) {
        console.error('Failed to get canvas context')
        setMapError(true)
        return
      }

      // Ensure parent has dimensions
      const containerWidth = mapRef.current.clientWidth || 800
      const containerHeight = parseInt(height) || 320
      
      console.log('Canvas dimensions:', containerWidth, 'x', containerHeight)

      // Set canvas size
      canvas.width = containerWidth
      canvas.height = containerHeight
      canvas.style.width = '100%'
      canvas.style.height = '100%'
      canvas.style.display = 'block'
      
      // Clear existing content
      mapRef.current.innerHTML = ''
      mapRef.current.appendChild(canvas)

      // Draw map background (dark theme)
      ctx.fillStyle = '#0a0a0a'
      ctx.fillRect(0, 0, canvas.width, canvas.height)

      // Draw grid
      ctx.strokeStyle = '#1a1a1a'
      ctx.lineWidth = 1
      for (let x = 0; x < canvas.width; x += 50) {
        ctx.beginPath()
        ctx.moveTo(x, 0)
        ctx.lineTo(x, canvas.height)
        ctx.stroke()
      }
      for (let y = 0; y < canvas.height; y += 50) {
        ctx.beginPath()
        ctx.moveTo(0, y)
        ctx.lineTo(canvas.width, y)
        ctx.stroke()
      }

      // Convert lat/lng to canvas coordinates
      const latLngToCanvas = (lat: number, lng: number) => {
        const x = ((lng + 180) / 360) * canvas.width
        const y = ((90 - lat) / 180) * canvas.height
        return { x, y }
      }

      // Draw alerts
      alerts.forEach((alert) => {
        const pos = latLngToCanvas(alert.location.latitude, alert.location.longitude)
        
        // Draw glow effect
        const gradient = ctx.createRadialGradient(pos.x, pos.y, 0, pos.x, pos.y, 20)
        gradient.addColorStop(0, getAlertColor(alert.alert_level))
        gradient.addColorStop(1, 'transparent')
        ctx.fillStyle = gradient
        ctx.fillRect(pos.x - 20, pos.y - 20, 40, 40)
        
        // Draw pin
        ctx.fillStyle = getAlertColor(alert.alert_level)
        ctx.beginPath()
        ctx.arc(pos.x, pos.y, 4, 0, Math.PI * 2)
        ctx.fill()
        
        // Draw pulsing ring
        ctx.strokeStyle = getAlertColor(alert.alert_level)
        ctx.lineWidth = 2
        ctx.beginPath()
        ctx.arc(pos.x, pos.y, 8, 0, Math.PI * 2)
        ctx.stroke()
      })

      // Add click handler
      canvas.onclick = (e) => {
        const rect = canvas.getBoundingClientRect()
        const x = e.clientX - rect.left
        const y = e.clientY - rect.top
        
        // Check if click is near any alert
        alerts.forEach((alert) => {
          const pos = latLngToCanvas(alert.location.latitude, alert.location.longitude)
          const distance = Math.sqrt((x - pos.x) ** 2 + (y - pos.y) ** 2)
          
          if (distance < 10) {
            setSelectedAlert(alert)
            if (onAlertClick) onAlertClick(alert)
          }
        })
      }

      // Add mousemove handler for tooltips
      canvas.onmousemove = (e) => {
        const rect = canvas.getBoundingClientRect()
        const x = e.clientX - rect.left
        const y = e.clientY - rect.top
        
        setMousePos({ x: e.clientX, y: e.clientY })
        
        let foundAlert = null
        alerts.forEach((alert) => {
          const pos = latLngToCanvas(alert.location.latitude, alert.location.longitude)
          const distance = Math.sqrt((x - pos.x) ** 2 + (y - pos.y) ** 2)
          
          if (distance < 10) {
            foundAlert = alert
          }
        })
        
        setHoveredAlert(foundAlert)
        canvas.style.cursor = foundAlert ? 'pointer' : 'default'
      }

      // Add mouseleave handler
      canvas.onmouseleave = () => {
        setHoveredAlert(null)
        canvas.style.cursor = 'default'
      }
    }

    // Add slight delay to ensure container is rendered
    setTimeout(renderMap, 100)

  }, [alerts, center, zoom])

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