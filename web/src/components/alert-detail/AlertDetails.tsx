'use client'

import { useState } from 'react'
import { getShortAlertUrl } from '@/utils/slug'
import { formatDistance, getUnitPreference } from '@/utils/units'
import { UnitConversion } from '@/utils/unitConversion'
import { useClientTranslations } from '@/hooks/useClientTranslations'
import { getPlatformsForLocale, generateShareUrl } from '@/utils/regional-platforms'

interface Alert {
  id: string
  title: string
  description: string
  created_at: string
  occurred_at?: string
  username?: string
  reporter_username?: string
  source?: string
  external_id?: string
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
  const [showShareMenu, setShowShareMenu] = useState(false)

  // Get available platforms for current locale
  const availablePlatforms = getPlatformsForLocale(locale)

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

  const formatDateOnly = (dateString: string) => {
    // Always return just the date, never include time (for MUFON import dates)
    const date = new Date(dateString)
    return date.toISOString().split('T')[0]
  }

  const getCleanDescription = () => {
    if (!alert.description) return ''
    
    // For MUFON alerts, remove the duplicate metadata section
    if (alert.source === 'mufon' || alert.username === 'MUFON') {
      return alert.description.split('━━━━━━━━━━━━━━━━━━━━━━━━')[0].trim()
    }
    
    return alert.description
  }

  // Individual platform sharing functions
  const shareToPlatform = (platformKey: string) => {
    const alertUrl = `${window.location.origin}${getShortAlertUrl(alert, locale)}`
    const shareText = `${t('ufoSightingAlert')}: ${alert.description || t('anomalyReported')} - ${alert.location?.name || t('unknownLocation')}`

    const platform = availablePlatforms.find(p => p.key === platformKey)
    if (platform) {
      const url = generateShareUrl(platform, shareText, alertUrl)
      window.open(url, '_blank')
      setShowShareMenu(false)
    }
  }

  const formatFullDate = (dateString: string) => {
    const date = new Date(dateString)
    const now = new Date()
    const diff = now.getTime() - date.getTime()
    const minutes = Math.floor(diff / (1000 * 60))

    // T+ format - universal aerospace/military time elapsed notation
    if (minutes < 60) {
      return `T+${minutes}m`
    }
    const hours = Math.floor(minutes / 60)
    if (hours < 24) {
      const remainingMinutes = minutes % 60
      return `T+${hours}h${remainingMinutes}m`
    }
    const days = Math.floor(hours / 24)
    const remainingHours = hours % 24
    return `T+${days}d${remainingHours}h`
  }

