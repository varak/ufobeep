'use client'

interface EnrichmentDataProps {
  enrichment?: any
}

export default function EnrichmentData({ enrichment }: EnrichmentDataProps) {
  if (!enrichment) return null

  const { weather, satellites, geocoding } = enrichment

  return (
    <div className="space-y-6">
      {/* Weather */}
      {weather && (
        <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
          <div className="flex items-center gap-2 mb-4">
            <span className="text-brand-primary">🌤️</span>
            <h2 className="text-lg font-semibold text-brand-primary">Weather Conditions</h2>
          </div>
          
          <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
            <div>
              <div className="text-text-tertiary text-xs">Temperature</div>
              <div className="text-text-primary text-sm">{weather.temperature_c?.toFixed(1)}°C</div>
            </div>
            <div>
              <div className="text-text-tertiary text-xs">Conditions</div>
              <div className="text-text-primary text-sm">{weather.weather_description}</div>
            </div>
            <div>
              <div className="text-text-tertiary text-xs">Visibility</div>
              <div className="text-text-primary text-sm">{weather.visibility_km} km</div>
            </div>
            <div>
              <div className="text-text-tertiary text-xs">Wind</div>
              <div className="text-text-primary text-sm">{weather.wind_speed_ms?.toFixed(1)} m/s</div>
            </div>
            <div>
              <div className="text-text-tertiary text-xs">Humidity</div>
              <div className="text-text-primary text-sm">{weather.humidity_percent}%</div>
            </div>
            <div>
              <div className="text-text-tertiary text-xs">Pressure</div>
              <div className="text-text-primary text-sm">{weather.pressure_hpa} hPa</div>
            </div>
          </div>
        </div>
      )}

      {/* Satellites */}
      {satellites && (
        <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
          <div className="flex items-center gap-2 mb-4">
            <span className="text-brand-primary">🛰️</span>
            <h2 className="text-lg font-semibold text-brand-primary">Satellite Activity</h2>
          </div>
          
          {satellites.iss_passes && satellites.iss_passes.length > 0 && (
            <div className="mb-4">
              <h3 className="text-sm font-medium text-text-primary mb-2">International Space Station</h3>
              {satellites.iss_passes.map((pass: any, index: number) => (
                <div key={index} className="text-sm text-text-secondary">
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
              {satellites.starlink_passes.map((pass: any, index: number) => (
                <div key={index} className="text-sm text-text-secondary">
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
      )}
    </div>
  )
}