'use client'

import { useState } from 'react'
import { useClientTranslations } from '@/hooks/useClientTranslations'

interface CelestialData {
  sun?: {
    altitude: number
    azimuth: number
    is_visible: boolean
  }
  moon?: {
    altitude: number
    azimuth: number
    is_visible: boolean
    illumination_pct?: number
    phase_name?: string
  }
  visible_planets?: Array<{
    name: string
    altitude: number
    azimuth: number
    magnitude?: number
  }>
  bright_stars_visible?: Array<{
    name: string
    altitude: number
    azimuth: number
    magnitude: number
  }>
  summary?: {
    twilight: string
  }
}

interface CelestialCardProps {
  celestial: CelestialData
  locale?: string
}

export default function CelestialCard({ celestial, locale = 'en' }: CelestialCardProps) {
  const { t } = useClientTranslations('common', locale)
  const [isExpanded, setIsExpanded] = useState(false)

  const hasPlanets = Array.isArray(celestial.visible_planets) && celestial.visible_planets.length > 0
  const hasStars = Array.isArray(celestial.bright_stars_visible) && celestial.bright_stars_visible.length > 0
  const hasMoon = celestial.moon !== undefined
  const hasSun = celestial.sun !== undefined
  const hasAnyData = hasPlanets || hasStars || hasMoon || hasSun

  return (
    <div className="bg-dark-surface/50 border border-dark-border/50 rounded-xl p-5 shadow-sm hover:bg-dark-surface/70 transition-colors">
      <div className="flex items-center gap-2 mb-4">
        <span className="text-brand-primary">🌌</span>
        <h2 className="text-lg font-semibold text-brand-primary">{t('celestialDataTitle')}</h2>
      </div>

      {!hasAnyData && (
        <div className="text-text-secondary text-sm">
          {t('noCelestialData', 'No celestial data available for this sighting.')}
        </div>
      )}

      <div className="space-y-4">
        {/* Sun */}
        {celestial.sun && (
          <div className="flex items-center gap-3">
            <span className="text-xl">☀️</span>
            <div>
              <div className="text-text-primary text-sm font-medium">
                Sun {celestial.sun.is_visible ? 'visible' : 'below horizon'}
              </div>
              <div className="text-text-tertiary text-xs">
                {celestial.sun.altitude.toFixed(1)}° altitude • {celestial.sun.azimuth.toFixed(1)}° azimuth
              </div>
            </div>
          </div>
        )}

        {/* Moon */}
        {celestial.moon && (
          <div className="flex items-center gap-3">
            <span className="text-xl">🌙</span>
            <div>
              <div className="text-text-primary text-sm font-medium">
                Moon {celestial.moon.phase_name ? `(${celestial.moon.phase_name})` : ''}
                {celestial.moon.illumination_pct !== undefined && ` ${celestial.moon.illumination_pct.toFixed(0)}% lit`}
              </div>
              <div className="text-text-tertiary text-xs">
                {celestial.moon.altitude.toFixed(1)}° altitude • {celestial.moon.azimuth.toFixed(1)}° azimuth
              </div>
            </div>
          </div>
        )}

        {/* Planets */}
        {hasPlanets && (
          <div className="flex items-start gap-3">
            <span className="text-xl">🪐</span>
            <div>
              <div className="text-text-primary text-sm font-medium">
                Planets ({celestial.visible_planets!.length} visible)
              </div>
              <div className="text-text-tertiary text-xs">
                {(() => {
                  const displayPlanets = isExpanded ? celestial.visible_planets! : celestial.visible_planets!.slice(0, 3)
                  const planetText = displayPlanets.map(p => `${p.name} at ${p.altitude.toFixed(0)}°`).join(', ')

                  if (!isExpanded && celestial.visible_planets!.length > 3) {
                    return planetText + ` (+${celestial.visible_planets!.length - 3} more)`
                  }
                  return planetText
                })()}
              </div>
            </div>
          </div>
        )}

        {/* Stars */}
        {hasStars && (
          <div className="flex items-start gap-3">
            <span className="text-xl">⭐</span>
            <div>
              <div className="text-text-primary text-sm font-medium">
                Bright Stars ({celestial.bright_stars_visible!.length} visible)
              </div>
              <div className="text-text-tertiary text-xs">
                {(() => {
                  const displayStars = isExpanded ? celestial.bright_stars_visible! : celestial.bright_stars_visible!.slice(0, 3)
                  const starText = displayStars.map(s => `${s.name} (${s.magnitude.toFixed(1)} mag)`).join(', ')

                  if (!isExpanded && celestial.bright_stars_visible!.length > 3) {
                    return starText + ` (+${celestial.bright_stars_visible!.length - 3} more)`
                  }
                  return starText
                })()}
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Show expand button if there are more than 3 planets or stars total */}
      {((Array.isArray(celestial.visible_planets) && celestial.visible_planets.length > 3) ||
        (Array.isArray(celestial.bright_stars_visible) && celestial.bright_stars_visible.length > 3)) && (
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