  return (
    <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
      {/* Hide Details header for MUFON/NUFORC (historical data) */}
      {alert.username !== 'MUFON' && alert.source !== 'nuforc' && (
        <div className="flex items-center gap-2 mb-4">
          <span className="text-brand-primary">ℹ️</span>
          <h2 className="text-lg font-semibold text-brand-primary">{t('detailsTitle')}</h2>
        </div>
      )}

      {/* Reporter section - hide for MUFON/NUFORC (already shown in attribution badges) */}
      {alert.source !== 'mufon' && alert.source !== 'nuforc' && (
        <div className="flex items-start gap-3 mb-4">
          <span className="text-text-tertiary mt-0.5">👤</span>
          <div className="flex-1">
            <div className="flex items-center gap-2">
              <span className="text-text-tertiary text-sm font-medium">Reported by:</span>
              <span className="text-text-primary text-sm">
                {alert.username || alert.reporter_username}
              </span>
            </div>
          </div>
        </div>
      )}



      {/* Description - Main description now contains full text */}
      {alert.description && (
        <div className="mb-6">
          {/* MUFON attribution with case number */}
          {alert.source === 'mufon' && (
            <div className="mb-4 p-3 bg-blue-500/10 border border-blue-500/20 rounded-lg">
              <div className="flex items-center gap-2">
                <span className="text-blue-400">🛸</span>
                <span className="text-blue-300 font-medium">
                  {(() => {
                    const caseNumber = alert.enrichment_data?.mufon_case_number
                    return caseNumber
                      ? t('mufonCaseTitle', { caseNumber })
                      : t('mufonDatabaseReport')
                  })()}
                </span>
              </div>
            </div>
          )}

          {/* NUFORC attribution with report ID - just the badge */}
          {alert.source === 'nuforc' && (
            <div className="mb-4 p-3 bg-green-500/10 border border-green-500/20 rounded-lg">
              <div className="flex items-center gap-2">
                <span className="text-green-400">🛸</span>
                <span className="text-green-300 font-medium">
                  {alert.enrichment_data?.nuforc_report_id
                    ? `NUFORC Report #${alert.enrichment_data.nuforc_report_id}`
                    : 'NUFORC Database Report'}
                </span>
              </div>
            </div>
          )}
          <div className="text-text-primary leading-relaxed max-w-none space-y-4">
            {getCleanDescription().split(/\n\n+/).map((paragraph, index) => {
              // For NUFORC/MUFON, render markdown bold syntax and preserve line breaks
              if (alert.source === 'nuforc' || alert.source === 'mufon') {
                // Convert **text** to <b>text</b> and normalize line breaks
                const formatted = paragraph
                  .replace(/\r\n/g, '\n')  // Normalize Windows line breaks
                  .replace(/\r/g, '\n')    // Normalize old Mac line breaks
                  .split(/\*\*(.+?)\*\*/g)  // Split on **bold** markers

                return (
                  <p key={index} className="mb-4 whitespace-pre-wrap">
                    {formatted.map((part, i) =>
                      i % 2 === 1 ? <b key={i} className="font-semibold">{part}</b> : part
                    )}
                  </p>
                )
              }

              // For UFOBeep reports, remove line breaks
              return (
                <p key={index} className="mb-4">
                  {paragraph.replace(/\n/g, ' ')}
                </p>
              )
            })}
          </div>
        </div>
      )}

      {/* NUFORC Observation Details - shown after description */}
      {alert.source === 'nuforc' && alert.enrichment_data && (
        <div className="mb-6 p-4 bg-dark-surface border border-dark-border rounded-lg">
          <div className="text-brand-primary font-semibold mb-3">🔭 Observation Details</div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-sm">
            {alert.enrichment_data.color && (
              <div>
                <span className="text-text-tertiary">Color:</span>{' '}
                <span className="text-text-primary">{alert.enrichment_data.color}</span>
              </div>
            )}
            {alert.enrichment_data.estimated_size && (
              <div>
                <span className="text-text-tertiary">Size:</span>{' '}
                <span className="text-text-primary">{alert.enrichment_data.estimated_size}</span>
              </div>
            )}
            {alert.enrichment_data.estimated_speed && (
              <div>
                <span className="text-text-tertiary">Speed:</span>{' '}
                <span className="text-text-primary">{alert.enrichment_data.estimated_speed}</span>
              </div>
            )}
            {alert.enrichment_data.direction_from_viewer && (
              <div>
                <span className="text-text-tertiary">Direction:</span>{' '}
                <span className="text-text-primary">{alert.enrichment_data.direction_from_viewer}</span>
              </div>
            )}
            {alert.enrichment_data.angle_of_elevation !== undefined && alert.enrichment_data.angle_of_elevation !== null && (
              <div>
                <span className="text-text-tertiary">Elevation:</span>{' '}
                <span className="text-text-primary">{alert.enrichment_data.angle_of_elevation}°</span>
              </div>
            )}
            {alert.enrichment_data.closest_distance && (
              <div>
                <span className="text-text-tertiary">Distance:</span>{' '}
                <span className="text-text-primary">{alert.enrichment_data.closest_distance}</span>
              </div>
            )}
            {alert.enrichment_data.duration && (
              <div>
                <span className="text-text-tertiary">Duration:</span>{' '}
                <span className="text-text-primary">{alert.enrichment_data.duration}</span>
              </div>
            )}
            {alert.enrichment_data.no_of_observers && (
              <div>
                <span className="text-text-tertiary">Observers:</span>{' '}
                <span className="text-text-primary">{alert.enrichment_data.no_of_observers}</span>
              </div>
            )}
            {alert.enrichment_data.viewed_from && (
              <div>
                <span className="text-text-tertiary">Viewed From:</span>{' '}
                <span className="text-text-primary">{alert.enrichment_data.viewed_from}</span>
              </div>
            )}
            {alert.enrichment_data.characteristics && (
              <div className="md:col-span-2">
                <span className="text-text-tertiary">Characteristics:</span>{' '}
                <span className="text-text-primary">{alert.enrichment_data.characteristics}</span>
              </div>
            )}
          </div>

          {/* Muse.ai embedded videos */}
          {alert.enrichment_data.muse_ai_videos && alert.enrichment_data.muse_ai_videos.length > 0 && (
            <div className="mt-4">
              <div className="text-brand-primary font-semibold mb-2">📹 Video Evidence</div>
              {alert.enrichment_data.muse_ai_videos.map((videoUrl: string, idx: number) => {
                // Extract video ID from URL (https://muse.ai/v/kamzZm8)
                const videoId = videoUrl.split('/').pop()
                return (
                  <div key={idx} className="mb-4">
                    <iframe
                      src={`https://muse.ai/embed/${videoId}`}
                      width="100%"
                      height="360"
                      style={{ border: 'none', borderRadius: '8px' }}
                      allowFullScreen
                      title={`NUFORC Video ${idx + 1}`}
                    />
                  </div>
                )
              })}
            </div>
          )}

          {/* Link to original NUFORC report */}
          {alert.enrichment_data.external_url && (
            <a
              href={alert.enrichment_data.external_url}
              target="_blank"
              rel="noopener noreferrer"
              className="mt-4 inline-flex items-center gap-2 px-4 py-2 bg-brand-primary/10 hover:bg-brand-primary/20 border border-brand-primary/30 rounded-lg text-brand-primary transition-colors"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
              </svg>
              View Original NUFORC Report
            </a>
          )}
        </div>
      )}

      {/* Time - Show MUFON times if available, otherwise show UFOBeep time */}
      {(alert.source === 'mufon' || alert.username === 'MUFON') ? (
        <div className="flex items-start gap-3 mb-4">
          <span className="text-text-tertiary mt-0.5">📅</span>
          <div className="flex-1">
            {/* Event Time (when sighting occurred) - for MUFON reports */}
            {alert.enrichment_data?.sighting_datetime && (
              <div className="mb-2">
                <div className="flex items-center gap-2">
                  <span className="text-text-tertiary text-sm font-medium">{t('eventTime')}:</span>
                  <span className="text-text-primary text-sm">{parseMufonDate(alert.enrichment_data.sighting_datetime)}</span>
                </div>
              </div>
            )}
            {/* Report Time (when added to MUFON database) */}
            {alert.enrichment_data?.report_date && (
              <div className="mb-2">
                <div className="flex items-center gap-2">
                  <span className="text-text-tertiary text-sm font-medium">{t('reportedTime')}:</span>
                  <span className="text-text-primary text-sm">{alert.enrichment_data.report_date}</span>
                </div>
              </div>
            )}
            {/* UFOBeep Import Time */}
            <div>
              <div className="flex items-center gap-2">
                <span className="text-text-tertiary text-sm font-medium">{t('addedToUfobeep')}:</span>
                <span className="text-text-primary text-sm">{formatDateOnly(alert.created_at)}</span>
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
              <span className="text-text-primary text-sm">{formatDate(alert.created_at)}</span>
            </div>
            <div className="text-text-tertiary text-xs mt-1">
              {formatFullDate(alert.created_at)}
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
                // Clean up location name using comprehensive enrichment data
                let locationName = alert.enrichment?.geocoding?.formatted_address ||
                                 alert.enrichment?.geocoding?.display_name ||
                                 alert.enrichment?.geocoding?.location_name ||
                                 alert.enrichment?.geocoding?.location ||
                                 alert.enrichment?.location_raw ||
                                 alert.location?.name ||
                                 'Unknown Location'

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
              <div className="relative">
                <button
                  onClick={() => setShowShareMenu(!showShareMenu)}
                  className="text-text-secondary hover:text-brand-primary transition-colors p-1"
                  title="Share to social media"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.367 2.684 3 3 0 00-5.367-2.684z" />
                  </svg>
                </button>

                {/* Share menu */}
                {showShareMenu && (
                  <div className="absolute bottom-full right-0 mb-2 bg-dark-surface border border-dark-border rounded-lg shadow-xl z-10 min-w-48">
                    <div className="p-2">
                      <button
                        onClick={() => {
                          navigator.clipboard.writeText(`https://ufobeep.com${getShortAlertUrl(alert, locale)}`)
                          setShowShareMenu(false)
                        }}
                        className="w-full text-left px-3 py-2 text-sm text-text-secondary hover:text-text-primary hover:bg-dark-background rounded flex items-center gap-2"
                      >
                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                        </svg>
                        {t('copyShortLink')}
                      </button>

                      <div className="border-t border-dark-border my-1"></div>

                      {availablePlatforms.map(platform => (
                        <button
                          key={platform.key}
                          onClick={() => shareToPlatform(platform.key)}
                          className="w-full text-left px-3 py-2 text-sm text-text-secondary hover:text-text-primary hover:bg-dark-background rounded flex items-center gap-2"
                        >
                          <span>{platform.icon}</span>
                          {platform.name}
                        </button>
                      ))}

                      {typeof window !== 'undefined' && 'share' in navigator && (
                        <button
                          onClick={() => {
                            navigator.share({
                              title: alert.title || t('ufoSightingAlt'),
                              url: `https://ufobeep.com${getShortAlertUrl(alert, locale)}`
                            })
                            setShowShareMenu(false)
                          }}
                          className="w-full text-left px-3 py-2 text-sm text-text-secondary hover:text-text-primary hover:bg-dark-background rounded flex items-center gap-2"
                        >
                          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
                          </svg>
                          {t('shareAlert')}
                        </button>
                      )}
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>

    </div>
  )
}