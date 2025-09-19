'use client'

import Link from 'next/link'
import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { useClientTranslations } from '../hooks/useClientTranslations'
import ImageWithLoading from './ImageWithLoading'
import MediaGalleryModal from './MediaGalleryModal'
import { AlertTitleUtils } from '@/utils/alert-title-utils'
import { convertToProxyUrl, convertMediaFilesUrls } from '@/utils/media-url-utils'
import { getAlertSlug, getShortAlertUrl } from '@/utils/slug'
import { formatDistance, getUnitPreference } from '@/utils/units'
import { UnitConversion } from '@/utils/unitConversion'
import { getPlatformsForLocale, generateShareUrl } from '@/utils/regional-platforms'

interface Alert {
  id: string
  title: string | null
  description: string | null
  category: string
  created_at: string
  occurred_at?: string
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
    web_url?: string
    preview_url?: string
    is_primary: boolean
    upload_order: number
    display_priority: number
  }>
  verification_score: number
  witness_count: number
  total_confirmations: number
  reporter_username?: string | null
  source?: string | null
  external_url?: string | null
  is_verified?: boolean
  distance?: number
  distance_km?: number
  comment_count?: number
  short_url?: string
  enrichment?: {
    short_description?: string
    mufon_case_id?: string
    sighting_datetime?: string
    [key: string]: any
  }
}

interface AlertCardProps {
  alert: Alert
  compact?: boolean
  locale?: string
}

