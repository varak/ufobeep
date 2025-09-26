'use client'

import { useState } from 'react'
import { useClientTranslations } from '@/hooks/useClientTranslations'

interface SatellitePass {
  satellite_name: string
  direction: string
  max_elevation_deg: number
  brightness_magnitude: number
  max_elevation_time_utc: string
}

interface SatelliteData {
  satellites_overhead?: SatellitePass[]
  satellites_overhead_preview?: SatellitePass[]
}

interface SatelliteCardProps {
  satellites: SatelliteData
  locale?: string
}

export default function SatelliteCard({ satellites, locale = 'en' }: SatelliteCardProps) {
  const { t } = useClientTranslations('common', locale)
  const [isExpanded, setIsExpanded] = useState(false)

  const previewSatellites = satellites.satellites_overhead_preview || []
  const allSatellites = satellites.satellites_overhead || []
  const hasData = previewSatellites.length > 0

  if (!hasData) return null

  const showExpandButton = allSatellites.length > previewSatellites.length
  const displaySatellites = isExpanded ? allSatellites : previewSatellites

  return (
    <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
      <div className="flex items-center gap-2 mb-4">
        <span className="text-brand-primary">🛰️</span>
        <h2 className="text-lg font-semibold text-brand-primary">{t('satelliteActivity')}</h2>
      </div>

      <div className="space-y-2">
        {displaySatellites.map((satellite, index) => (
          <div key={index} className="text-sm text-text-secondary mb-2">
            <div className="flex items-center justify-between">
              <span className="font-medium text-text-primary">{satellite.satellite_name}</span>
              <span className="text-xs text-text-tertiary">{satellite.direction}</span>
            </div>
            <div className="text-xs text-text-tertiary">
              Max elevation: {satellite.max_elevation_deg}° |
              Magnitude: {satellite.brightness_magnitude} |
              {new Date(satellite.max_elevation_time_utc).toLocaleTimeString()}
            </div>
          </div>
        ))}

        {/* Expand/collapse button */}
        {showExpandButton && (
          <div className="pt-2">
            <button
              onClick={() => setIsExpanded(!isExpanded)}
              className="flex items-center gap-2 w-full justify-center py-2 px-4 bg-dark-background border border-brand-primary rounded-lg text-brand-primary hover:bg-brand-primary/5 transition-colors text-sm"
            >
              <span>
                {isExpanded ? 'Show less' : `See all ${allSatellites.length} satellites`}
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

      <div className="text-xs text-text-tertiary mt-3 p-2 bg-dark-background rounded">
        {t('satellitesVisibleOverhead')}
      </div>
    </div>
  )
}