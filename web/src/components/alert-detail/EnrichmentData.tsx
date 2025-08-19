'use client'

import WeatherCard from './WeatherCard'
import SatelliteCard from './SatelliteCard'

interface EnrichmentDataProps {
  enrichment?: any
}

export default function EnrichmentData({ enrichment }: EnrichmentDataProps) {
  if (!enrichment) return null

  const { weather, satellites } = enrichment

  return (
    <div className="space-y-6">
      {weather && <WeatherCard weather={weather} />}
      {satellites && <SatelliteCard satellites={satellites} />}
    </div>
  )
}