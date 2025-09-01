'use client'

import { useState } from 'react'
import MediaGalleryModal from '../MediaGalleryModal'

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
}

export default function AlertHero({ alert }: AlertHeroProps) {
  const [isMediaModalOpen, setIsMediaModalOpen] = useState(false)
  const [selectedMediaIndex, setSelectedMediaIndex] = useState(0)
  const hasMedia = alert.media_files && alert.media_files.length > 0
  const hasDescription = alert.description?.trim()

  return (
    <div className="bg-dark-surface border border-dark-border rounded-lg overflow-hidden mb-6">
      {/* Header */}
      <div className="p-6">
        <div className="flex items-start gap-4">
          {/* Content type icon - contextual */}
          {(hasMedia || hasDescription) && (
            <div className="bg-brand-primary/10 p-3 rounded-xl border border-brand-primary/20">
              <span className="text-2xl">
                {hasMedia ? (
                  alert.media_files.some(m => m.type === 'video') ? '🎥' : '📸'
                ) : '👁️'}
              </span>
            </div>
          )}
          
          {/* Title and metadata */}
          <div className="flex-1">
            <h1 className="text-2xl font-bold text-text-primary mb-2">
              {alert.title || 'UFO Sighting'}
            </h1>
            
            {/* Content type indicator */}
            {!hasMedia && !hasDescription && (
              <div className="inline-flex items-center gap-2 bg-text-tertiary/10 text-text-tertiary px-3 py-1 rounded-full text-sm font-medium border border-text-tertiary/20">
                <span>📡</span>
                <span>beep only</span>
              </div>
            )}
            {hasMedia && (
              <div className="inline-flex items-center gap-2 bg-brand-primary/10 text-brand-primary px-3 py-1 rounded-full text-sm font-medium border border-brand-primary/20">
                <span>{alert.media_files.some(m => m.type === 'video') ? '🎥' : '📸'}</span>
                <span>{alert.media_files.length} {alert.media_files.some(m => m.type === 'video') ? 'video' : 'photo'}{alert.media_files.length > 1 ? 's' : ''}</span>
              </div>
            )}
            {!hasMedia && hasDescription && (
              <div className="inline-flex items-center gap-2 bg-brand-primary/10 text-brand-primary px-3 py-1 rounded-full text-sm font-medium border border-brand-primary/20">
                <span>👁️</span>
                <span>witness report</span>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Media (if available) */}
      {hasMedia && (
        <div className="relative cursor-pointer group">
          <img 
            src={alert.media_files[0].web_url || alert.media_files[0].url}
            alt={alert.title || 'UFO Sighting'}
            className="w-full h-auto max-h-[400px] object-contain bg-dark-background group-hover:opacity-90 transition-opacity"
            onClick={() => {
              setSelectedMediaIndex(0)
              setIsMediaModalOpen(true)
            }}
          />
          
          {/* Click to view gallery indicator */}
          <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity bg-black/20">
            <div className="bg-black/70 text-white px-4 py-2 rounded-lg flex items-center gap-2">
              <span className="text-lg">{alert.media_files.length > 1 ? '🖼️' : '🔍'}</span>
              <span className="text-sm">
                {alert.media_files.length > 1 ? 'View Gallery' : 'View Full Size'}
              </span>
            </div>
          </div>
          
          {/* Multiple media indicator */}
          {alert.media_files.length > 1 && (
            <div className="absolute top-4 right-4 bg-black/70 text-white px-3 py-1 rounded-full text-sm flex items-center gap-2">
              <span>🖼️</span>
              <span>{alert.media_files.length}</span>
            </div>
          )}
        </div>
      )}
      
      {/* Media Gallery Modal */}
      <MediaGalleryModal
        isOpen={isMediaModalOpen}
        onClose={() => setIsMediaModalOpen(false)}
        mediaFiles={alert.media_files || []}
        initialIndex={selectedMediaIndex}
        alertTitle={alert.title}
      />
    </div>
  )
}