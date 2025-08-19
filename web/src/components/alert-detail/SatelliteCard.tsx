'use client'

interface SatellitePass {
  satellite_name: string
  direction: string
  max_elevation_deg: number
  brightness_magnitude: number
  max_elevation_time_utc: string
}

interface SatelliteData {
  iss_passes?: SatellitePass[]
  starlink_passes?: SatellitePass[]
}

interface SatelliteCardProps {
  satellites: SatelliteData
}

export default function SatelliteCard({ satellites }: SatelliteCardProps) {
  const hasData = (satellites.iss_passes && satellites.iss_passes.length > 0) || 
                  (satellites.starlink_passes && satellites.starlink_passes.length > 0)
  
  if (!hasData) return null

  return (
    <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
      <div className="flex items-center gap-2 mb-4">
        <span className="text-brand-primary">🛰️</span>
        <h2 className="text-lg font-semibold text-brand-primary">Satellite Activity</h2>
      </div>
      
      {satellites.iss_passes && satellites.iss_passes.length > 0 && (
        <div className="mb-4">
          <h3 className="text-sm font-medium text-text-primary mb-2">International Space Station</h3>
          {satellites.iss_passes.map((pass, index) => (
            <div key={index} className="text-sm text-text-secondary mb-2">
              <div>{pass.satellite_name} - {pass.direction}</div>
              <div className="text-xs text-text-tertiary">
                Max elevation: {pass.max_elevation_deg}° | 
                Magnitude: {pass.brightness_magnitude} | 
                {new Date(pass.max_elevation_time_utc).toLocaleTimeString()}
              </div>
            </div>
          ))}
        </div>
      )}

      {satellites.starlink_passes && satellites.starlink_passes.length > 0 && (
        <div className="mb-4">
          <h3 className="text-sm font-medium text-text-primary mb-2">Starlink Satellites</h3>
          {satellites.starlink_passes.map((pass, index) => (
            <div key={index} className="text-sm text-text-secondary mb-2">
              <div>{pass.satellite_name} - {pass.direction}</div>
              <div className="text-xs text-text-tertiary">
                Max elevation: {pass.max_elevation_deg}° | 
                Magnitude: {pass.brightness_magnitude} | 
                {new Date(pass.max_elevation_time_utc).toLocaleTimeString()}
              </div>
            </div>
          ))}
        </div>
      )}

      <div className="text-xs text-text-tertiary mt-3 p-2 bg-dark-background rounded">
        Satellites visible overhead at sighting time & location
      </div>
    </div>
  )
}