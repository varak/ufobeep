import { notFound } from 'next/navigation'
import Link from 'next/link'
import type { Metadata } from 'next'

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
  }>
  enrichment?: {
    status: string
    weather?: {
      temperature: number
      condition: string
      description: string
      humidity: number
      pressure: number
      wind_speed: number
      visibility: number
      observation_quality: string
    }
    celestial?: any
    aircraft?: any
  }
}

interface AlertPageProps {
  params: { slug: string }
}

function generateSlug(title: string, location: string, date: string): string {
  const titlePart = title.toLowerCase()
    .replace(/[^a-z0-9\s]/g, '')
    .replace(/\s+/g, '-')
    .substring(0, 30)
  
  const locationPart = location.split(',')[0].toLowerCase()
    .replace(/[^a-z0-9\s]/g, '')
    .replace(/\s+/g, '-')
    .substring(0, 20)
  
  const datePart = new Date(date).toISOString().split('T')[0]
  
  return `${titlePart}-${locationPart}-${datePart}`.replace(/--+/g, '-').replace(/^-|-$/g, '')
}

async function fetchAlertBySlug(slug: string): Promise<Alert | null> {
  try {
    // Fetch all recent alerts and find one matching the slug
    const response = await fetch('https://api.ufobeep.com/alerts?limit=100&offset=0&verified_only=false', {
      cache: 'no-store' // Always get fresh data
    })
    
    if (!response.ok) {
      console.error('Failed to fetch alerts:', response.status)
      return null
    }
    
    const data = await response.json()
    
    if (!data.success || !data.data?.alerts) {
      console.error('Invalid API response structure')
      return null
    }
    
    // Find alert by matching generated slug
    for (const alert of data.data.alerts) {
      const alertSlug = generateSlug(alert.title, alert.location?.name || 'unknown', alert.created_at)
      if (alertSlug === slug) {
        return alert
      }
    }
    
    return null
  } catch (error) {
    console.error('Error fetching alert:', error)
    return null
  }
}

export async function generateMetadata({ params }: AlertPageProps): Promise<Metadata> {
  const alert = await fetchAlertBySlug(params.slug)
  
  if (!alert) {
    return {
      title: 'Alert Not Found',
      description: 'The requested UFO sighting alert could not be found.',
    }
  }
  
  const description = alert.description.length > 160 
    ? alert.description.substring(0, 157) + '...'
    : alert.description
  
  return {
    title: `${alert.title} - UFO Sighting in ${alert.location.name}`,
    description,
    openGraph: {
      title: `${alert.title} | UFOBeep`,
      description: alert.description,
      type: 'article',
      publishedTime: alert.created_at,
      images: alert.media_files && alert.media_files.length > 0 ? [{
        url: alert.media_files[0].url,
        width: 800,
        height: 600,
        alt: alert.title,
      }] : undefined,
    },
    twitter: {
      card: 'summary_large_image',
      title: alert.title,
      description: description,
      images: alert.media_files && alert.media_files.length > 0 ? [alert.media_files[0].url] : undefined,
    },
  }
}

