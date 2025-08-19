'use client'

interface EnrichmentDataProps {
  enrichment?: any
}

export default function EnrichmentData({ enrichment }: EnrichmentDataProps) {
  if (!enrichment) return null

  const { weather, celestial, aircraft } = enrichment

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
              <div className="text-text-primary text-sm">{weather.temperature}°C</div>
            </div>
            <div>
              <div className="text-text-tertiary text-xs">Conditions</div>
              <div className="text-text-primary text-sm">{weather.condition}</div>
            </div>
            <div>
              <div className="text-text-tertiary text-xs">Visibility</div>
              <div className="text-text-primary text-sm">{weather.visibility} km</div>
            </div>
            <div>
              <div className="text-text-tertiary text-xs">Wind</div>
              <div className="text-text-primary text-sm">{weather.wind_speed} m/s</div>
            </div>
            <div>
              <div className="text-text-tertiary text-xs">Humidity</div>
              <div className="text-text-primary text-sm">{weather.humidity}%</div>
            </div>
            <div>
              <div className="text-text-tertiary text-xs">Pressure</div>
              <div className="text-text-primary text-sm">{weather.pressure} hPa</div>
            </div>
          </div>
        </div>
      )}

      {/* Celestial data would go here if available */}
      {/* Aircraft data would go here if available */}
    </div>
  )
}