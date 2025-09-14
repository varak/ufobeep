'use client'

import WeatherCard from './WeatherCard'
import SatelliteCard from './SatelliteCard'
import AircraftTrackingCard from './AircraftTrackingCard'
import CelestialCard from './CelestialCard'
import LocationCard from './LocationCard'
import ProcessingSummaryCard from './ProcessingSummaryCard'

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

  const { weather, satellites, aircraft_tracking, celestial, location, processing_summary } = enrichment

  return (
    <div className="space-y-6">
      {weather && <WeatherCard weather={weather} />}
      {celestial && <CelestialCard celestial={celestial} />}
      {location && <LocationCard location={location} />}
      {satellites && <SatelliteCard satellites={satellites} />}
      {aircraft_tracking && <AircraftTrackingCard aircraftData={aircraft_tracking} />}
      {processing_summary && <ProcessingSummaryCard summary={processing_summary} />}
    </div>
  )
}