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

  // Sort satellites by brightness (lower magnitude = brighter)
  const sortByBrightness = (sats: SatellitePass[]) => {
    return [...sats].sort((a, b) => {
      const magA = a.brightness_magnitude ?? 999
      const magB = b.brightness_magnitude ?? 999
      return magA - magB
    })
  }

  const previewSatellites = sortByBrightness(satellites.satellites_overhead_preview || [])
  const allSatellites = sortByBrightness(satellites.satellites_overhead || [])
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
        {displaySatellites.map((satellite, index) => {
          // Handle missing or invalid data gracefully
          const elevation = satellite.max_elevation_deg ?? 'N/A'
          const magnitude = satellite.brightness_magnitude ?? 'N/A'
          const timeString = satellite.max_elevation_time_utc
          let formattedTime = 'N/A'

          if (timeString) {
            try {
              const date = new Date(timeString)
              if (!isNaN(date.getTime())) {
                formattedTime = date.toLocaleTimeString([], {
                  hour: '2-digit',
                  minute: '2-digit',
                  hour12: false
                })
              }
            } catch (e) {
              console.warn('Invalid satellite time:', timeString)
            }
          }

          return (
            <div key={index} className="text-sm text-text-secondary mb-2">
              <div className="flex items-center justify-between">
                <span className="font-medium text-text-primary">
                  {satellite.satellite_name || 'Unknown Satellite'}
                </span>
                <span className="text-xs text-text-tertiary">
                  {satellite.direction || 'N/A'}
                </span>
              </div>
              <div className="text-xs text-text-tertiary">
                {elevation !== 'N/A' && `Max elevation: ${elevation}°`}
                {elevation !== 'N/A' && magnitude !== 'N/A' && ' | '}
                {magnitude !== 'N/A' && `Magnitude: ${magnitude}`}
                {(elevation !== 'N/A' || magnitude !== 'N/A') && formattedTime !== 'N/A' && ' | '}
                {formattedTime !== 'N/A' && formattedTime}
              </div>
            </div>
          )
        })}

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