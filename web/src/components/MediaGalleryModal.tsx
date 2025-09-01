'use client'

import { useState, useEffect } from 'react'

interface MediaFile {
  id?: string
  type: string
  url: string
  thumbnail_url: string
  web_url?: string
  preview_url?: string
}

interface MediaGalleryModalProps {
  isOpen: boolean
  onClose: () => void
  mediaFiles: MediaFile[]
  initialIndex?: number
  alertTitle?: string
}

export default function MediaGalleryModal({ 
  isOpen, 
  onClose, 
  mediaFiles, 
  initialIndex = 0,
  alertTitle 
}: MediaGalleryModalProps) {
  const [currentIndex, setCurrentIndex] = useState(initialIndex)

  useEffect(() => {
    setCurrentIndex(initialIndex)
  }, [initialIndex])

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden'
    } else {
      document.body.style.overflow = 'auto'
    }
    
    return () => {
      document.body.style.overflow = 'auto'
    }
  }, [isOpen])

  const goToPrevious = () => {
    setCurrentIndex(prev => prev > 0 ? prev - 1 : mediaFiles.length - 1)
  }

  const goToNext = () => {
    setCurrentIndex(prev => prev < mediaFiles.length - 1 ? prev + 1 : 0)
  }

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose()
      if (e.key === 'ArrowLeft') goToPrevious()
      if (e.key === 'ArrowRight') goToNext()
    }

    if (isOpen) {
      document.addEventListener('keydown', handleKeyDown)
      return () => document.removeEventListener('keydown', handleKeyDown)
    }
  }, [isOpen, onClose, goToPrevious, goToNext])

  if (!isOpen || !mediaFiles.length) return null

  const currentMedia = mediaFiles[currentIndex]
  const isVideo = currentMedia.type === 'video' || currentMedia.url?.toLowerCase().includes('.mp4')

  const getFullImageUrl = (media: MediaFile) => {
    return media.url?.startsWith('http') 
      ? media.url 
      : `https://api.ufobeep.com${media.url}`
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-95 z-50 flex flex-col animate-in fade-in duration-200">
      {/* Header */}
      <div className="flex justify-between items-center p-6 bg-dark-surface/80 backdrop-blur-sm border-b border-dark-border/50">
        <div className="flex items-center gap-4">
          <div className="text-2xl">{isVideo ? '🎥' : '📸'}</div>
          <div>
            <h3 className="text-xl font-bold text-text-primary flex items-center gap-2">
              Media Gallery
              <span className="bg-brand-primary/20 text-brand-primary px-2 py-1 rounded text-sm font-medium">
                {currentIndex + 1} of {mediaFiles.length}
              </span>
            </h3>
            {alertTitle && (
              <p className="text-text-secondary text-sm mt-1">
                {alertTitle}
              </p>
            )}
          </div>
        </div>
        <div className="flex items-center gap-2">
          <div className="bg-dark-background/50 text-text-tertiary px-3 py-1 rounded-full text-xs">
            ← → Navigate • ESC Close
          </div>
          <button
            onClick={onClose}
            className="text-text-primary hover:text-brand-primary p-3 rounded-lg border border-dark-border transition-colors hover:bg-dark-background/50"
            title="Close gallery"
          >
            <span className="text-lg">✕</span>
          </button>
        </div>
      </div>

      {/* Media Display */}
      <div className="flex-1 flex items-center justify-center p-6 relative overflow-auto">
        {isVideo ? (
          <video 
            src={getFullImageUrl(currentMedia)}
            controls
            className="max-w-[90vw] max-h-[70vh] rounded-lg shadow-2xl"
            autoPlay={false}
          />
        ) : (
          <div className="relative group">
            <img 
              src={getFullImageUrl(currentMedia)}
              alt={`Media ${currentIndex + 1}`}
              className="max-w-[90vw] max-h-[70vh] object-contain rounded-lg shadow-2xl cursor-zoom-in transition-all duration-200"
              onClick={(e) => {
                // Toggle between fit-to-screen and actual size
                const img = e.target as HTMLImageElement
                if (img.classList.contains('max-w-[90vw]')) {
                  img.classList.remove('max-w-[90vw]', 'max-h-[70vh]', 'cursor-zoom-in')
                  img.classList.add('cursor-zoom-out')
                  img.style.maxWidth = 'none'
                  img.style.maxHeight = 'none'
                } else {
                  img.classList.add('max-w-[90vw]', 'max-h-[70vh]', 'cursor-zoom-in')
                  img.classList.remove('cursor-zoom-out')
                  img.style.maxWidth = ''
                  img.style.maxHeight = ''
                }
              }}
            />
            {/* Zoom hint */}
            <div className="absolute bottom-4 right-4 bg-black/70 text-white px-2 py-1 rounded text-xs opacity-0 group-hover:opacity-100 transition-opacity">
              Click to zoom
            </div>
          </div>
        )}

        {/* Navigation Arrows */}
        {mediaFiles.length > 1 && (
          <>
            <button
              onClick={goToPrevious}
              className="absolute left-4 top-1/2 -translate-y-1/2 bg-dark-background/80 hover:bg-dark-surface/90 text-text-primary p-3 rounded-full border border-dark-border transition-colors hover:scale-110"
              title="Previous media"
            >
              <span className="text-xl">←</span>
            </button>
            <button
              onClick={goToNext}
              className="absolute right-4 top-1/2 -translate-y-1/2 bg-dark-background/80 hover:bg-dark-surface/90 text-text-primary p-3 rounded-full border border-dark-border transition-colors hover:scale-110"
              title="Next media"
            >
              <span className="text-xl">→</span>
            </button>
          </>
        )}
      </div>

      {/* Thumbnail Strip */}
      {mediaFiles.length > 1 && (
        <div className="p-4 bg-dark-surface/80 backdrop-blur-sm border-t border-dark-border/50">
          <div className="flex justify-center gap-2 max-w-full overflow-x-auto pb-2">
            {mediaFiles.map((media, index) => (
              <button
                key={media.id || `media-${index}`}
                onClick={() => setCurrentIndex(index)}
                className={`flex-shrink-0 w-16 h-16 rounded-lg overflow-hidden border-2 transition-all hover:scale-105 ${
                  index === currentIndex 
                    ? 'border-brand-primary shadow-glow' 
                    : 'border-dark-border hover:border-brand-primary/50'
                }`}
              >
                {media.type === 'video' ? (
                  <div className="w-full h-full bg-dark-background flex items-center justify-center">
                    <span className="text-xl">🎥</span>
                  </div>
                ) : (
                  <img 
                    src={media.web_url || media.thumbnail_url || media.url} 
                    alt={`Thumbnail ${index + 1}`}
                    className="w-full h-full object-cover"
                  />
                )}
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}