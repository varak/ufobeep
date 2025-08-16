'use client'

import Link from 'next/link'
import ImageWithLoading from './ImageWithLoading'

interface Alert {
  id: string
  title: string
  description: string
  category: string
  created_at: string
  location: {
    latitude: number
    longitude: number
    name: string
  }
  alert_level: string
  media_files: Array<{
    id: string
    type: string
    url: string
    thumbnail_url: string
    is_primary: boolean
    upload_order: number
    display_priority: number
  }>
  verification_score: number
  witness_count: number
  total_confirmations: number
}

interface AlertCardProps {
  alert: Alert
  compact?: boolean
}

export default function AlertCard({ alert, compact = false }: AlertCardProps) {
  // Get primary media file (or first if no primary)
  const getPrimaryMedia = () => {
    if (!alert.media_files || alert.media_files.length === 0) return null
    
    // Look for primary media
    const primaryMedia = alert.media_files.find(media => media.is_primary)
    if (primaryMedia) return primaryMedia
    
    // Fallback to first media file
    return alert.media_files[0]
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    if (compact) {
      const now = new Date()
      const diffInHours = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60))
      
      if (diffInHours < 1) return 'Just now'
      if (diffInHours < 24) return `${diffInHours}h ago`
      if (diffInHours < 48) return '1 day ago'
      return `${Math.floor(diffInHours / 24)} days ago`
    }
    
    return date.toLocaleString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  const formatLocation = (location: Alert['location']) => {
    return location.name || `${location.latitude.toFixed(4)}, ${location.longitude.toFixed(4)}`
  }

  const getAlertLevelColor = (level: string) => {
    switch (level?.toLowerCase()) {
      case 'critical': return 'text-red-400'
      case 'high': return 'text-orange-400'
      case 'medium': return 'text-yellow-400'
      case 'low': return 'text-green-400'
      default: return 'text-gray-400'
    }
  }

  const getWitnessCount = () => {
    // Use total_confirmations if available, otherwise fall back to witness_count
    return alert.total_confirmations || alert.witness_count || 1
  }

  const getWitnessEscalationLevel = (count: number) => {
    if (count >= 10) return { level: 'emergency', color: 'text-red-400 bg-red-900/20 border-red-400/30', icon: '🚨' }
    if (count >= 3) return { level: 'urgent', color: 'text-orange-400 bg-orange-900/20 border-orange-400/30', icon: '⚠️' }
    return { level: 'normal', color: 'text-brand-primary bg-brand-primary/10 border-brand-primary/30', icon: '👁️' }
  }

  if (compact) {
    return (
      <Link href={`/alerts/${alert.id}`}>
        <div className="p-4 bg-dark-surface rounded-lg border border-dark-border hover:border-brand-primary transition-colors cursor-pointer group">
          <div className="flex items-start justify-between">
            <div className="flex-1">
              <div className="flex items-center gap-2 mb-1">
                <span className={`px-2 py-1 rounded text-xs font-semibold uppercase ${getAlertLevelColor(alert.alert_level)}`}>
                  {alert.alert_level}
                </span>
                {(() => {
                  const witnessCount = getWitnessCount()
                  const escalation = getWitnessEscalationLevel(witnessCount)
                  return (
                    <span className={`px-2 py-1 rounded text-xs font-semibold border ${escalation.color}`}>
                      {escalation.icon} {witnessCount}
                    </span>
                  )
                })()}
                {alert.media_files && alert.media_files.length > 0 && (
                  <span className="text-xs text-text-tertiary">📸</span>
                )}
              </div>
              <h4 className="font-medium text-text-primary text-sm group-hover:text-brand-primary transition-colors line-clamp-1">
                {alert.title}
              </h4>
              <p className="text-text-secondary text-xs mt-1 line-clamp-1">
                {formatLocation(alert.location)}
              </p>
              <div className="flex items-center gap-2 mt-2">
                <span className="text-brand-primary text-xs">⚡ Live Chat Active</span>
                <span className="text-text-tertiary text-xs">•</span>
                <span className="text-text-tertiary text-xs">{formatDate(alert.created_at)}</span>
              </div>
            </div>
            <div className="w-2 h-2 bg-brand-primary rounded-full animate-pulse"></div>
          </div>
        </div>
      </Link>
    )
  }

  return (
    <Link href={`/alerts/${alert.id}`}>
      <div className="bg-dark-surface border border-dark-border rounded-lg overflow-hidden hover:border-brand-primary transition-all duration-300 hover:shadow-lg cursor-pointer group">
        {/* Primary Media Thumbnail */}
        {(() => {
          const primaryMedia = getPrimaryMedia()
          return primaryMedia ? (
            <div className="h-48 bg-gray-800 relative overflow-hidden">
              <ImageWithLoading 
                src={`${primaryMedia.thumbnail_url || primaryMedia.url}?thumbnail=true`}
                alt={alert.title}
                width={400}
                height={192}
                className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
              />
              <div className="absolute top-2 right-2 bg-black bg-opacity-50 text-white text-xs px-2 py-1 rounded">
                📸 {alert.media_files.length}
              </div>
              {primaryMedia.is_primary && (
                <div className="absolute bottom-2 left-2 bg-brand-primary text-black text-xs px-2 py-1 rounded font-semibold">
                  PRIMARY
                </div>
              )}
            </div>
          ) : (
            <div className="h-48 bg-gray-800 flex items-center justify-center">
              <div className="text-4xl text-gray-500">👁️</div>
            </div>
          )
        })()}

        <div className="p-4">
          {/* Alert Level Badge and Witness Count */}
          <div className="flex justify-between items-start mb-3">
            <div className="flex items-center gap-2">
              <span className={`px-2 py-1 rounded text-xs font-semibold uppercase ${getAlertLevelColor(alert.alert_level)}`}>
                {alert.alert_level}
              </span>
              {(() => {
                const witnessCount = getWitnessCount()
                const escalation = getWitnessEscalationLevel(witnessCount)
                return (
                  <span className={`px-3 py-1 rounded-full text-sm font-semibold border ${escalation.color}`}>
                    {escalation.icon} {witnessCount} witness{witnessCount !== 1 ? 'es' : ''}
                  </span>
                )
              })()}
            </div>
          </div>

          {/* Title & Description */}
          <h3 className="text-lg font-semibold text-text-primary mb-2 group-hover:text-brand-primary transition-colors line-clamp-1">
            {alert.title}
          </h3>
          <p className="text-text-secondary text-sm mb-4 line-clamp-2">
            {alert.description}
          </p>

          {/* Metadata */}
          <div className="space-y-2 text-xs text-text-tertiary">
            <div className="flex items-center gap-2">
              <span>📅</span>
              <span>{formatDate(alert.created_at)}</span>
            </div>
            <div className="flex items-center gap-2">
              <span>📍</span>
              <span>{formatLocation(alert.location)}</span>
            </div>
          </div>

          {/* Click indicator */}
          <div className="mt-4 pt-3 border-t border-dark-border text-center">
            <span className="text-brand-primary text-sm group-hover:underline">
              View Details →
            </span>
          </div>
        </div>
      </div>
    </Link>
  )
}