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


  if (compact) {
    return (
      <Link href={`/alerts/${alert.id}`}>
        <div className="p-4 bg-dark-surface rounded-lg border border-dark-border hover:border-brand-primary transition-colors cursor-pointer group">
          <div className="flex items-start justify-between">
            <div className="flex-1">
              <div className="flex items-center justify-between mb-1">
                <span className="text-text-tertiary text-xs">{formatDate(alert.created_at)}</span>
                {alert.media_files && alert.media_files.length > 0 ? (
                  <span className="text-xs text-text-tertiary">📸</span>
                ) : (
                  <span className="text-xs text-text-tertiary">👁️</span>
                )}
              </div>
              <p className="text-text-secondary text-xs line-clamp-1">
                📍 {formatLocation(alert.location)}
              </p>
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
        {/* Primary Media Thumbnail - Only show if media exists */}
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
          ) : null
        })()}

        <div className="p-4">
          <div className="flex items-center justify-between mb-2">
            <div className="text-xs text-text-tertiary">
              {formatDate(alert.created_at)}
            </div>
            <div className="flex items-center gap-2 text-xs text-text-tertiary">
              {getPrimaryMedia() ? (
                <span>📸 Photo</span>
              ) : (
                <span>👁️ Witness beeped only</span>
              )}
            </div>
          </div>
          
          <div className="text-xs text-text-tertiary mb-3">
            📍 {formatLocation(alert.location)}
          </div>

          {alert.description && (
            <p className="text-text-secondary text-sm line-clamp-2">
              {alert.description}
            </p>
          )}
        </div>
      </div>
    </Link>
  )
}