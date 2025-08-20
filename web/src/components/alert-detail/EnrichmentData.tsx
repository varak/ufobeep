'use client'

import WeatherCard from './WeatherCard'
import SatelliteCard from './SatelliteCard'
import AircraftTrackingCard from './AircraftTrackingCard'

interface EnrichmentDataProps {
  enrichment?: any
}

export default function EnrichmentData({ enrichment }: EnrichmentDataProps) {
  if (!enrichment) return null

  const { weather, satellites, aircraft_tracking } = enrichment

  return (
    <div className="space-y-6">
      {aircraft_tracking && <AircraftTrackingCard aircraftData={aircraft_tracking} />}
      {weather && <WeatherCard weather={weather} />}
      {satellites && <SatelliteCard satellites={satellites} />}
    </div>
  )
}