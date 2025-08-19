'use client'

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
  const hasMedia = alert.media_files && alert.media_files.length > 0
  const hasDescription = alert.description?.trim()

  return (
    <div className="bg-dark-surface border border-dark-border rounded-lg overflow-hidden mb-6">
      {/* Header */}
      <div className="p-6">
        <div className="flex items-start gap-4">
          {/* UFO Icon */}
          <div className="bg-brand-primary/10 p-3 rounded-xl border border-brand-primary/20">
            <span className="text-2xl">🛸</span>
          </div>
          
          {/* Title and metadata */}
          <div className="flex-1">
            <h1 className="text-2xl font-bold text-text-primary mb-2">
              {alert.title}
            </h1>
            
            {/* Content type indicator */}
            {!hasMedia && !hasDescription && (
              <div className="inline-block bg-text-tertiary/10 text-text-tertiary px-3 py-1 rounded-full text-sm font-medium border border-text-tertiary/20">
                beep only
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Media (if available) */}
      {hasMedia && (
        <div className="relative">
          <img 
            src={alert.media_files[0].web_url || alert.media_files[0].url}
            alt={alert.title}
            className="w-full h-auto max-h-[400px] object-contain bg-dark-background"
          />
          
          {/* Multiple media indicator */}
          {alert.media_files.length > 1 && (
            <div className="absolute top-4 right-4 bg-black/70 text-white px-3 py-1 rounded-full text-sm flex items-center gap-2">
              <span>📸</span>
              <span>{alert.media_files.length}</span>
            </div>
          )}
        </div>
      )}
    </div>
  )
}