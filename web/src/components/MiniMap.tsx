'use client'

import { useState } from 'react'

interface MiniMapProps {
  className?: string
}

export default function MiniMap({ className = '' }: MiniMapProps) {
  const [isLoaded, setIsLoaded] = useState(false)
  
  // Mock recent sighting data
  const mockSightings = [
    { id: 1, lat: 40.7128, lng: -74.0060, title: 'Bright Object - NYC', time: '2h ago' },
    { id: 2, lat: 34.0522, lng: -118.2437, title: 'Formation - LA', time: '4h ago' },
    { id: 3, lat: 51.5074, lng: -0.1278, title: 'Unknown Craft - London', time: '6h ago' },
    { id: 4, lat: 35.6762, lng: 139.6503, title: 'Light Anomaly - Tokyo', time: '8h ago' },
  ]

  const handleMapClick = () => {
    // Simulate map loading
    if (!isLoaded) {
      setIsLoaded(true)
      setTimeout(() => setIsLoaded(false), 3000) // Reset for demo
    }
  }

  return (
    <div className={`relative overflow-hidden rounded-xl border border-dark-border bg-dark-surface ${className}`}>
      {/* Map Header */}
      <div className="p-4 border-b border-dark-border">
        <div className="flex items-center justify-between">
          <h3 className="text-lg font-semibold text-text-primary">Recent Sightings</h3>
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 bg-brand-primary rounded-full animate-pulse"></div>
            <span className="text-sm text-brand-primary">Live</span>
          </div>
        </div>
        <p className="text-sm text-text-secondary mt-1">Real-time community reports worldwide</p>
      </div>

      {/* Mock Map Area */}
      <div 
        className="relative h-80 bg-gradient-to-br from-dark-background via-dark-surface to-dark-surface-elevated cursor-pointer group"
        onClick={handleMapClick}
      >
        {/* Grid overlay to simulate map */}
        <div className="absolute inset-0 opacity-20">
          <svg className="w-full h-full">
            <defs>
              <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
                <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#39FF14" strokeWidth="1"/>
              </pattern>
            </defs>
            <rect width="100%" height="100%" fill="url(#grid)" />
          </svg>
        </div>

        {/* Mock sighting pins */}
        {mockSightings.map((sighting, index) => (
          <div
            key={sighting.id}
            className="absolute transform -translate-x-1/2 -translate-y-1/2 group-hover:scale-110 transition-transform"
            style={{
              left: `${20 + (index * 15)}%`,
              top: `${30 + (index % 2 * 20)}%`,
            }}
          >
            <div className="relative">
              {/* Pin */}
              <div className="w-4 h-4 bg-brand-primary rounded-full border-2 border-white shadow-lg animate-pulse">
                <div className="absolute inset-0 bg-brand-primary rounded-full animate-ping opacity-40"></div>
              </div>
              
              {/* Tooltip on hover */}
              <div className="absolute bottom-6 left-1/2 transform -translate-x-1/2 opacity-0 group-hover:opacity-100 transition-opacity bg-dark-surface-elevated border border-dark-border rounded-md p-2 whitespace-nowrap text-xs z-10">
                <div className="text-text-primary font-medium">{sighting.title}</div>
                <div className="text-text-tertiary">{sighting.time}</div>
                <div className="absolute top-full left-1/2 transform -translate-x-1/2 w-0 h-0 border-l-4 border-r-4 border-t-4 border-transparent border-t-dark-surface-elevated"></div>
              </div>
            </div>
          </div>
        ))}

        {/* Loading state */}
        {isLoaded && (
          <div className="absolute inset-0 bg-dark-background bg-opacity-50 flex items-center justify-center">
            <div className="bg-dark-surface-elevated p-4 rounded-lg border border-dark-border">
              <div className="flex items-center gap-3">
                <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-brand-primary"></div>
                <span className="text-text-primary">Loading interactive map...</span>
              </div>
            </div>
          </div>
        )}

        {/* Map controls overlay */}
        <div className="absolute top-4 right-4 flex flex-col gap-2">
          <button className="p-2 bg-dark-surface-elevated border border-dark-border rounded-md hover:bg-dark-border transition-colors">
            <svg className="w-4 h-4 text-text-secondary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
          </button>
          <button className="p-2 bg-dark-surface-elevated border border-dark-border rounded-md hover:bg-dark-border transition-colors">
            <svg className="w-4 h-4 text-text-secondary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 12H4" />
            </svg>
          </button>
        </div>

        {/* Center crosshair */}
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 pointer-events-none">
          <div className="w-8 h-8 border-2 border-brand-primary rounded-full opacity-30">
            <div className="absolute top-1/2 left-1/2 w-1 h-1 bg-brand-primary rounded-full transform -translate-x-1/2 -translate-y-1/2"></div>
          </div>
        </div>

        {/* Click instruction */}
        <div className="absolute bottom-4 left-1/2 transform -translate-x-1/2 text-center opacity-60 group-hover:opacity-100 transition-opacity">
          <div className="bg-dark-surface-elevated px-3 py-1 rounded-full border border-dark-border text-xs text-text-secondary">
            Click to explore interactive map
          </div>
        </div>
      </div>

      {/* Stats Footer */}
      <div className="p-4 border-t border-dark-border bg-dark-surface-elevated">
        <div className="flex justify-between items-center">
          <div className="flex gap-6">
            <div className="text-center">
              <div className="text-lg font-bold text-brand-primary">24</div>
              <div className="text-xs text-text-secondary">Today</div>
            </div>
            <div className="text-center">
              <div className="text-lg font-bold text-text-primary">1,847</div>
              <div className="text-xs text-text-secondary">This Week</div>
            </div>
            <div className="text-center">
              <div className="text-lg font-bold text-text-primary">15,392</div>
              <div className="text-xs text-text-secondary">All Time</div>
            </div>
          </div>
          <button className="text-sm text-brand-primary hover:text-brand-primary-light transition-colors">
            View All →
          </button>
        </div>
      </div>
    </div>
  )
}