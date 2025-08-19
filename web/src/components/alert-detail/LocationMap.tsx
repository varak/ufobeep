'use client'

interface LocationMapProps {
  location: {
    latitude: number
    longitude: number
    name: string
  }
}

export default function LocationMap({ location }: LocationMapProps) {
  const { latitude, longitude, name } = location
  
  // Create URLs for different map services
  const googleMapsUrl = `https://www.google.com/maps?q=${latitude},${longitude}&z=15`
  const openStreetMapUrl = `https://www.openstreetmap.org/?mlat=${latitude}&mlon=${longitude}&zoom=15`
  
  return (
    <div className="bg-dark-background border border-dark-border rounded-lg overflow-hidden">
      {/* Static map placeholder with coordinates */}
      <div className="aspect-video bg-gradient-to-br from-dark-background via-dark-surface to-dark-background flex items-center justify-center relative">
        <div className="text-center">
          <div className="text-4xl mb-2">🗺️</div>
          <div className="text-text-primary font-medium mb-1">{name}</div>
          <div className="text-text-tertiary text-sm mb-4">
            {latitude.toFixed(4)}, {longitude.toFixed(4)}
          </div>
          
          {/* Action buttons */}
          <div className="flex gap-2 justify-center">
            <a
              href={googleMapsUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="bg-brand-primary text-text-inverse px-3 py-1 rounded text-sm hover:bg-brand-primary/80 transition-colors"
            >
              Google Maps
            </a>
            <a
              href={openStreetMapUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="bg-dark-surface text-text-primary border border-dark-border px-3 py-1 rounded text-sm hover:bg-dark-border transition-colors"
            >
              OpenStreetMap
            </a>
          </div>
        </div>
        
        {/* Coordinates overlay */}
        <div className="absolute bottom-2 left-2 bg-black/70 text-white text-xs px-2 py-1 rounded">
          📍 {latitude.toFixed(6)}, {longitude.toFixed(6)}
        </div>
      </div>
    </div>
  )
}