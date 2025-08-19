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

      {/* Description */}
      {alert.description && (
        <div className="mb-6">
          <p className="text-text-secondary leading-relaxed">
            {alert.description}
          </p>
        </div>
      )}

      {/* Time */}
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

      {/* Location */}
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
    </div>
  )
}