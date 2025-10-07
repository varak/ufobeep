'use client'

import { useState } from 'react'
import { useClientTranslations } from '@/hooks/useClientTranslations'

interface SatellitePass {
  name: string
  norad_id?: number
  brightness_magnitude: number
  altitude: number
  is_bright: boolean
  direction?: string
  max_elevation_deg?: number
  max_elevation_time_utc?: string
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

  // Sort satellites by brightness (bright satellites first, then by magnitude)
  const sortByBrightness = (sats: SatellitePass[]) => {
    return [...sats].sort((a, b) => {
      // Bright satellites first
      if (a.is_bright && !b.is_bright) return -1
      if (!a.is_bright && b.is_bright) return 1

      // Then by magnitude (lower = brighter)
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
    <div className="bg-dark-surface/50 border border-dark-border/50 rounded-xl p-5 shadow-sm hover:bg-dark-surface/70 transition-colors">
      <div className="flex items-center gap-2 mb-4">
        <span className="text-brand-primary">🛰️</span>
        <h2 className="text-lg font-semibold text-brand-primary">{t('satelliteActivity')}</h2>
      </div>

      <div className="space-y-2">
        {displaySatellites.map((satellite, index) => {
          const name = satellite.name || 'Satellite'
          const noradId = satellite.norad_id
          const magnitude = satellite.brightness_magnitude
          const altitude = satellite.altitude
          const isBright = satellite.is_bright
          const direction = satellite.direction

          // Build satellite tracker URL
          const satelliteUrl = noradId
            ? `https://www.heavens-above.com/SatInfo.aspx?satid=${noradId}`
            : `https://www.heavens-above.com/SearchResults.aspx?searchstring=${encodeURIComponent(name)}`

          // Skip satellites with no useful data
          if (!name || name === 'Unknown Satellite') {
            return null
          }

          return (
            <div
              key={index}
              className={`p-3 rounded-lg border mb-2 ${
                isBright
                  ? 'bg-yellow-500/5 border-yellow-500/30'
                  : 'bg-dark-background border-dark-border'
              }`}
            >
              <div className="flex items-center justify-between mb-1">
                <div className="flex items-center gap-2">
                  <span className={`text-xs ${
                    isBright ? 'text-yellow-400' : 'text-text-tertiary'
                  }`}>
                    {isBright ? '☀️' : '🛰️'}
                  </span>
                  <a
                    href={satelliteUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="font-medium text-brand-primary hover:text-blue-400 hover:underline transition-colors text-sm"
                    title={noradId ? `View ${name} orbital details on Heavens-Above` : `Search for ${name} on Heavens-Above`}
                  >
                    {name}
                  </a>
                </div>
                {direction && (
                  <span className="text-xs text-text-tertiary bg-dark-surface px-2 py-1 rounded">
                    {direction}
                  </span>
                )}
              </div>
              <div className="text-xs text-text-secondary flex items-center gap-3">
                {altitude != null && (
                  <span className="flex items-center gap-1">
                    <span className="text-text-tertiary">Alt:</span>
                    <span className="text-text-primary">{altitude.toFixed(1)}°</span>
                  </span>
                )}
                {magnitude != null && (
                  <span>Magnitude: {magnitude}</span>
                )}
                {altitude != null && (
                  <span>Altitude: {altitude.toFixed(0)}km</span>
                )}
                {isBright && (
                  <span className="text-yellow-400 font-medium">Bright</span>
                )}
              </div>
            </div>
          )
        }).filter(Boolean)}

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