'use client'

import WeatherCard from './WeatherCard'
import SatelliteCard from './SatelliteCard'
import AircraftTrackingCard from './AircraftTrackingCard'
import CelestialCard from './CelestialCard'
import LocationCard from './LocationCard'
import ProcessingSummaryCard from './ProcessingSummaryCard'
import { useClientTranslations } from '@/hooks/useClientTranslations'

interface EnrichmentDataProps {
  enrichment?: any
  alert?: {
    source?: string
    reporter_username?: string
  }
  locale?: string
}

export default function EnrichmentData({ enrichment, alert, locale = 'en' }: EnrichmentDataProps) {
  const { t } = useClientTranslations('common', locale)

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
            <h2 className="text-lg font-semibold text-brand-primary">{t('blackskyImagery')}</h2>
          </div>
          <div className="space-y-2 text-text-secondary">
            <p><strong>{t('resolution')}:</strong> {t('groundResolution')}</p>
            <p><strong>{t('delivery')}:</strong> {t('averageDelivery')}</p>
            <p><strong>{t('cost')}:</strong> ${blacksky.pricing?.estimated_cost_usd || '50-100'}</p>
            <p><strong>{t('status')}:</strong> {blacksky.status}</p>
          </div>
        </div>
      )}
      {skyfi && (
        <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
          <div className="flex items-center gap-2 mb-4">
            <span className="text-brand-primary">🛰️</span>
            <h2 className="text-lg font-semibold text-brand-primary">{t('skyfiSatelliteImagery')}</h2>
          </div>
          <div className="space-y-2 text-text-secondary">
            <p><strong>{t('region')}:</strong> {skyfi.location?.region || t('remoteArea')}</p>
            <p><strong>{t('startingPrice')}:</strong> ${skyfi.pricing?.starting_price_usd}</p>
            <p><strong>{t('coverage')}:</strong> {(skyfi.availability?.coverage_confidence * 100).toFixed(0)}% {t('confidenceCoverage').split('%')[1]}</p>
            <p><strong>{t('status')}:</strong> {skyfi.integration_status?.status}</p>
          </div>
        </div>
      )}
    </div>
  )
}