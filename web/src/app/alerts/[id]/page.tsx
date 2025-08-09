import { notFound } from 'next/navigation'
import Link from 'next/link'

// Mock data for development
const mockAlerts = [
  {
    id: '1',
    title: 'Strange Lights Over Downtown',
    description: 'Multiple witnesses reported a formation of bright lights moving in coordinated patterns over the downtown area. The lights appeared to pulse and change colors from blue to green to white.',
    category: 'ufo',
    location: 'San Francisco, CA',
    coordinates: { lat: 37.7749, lng: -122.4194 },
    timestamp: '2024-01-15T22:30:00Z',
    verified: true,
    mediaUrl: null,
    weatherData: {
      temperature: '18°C',
      conditions: 'Clear skies',
      visibility: '16 km',
      windSpeed: '8 km/h'
    },
    celestialData: {
      moonPhase: 'Waning Gibbous',
      moonVisibility: '87%',
      nearbyPlanets: ['Venus', 'Mars']
    },
    chatRoomId: 'room_abc123',
    witnessCount: 12
  },
  {
    id: '2',
    title: 'Missing Cat - Whiskers',
    description: 'Orange tabby cat with white patches on chest and paws. Very friendly, responds to "Whiskers". Last seen near Dolores Park wearing a blue collar with bell.',
    category: 'missing_pet',
    location: 'Mission District, San Francisco',
    coordinates: { lat: 37.7595, lng: -122.4267 },
    timestamp: '2024-01-16T14:15:00Z',
    verified: false,
    mediaUrl: null,
    weatherData: null,
    celestialData: null,
    chatRoomId: 'room_def456',
    witnessCount: 3
  }
]

interface AlertPageProps {
  params: { id: string }
}