export default function AlertCard({ alert, compact = false, locale = 'en' }: AlertCardProps) {
  // Convert all media URLs to use main domain proxy for compatibility
  const alertWithFixedUrls = {
    ...alert,
    media_files: convertMediaFilesUrls(alert.media_files)
  }
  // Use the converted alert for all operations
  const alertData = alertWithFixedUrls
  
  const router = useRouter()
  
  // Use locale prop passed from parent component
  const { t } = useClientTranslations('common', locale)
  const [showShareMenu, setShowShareMenu] = useState(false)
  const [isMediaModalOpen, setIsMediaModalOpen] = useState(false)
  const [selectedMediaIndex, setSelectedMediaIndex] = useState(0)

  // Helper function to get detail URL with optional image parameter
  const getDetailUrl = (imageIndex?: number) => {
    const slug = getAlertSlug({
      id: alert.id,
      title: alert.title,
      created_at: alert.created_at,
      location: alert.location,
      reporter_username: alert.reporter_username,
      description: alert.description,
      source: alert.source,
      external_url: alert.external_url,
      short_url: alert.short_url
    }, locale, { slugs: t('slugs', { returnObjects: true }) }, alert.short_url)
    const baseUrl = `/beep/${locale}/${slug}`
    return imageIndex !== undefined ? `${baseUrl}?openImage=${imageIndex}` : baseUrl
  }

  // Smart description selection for preview cards
  const getPreviewDescription = () => {
    // MUFON alerts have short_description in enrichment
    if (alert.enrichment?.short_description) {
      return alert.enrichment.short_description
    }
    // For MUFON alerts, clean up the description by removing duplicate metadata
    if (alert.reporter_username === 'MUFON' && alert.description) {
      // Remove the appended metadata section (everything after the separator line)
      const cleanDescription = alert.description.split('━━━━━━━━━━━━━━━━━━━━━━━━')[0].trim()
      const truncated = cleanDescription.substring(0, 150)
      return truncated + (cleanDescription.length > 150 ? '...' : '')
    }
    // Regular alerts use truncated main description  
    if (alert.description) {
      const truncated = alert.description.substring(0, 150)
      return truncated + (alert.description.length > 150 ? '...' : '')
    }
    return null
  }

  // Calculate actual comment count - only use API count, don't add description
  const getActualCommentCount = () => {
    // Always use the exact API comment count - descriptions are not comments
    return alert.comment_count || 0
  }

  // Get primary media file (or first if no primary)
  const getPrimaryMedia = () => {
    if (!alert.media_files || alert.media_files.length === 0) return null
    
    // Look for primary media
    const primaryMedia = alert.media_files.find(media => media.is_primary)
    if (primaryMedia) return primaryMedia
    
    // Fallback to first media file
    return alert.media_files[0]
  }

  // Detect if media is video (with URL-based fallback)
  const isVideoMedia = (media: any) => {
    return media.type === 'video' || 
           media.url?.toLowerCase().includes('.mp4') ||
           media.url?.toLowerCase().includes('.mov')
  }

  // Share functionality
  const handleShare = (e: React.MouseEvent, type: 'native' | 'copy' | 'social') => {
    e.preventDefault()
    e.stopPropagation()
    
    const alertUrl = `${window.location.origin}${getShortAlertUrl(alert, locale)}`
    const shareText = `${t('ufoSightingAlert')}: ${alert.description || t('anomalyReported')} - ${formatLocation(alert.location)}`
    
    switch (type) {
      case 'native':
        if (typeof window !== 'undefined' && 'share' in navigator) {
          navigator.share({
            title: t('ufoSightingAlert'),
            text: shareText,
            url: alertUrl
          }).catch(console.error)
        }
        break
        
      case 'copy':
        navigator.clipboard.writeText(alertUrl).then(() => {
          // Could add toast notification here
        }).catch(console.error)
        break
        
      case 'social':
        // This now handled by individual platform buttons in menu
        break
    }
    
    setShowShareMenu(false)
  }

  // Get available platforms for current locale
  const availablePlatforms = getPlatformsForLocale(locale)

  // Individual platform sharing functions
  const shareToPlatform = (platformKey: string) => {
    const alertUrl = `${window.location.origin}${getShortAlertUrl(alert, locale)}`
    const shareText = `${t('ufoSightingAlert')}: ${alert.description || t('anomalyReported')} - ${formatLocation(alert.location)}`

    const platform = availablePlatforms.find(p => p.key === platformKey)
    if (platform) {
      const url = generateShareUrl(platform, shareText, alertUrl)
      window.open(url, '_blank')
      setShowShareMenu(false)
    }
  }

  const shareMedia = (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    
    const primaryMedia = getPrimaryMedia()
    if (!primaryMedia) return
    
    const mediaUrl = primaryMedia.url.startsWith('http') ? primaryMedia.url : `/api${primaryMedia.url}`
    const shareText = `Check out this UFO sighting photo/video from UFOBeep`
    
    if (typeof window !== 'undefined' && 'share' in navigator) {
      // For mobile devices that support native sharing
      fetch(mediaUrl)
        .then(res => res.blob())
        .then(blob => {
          const file = new File([blob], `ufo-sighting-${alert.id}.${isVideoMedia(primaryMedia) ? 'mp4' : 'jpg'}`, { 
            type: isVideoMedia(primaryMedia) ? 'video/mp4' : 'image/jpeg' 
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

  // Get the appropriate date to display (occurred_at for MUFON, created_at for others)
  const getDisplayDate = () => {
    if (alert.source === 'mufon' && alert.occurred_at) {
      return alert.occurred_at
    }
    return alert.created_at
  }

  const formatDate = (dateString: string) => {
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

  const formatElapsed = (dateString: string) => {
    const date = new Date(dateString)
    const now = new Date()
    const diffMs = now.getTime() - date.getTime()

    const diffMinutes = Math.floor(diffMs / (1000 * 60))
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60))
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))

    // T+ format - universal aerospace/military time elapsed notation
    if (diffDays > 0) {
      const hours = diffHours % 24
      return `T+${diffDays}d${hours}h`
    } else if (diffHours > 0) {
      const minutes = diffMinutes % 60
      return `T+${diffHours}h${minutes}m`
    } else if (diffMinutes > 0) {
      return `T+${diffMinutes}m`
    } else {
      return 'T+0m'
    }
  }

  const formatLocation = (location: Alert['location']) => {
    return location.name || `${location.latitude.toFixed(4)}, ${location.longitude.toFixed(4)}`
  }


  if (compact) {
    const slug = getAlertSlug({
      id: alert.id,
      title: alert.title,
      created_at: alert.created_at,
      location: alert.location,
      reporter_username: alert.reporter_username,
      description: alert.description,
      source: alert.source,
      external_url: alert.external_url,
      short_url: alert.short_url
    }, locale, { slugs: t('slugs', { returnObjects: true }) }, alert.short_url)
    return (
      <Link
        href={`/beep/${locale}/${slug}`}
        onClick={() => {
          // Save scroll position before navigating
          if (typeof window !== 'undefined') {
            window.history.replaceState({ ...window.history.state, scrollY: window.scrollY }, '')
          }
        }}>
        <div className="p-4 bg-dark-surface rounded-lg border border-dark-border hover:border-brand-primary transition-colors cursor-pointer group">
          <div className="flex items-start justify-between">
            <div className="flex-1">
              <div className="flex items-center justify-between mb-1">
                <span className="text-text-tertiary text-xs">
                  {formatDate(getDisplayDate())}
                </span>
{(() => {
                  const hasMedia = alert.media_files?.length > 0
                  const hasDescription = getPreviewDescription()?.trim()
                  
                  if (!hasMedia && !hasDescription) {
                    const staticTranslations = t('slugs', { returnObjects: true }) || {}
                    const beepOnlyText = staticTranslations.beepOnly || 'beep only'
                    return <span className="text-xs text-text-tertiary">{beepOnlyText}</span>
                  }
                  if (hasMedia && !hasDescription) {
                    const videoCount = alert.media_files.filter(media => media.type === 'video').length
                    const imageCount = alert.media_files.length - videoCount

                    if (videoCount > 0 && imageCount > 0) {
                      return <span className="text-xs text-text-tertiary">{t('mediaOnly')}</span>
                    } else if (videoCount > 0) {
                      return <span className="text-xs text-text-tertiary">{t('videoOnly')}</span>
                    } else {
                      return <span className="text-xs text-text-tertiary">{t('imageOnly')}</span>
                    }
                  }
                  if (hasMedia && hasDescription) return null
                  // For MUFON reports, don't show eye icon since "witness report only" is in title
                  if (alert.reporter_username === 'MUFON') return null
                  return <span className="text-xs text-text-tertiary">👁️</span>
                })()}
              </div>
              {/* Location with distance */}
              <p className="text-text-primary text-sm font-medium line-clamp-1">
                {(() => {
                  // Clean up location name to avoid duplication
                  let locationName = alert.reporter_username === 'MUFON' 
                    ? (alert.enrichment?.location_raw || alert.location?.name || formatLocation(alert.location))
                    : (alert.location?.name || formatLocation(alert.location))
                  
                  // Remove duplicate state/country suffixes
                  if (locationName && locationName.includes(',')) {
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
                  <span className="text-text-tertiary text-xs font-normal ml-1">
                    {UnitConversion.formatDistanceFromKm(
                      alert.distance_km,
                      UnitConversion.getAutoUnits()
                    )}
                  </span>
                )}
              </p>
              
              {/* Small thumbnail preview for compact cards */}
              {alert.media_files && alert.media_files.length > 0 && (
                <div className="flex gap-1 mt-2">
                  {alert.media_files.slice(0, 3).map((media, index) => (
                    <div 
                      key={media.id}
                      className="w-6 h-6 bg-dark-background rounded overflow-hidden cursor-pointer hover:ring-1 hover:ring-brand-primary/50 transition-all"
                      onClick={(e) => {
                        e.preventDefault()
                        e.stopPropagation()
                        router.push(getDetailUrl(index))
                      }}
                    >
                      <ImageWithLoading 
                        src={media.thumbnail_url || media.url}
                        alt={`Preview ${index + 1}`}
                        width={24}
                        height={24}
                        className="w-full h-full object-cover"
                      />
                    </div>
                  ))}
                  {alert.media_files.length > 3 && (
                    <div className="w-6 h-6 bg-dark-background/50 rounded flex items-center justify-center text-xs text-text-tertiary">
                      +{alert.media_files.length - 3}
                    </div>
                  )}
                </div>
              )}
            </div>
            <div className="w-2 h-2 bg-brand-primary rounded-full animate-pulse"></div>
          </div>
        </div>
      </Link>
    )
  }

  return (
    <div id={`alert-${alert.id}`} className="bg-dark-surface border border-dark-border rounded-xl hover:border-brand-primary transition-all duration-300 hover:shadow-lg group relative">
      <Link
        href={`/beep/${locale}/${getAlertSlug({ id: alert.id, title: alert.title, created_at: alert.created_at, location: alert.location, reporter_username: alert.reporter_username, description: alert.description, source: alert.source, external_url: alert.external_url, short_url: alert.short_url }, locale, { slugs: t('slugs', { returnObjects: true }) }, alert.short_url)}`}
        className="block"
        onClick={() => {
          // Save scroll position before navigating - use sessionStorage to not interfere with history
          if (typeof window !== 'undefined') {
            sessionStorage.setItem('beepListScrollY', window.scrollY.toString())
            sessionStorage.setItem('beepListUrl', window.location.href)
          }
        }}>
        <div className="p-4">
          {/* Header row */}
          <div className="flex items-start gap-3 mb-3">
            {/* UFO Icon */}
            <div className="p-2 bg-brand-primary/10 rounded-lg flex-shrink-0">
              <span className="text-base">🛸</span>
            </div>
            
            {/* Title and metadata */}
            <div className="flex-1 min-w-0">
              <h3 className="text-text-primary text-sm font-semibold line-clamp-2 leading-tight mb-1">
                {(() => {
                  // Get translated title using AlertTitleUtils
                  const ufoSightingText = AlertTitleUtils.getContextualTitle(alert, t) || t('ufoSighting')
                  const beepOnlyText = t('beepOnly')  
                  const reportOnlyText = t('reportOnly')
                  
                  // Determine content type indicator
                  const hasMedia = alert.media_files?.length > 0
                  const hasDescription = getPreviewDescription()?.trim()
                  let typeIndicator = ''
                  
                  if (!hasMedia && !hasDescription) {
                    typeIndicator = ` • 📡 ${beepOnlyText}`
                  } else if (hasDescription && !hasMedia) {
                    typeIndicator = ` • 👁️ ${reportOnlyText}`
                  }
                  
                  return (
                    <>
                      {ufoSightingText}
                      {typeIndicator && (
                        <span className="text-text-tertiary font-normal text-xs ml-1">{typeIndicator}</span>
                      )}
                    </>
                  )
                })()}
              </h3>
              
              {/* Location with distance - right under title for all alerts */}
              <div className="text-text-primary text-sm font-medium mb-2">
                {(() => {
                  // Clean up location name to avoid duplication
                  let locationName = alert.reporter_username === 'MUFON' 
                    ? (alert.enrichment?.location_raw || alert.location?.name || formatLocation(alert.location))
                    : (alert.location?.name || formatLocation(alert.location))
                  
                  // Remove duplicate state/country suffixes
                  if (locationName && locationName.includes(',')) {
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
              </div>
              
              {/* Verification badge */}
              {alert.is_verified && (
                <div className="inline-flex items-center px-2 py-0.5 bg-brand-primary/10 border border-brand-primary/30 rounded-full mb-2">
                  <svg className="w-2.5 h-2.5 text-brand-primary mr-1" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                  </svg>
                  <span className="text-brand-primary text-xs font-medium">Verified</span>
                </div>
              )}
            </div>
            
            {/* Username and time */}
            <div className="text-right flex-shrink-0">
              {alert.reporter_username && (
                <div className="text-brand-primary text-xs font-medium mb-1">
                  by {alert.reporter_username}
                </div>
              )}
              <div className="text-text-tertiary text-xs">
                {formatDate(getDisplayDate())}
              </div>
              <div className="text-text-tertiary text-xs font-medium">
                {formatElapsed(getDisplayDate())}
              </div>
            </div>
          </div>

          {/* Content section */}
          <div className="space-y-2">

            {/* Description */}
            {(() => {
              const previewDescription = getPreviewDescription()
              return previewDescription && (
                <div 
                  className="text-text-secondary text-sm line-clamp-2 leading-relaxed prose prose-sm prose-invert max-w-none"
                  dangerouslySetInnerHTML={{ __html: previewDescription.replace(/\n/g, '<br>') }}
                />
              )
            })()}

            {/* Footer indicators - only show when no media */}
            {!(alert.media_files && alert.media_files.length > 0) && (
              <div className="flex items-center justify-between pt-3">
                <div className="flex items-center gap-2">
                  {/* Comments indicator (only show if there are comments) */}
                  {getActualCommentCount() > 0 && (
                    <div className="px-2 py-1 bg-brand-primary/20 border border-brand-primary/40 rounded-lg hover:bg-brand-primary/30 transition-colors">
                      <div className="flex items-center gap-1.5 text-xs text-brand-primary font-semibold">
                        <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 20 20">
                          <path fillRule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clipRule="evenodd" />
                        </svg>
                        <span>{getActualCommentCount()} comment{getActualCommentCount() !== 1 ? 's' : ''}</span>
                      </div>
                    </div>
                  )}

                  {/* Content type now shown in title - no longer needed here */}
                </div>
                
                {/* Witness count - hidden for MUFON alerts */}
                {alert.witness_count > 1 && alert.reporter_username !== 'MUFON' && (
                  <div className="text-xs text-brand-primary font-medium flex items-center gap-1">
                    <span>👥</span>
                    <span>{alert.witness_count} witnesses</span>
                  </div>
                )}
              </div>
            )}

            {/* Media gallery if available */}
            {alert.media_files && alert.media_files.length > 0 && (
              <div className="mt-3">
                {/* Always show thumbnails, even for single media */}
                <div className="relative">
                  <div className={`flex gap-2 overflow-x-auto pb-2 ${alert.media_files.length >= 5 ? 'scrollbar-thin' : 'scrollbar-hide'}`}>
                    {alert.media_files.slice(0, 6).map((media, index) => (
                      <div 
                        key={media.id}
                        className="flex-shrink-0 w-32 h-32 bg-dark-background rounded-lg overflow-hidden relative cursor-pointer hover:ring-2 hover:ring-brand-primary/50 transition-all duration-200"
                        onClick={(e) => {
                          e.preventDefault()
                          e.stopPropagation()
                          router.push(getDetailUrl(index))
                        }}
                      >
                        <ImageWithLoading 
                          src={media.thumbnail_url || media.url}
                          alt={`${AlertTitleUtils.getShortTitle(alert)} - ${index + 1}`}
                          width={128}
                          height={128}
                          className="w-full h-full object-cover"
                        />
                        
                        {/* Video indicator */}
                        {isVideoMedia(media) && (
                          <div className="absolute inset-0 flex items-center justify-center">
                            <div className="bg-black/70 rounded-full p-1.5">
                              <svg className="w-4 h-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M6.3 4.1c0-.8.9-1.3 1.5-.9l8.4 4.9c.6.4.6 1.4 0 1.8L7.8 14.8c-.6.4-1.5-.1-1.5-.9V4.1z"/>
                              </svg>
                            </div>
                          </div>
                        )}
                        
                        {/* Show +N overlay on last visible item if more exist */}
                        {index === 5 && alert.media_files.length > 6 && (
                          <div className="absolute inset-0 bg-black/60 flex items-center justify-center">
                            <span className="text-white text-sm font-semibold">
                              +{alert.media_files.length - 6}
                            </span>
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
                
                {/* Comments indicator below media */}
                <div className="flex items-center justify-between pt-2">
                  <div className="flex items-center gap-2">
                    {/* Comments indicator (only show if there are comments) */}
                    {getActualCommentCount() > 0 && (
                      <div className="px-2 py-1 bg-brand-primary/20 border border-brand-primary/40 rounded-lg hover:bg-brand-primary/30 transition-colors">
                        <div className="flex items-center gap-1.5 text-xs text-brand-primary font-semibold">
                          <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clipRule="evenodd" />
                          </svg>
                          <span>{getActualCommentCount()} comment{getActualCommentCount() !== 1 ? 's' : ''}</span>
                        </div>
                      </div>
                    )}
                  </div>
                  
                  {/* Witness count - hidden for MUFON alerts */}
                  {alert.witness_count > 1 && alert.reporter_username !== 'MUFON' && (
                    <div className="text-xs text-brand-primary font-medium flex items-center gap-1">
                      <span>👥</span>
                      <span>{alert.witness_count} witnesses</span>
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>
      </Link>

      {/* Share URL display */}
      <div className="px-4 pb-3 border-t border-dark-border/50 bg-dark-background/30">
        <div className="flex items-center justify-between py-2">
          <div className="flex items-center gap-2 min-w-0 flex-1">
            <svg className="w-4 h-4 text-text-tertiary flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.102m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1" />
            </svg>
            <span className="text-text-tertiary text-xs font-mono truncate">
              ufobeep.com{getShortAlertUrl(alert, locale)}
            </span>
          </div>
          <div className="relative">
            <button
              onClick={(e) => {
                e.preventDefault()
                e.stopPropagation()
                setShowShareMenu(!showShareMenu)
              }}
              className="ml-2 p-1.5 text-text-tertiary hover:text-brand-primary hover:bg-brand-primary/10 rounded transition-all flex-shrink-0"
              title="Share alert"
            >
              <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.367 2.684 3 3 0 00-5.367-2.684z" />
              </svg>
            </button>

            {/* Share menu positioned above button */}
            {showShareMenu && (
              <div className="absolute bottom-full right-0 mb-2 bg-dark-surface border border-dark-border rounded-lg shadow-xl z-10 min-w-48">
                <div className="p-2">
                  <button
                    onClick={(e) => handleShare(e, 'copy')}
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
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      
      {/* Media Gallery Modal */}
      <MediaGalleryModal
        isOpen={isMediaModalOpen}
        onClose={() => setIsMediaModalOpen(false)}
        mediaFiles={alert.media_files || []}
        initialIndex={selectedMediaIndex}
        alertTitle={AlertTitleUtils.getShortTitle(alert)}
      />
    </div>
  )
}
