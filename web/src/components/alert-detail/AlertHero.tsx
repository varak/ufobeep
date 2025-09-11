'use client'

import { useState, useEffect, useRef } from 'react'
import { useRouter } from 'next/navigation'
import MediaGalleryModal from '../MediaGalleryModal'
import { useClientTranslations } from '@/hooks/useClientTranslations'

interface Alert {
  id: string
  title: string
  description: string
  created_at: string
  location: {
    latitude: number
    longitude: number
    name: string
  }
  media_files: Array<{
    type: string
    url: string
    thumbnail_url: string
    web_url?: string
  }>
}

interface AlertHeroProps {
  alert: Alert
  openImageIndex?: number
}

export default function AlertHero({ alert, openImageIndex }: AlertHeroProps) {
  const [isMediaModalOpen, setIsMediaModalOpen] = useState(false)
  const [selectedMediaIndex, setSelectedMediaIndex] = useState(0)
  const router = useRouter()
  const { t } = useClientTranslations('common')
  const hasMedia = alert.media_files && alert.media_files.length > 0
  const hasDescription = alert.description?.trim()

  const handleCloseModal = () => {
    setIsMediaModalOpen(false)
    const url = new URL(window.location.href)
    url.searchParams.delete('openImage')
    router.replace(url.pathname + url.search, { scroll: false })
    setTimeout(() => window.scrollTo({ top: 0, behavior: 'smooth' }), 100)
  }

  // Auto-open image modal if openImageIndex is provided
  const hasAutoOpened = useRef(false)
  useEffect(() => {
    if (openImageIndex !== undefined && hasMedia && !hasAutoOpened.current) {
      const validIndex = Math.max(0, Math.min(openImageIndex, alert.media_files.length - 1))
      setSelectedMediaIndex(validIndex)
      setIsMediaModalOpen(true)
      hasAutoOpened.current = true
    }
  }, [openImageIndex, hasMedia, alert.media_files])

  return (
    <div className="bg-dark-surface border border-dark-border rounded-lg overflow-hidden mb-6">
      {/* Header */}
      <div className="p-6">
        <div className="flex items-start gap-4">
          {/* UFOBeep icon for all reports */}
          <div className="bg-brand-primary/10 p-3 rounded-xl border border-brand-primary/20">
            <span className="text-2xl">🛸</span>
          </div>
          
          {/* Title and metadata */}
          <div className="flex-1">
            <h1 className="text-2xl font-bold text-text-primary mb-2">
              {alert.title || 'UFO Sighting Report'}
            </h1>
            
            {/* Content type indicator - only show "witness report" when no media to explain lack */}
            {!hasMedia && !hasDescription && (
              <div className="inline-flex items-center gap-2 bg-text-tertiary/10 text-text-tertiary px-3 py-1 rounded-full text-sm font-medium border border-text-tertiary/20">
                <span>📡</span>
                <span>{t('beepOnly')}</span>
              </div>
            )}
            {!hasMedia && hasDescription && (
              <div className="inline-flex items-center gap-2 bg-brand-primary/10 text-brand-primary px-3 py-1 rounded-full text-sm font-medium border border-brand-primary/20">
                <span>👁️</span>
                <span>{t('reportOnly', 'Report only')}</span>
              </div>
            )}
            {/* Remove redundant media count badge - thumbnails already show how many */}
          </div>
        </div>
      </div>

      {/* Media gallery - thumbnails show count visually, no need for text badge */}
      {hasMedia && (
        <div className="px-6 pb-6">
          <div className={`flex gap-2 overflow-x-auto pb-2 ${alert.media_files.length >= 5 ? 'scrollbar-thin' : 'scrollbar-hide'}`}>
            {alert.media_files.slice(0, 6).map((media, index) => (
              <div 
                key={`media-${index}`}
                className="flex-shrink-0 w-32 h-32 bg-dark-background rounded-lg overflow-hidden relative cursor-pointer hover:ring-2 hover:ring-brand-primary/50 transition-all duration-200"
                onClick={() => {
                  setSelectedMediaIndex(index)
                  setIsMediaModalOpen(true)
                }}
              >
                <img 
                  src={media.web_url || media.thumbnail_url || media.url}
                  alt={`${alert.title || 'UFO Sighting'} - ${index + 1}`}
                  className="w-full h-full object-cover"
                  onError={(e) => {
                    // Show placeholder for broken images
                    const target = e.target as HTMLImageElement;
                    target.style.display = 'none';
                    const parent = target.parentElement;
                    if (parent && !parent.querySelector('.image-error')) {
                      const errorDiv = document.createElement('div');
                      errorDiv.className = 'image-error w-full h-full flex items-center justify-center bg-dark-background text-text-tertiary text-xs';
                      errorDiv.innerHTML = '<div><div class="text-2xl mb-1">🖼️</div><div>Image not found</div></div>';
                      parent.appendChild(errorDiv);
                    }
                  }}
                />
                
                {/* Video indicator */}
                {media.type === 'video' && (
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
      )}
      
      {/* Media Gallery Modal */}
      <MediaGalleryModal
        isOpen={isMediaModalOpen}
        onClose={handleCloseModal}
        mediaFiles={alert.media_files || []}
        initialIndex={selectedMediaIndex}
        alertTitle={alert.title}
      />
    </div>
  )
}