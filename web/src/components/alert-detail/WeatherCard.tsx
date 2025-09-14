'use client'

import { useClientTranslations } from '@/hooks/useClientTranslations'
import { UnitConversion } from '../../utils/unitConversion'

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
  locale?: string
}

export default function WeatherCard({ weather, locale = 'en' }: WeatherCardProps) {
  const { t } = useClientTranslations('common', locale)
  // Website defaults to imperial units
  const units = 'imperial';

  return (
    <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
      <div className="flex items-center gap-2 mb-4">
        <span className="text-brand-primary">🌤️</span>
        <h2 className="text-lg font-semibold text-brand-primary">{t('weatherConditionsTitle')}</h2>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
        <div>
          <div className="text-text-tertiary text-xs">{t('temperature')}</div>
          <div className="text-text-primary text-sm">{UnitConversion.formatTemperature(weather.temperature_c, units)}</div>
        </div>
        <div>
          <div className="text-text-tertiary text-xs">{t('weather')}</div>
          <div className="text-text-primary text-sm">{weather.weather_description}</div>
        </div>
        <div>
          <div className="text-text-tertiary text-xs">{t('visibility')}</div>
          <div className="text-text-primary text-sm">{UnitConversion.formatVisibility(weather.visibility_km, units)}</div>
        </div>
        <div>
          <div className="text-text-tertiary text-xs">{t('wind')}</div>
          <div className="text-text-primary text-sm">{UnitConversion.formatWindSpeed(weather.wind_speed_ms, units)}</div>
        </div>
        <div>
          <div className="text-text-tertiary text-xs">{t('humidity')}</div>
          <div className="text-text-primary text-sm">{weather.humidity_percent}{t('percent')}</div>
        </div>
        <div>
          <div className="text-text-tertiary text-xs">{t('pressure')}</div>
          <div className="text-text-primary text-sm">{weather.pressure_hpa} hPa</div>
        </div>
      </div>
    </div>
  )
}