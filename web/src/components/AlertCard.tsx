'use client'

import Link from 'next/link'
import { useState } from 'react'
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
  const [showShareMenu, setShowShareMenu] = useState(false)

  // Get primary media file (or first if no primary)
  const getPrimaryMedia = () => {
    if (!alert.media_files || alert.media_files.length === 0) return null
    
    // Look for primary media
    const primaryMedia = alert.media_files.find(media => media.is_primary)
    if (primaryMedia) return primaryMedia
    
    // Fallback to first media file
    return alert.media_files[0]
  }

  // Share functionality
  const handleShare = (e: React.MouseEvent, type: 'native' | 'copy' | 'social') => {
    e.preventDefault()
    e.stopPropagation()
    
    const alertUrl = `${window.location.origin}/alerts/${alert.id}`
    const shareText = `UFO Sighting Alert: ${alert.description || 'Anomaly reported'} - ${formatLocation(alert.location)}`
    
    switch (type) {
      case 'native':
        if (typeof window !== 'undefined' && 'share' in navigator) {
          navigator.share({
            title: 'UFO Sighting Alert',
            text: shareText,
            url: alertUrl
          }).catch(console.error)
        }
        break
        
      case 'copy':
        navigator.clipboard.writeText(`${shareText} - ${alertUrl}`).then(() => {
          // Could add toast notification here
        }).catch(console.error)
        break
        
      case 'social':
        const twitterUrl = `https://twitter.com/intent/tweet?text=${encodeURIComponent(shareText)}&url=${encodeURIComponent(alertUrl)}`
        window.open(twitterUrl, '_blank')
        break
    }
    
    setShowShareMenu(false)
  }

  const shareMedia = (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    
    const primaryMedia = getPrimaryMedia()
    if (!primaryMedia) return
    
    const mediaUrl = `${window.location.origin}${primaryMedia.url}`
    const shareText = `Check out this UFO sighting photo/video from UFOBeep`
    
    if (typeof window !== 'undefined' && 'share' in navigator) {
      // For mobile devices that support native sharing
      fetch(mediaUrl)
        .then(res => res.blob())
        .then(blob => {
          const file = new File([blob], `ufo-sighting-${alert.id}.${primaryMedia.type === 'video' ? 'mp4' : 'jpg'}`, { 
            type: primaryMedia.type === 'video' ? 'video/mp4' : 'image/jpeg' 
          })
          return navigator.share({
            title: 'UFO Sighting Media',
            text: shareText,
            files: [file]
          })
        })
        .catch(() => {
          // Fallback to URL sharing if file sharing fails
          navigator.share({
            title: 'UFO Sighting Media',
            text: shareText,
            url: mediaUrl
          })
        })
    } else {
      // Fallback for desktop - copy media URL
      navigator.clipboard.writeText(mediaUrl).catch(console.error)
    }
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
    <div className="bg-dark-surface border border-dark-border rounded-lg hover:border-brand-primary transition-all duration-300 hover:shadow-lg group relative">
      <Link href={`/alerts/${alert.id}`} className="block">
        <div className="flex items-center gap-4 p-4">
          {/* Thumbnail or icon */}
          {(() => {
            const primaryMedia = getPrimaryMedia()
            return primaryMedia ? (
              <div className="w-16 h-16 bg-gray-800 rounded-lg overflow-hidden flex-shrink-0 relative">
                <ImageWithLoading 
                  src={`${primaryMedia.thumbnail_url || primaryMedia.url}?thumbnail=true`}
                  alt={alert.title}
                  width={64}
                  height={64}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                />
                {/* Video indicator */}
                {primaryMedia.type === 'video' && (
                  <div className="absolute inset-0 flex items-center justify-center">
                    <div className="bg-black/70 rounded-full p-1">
                      <svg className="w-4 h-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                        <path d="M6.3 4.1c0-.8.9-1.3 1.5-.9l8.4 4.9c.6.4.6 1.4 0 1.8L7.8 14.8c-.6.4-1.5-.1-1.5-.9V4.1z"/>
                      </svg>
                    </div>
                  </div>
                )}
              </div>
            ) : (
              <div className="w-16 h-16 bg-dark-background rounded-lg flex items-center justify-center flex-shrink-0">
                <span className="text-text-tertiary text-xl">👁️</span>
              </div>
            )
          })()}

          {/* Content */}
          <div className="flex-1 min-w-0">
            <div className="flex items-center justify-between mb-1">
              <div className="text-xs text-text-tertiary">
                {formatDate(alert.created_at)}
              </div>
              <div className="text-xs text-text-tertiary">
                {(() => {
                  const media = getPrimaryMedia()
                  if (!media) return 'Witness beeped only'
                  return media.type === 'video' ? '🎥 Video' : '📸 Photo'
                })()}
              </div>
            </div>
            
            <div className="text-xs text-text-tertiary mb-2">
              📍 {formatLocation(alert.location)}
            </div>

            {alert.description && (
              <p className="text-text-secondary text-sm line-clamp-1">
                {alert.description}
              </p>
            )}
          </div>
        </div>
      </Link>

      {/* Share button */}
      <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
        <div className="relative">
          <button
            onClick={(e) => {
              e.preventDefault()
              e.stopPropagation()
              setShowShareMenu(!showShareMenu)
            }}
            className="p-2 bg-dark-background/80 hover:bg-brand-primary/20 rounded-full border border-dark-border hover:border-brand-primary transition-all"
            title="Share alert"
          >
            <svg className="w-4 h-4 text-text-secondary hover:text-brand-primary transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.367 2.684 3 3 0 00-5.367-2.684z" />
            </svg>
          </button>

          {/* Share menu */}
          {showShareMenu && (
            <div className="absolute top-full right-0 mt-2 bg-dark-surface border border-dark-border rounded-lg shadow-xl z-10 min-w-48">
              <div className="p-2">
                <button
                  onClick={(e) => handleShare(e, 'copy')}
                  className="w-full text-left px-3 py-2 text-sm text-text-secondary hover:text-text-primary hover:bg-dark-background rounded flex items-center gap-2"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                  </svg>
                  Copy alert link
                </button>
                
                {getPrimaryMedia() && (
                  <button
                    onClick={shareMedia}
                    className="w-full text-left px-3 py-2 text-sm text-text-secondary hover:text-text-primary hover:bg-dark-background rounded flex items-center gap-2"
                  >
                    {getPrimaryMedia()?.type === 'video' ? (
                      <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
                      </svg>
                    ) : (
                      <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                      </svg>
                    )}
                    Share {getPrimaryMedia()?.type === 'video' ? 'video' : 'photo'}
                  </button>
                )}
                
                <button
                  onClick={(e) => handleShare(e, 'social')}
                  className="w-full text-left px-3 py-2 text-sm text-text-secondary hover:text-text-primary hover:bg-dark-background rounded flex items-center gap-2"
                >
                  <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.827 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z"/>
                  </svg>
                  Share on Twitter
                </button>

                {typeof window !== 'undefined' && 'share' in navigator && (
                  <button
                    onClick={(e) => handleShare(e, 'native')}
                    className="w-full text-left px-3 py-2 text-sm text-text-secondary hover:text-text-primary hover:bg-dark-background rounded flex items-center gap-2"
                  >
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
                    </svg>
                    Share via apps
                  </button>
                )}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}