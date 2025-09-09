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
  reporter_username?: string
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
  distance_km?: number
}

interface AlertDetailsProps {
  alert: Alert
  locale?: string
}

export default function AlertDetails({ alert, locale = 'en' }: AlertDetailsProps) {
  const { t } = useClientTranslations('beep-detail', locale)
  
  // Check if this is a UFOBeep report (not MUFON/NUFORC)
  const isUfoBeepReport = !alert.reporter_username || 
    (alert.reporter_username !== 'MUFON' && alert.reporter_username !== 'NUFORC')
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  const getCleanDescription = () => {
    if (!alert.description) return ''
    
    // For MUFON alerts, remove the duplicate metadata section
    if (alert.reporter_username === 'MUFON') {
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
          <h2 className="text-lg font-semibold text-brand-primary">Details</h2>
        </div>
      )}

      {/* Description - Main description now contains full text */}
      {alert.description && (
        <div className="mb-6">
          {/* MUFON attribution with case number */}
          {alert.reporter_username === 'MUFON' && (
            <div className="mb-4 p-3 bg-blue-500/10 border border-blue-500/20 rounded-lg">
              <div className="flex items-center gap-2">
                <span className="text-blue-400">🛸</span>
                <span className="text-blue-300 font-medium">MUFON Database Report</span>
                {alert.enrichment?.mufon_case_id && (
                  <span className="text-text-tertiary text-sm">
                    Case #{alert.enrichment.mufon_case_id}
                  </span>
                )}
              </div>
            </div>
          )}
          <div 
            className="text-text-secondary leading-relaxed prose prose-invert max-w-none"
            dangerouslySetInnerHTML={{ 
              __html: getCleanDescription().replace(/\n/g, '<br>') 
            }}
          />
        </div>
      )}

      {/* Time - Show MUFON times if available, otherwise show UFOBeep time */}
      {alert.enrichment?.sighting_datetime || alert.enrichment?.report_date ? (
        <div className="flex items-start gap-3 mb-4">
          <span className="text-text-tertiary mt-0.5">📅</span>
          <div className="flex-1">
            {/* Sighting Time */}
            {alert.enrichment.sighting_datetime && (
              <div className="mb-2">
                <div className="flex items-center gap-2">
                  <span className="text-text-tertiary text-sm font-medium">Event Time:</span>
                  <span className="text-text-primary text-sm">{alert.enrichment.sighting_datetime}</span>
                </div>
              </div>
            )}
            {/* Report Time */}
            {alert.enrichment.report_date && (
              <div>
                <div className="flex items-center gap-2">
                  <span className="text-text-tertiary text-sm font-medium">Reported:</span>
                  <span className="text-text-secondary text-sm">{alert.enrichment.report_date}</span>
                </div>
              </div>
            )}
          </div>
        </div>
      ) : (
        <div className="flex items-start gap-3 mb-4">
          <span className="text-text-tertiary mt-0.5">⏰</span>
          <div className="flex-1">
            <div className="flex items-center gap-2">
              <span className="text-text-tertiary text-sm font-medium">Time:</span>
              <span className="text-text-primary text-sm">{formatFullDate(alert.created_at)}</span>
            </div>
            <div className="text-text-secondary text-xs mt-1">
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
            <span className="text-text-tertiary text-sm font-medium">{t('location')}:</span>
            <span className="text-text-primary text-sm">
              {(() => {
                // Clean up location name to avoid duplication
                let locationName = alert.reporter_username === 'MUFON' 
                  ? (alert.enrichment?.location_raw || alert.location?.name || 'Unknown Location')
                  : (alert.location?.name || 'Unknown Location')
                
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
                  {UnitConversion.formatDistanceFromKm(
                    alert.distance_km,
                    UnitConversion.getAutoUnits()
                  )}
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
              <span>🔍 {t('ufobeep.alertLevel')}: {alert.alert_level}</span>
            )}
            {alert.witness_count !== undefined && (
              <span>👥 {t('ufobeep.witnesses')}: {alert.witness_count || 0}</span>
            )}
            {alert.total_confirmations !== undefined && (
              <span>✅ {t('ufobeep.confirmations')}: {alert.total_confirmations || 0}</span>
            )}
          </div>
        </div>
      )}

      {/* Share link for all alerts */}
      <div className="mt-4 pt-4 border-t border-dark-border">
        <div className="flex items-center gap-3">
          <span className="text-text-tertiary">🔗</span>
          <div className="flex-1">
            <div className="flex items-center gap-2">
              <span className="text-text-tertiary text-sm font-medium">Share Link:</span>
              <code className="text-brand-primary text-sm bg-dark-bg px-2 py-1 rounded">
                ufobeep.com{getShortAlertUrl(alert.id)}
              </code>
              <button
                onClick={() => {
                  navigator.clipboard.writeText(`https://ufobeep.com${getShortAlertUrl(alert.id)}`)
                  // TODO: Show toast notification
                }}
                className="text-text-secondary hover:text-brand-primary transition-colors p-1"
                title="Copy short link"
              >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 16H6a2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}