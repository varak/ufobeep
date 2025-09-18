'use client'

import { getShortAlertUrl } from '@/utils/slug'
import { formatDistance, getUnitPreference } from '@/utils/units'
import { UnitConversion } from '@/utils/unitConversion'
import { useClientTranslations } from '@/hooks/useClientTranslations'

interface Alert {
  id: string
  title: string
  description: string
  created_at: string
  occurred_at?: string
  username?: string
  source?: string
  location: {
    latitude: number
    longitude: number
    name: string
  }
  alert_level?: string
  witness_count?: number
  total_confirmations?: number
  enrichment?: {
    report_date?: string
    sighting_datetime?: string
    mufon_case_id?: string
    [key: string]: any
  }
  enrichment_data?: {
    report_date?: string
    sighting_datetime?: string
    mufon_case_id?: string
    [key: string]: any
  }
  distance_km?: number
}

interface AlertDetailsProps {
  alert: Alert
  locale?: string
}

export default function AlertDetails({ alert, locale = 'en' }: AlertDetailsProps) {
  const { t } = useClientTranslations('common', locale)
  
  // Check if this is a UFOBeep report (not MUFON/NUFORC)
  const isUfoBeepReport = alert.username &&
    alert.username !== 'MUFON' &&
    alert.username !== 'NUFORC'
  // Parse MUFON date format like "1979-07-21\n12:00AM"
  const parseMufonDate = (dateString: string) => {
    if (!dateString) return dateString
    // Extract just the date part before the newline/br
    const datePart = dateString.split(/[\n<]/)[0].trim()
    return datePart
  }

  const formatDate = (dateString: string) => {
    // Map locale to proper browser locale format
    const localeMap: Record<string, string> = {
      'en': 'en-US',
      'es': 'es-ES',
      'de': 'de-DE',
      'fr': 'fr-FR',
      'pt': 'pt-PT',
      'ru': 'ru-RU',
      'ja': 'ja-JP',
      'zh': 'zh-CN',
      'it': 'it-IT',
      'ar': 'ar-SA',
      'ko': 'ko-KR',
      'tr': 'tr-TR',
      'hi': 'hi-IN',
      'pl': 'pl-PL',
      'cs': 'cs-CZ',
      'nl': 'nl-NL',
      'sv': 'sv-SE',
      'da': 'da-DK',
      'no': 'nb-NO',
      'fi': 'fi-FI',
      'el': 'el-GR',
      'he': 'he-IL'
    }

    const browserLocale = localeMap[locale] || 'en-US'
    return new Date(dateString).toLocaleString(browserLocale, {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  const formatDateISO = (dateString: string) => {
    const date = new Date(dateString)
    const now = new Date()

    // ISO format (YYYY-MM-DD) for international consistency
    const isoDate = date.toISOString().split('T')[0]

    // Check if it's today
    const isToday = date.toDateString() === now.toDateString()

    if (isToday) {
      // Show date and time for today's sightings
      const timeStr = date.toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: false // Use 24-hour format for consistency
      })
      return `${isoDate} • ${timeStr}`
    } else {
      // Show just the ISO date for older sightings
      return isoDate
    }
  }

  const getCleanDescription = () => {
    if (!alert.description) return ''
    
    // For MUFON alerts, remove the duplicate metadata section
    if (alert.source === 'mufon' || alert.reporter_username === 'MUFON') {
      return alert.description.split('━━━━━━━━━━━━━━━━━━━━━━━━')[0].trim()
    }
    
    return alert.description
  }

  const formatFullDate = (dateString: string) => {
    const date = new Date(dateString)
    const now = new Date()
    const diff = now.getTime() - date.getTime()
    const minutes = Math.floor(diff / (1000 * 60))
    
    if (minutes < 60) return `${minutes}m ago`
    const hours = Math.floor(minutes / 60)
    if (hours < 24) return `${hours}h ago`
    const days = Math.floor(hours / 24)
    return `${days}d ago`
  }

  return (
    <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
      {alert.reporter_username !== 'MUFON' && (
        <div className="flex items-center gap-2 mb-4">
          <span className="text-brand-primary">ℹ️</span>
          <h2 className="text-lg font-semibold text-brand-primary">{t('detailsTitle')}</h2>
        </div>
      )}

      {/* Reporter section */}
      <div className="flex items-start gap-3 mb-4">
        <span className="text-text-tertiary mt-0.5">👤</span>
        <div className="flex-1">
          <div className="flex items-center gap-2">
            <span className="text-text-tertiary text-sm font-medium">Reported by:</span>
            <span className="text-text-primary text-sm">{alert.username}</span>
          </div>
        </div>
      </div>



      {/* Description - Main description now contains full text */}
      {alert.description && (
        <div className="mb-6">
          {/* MUFON attribution with case number */}
          {alert.reporter_username === 'MUFON' && (
            <div className="mb-4 p-3 bg-blue-500/10 border border-blue-500/20 rounded-lg">
              <div className="flex items-center gap-2">
                <span className="text-blue-400">🛸</span>
                <span className="text-blue-300 font-medium">{t('mufonDatabaseReport')}</span>
                {alert.enrichment?.mufon_case_id && (
                  <span className="text-text-tertiary text-sm">
                    Case #{alert.enrichment.mufon_case_id}
                  </span>
                )}
              </div>
            </div>
          )}
          <div
            className="text-text-primary leading-relaxed prose prose-invert max-w-none"
            dangerouslySetInnerHTML={{
              __html: getCleanDescription().replace(/\n/g, '<br>')
            }}
          />
        </div>
      )}

      {/* Time - Show MUFON times if available, otherwise show UFOBeep time */}
      {(alert.source === 'mufon' || alert.reporter_username === 'MUFON') ? (
        <div className="flex items-start gap-3 mb-4">
          <span className="text-text-tertiary mt-0.5">📅</span>
          <div className="flex-1">
            {/* Event Time (when sighting occurred) - for MUFON reports */}
            {alert.enrichment_data?.sighting_datetime && (
              <div className="mb-2">
                <div className="flex items-center gap-2">
                  <span className="text-text-tertiary text-sm font-medium">{t('eventTime')}</span>
                  <span className="text-text-primary text-sm">{parseMufonDate(alert.enrichment_data.sighting_datetime)}</span>
                </div>
              </div>
            )}
            {/* Report Time (when added to MUFON database) */}
            {alert.enrichment_data?.report_date && (
              <div className="mb-2">
                <div className="flex items-center gap-2">
                  <span className="text-text-tertiary text-sm font-medium">{t('reportedTime')}</span>
                  <span className="text-text-primary text-sm">{alert.enrichment_data.report_date}</span>
                </div>
              </div>
            )}
            {/* UFOBeep Import Time */}
            <div>
              <div className="flex items-center gap-2">
                <span className="text-text-tertiary text-sm font-medium">{t('addedToUfobeep')}:</span>
                <span className="text-text-primary text-sm">{formatDateISO(alert.created_at)}</span>
              </div>
            </div>
          </div>
        </div>
      ) : (
        <div className="flex items-start gap-3 mb-4">
          <span className="text-text-tertiary mt-0.5">⏰</span>
          <div className="flex-1">
            <div className="flex items-center gap-2">
              <span className="text-text-tertiary text-sm font-medium">{t('timeLabel')}</span>
              <span className="text-text-primary text-sm">{formatFullDate(alert.created_at)}</span>
            </div>
            <div className="text-text-primary text-xs mt-1">
              {formatDate(alert.created_at)}
            </div>
          </div>
        </div>
      )}

      {/* Location for all alerts */}
      <div className="flex items-start gap-3 mb-4">
        <span className="text-text-tertiary mt-0.5">📍</span>
        <div className="flex-1">
          <div className="flex items-center gap-2">
            <span className="text-text-tertiary text-sm font-medium">{t('locationLabel')}</span>
            <span className="text-text-primary text-sm">
              {(() => {
                // Clean up location name to avoid duplication
                let locationName = alert.reporter_username === 'MUFON'
                  ? (alert.enrichment?.geocoding?.display_name ||
                     alert.enrichment?.geocoding?.location ||
                     alert.enrichment?.location_raw ||
                     alert.location?.name || 'Unknown Location')
                  : (alert.location?.name || 'Unknown Location')

                // For MUFON reports, also check enrichment fallback
                if (locationName === 'Unknown Location' || locationName.includes('°')) {
                  // Remove coordinates fallback since we want proper location names
                  locationName = 'Unknown Location'
                }
                
                // Remove duplicate state/country suffixes
                if (locationName.includes(',')) {
                  const parts = locationName.split(',').map((p: string) => p.trim())
                  // Remove duplicate consecutive parts (e.g., "Nevada, Nevada" -> "Nevada")
                  const uniqueParts = parts.filter((part: string, index: number) => {
                    return index === 0 || part !== parts[index - 1]
                  })
                  locationName = uniqueParts.join(', ')
                }
                
                return locationName
              })()} 
              {alert.distance_km !== undefined && alert.distance_km > 0 && (
                <span className="text-text-tertiary text-xs font-normal ml-2">
                  ({UnitConversion.formatDistanceFromKm(
                    alert.distance_km,
                    UnitConversion.getAutoUnits()
                  )} {t('distanceAway')})
                </span>
              )}
            </span>
          </div>
        </div>
      </div>
      
      {/* Environmental Analysis Sections */}
      {alert.enrichment && (
        <>
          {/* Weather Conditions */}
          {alert.enrichment.weather && (
            <div className="flex items-start gap-3 mb-4">
              <span className="text-text-tertiary mt-0.5">🌤️</span>
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-2">
                  <span className="text-text-tertiary text-sm font-medium">{t('weather')}</span>
                </div>
                <div className="text-text-primary text-sm">
                  {alert.enrichment.weather.weather_description && (
                    <div>{alert.enrichment.weather.weather_description}</div>
                  )}
                  {alert.enrichment.weather.temperature_c !== undefined && (
                    <div>{t('temperature')}: {UnitConversion.formatTemperature(
                      alert.enrichment.weather.temperature_c, 
                      UnitConversion.getAutoUnits()
                    )}</div>
                  )}
                  {alert.enrichment.weather.cloud_cover !== undefined && (
                    <div>{t('cloudCover', { percent: alert.enrichment.weather.cloud_cover })}</div>
                  )}
                  {alert.enrichment.weather.wind_speed && (
                    <div>{t('wind', { speed: alert.enrichment.weather.wind_speed, unit: alert.enrichment.weather.wind_unit || 'mph' })}</div>
                  )}
                </div>
              </div>
            </div>
          )}
          
          {/* Aircraft Tracking */}
          {(alert.enrichment.aircraft || alert.enrichment.nearby_aircraft) && (
            <div className="flex items-start gap-3 mb-4">
              <span className="text-text-tertiary mt-0.5">✈️</span>
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-2">
                  <span className="text-text-tertiary text-sm font-medium">{t('aircraftTrackingTitle')}</span>
                </div>
                <div className="text-text-primary text-sm">
                  {alert.enrichment.nearby_aircraft ? (
                    <div>{alert.enrichment.nearby_aircraft.length} {t('nearbyAircraft')}</div>
                  ) : (
                    <div>{t('noAircraft')}</div>
                  )}
                </div>
              </div>
            </div>
          )}
          
          {/* Satellite Passes */}
          {alert.enrichment.satellite_passes && (
            <div className="flex items-start gap-3 mb-4">
              <span className="text-text-tertiary mt-0.5">🛰️</span>
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-2">
                  <span className="text-text-tertiary text-sm font-medium">{t('satellitePassesTitle')}</span>
                </div>
                <div className="text-text-primary text-sm">
                  {alert.enrichment.satellite_passes.length > 0 ? (
                    <div>
                      <div>{alert.enrichment.satellite_passes.length} visible passes during timeframe</div>
                      <div className="text-xs mt-1 text-text-tertiary">{t('satellitePassExplanation')}</div>
                    </div>
                  ) : (
                    <div>{t('noSatellitePasses')}</div>
                  )}
                </div>
              </div>
            </div>
          )}
        </>
      )}

      {/* UFOBeep-specific metadata (witnesses, confirmations, alert level) */}
      {isUfoBeepReport && (alert.witness_count !== undefined || alert.total_confirmations !== undefined || alert.alert_level) && (
        <div className="mt-4 pt-4 border-t border-dark-border">
          <div className="flex items-center gap-4 text-sm text-text-tertiary">
            {alert.alert_level && (
              <span>🔍 {t('alertLevel')}: {alert.alert_level}</span>
            )}
            {alert.witness_count !== undefined && (
              <span>👥 {t('witnesses')}: {alert.witness_count || 0}</span>
            )}
            {alert.total_confirmations !== undefined && (
              <span>✅ {t('confirmations')}: {alert.total_confirmations || 0}</span>
            )}
          </div>
        </div>
      )}

      {/* Share link at bottom */}
      <div className="mt-6 pt-4 border-t border-dark-border">
        <div className="flex items-center gap-3">
          <span className="text-text-tertiary">🔗</span>
          <div className="flex-1">
            <div className="flex items-center gap-2">
              <span className="text-text-tertiary text-sm font-medium">{t('shareLink')}:</span>
              <code className="text-brand-primary text-sm bg-dark-surface border border-dark-border px-2 py-1 rounded">
                ufobeep.com{getShortAlertUrl(alert, locale)}
              </code>
              <button
                onClick={() => {
                  if (typeof navigator !== 'undefined' && 'share' in navigator) {
                    navigator.share({
                      title: alert.title || t('ufoSightingAlt'),
                      url: `https://ufobeep.com${getShortAlertUrl(alert, locale)}`
                    })
                  } else if (typeof navigator !== 'undefined' && 'clipboard' in navigator) {
                    (navigator as any).clipboard.writeText(`https://ufobeep.com${getShortAlertUrl(alert, locale)}`)
                  }
                }}
                className="text-text-secondary hover:text-brand-primary transition-colors p-1"
                title={typeof navigator !== 'undefined' && 'share' in navigator ? t('share') : t('copyShortLinkTitle')}
              >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.367 2.684 3 3 0 00-5.367-2.684z" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>

    </div>
  )
}