export default function AlertPage({ params }: AlertPageProps) {
  const alert = mockAlerts.find(a => a.id === params.id)

  if (!alert) {
    notFound()
  }

  const formatTimestamp = (timestamp: string) => {
    return new Date(timestamp).toLocaleString('en-US', {
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
      case 'missing_pet': return '🐾'
      case 'missing_person': return '👤'
      default: return '❓'
    }
  }

  const getCategoryName = (category: string) => {
    switch (category) {
      case 'ufo': return 'UFO Sighting'
      case 'missing_pet': return 'Missing Pet'
      case 'missing_person': return 'Missing Person'
      default: return 'Unknown'
    }
  }

  return (
    <main className="min-h-screen py-8 px-4 md:px-8">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <Link 
            href="/" 
            className="text-brand-primary hover:text-brand-primary-light transition-colors mb-4 inline-block"
          >
            ← Back to Home
          </Link>
          
          <div className="flex items-start justify-between flex-wrap gap-4">
            <div className="flex-1">
              <div className="flex items-center gap-3 mb-4">
                <span className="text-3xl">{getCategoryIcon(alert.category)}</span>
                <div>
                  <span className="bg-dark-surface text-brand-primary px-3 py-1 rounded-full text-sm font-semibold">
                    {getCategoryName(alert.category)}
                  </span>
                  {alert.verified && (
                    <span className="bg-semantic-success bg-opacity-20 text-semantic-success px-3 py-1 rounded-full text-sm font-semibold ml-2">
                      ✓ Verified
                    </span>
                  )}
                </div>
              </div>
              <h1 className="text-3xl md:text-4xl font-bold text-text-primary mb-2">
                {alert.title}
              </h1>
              <p className="text-text-secondary">
                {alert.location} • {formatTimestamp(alert.timestamp)}
              </p>
            </div>
            
            <button className="bg-brand-primary text-text-inverse px-6 py-3 rounded-lg font-semibold hover:bg-brand-primary-dark transition-colors">
              Share Alert
            </button>
          </div>
        </div>

        {/* Media Section */}
        <div className="mb-8">
          <div className="bg-dark-surface border border-dark-border rounded-lg p-8 text-center">
            <div className="text-6xl mb-4">📸</div>
            <p className="text-text-secondary">No media attached to this sighting</p>
            <p className="text-text-tertiary text-sm mt-2">Media sharing coming soon</p>
          </div>
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
            {(alert.weatherData || alert.celestialData) && (
              <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h2 className="text-xl font-semibold text-text-primary mb-4">Environmental Data</h2>
                
                {alert.weatherData && (
                  <div className="mb-6">
                    <h3 className="text-lg font-medium text-brand-primary mb-3">Weather Conditions</h3>
                    <div className="grid sm:grid-cols-2 gap-4">
                      <div>
                        <p className="text-text-tertiary text-sm">Temperature</p>
                        <p className="text-text-primary">{alert.weatherData.temperature}</p>
                      </div>
                      <div>
                        <p className="text-text-tertiary text-sm">Conditions</p>
                        <p className="text-text-primary">{alert.weatherData.conditions}</p>
                      </div>
                      <div>
                        <p className="text-text-tertiary text-sm">Visibility</p>
                        <p className="text-text-primary">{alert.weatherData.visibility}</p>
                      </div>
                      <div>
                        <p className="text-text-tertiary text-sm">Wind Speed</p>
                        <p className="text-text-primary">{alert.weatherData.windSpeed}</p>
                      </div>
                    </div>
                  </div>
                )}

                {alert.celestialData && (
                  <div>
                    <h3 className="text-lg font-medium text-brand-primary mb-3">Celestial Information</h3>
                    <div className="grid sm:grid-cols-2 gap-4">
                      <div>
                        <p className="text-text-tertiary text-sm">Moon Phase</p>
                        <p className="text-text-primary">{alert.celestialData.moonPhase}</p>
                      </div>
                      <div>
                        <p className="text-text-tertiary text-sm">Moon Visibility</p>
                        <p className="text-text-primary">{alert.celestialData.moonVisibility}</p>
                      </div>
                      <div className="sm:col-span-2">
                        <p className="text-text-tertiary text-sm">Visible Planets</p>
                        <p className="text-text-primary">{alert.celestialData.nearbyPlanets.join(', ')}</p>
                      </div>
                    </div>
                  </div>
                )}
              </section>
            )}

            {/* Chat Section */}
            <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-xl font-semibold text-text-primary">Discussion</h2>
                <span className="text-text-tertiary text-sm">
                  {alert.witnessCount} participant{alert.witnessCount !== 1 ? 's' : ''}
                </span>
              </div>
              
              <div className="bg-dark-background rounded-lg p-6 text-center">
                <div className="text-4xl mb-4">💬</div>
                <p className="text-text-secondary mb-4">
                  Join the discussion about this sighting
                </p>
                <p className="text-text-tertiary text-sm mb-6">
                  Real-time chat powered by Matrix protocol (coming soon)
                </p>
                <button className="bg-brand-primary text-text-inverse px-6 py-3 rounded-lg font-semibold hover:bg-brand-primary-dark transition-colors">
                  Join Chat Room
                </button>
              </div>
            </section>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Location */}
            <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h3 className="text-lg font-semibold text-text-primary mb-4">Location</h3>
              <p className="text-text-secondary mb-4">{alert.location}</p>
              
              <div className="bg-dark-background rounded-lg p-4 text-center">
                <div className="text-3xl mb-2">🗺️</div>
                <p className="text-text-tertiary text-sm">Interactive map coming soon</p>
              </div>
              
              <button className="w-full mt-4 bg-brand-primary text-text-inverse py-3 rounded-lg font-semibold hover:bg-brand-primary-dark transition-colors">
                Get Directions
              </button>
            </section>

            {/* Actions */}
            <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h3 className="text-lg font-semibold text-text-primary mb-4">Actions</h3>
              <div className="space-y-3">
                <button className="w-full bg-dark-background border border-dark-border-light text-text-primary py-3 rounded-lg hover:bg-dark-border-light transition-colors">
                  Report Issue
                </button>
                <button className="w-full bg-dark-background border border-dark-border-light text-text-primary py-3 rounded-lg hover:bg-dark-border-light transition-colors">
                  Save Alert
                </button>
                <button className="w-full bg-dark-background border border-dark-border-light text-text-primary py-3 rounded-lg hover:bg-dark-border-light transition-colors">
                  Follow Updates
                </button>
              </div>
            </section>

            {/* Stats */}
            <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h3 className="text-lg font-semibold text-text-primary mb-4">Alert Stats</h3>
              <div className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-text-tertiary">Views</span>
                  <span className="text-text-primary">247</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-text-tertiary">Witnesses</span>
                  <span className="text-text-primary">{alert.witnessCount}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-text-tertiary">Reports</span>
                  <span className="text-text-primary">3</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-text-tertiary">Verification</span>
                  <span className={alert.verified ? 'text-semantic-success' : 'text-text-tertiary'}>
                    {alert.verified ? 'Verified' : 'Pending'}
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