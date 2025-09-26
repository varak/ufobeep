'use client'

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

        {celestial.visible_planets && celestial.visible_planets.length > 0 && (
          <div className="col-span-2">
            <div className="text-text-tertiary text-xs">{t('visiblePlanets', 'Visible Planets')}</div>
            <div className="text-text-primary text-sm">{celestial.visible_planets.join(', ')}</div>
          </div>
        )}

        {celestial.brightest_stars && celestial.brightest_stars.length > 0 && (
          <div className="col-span-2">
            <div className="text-text-tertiary text-xs">{t('brightestStars', 'Brightest Stars')}</div>
            <div className="text-text-primary text-sm">{celestial.brightest_stars.join(', ')}</div>
          </div>
        )}
      </div>
    </div>
  )
}
