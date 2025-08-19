'use client'

interface WeatherData {
  temperature_c: number
  weather_description: string
  visibility_km: number
  wind_speed_ms: number
  humidity_percent: number
  pressure_hpa: number
}

interface WeatherCardProps {
  weather: WeatherData
}

export default function WeatherCard({ weather }: WeatherCardProps) {
  return (
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
  )
}