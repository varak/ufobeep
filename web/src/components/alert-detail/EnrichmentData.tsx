'use client'

import WeatherCard from './WeatherCard'
import SatelliteCard from './SatelliteCard'
import AircraftTrackingCard from './AircraftTrackingCard'

interface EnrichmentDataProps {
  enrichment?: any
  alert?: {
    source?: string
    reporter_username?: string
  }
}

export default function EnrichmentData({ enrichment, alert }: EnrichmentDataProps) {
  // Skip enrichment data display for MUFON cases
  const isMufonCase = alert?.source === 'mufon' || alert?.reporter_username === 'MUFON_Database'
  
  if (!enrichment || isMufonCase) return null

  const { weather, satellites, aircraft_tracking } = enrichment

  return (
    <div className="space-y-6">
      {weather && <WeatherCard weather={weather} />}
      {satellites && <SatelliteCard satellites={satellites} />}
      {aircraft_tracking && <AircraftTrackingCard aircraftData={aircraft_tracking} />}
    </div>
  )
}