export default async function AlertPage({ params }: AlertPageProps) {
  const alert = await fetchAlertBySlug(params.slug)

  if (!alert) {
    notFound()
  }

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

  const getCategoryIcon = (category: string) => {
    switch (category) {
      case 'ufo': return '🛸'
      case 'anomaly': return '⭐'
      default: return '❓'
    }
  }

  const getCategoryName = (category: string) => {
    switch (category) {
      case 'ufo': return 'UFO Sighting'
      case 'anomaly': return 'Anomalous Phenomenon'
      default: return 'Sighting'
    }
  }

  const getAlertLevelColor = (level: string) => {
    switch (level.toLowerCase()) {
      case 'critical': return 'text-red-400'
      case 'high': return 'text-orange-400'
      case 'medium': return 'text-yellow-400'
      case 'low': return 'text-green-400'
      default: return 'text-gray-400'
    }
  }

  return (
    <main className="min-h-screen py-8 px-4 md:px-8">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <Link 
            href="/alerts" 
            className="text-brand-primary hover:text-brand-primary-light transition-colors mb-4 inline-block"
          >
            ← Back to All Alerts
          </Link>
          
          <div className="flex items-start justify-between flex-wrap gap-4">
            <div className="flex-1">
              <div className="flex items-center gap-3 mb-4">
                <span className="text-3xl">{getCategoryIcon(alert.category)}</span>
                <div>
                  <span className="bg-dark-surface text-brand-primary px-3 py-1 rounded-full text-sm font-semibold">
                    {getCategoryName(alert.category)}
                  </span>
                  <span className={`px-3 py-1 rounded-full text-xs font-semibold uppercase ${getAlertLevelColor(alert.alert_level)} ml-2`}>
                    {alert.alert_level}
                  </span>
                </div>
              </div>
              <h1 className="text-3xl md:text-4xl font-bold text-text-primary mb-2">
                {alert.title}
              </h1>
              <p className="text-text-secondary">
                {alert.location.name} • {formatDate(alert.created_at)}
              </p>
            </div>
          </div>
        </div>

        {/* Media Section */}
        <div className="mb-8">
          {alert.media_files && alert.media_files.length > 0 ? (
            <div className="bg-dark-surface border border-dark-border rounded-lg overflow-hidden">
              <div className="aspect-video bg-dark-background relative">
                <img 
                  src={alert.media_files[0].url} 
                  alt={alert.title}
                  className="w-full h-full object-cover"
                  onError={(e) => {
                    const target = e.target as HTMLImageElement;
                    target.style.display = 'none';
                    const fallback = target.parentElement?.querySelector('.fallback-placeholder');
                    if (fallback) (fallback as HTMLElement).style.display = 'flex';
                  }}
                />
                <div className="fallback-placeholder absolute inset-0 bg-dark-background flex items-center justify-center" style={{display: 'none'}}>
                  <div className="text-center">
                    <div className="text-4xl mb-4">📸</div>
                    <p className="text-text-secondary">Image unavailable</p>
                  </div>
                </div>
              </div>
              <div className="p-4 bg-dark-surface">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-text-tertiary">Media attached</span>
                  <span className="text-brand-primary">{alert.media_files.length} file{alert.media_files.length > 1 ? 's' : ''}</span>
                </div>
              </div>
            </div>
          ) : (
            <div className="bg-dark-surface border border-dark-border rounded-lg p-8 text-center">
              <div className="text-6xl mb-4">👁️</div>
              <p className="text-text-secondary">No media attached to this sighting</p>
              <p className="text-text-tertiary text-sm mt-2">Witness provided description only</p>
            </div>
          )}
        </div>

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-6">
            {/* Description */}
            <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h2 className="text-xl font-semibold text-text-primary mb-4">Description</h2>
              <p className="text-text-secondary leading-relaxed">
                {alert.description}
              </p>
            </section>

            {/* Environmental Data */}
            {alert.enrichment && alert.enrichment.weather && (
              <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h2 className="text-xl font-semibold text-text-primary mb-4">Environmental Context</h2>
                
                <div className="mb-6">
                  <h3 className="text-lg font-medium text-brand-primary mb-3 flex items-center gap-2">
                    🌤️ Weather Conditions
                  </h3>
                  <div className="grid sm:grid-cols-3 gap-4">
                    <div>
                      <p className="text-text-tertiary text-sm">Temperature</p>
                      <p className="text-text-primary">{alert.enrichment.weather.temperature}°C</p>
                    </div>
                    <div>
                      <p className="text-text-tertiary text-sm">Conditions</p>
                      <p className="text-text-primary">{alert.enrichment.weather.condition}</p>
                    </div>
                    <div>
                      <p className="text-text-tertiary text-sm">Visibility</p>
                      <p className="text-text-primary">{alert.enrichment.weather.visibility} km</p>
                    </div>
                    <div>
                      <p className="text-text-tertiary text-sm">Wind Speed</p>
                      <p className="text-text-primary">{alert.enrichment.weather.wind_speed} m/s</p>
                    </div>
                    <div>
                      <p className="text-text-tertiary text-sm">Humidity</p>
                      <p className="text-text-primary">{alert.enrichment.weather.humidity}%</p>
                    </div>
                    <div>
                      <p className="text-text-tertiary text-sm">Pressure</p>
                      <p className="text-text-primary">{alert.enrichment.weather.pressure} hPa</p>
                    </div>
                  </div>
                  {alert.enrichment.weather.observation_quality && (
                    <div className="mt-3 p-3 bg-dark-background rounded border border-dark-border">
                      <p className="text-text-tertiary text-sm">
                        <strong>Observation Quality:</strong> {alert.enrichment.weather.observation_quality}
                      </p>
                    </div>
                  )}
                </div>
              </section>
            )}
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Location */}
            <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h3 className="text-lg font-semibold text-text-primary mb-4">Location</h3>
              <p className="text-text-secondary mb-4">{alert.location.name}</p>
              <p className="text-text-tertiary text-sm mb-4">
                {alert.location.latitude.toFixed(6)}, {alert.location.longitude.toFixed(6)}
              </p>
              
              <div className="bg-dark-background rounded-lg p-4 text-center">
                <div className="text-3xl mb-2">🗺️</div>
                <p className="text-text-tertiary text-sm">Interactive map coming soon</p>
              </div>
            </section>

            {/* Stats */}
            <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h3 className="text-lg font-semibold text-text-primary mb-4">Sighting Details</h3>
              <div className="space-y-4">
                <div className="flex justify-between items-center">
                  <span className="text-text-tertiary flex items-center gap-2">
                    <span>📸</span> Media Files
                  </span>
                  <span className="text-text-primary font-medium">{alert.media_files?.length || 0}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-text-tertiary flex items-center gap-2">
                    <span>🛡️</span> Status
                  </span>
                  <span className="text-text-primary font-medium">
                    {alert.enrichment?.status || 'Processing'}
                  </span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-text-tertiary flex items-center gap-2">
                    <span>⚡</span> Alert Level
                  </span>
                  <span className={`font-medium ${getAlertLevelColor(alert.alert_level)}`}>
                    {alert.alert_level}
                  </span>
                </div>
              </div>
            </section>
          </div>
        </div>
      </div>
    </main>
  )
}