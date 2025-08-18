'use client'

import { useEffect, useRef, useState } from 'react'

// Extend Window interface for Google Maps
declare global {
  interface Window {
    google: any
  }
}

interface Sighting {
  id: string
  location: {
    latitude: number
    longitude: number
    name: string
  }
  title: string
  category: string
  created_at: string
  witness_count: number
  alert_level: string
}

interface InteractiveMapProps {
  sighting: Sighting
  nearbySightings?: Sighting[]
  width?: string
  height?: string
  showFullscreenButton?: boolean
}

export default function InteractiveMap({ 
  sighting, 
  nearbySightings = [], 
  width = "100%", 
  height = "300px",
  showFullscreenButton = true 
}: InteractiveMapProps) {
  const mapRef = useRef<HTMLDivElement>(null)
  const [map, setMap] = useState<any>(null)
  const [isFullscreen, setIsFullscreen] = useState(false)
  const [isLoaded, setIsLoaded] = useState(false)
  const [loadError, setLoadError] = useState<string | null>(null)

  useEffect(() => {
    const loadGoogleMaps = () => {
      // Check if Google Maps is already loaded
      if (window.google && window.google.maps) {
        initializeMap()
        return
      }

      // Check if script is already being loaded
      if (document.querySelector('script[src*="maps.googleapis.com"]')) {
        // Wait for it to load
        const checkInterval = setInterval(() => {
          if (window.google && window.google.maps) {
            clearInterval(checkInterval)
            initializeMap()
          }
        }, 100)
        return
      }

      // Load Google Maps script
      const script = document.createElement('script')
      script.src = `https://maps.googleapis.com/maps/api/js?key=${process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY || ''}&libraries=geometry`
      script.async = true
      script.defer = true
      script.onload = initializeMap
      script.onerror = () => {
        setLoadError('Failed to load Google Maps. Please try again later.')
      }
      document.head.appendChild(script)
    }

    const initializeMap = () => {
      if (!mapRef.current || !window.google) {
        setLoadError('Map container not available')
        return
      }

      try {
        const mapInstance = new window.google.maps.Map(mapRef.current, {
          center: { 
            lat: sighting.location.latitude, 
            lng: sighting.location.longitude 
          },
          zoom: 12,
          styles: [
            // Dark theme for the map
            { elementType: "geometry", stylers: [{ color: "#242f3e" }] },
            { elementType: "labels.text.stroke", stylers: [{ color: "#242f3e" }] },
            { elementType: "labels.text.fill", stylers: [{ color: "#746855" }] },
            {
              featureType: "administrative.locality",
              elementType: "labels.text.fill",
              stylers: [{ color: "#d59563" }],
            },
            {
              featureType: "poi",
              elementType: "labels.text.fill",
              stylers: [{ color: "#d59563" }],
            },
            {
              featureType: "poi.park",
              elementType: "geometry",
              stylers: [{ color: "#263c3f" }],
            },
            {
              featureType: "poi.park",
              elementType: "labels.text.fill",
              stylers: [{ color: "#6b9a76" }],
            },
            {
              featureType: "road",
              elementType: "geometry",
              stylers: [{ color: "#38414e" }],
            },
            {
              featureType: "road",
              elementType: "geometry.stroke",
              stylers: [{ color: "#212a37" }],
            },
            {
              featureType: "road",
              elementType: "labels.text.fill",
              stylers: [{ color: "#9ca5b3" }],
            },
            {
              featureType: "road.highway",
              elementType: "geometry",
              stylers: [{ color: "#746855" }],
            },
            {
              featureType: "road.highway",
              elementType: "geometry.stroke",
              stylers: [{ color: "#1f2835" }],
            },
            {
              featureType: "road.highway",
              elementType: "labels.text.fill",
              stylers: [{ color: "#f3d19c" }],
            },
            {
              featureType: "transit",
              elementType: "geometry",
              stylers: [{ color: "#2f3948" }],
            },
            {
              featureType: "transit.station",
              elementType: "labels.text.fill",
              stylers: [{ color: "#d59563" }],
            },
            {
              featureType: "water",
              elementType: "geometry",
              stylers: [{ color: "#17263c" }],
            },
            {
              featureType: "water",
              elementType: "labels.text.fill",
              stylers: [{ color: "#515c6d" }],
            },
            {
              featureType: "water",
              elementType: "labels.text.stroke",
              stylers: [{ color: "#17263c" }],
            },
          ],
        })

        // Main sighting marker (prominent)
        const mainMarker = new window.google.maps.Marker({
          position: { 
            lat: sighting.location.latitude, 
            lng: sighting.location.longitude 
          },
          map: mapInstance,
          title: sighting.title || 'UFO Sighting',
          icon: {
            path: window.google.maps.SymbolPath.CIRCLE,
            scale: 15,
            fillColor: '#00ff88',
            fillOpacity: 0.9,
            strokeColor: '#ffffff',
            strokeWeight: 3,
          },
          zIndex: 1000,
        })

        // Main sighting info window
        const mainInfoWindow = new window.google.maps.InfoWindow({
          content: `
            <div style="color: #333; padding: 8px; max-width: 250px;">
              <div style="font-weight: bold; margin-bottom: 8px; color: #00ff88;">
                🛸 ${sighting.category === 'ufo' ? 'UFO Sighting' : 'Anomaly'}
              </div>
              <div style="font-size: 14px; margin-bottom: 4px;">
                <strong>${sighting.title || 'Witnessed Sighting'}</strong>
              </div>
              <div style="font-size: 12px; color: #666; margin-bottom: 4px;">
                📍 ${sighting.location.name}
              </div>
              <div style="font-size: 12px; color: #666; margin-bottom: 4px;">
                👁️ ${sighting.witness_count || 1} witness${(sighting.witness_count || 1) !== 1 ? 'es' : ''}
              </div>
              <div style="font-size: 11px; color: #888;">
                ${new Date(sighting.created_at).toLocaleDateString()}
              </div>
            </div>
          `,
        })

        mainMarker.addListener('click', () => {
          mainInfoWindow.open(mapInstance, mainMarker)
        })

        // Nearby sightings markers (smaller, different color)
        nearbySightings.forEach((nearby, index) => {
          if (nearby.id === sighting.id) return // Skip the main sighting

          const nearbyMarker = new window.google.maps.Marker({
            position: { 
              lat: nearby.location.latitude, 
              lng: nearby.location.longitude 
            },
            map: mapInstance,
            title: nearby.title || 'Nearby Sighting',
            icon: {
              path: window.google.maps.SymbolPath.CIRCLE,
              scale: 8,
              fillColor: '#ff6b35',
              fillOpacity: 0.7,
              strokeColor: '#ffffff',
              strokeWeight: 2,
            },
            zIndex: 500 - index,
          })

          const nearbyInfoWindow = new window.google.maps.InfoWindow({
            content: `
              <div style="color: #333; padding: 6px; max-width: 200px;">
                <div style="font-weight: bold; margin-bottom: 6px; color: #ff6b35;">
                  ${nearby.category === 'ufo' ? '🛸' : '⭐'} Nearby Sighting
                </div>
                <div style="font-size: 13px; margin-bottom: 3px;">
                  <strong>${nearby.title || 'Witnessed Sighting'}</strong>
                </div>
                <div style="font-size: 11px; color: #666; margin-bottom: 3px;">
                  📍 ${nearby.location.name}
                </div>
                <div style="font-size: 11px; color: #666; margin-bottom: 3px;">
                  👁️ ${nearby.witness_count || 1} witness${(nearby.witness_count || 1) !== 1 ? 'es' : ''}
                </div>
                <div style="font-size: 10px; color: #888;">
                  ${new Date(nearby.created_at).toLocaleDateString()}
                </div>
                <div style="margin-top: 6px;">
                  <a href="/alerts/${nearby.id}" style="color: #ff6b35; text-decoration: none; font-size: 11px;">
                    View Details →
                  </a>
                </div>
              </div>
            `,
          })

          nearbyMarker.addListener('click', () => {
            nearbyInfoWindow.open(mapInstance, nearbyMarker)
          })
        })

        // Auto-fit bounds if there are nearby sightings
        if (nearbySightings.length > 0) {
          const bounds = new window.google.maps.LatLngBounds()
          bounds.extend({ lat: sighting.location.latitude, lng: sighting.location.longitude })
          nearbySightings.forEach(nearby => {
            bounds.extend({ lat: nearby.location.latitude, lng: nearby.location.longitude })
          })
          mapInstance.fitBounds(bounds)
          
          // Ensure minimum zoom level
          const listener = window.google.maps.event.addListenerOnce(mapInstance, 'bounds_changed', () => {
            if (mapInstance.getZoom() > 15) {
              mapInstance.setZoom(15)
            }
          })
        }

        setMap(mapInstance)
        setIsLoaded(true)

      } catch (error) {
        console.error('Error initializing map:', error)
        setLoadError('Failed to initialize map. Please try again.')
      }
    }

    loadGoogleMaps()

    // Cleanup function
    return () => {
      if (map) {
        // Clean up map instance if needed
      }
    }
  }, [sighting, nearbySightings])

  const toggleFullscreen = () => {
    if (!isFullscreen) {
      setIsFullscreen(true)
      document.body.style.overflow = 'hidden'
    } else {
      setIsFullscreen(false)
      document.body.style.overflow = 'auto'
    }
    
    // Re-trigger map resize after fullscreen change
    setTimeout(() => {
      if (map) {
        window.google.maps.event.trigger(map, 'resize')
      }
    }, 100)
  }

  const closeFullscreen = () => {
    setIsFullscreen(false)
    document.body.style.overflow = 'auto'
    setTimeout(() => {
      if (map) {
        window.google.maps.event.trigger(map, 'resize')
      }
    }, 100)
  }

  if (loadError) {
    return (
      <div 
        style={{ width, height }}
        className="bg-dark-background rounded-lg flex items-center justify-center border border-dark-border"
      >
        <div className="text-center p-6">
          <div className="text-3xl mb-2">🗺️</div>
          <p className="text-text-tertiary text-sm">{loadError}</p>
          <p className="text-text-tertiary text-xs mt-2">Showing coordinates only</p>
          <p className="text-text-primary text-sm mt-2">
            {sighting.location.latitude.toFixed(6)}, {sighting.location.longitude.toFixed(6)}
          </p>
        </div>
      </div>
    )
  }

  if (!isLoaded) {
    return (
      <div 
        style={{ width, height }}
        className="bg-dark-background rounded-lg flex items-center justify-center border border-dark-border"
      >
        <div className="text-center p-6">
          <div className="text-3xl mb-2 animate-pulse">🗺️</div>
          <p className="text-text-tertiary text-sm">Loading interactive map...</p>
        </div>
      </div>
    )
  }

  return (
    <>
      <div className="relative" style={{ width, height }}>
        <div 
          ref={mapRef}
          className="w-full h-full rounded-lg overflow-hidden border border-dark-border"
        />
        {showFullscreenButton && (
          <button
            onClick={toggleFullscreen}
            className="absolute top-2 right-2 bg-dark-background/80 hover:bg-dark-surface/90 text-text-primary p-2 rounded border border-dark-border transition-colors"
            title="Expand map fullscreen"
          >
            🔍
          </button>
        )}
        {nearbySightings.length > 0 && (
          <div className="absolute bottom-2 left-2 bg-dark-background/80 text-text-secondary px-3 py-1 rounded text-xs border border-dark-border">
            📍 {nearbySightings.length} nearby sighting{nearbySightings.length !== 1 ? 's' : ''}
          </div>
        )}
      </div>

      {/* Fullscreen Modal */}
      {isFullscreen && (
        <div className="fixed inset-0 bg-black bg-opacity-95 z-50 flex flex-col">
          <div className="flex justify-between items-center p-4 bg-dark-surface border-b border-dark-border">
            <div>
              <h3 className="text-lg font-semibold text-text-primary">Interactive Map</h3>
              <p className="text-text-secondary text-sm">
                {sighting.location.name} • {nearbySightings.length} nearby sighting{nearbySightings.length !== 1 ? 's' : ''}
              </p>
            </div>
            <button
              onClick={closeFullscreen}
              className="text-text-primary hover:text-brand-primary p-2 rounded border border-dark-border transition-colors"
            >
              ✕ Close
            </button>
          </div>
          <div className="flex-1">
            <div 
              ref={mapRef}
              className="w-full h-full"
            />
          </div>
        </div>
      )}
    </>
  )
}