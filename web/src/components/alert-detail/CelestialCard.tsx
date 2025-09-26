'use client'

import { useState } from 'react'
import { useClientTranslations } from '@/hooks/useClientTranslations'

interface CelestialData {
  moon_phase?: number
  moon_phase_name?: string
  moon_illumination?: number
  sun_elevation?: number
  is_twilight?: boolean
  visible_planets?: string[]
  brightest_stars?: string[]
}

interface CelestialCardProps {
  celestial: CelestialData
  locale?: string
}

export default function CelestialCard({ celestial, locale = 'en' }: CelestialCardProps) {
  const { t } = useClientTranslations('common', locale)
  const [isExpanded, setIsExpanded] = useState(false)

  const hasPlanets = Array.isArray(celestial.visible_planets) && celestial.visible_planets.length > 0
  const hasStars = Array.isArray(celestial.brightest_stars) && celestial.brightest_stars.length > 0
  const hasMoon = celestial.moon_phase_name !== undefined || celestial.moon_illumination !== undefined
  const hasSun = celestial.sun_elevation !== undefined || celestial.is_twilight !== undefined
  const hasAnyData = hasPlanets || hasStars || hasMoon || hasSun

  return (
    <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
      <div className="flex items-center gap-2 mb-4">
        <span className="text-brand-primary">🌙</span>
        <h2 className="text-lg font-semibold text-brand-primary">{t('celestialDataTitle')}</h2>
      </div>

      {!hasAnyData && (
        <div className="text-text-secondary text-sm">
          {t('noCelestialData', 'No celestial data available for this sighting.')}
        </div>
      )}

      <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
        {celestial.moon_phase_name && (
          <div>
            <div className="text-text-tertiary text-xs">{t('moonPhase', 'Moon Phase')}</div>
            <div className="text-text-primary text-sm">{celestial.moon_phase_name}</div>
          </div>
        )}

        {celestial.moon_illumination !== undefined && (
          <div>
            <div className="text-text-tertiary text-xs">{t('moonIllumination', 'Moon Illumination')}</div>
            <div className="text-text-primary text-sm">{celestial.moon_illumination}%</div>
          </div>
        )}

        {celestial.sun_elevation !== undefined && (
          <div>
            <div className="text-text-tertiary text-xs">{t('sunElevation', 'Sun Elevation')}</div>
            <div className="text-text-primary text-sm">{celestial.sun_elevation.toFixed(1)}°</div>
          </div>
        )}

        {celestial.is_twilight !== undefined && (
          <div>
            <div className="text-text-tertiary text-xs">{t('isTwilight', 'Twilight')}</div>
            <div className="text-text-primary text-sm">{celestial.is_twilight ? t('yes') : t('no')}</div>
          </div>
        )}

        {Array.isArray(celestial.visible_planets) && celestial.visible_planets.length > 0 ? (
          <div className="col-span-2">
            <div className="text-text-tertiary text-xs">{t('visiblePlanets', 'Visible Planets')}</div>
            <div className="text-text-primary text-sm">
              {(() => {
                if (Array.isArray(celestial.visible_planets)) {
                  // Accept either string[] or {name:string}[]
                  const allNames = celestial.visible_planets.map((p: any) => typeof p === 'string' ? p : (p?.name || '')).filter(Boolean)
                  const displayNames = isExpanded ? allNames : allNames.slice(0, 4)
                  const result = displayNames.join(', ')

                  // Add expand indicator if there are more planets
                  if (!isExpanded && allNames.length > 4) {
                    return result + ` (+${allNames.length - 4} more)`
                  }
                  return result
                }
                return ''
              })()}
            </div>
          </div>
        ) : null}

        {celestial.brightest_stars && celestial.brightest_stars.length > 0 && (
          <div className="col-span-2">
            <div className="text-text-tertiary text-xs">{t('brightestStars', 'Brightest Stars')}</div>
            <div className="text-text-primary text-sm">
              {(() => {
                const allStars = celestial.brightest_stars
                const displayStars = isExpanded ? allStars : allStars.slice(0, 4)
                const result = displayStars.join(', ')

                // Add expand indicator if there are more stars
                if (!isExpanded && allStars.length > 4) {
                  return result + ` (+${allStars.length - 4} more)`
                }
                return result
              })()
              }
            </div>
          </div>
        )}
      </div>

      {/* Show expand button if there are more than 4 planets or stars total */}
      {((Array.isArray(celestial.visible_planets) && celestial.visible_planets.length > 4) ||
        (Array.isArray(celestial.brightest_stars) && celestial.brightest_stars.length > 4)) && (
        <div className="pt-4">
          <button
            onClick={() => setIsExpanded(!isExpanded)}
            className="flex items-center gap-2 w-full justify-center py-2 px-4 bg-dark-background border border-brand-primary rounded-lg text-brand-primary hover:bg-brand-primary/5 transition-colors text-sm"
          >
            <span>
              {isExpanded ? 'Show less' : 'See all celestial objects'}
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
    </div>
  )
}
