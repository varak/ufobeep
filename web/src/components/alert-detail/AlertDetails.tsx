'use client'

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
  enrichment?: {
    report_date?: string
    sighting_datetime?: string
    mufon_case_id?: string
    [key: string]: any
  }
}

interface AlertDetailsProps {
  alert: Alert
}

export default function AlertDetails({ alert }: AlertDetailsProps) {
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
      <div className="flex items-center gap-2 mb-4">
        <span className="text-brand-primary">ℹ️</span>
        <h2 className="text-lg font-semibold text-brand-primary">Details</h2>
      </div>

      {/* Description - Main description now contains full text */}
      {alert.description && (
        <div className="mb-6">
          {/* MUFON attribution - removed duplicate case number since it's in header */}
          {alert.reporter_username === 'MUFON' && (
            <div className="mb-4 p-3 bg-blue-500/10 border border-blue-500/20 rounded-lg">
              <div className="flex items-center gap-2">
                <span className="text-blue-400">🛸</span>
                <span className="text-blue-300 font-medium">MUFON Database Report</span>
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

      {/* Location - hidden for MUFON alerts */}
      {alert.reporter_username !== 'MUFON' && (
        <div className="flex items-start gap-3">
          <span className="text-text-tertiary mt-0.5">📍</span>
          <div className="flex-1">
            <div className="flex items-center gap-2">
              <span className="text-text-tertiary text-sm font-medium">Location:</span>
              <span className="text-text-primary text-sm">{alert.location.name}</span>
            </div>
            <div className="text-text-secondary text-xs mt-1">
              {alert.location.latitude.toFixed(4)}, {alert.location.longitude.toFixed(4)}
            </div>
          </div>
        </div>
      )}
    </div>
  )
}