'use client'

import { useState } from 'react'
import { useClientTranslations } from '@/hooks/useClientTranslations'

interface Aircraft {
  callsign: string
  distance_km: number
  altitude_ft: number | null
  speed_knots: number | null
  heading: number | null
  country: string
  lat: number
  lon: number
}

interface AircraftData {
  aircraft: Aircraft[]
  total: number
  summary: string
}

interface AircraftTrackingCardProps {
  aircraftData: AircraftData
  locale?: string
}

export default function AircraftTrackingCard({ aircraftData, locale = 'en' }: AircraftTrackingCardProps) {
  const { t } = useClientTranslations('common', locale)
  const [isExpanded, setIsExpanded] = useState(false)

  if (!aircraftData || aircraftData.total === 0) {
    return (
      <div className="bg-dark-surface/50 border border-dark-border/50 rounded-xl p-5 shadow-sm hover:bg-dark-surface/70 transition-colors">
        <div className="flex items-center gap-3 mb-4">
          <div className="bg-blue-500/10 p-2 rounded-lg">
            <span className="text-xl">✈️</span>
          </div>
          <div>
            <h3 className="text-lg font-semibold text-brand-primary">{t('aircraftTrackingTitle')}</h3>
            <p className="text-sm text-text-secondary">{t('aircraftDataSource')}</p>
          </div>
        </div>

        <div className="text-center py-4 text-text-tertiary">
          <p>{t('noAircraftDetected')}</p>
        </div>
      </div>
    )
  }

  return (
    <div className="bg-dark-surface/50 border border-dark-border/50 rounded-xl p-5 shadow-sm hover:bg-dark-surface/70 transition-colors">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-3">
          <div className="bg-blue-500/10 p-2 rounded-lg">
            <span className="text-xl">✈️</span>
          </div>
          <div>
            <h3 className="text-lg font-semibold text-brand-primary">{t('aircraftTrackingTitle')}</h3>
            <p className="text-sm text-text-secondary">{t('aircraftDataSource')}</p>
          </div>
        </div>

        <div className="text-right">
          <div className="text-lg font-bold text-brand-primary">{aircraftData.total}</div>
          <div className="text-xs text-text-tertiary">{t('aircraftDetected')}</div>
        </div>
      </div>

      <div className="mb-4 text-sm text-text-secondary">
        {aircraftData.summary}
      </div>

      {aircraftData.aircraft.length > 0 && (
        <div className="space-y-3">
          <h4 className="text-sm font-medium text-brand-primary">{t('nearbyAircraft')}</h4>
          <div className="space-y-2">
            {(isExpanded ? aircraftData.aircraft : aircraftData.aircraft.slice(0, 4)).map((aircraft, index) => (
              <div key={index} className="bg-dark-surface border border-dark-border rounded-lg p-3">
                <div className="flex items-center justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      {aircraft.callsign ? (
                        <a
                          href={`https://flightaware.com/live/flight/${aircraft.callsign}`}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="font-medium text-brand-primary hover:text-blue-400 hover:underline transition-colors"
                        >
                          {aircraft.callsign}
                        </a>
                      ) : (
                        <span className="font-medium text-brand-primary">
                          {t('unknown')}
                        </span>
                      )}
                      <span className="text-xs text-text-tertiary bg-dark-surface px-2 py-1 rounded">
                        {aircraft.country}
                      </span>
                    </div>
                    
                    <div className="flex items-center gap-4 mt-1 text-sm text-text-secondary">
                      <span>{aircraft.distance_km}km away</span>
                      {aircraft.altitude_ft && (
                        <span>{aircraft.altitude_ft.toLocaleString()}ft</span>
                      )}
                      {aircraft.speed_knots && (
                        <span>{aircraft.speed_knots}kts</span>
                      )}
                      {aircraft.heading && (
                        <span>{aircraft.heading}°</span>
                      )}
                    </div>
                  </div>
                  
                  <div className="text-right text-xs text-text-tertiary">
                    <div>{aircraft.lat}°</div>
                    <div>{aircraft.lon}°</div>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Show expand button if more than 4 aircraft */}
          {aircraftData.aircraft.length > 4 && (
            <div className="pt-2">
              <button
                onClick={() => setIsExpanded(!isExpanded)}
                className="flex items-center gap-2 w-full justify-center py-2 px-4 bg-dark-background border border-brand-primary rounded-lg text-brand-primary hover:bg-brand-primary/5 transition-colors text-sm"
              >
                <span>
                  {isExpanded ? 'Show less' : `See all ${aircraftData.aircraft.length} aircraft`}
                </span>
                <svg
                  className={`w-4 h-4 transition-transform ${
                    isExpanded ? 'rotate-180' : ''
                  }`}
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M19 9l-7 7-7-7"
                  />
                </svg>
              </button>
            </div>
          )}

          {/* Show additional summary if there are more in total from API */}
          {aircraftData.total > aircraftData.aircraft.length && (
            <div className="text-center text-xs text-text-tertiary pt-2">
              +{aircraftData.total - aircraftData.aircraft.length} {t('moreAircraftInArea')}
            </div>
          )}
        </div>
      )}
    </div>
  )
}