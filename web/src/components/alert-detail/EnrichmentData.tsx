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
  locale?: string
}

export default function EnrichmentData({ enrichment, alert, locale = 'en' }: EnrichmentDataProps) {
  // Skip enrichment data display for MUFON cases
  const isMufonCase = alert?.source === 'mufon' || alert?.reporter_username === 'MUFON_Database'
  
  if (!enrichment || isMufonCase) return null

  const { weather, satellites, aircraft_tracking, celestial, location, processing_summary, geocoding, blacksky, skyfi } = enrichment

  return (
    <div className="space-y-6">
      {weather && <WeatherCard weather={weather} locale={locale} />}
      {celestial && <CelestialCard celestial={celestial} locale={locale} />}
      {geocoding && <LocationCard location={geocoding} locale={locale} />}
      {satellites && <SatelliteCard satellites={satellites} locale={locale} />}
      {aircraft_tracking && <AircraftTrackingCard aircraftData={aircraft_tracking} locale={locale} />}
      {processing_summary && <ProcessingSummaryCard summary={processing_summary} locale={locale} />}
      {blacksky && (
        <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
          <div className="flex items-center gap-2 mb-4">
            <span className="text-brand-primary">🛰️</span>
            <h2 className="text-lg font-semibold text-brand-primary">BlackSky Imagery</h2>
          </div>
          <div className="space-y-2 text-text-secondary">
            <p><strong>Resolution:</strong> 35cm ground resolution</p>
            <p><strong>Delivery:</strong> 90-minute average</p>
            <p><strong>Cost:</strong> ${blacksky.pricing?.estimated_cost_usd || '50-100'}</p>
            <p><strong>Status:</strong> {blacksky.status}</p>
          </div>
        </div>
      )}
      {skyfi && (
        <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
          <div className="flex items-center gap-2 mb-4">
            <span className="text-brand-primary">🛰️</span>
            <h2 className="text-lg font-semibold text-brand-primary">SkyFi Satellite Imagery</h2>
          </div>
          <div className="space-y-2 text-text-secondary">
            <p><strong>Region:</strong> {skyfi.location?.region}</p>
            <p><strong>Starting Price:</strong> ${skyfi.pricing?.starting_price_usd}</p>
            <p><strong>Coverage:</strong> {(skyfi.availability?.coverage_confidence * 100).toFixed(0)}% confidence</p>
            <p><strong>Status:</strong> {skyfi.integration_status?.status}</p>
          </div>
        </div>
      )}
    </div>
  )
}