import { notFound } from 'next/navigation'
import Link from 'next/link'
import type { Metadata } from 'next'
import MatrixTranscript from '@/components/MatrixTranscript'
import { getMatrixRoomData, generateMockMatrixData } from '@/lib/matrix-api'

// Mock data for development - Enhanced with more realistic sightings
const mockAlerts = [
  {
    id: '1',
    title: 'Triangle Formation Over Bay Bridge',
    description: 'Three bright triangular objects observed moving in perfect formation over the Bay Bridge around 10:30 PM. Objects maintained consistent spacing and altitude, estimated 1000-1500 feet. No sound detected. Duration approximately 4 minutes before objects accelerated rapidly southward and disappeared. Multiple independent witnesses from different vantage points.',
    category: 'ufo',
    location: 'San Francisco Bay, CA',
    coordinates: { lat: 37.7749, lng: -122.4194 },
    timestamp: '2024-01-15T22:30:00Z',
    verified: true,
    mediaUrl: 'https://example.com/media/triangle-formation.mp4',
    weatherData: {
      temperature: '12°C',
      conditions: 'Clear skies',
      visibility: '25 km',
      windSpeed: '5 km/h',
      humidity: '68%',
      barometric: '1013.2 hPa'
    },
    celestialData: {
      moonPhase: 'Waning Gibbous',
      moonVisibility: '87%',
      nearbyPlanets: ['Venus (SW)', 'Mars (E)'],
      satellites: ['ISS (not visible)', 'Starlink chain (passed 45min earlier)']
    },
    enrichment: {
      aircraftChecked: true,
      noKnownAircraft: true,
      weatherImpact: 'Minimal - excellent visibility',
      conventionalExplanation: null
    },
    chatRoomId: 'room_abc123',
    matrixRoomId: '!sighting_abc123_xyz789:ufobeep.com',
    witnessCount: 12,
    mediaCount: 3,
    reporterDistance: '2.1 km',
    estimatedAltitude: '400-500m',
    duration: '4 minutes 15 seconds'
  },
  {
    id: '2', 
    title: 'Bright Orange Orb - Residential Area',
    description: 'Single orange-red spherical object hovering approximately 200 feet above residential area. Object pulsed with warm orange light, no navigation lights visible. Hovered for about 2 minutes before moving east at moderate speed. No sound whatsoever. Size estimated similar to small aircraft.',
    category: 'ufo',
    location: 'Fremont, CA',
    coordinates: { lat: 37.5485, lng: -121.9886 },
    timestamp: '2024-01-16T19:45:00Z',
    verified: false,
    mediaUrl: 'https://example.com/media/orange-orb.jpg',
    weatherData: {
      temperature: '16°C',
      conditions: 'Partly cloudy',
      visibility: '12 km',
      windSpeed: '12 km/h',
      humidity: '74%',
      barometric: '1011.8 hPa'
    },
    celestialData: {
      moonPhase: 'New Moon',
      moonVisibility: '2%',
      nearbyPlanets: ['Jupiter (high SE)'],
      satellites: ['Several Starlink satellites visible earlier']
    },
    enrichment: {
      aircraftChecked: true,
      noKnownAircraft: false,
      possibleAircraft: 'Small private aircraft reported in area',
      weatherImpact: 'Light clouds may affect visibility',
      conventionalExplanation: 'Possible aircraft with unusual lighting'
    },
    chatRoomId: 'room_def456',
    matrixRoomId: '!sighting_def456_abc123:ufobeep.com',
    witnessCount: 5,
    mediaCount: 2,
    reporterDistance: '150m',
    estimatedAltitude: '60-80m', 
    duration: '2 minutes 30 seconds'
  },
  {
    id: '3',
    title: 'Fast-Moving Light Chain',
    description: 'String of 15-20 bright white lights moving in single file formation from northwest to southeast. Consistent spacing between objects, no blinking or variation in brightness. Passed overhead in approximately 90 seconds. Initially thought to be aircraft but formation and speed inconsistent with conventional air traffic.',
    category: 'ufo',
    location: 'Santa Rosa, CA', 
    coordinates: { lat: 38.4404, lng: -122.7144 },
    timestamp: '2024-01-17T06:15:00Z',
    verified: true,
    mediaUrl: null,
    weatherData: {
      temperature: '8°C',
      conditions: 'Clear skies',
      visibility: '30 km',
      windSpeed: '3 km/h',
      humidity: '82%',
      barometric: '1015.1 hPa'
    },
    celestialData: {
      moonPhase: 'Waxing Crescent',
      moonVisibility: '15%',
      nearbyPlanets: ['Venus (bright, E)'],
      satellites: ['Active Starlink deployment window']
    },
    enrichment: {
      aircraftChecked: true,
      noKnownAircraft: true,
      weatherImpact: 'Excellent viewing conditions',
      conventionalExplanation: 'Likely Starlink satellite constellation'
    },
    chatRoomId: 'room_ghi789',
    matrixRoomId: '!sighting_ghi789_def456:ufobeep.com',
    witnessCount: 8,
    mediaCount: 0,
    reporterDistance: 'Overhead',
    estimatedAltitude: 'High altitude (satellite orbit)',
    duration: '90 seconds'
  }
]

interface AlertPageProps {
  params: { id: string }
}

export async function generateMetadata(
  { params }: AlertPageProps
): Promise<Metadata> {
  const alert = mockAlerts.find(a => a.id === params.id)
  
  if (!alert) {
    return {
      title: 'Alert Not Found',
      description: 'The requested sighting alert could not be found.',
    }
  }
  
  return {
    title: alert.title,
    description: alert.description.slice(0, 160) + (alert.description.length > 160 ? '...' : ''),
    openGraph: {
      title: `${alert.title} | UFOBeep`,
      description: alert.description,
      type: 'article',
      publishedTime: alert.timestamp,
      images: alert.mediaUrl ? [{
        url: alert.mediaUrl,
        width: 800,
        height: 600,
        alt: alert.title,
      }] : undefined,
    },
    twitter: {
      card: 'summary_large_image',
      title: alert.title,
      description: alert.description.slice(0, 200),
      images: alert.mediaUrl ? [alert.mediaUrl] : undefined,
    },
  }
}

export default async function AlertPage({ params }: AlertPageProps) {
  const alert = mockAlerts.find(a => a.id === params.id)

  if (!alert) {
    notFound()
  }

  // Fetch Matrix room data for SSR
  let matrixData;
  try {
    // In development, use mock data if Matrix API is not available
    const isMatrixAvailable = process.env.NODE_ENV === 'production';
    
    if (isMatrixAvailable && alert.matrixRoomId) {
      matrixData = await getMatrixRoomData(alert.matrixRoomId);
    } else {
      // Use mock data for development/demo
      matrixData = generateMockMatrixData();
    }
  } catch (error) {
    console.error('Error fetching Matrix data:', error);
    matrixData = generateMockMatrixData();
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
      case 'anomaly': return '⭐'
      case 'missing_pet': return '🐾'
      case 'missing_person': return '👤'
      default: return '❓'
    }
  }

  const getCategoryName = (category: string) => {
    switch (category) {
      case 'ufo': return 'UFO Sighting'
      case 'anomaly': return 'Anomalous Phenomenon'
      case 'missing_pet': return 'Missing Pet'
      case 'missing_person': return 'Missing Person'
      default: return 'Unknown'
    }
  }

  const getVerificationBadge = (alert: any) => {
    if (alert.verified) {
      return (
        <span className="bg-semantic-success bg-opacity-20 text-semantic-success px-3 py-1 rounded-full text-sm font-semibold ml-2">
          ✓ Verified
        </span>
      )
    }
    if (alert.enrichment?.conventionalExplanation) {
      return (
        <span className="bg-semantic-info bg-opacity-20 text-semantic-info px-3 py-1 rounded-full text-sm font-semibold ml-2">
          ℹ️ Explained
        </span>
      )
    }
    return (
      <span className="bg-semantic-warning bg-opacity-20 text-semantic-warning px-3 py-1 rounded-full text-sm font-semibold ml-2">
        ⏳ Under Review
      </span>
    )
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
                  {getVerificationBadge(alert)}
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
          {alert.mediaUrl ? (
            <div className="bg-dark-surface border border-dark-border rounded-lg overflow-hidden">
              <div className="aspect-video bg-dark-background flex items-center justify-center">
                <div className="text-center">
                  <div className="text-4xl mb-4">🎥</div>
                  <p className="text-text-secondary mb-2">Media Preview</p>
                  <p className="text-text-tertiary text-sm">Click to view full media</p>
                  <button className="mt-4 bg-brand-primary text-text-inverse px-4 py-2 rounded-lg hover:bg-brand-primary-dark transition-colors">
                    View Media
                  </button>
                </div>
              </div>
              <div className="p-4 bg-dark-surface">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-text-tertiary">Media available</span>
                  <span className="text-brand-primary">{alert.mediaCount || 1} file{(alert.mediaCount || 1) > 1 ? 's' : ''}</span>
                </div>
              </div>
            </div>
          ) : (
            <div className="bg-dark-surface border border-dark-border rounded-lg p-8 text-center">
              <div className="text-6xl mb-4">📸</div>
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

            {/* Sighting Details */}
            <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h2 className="text-xl font-semibold text-text-primary mb-4">Sighting Details</h2>
              <div className="grid sm:grid-cols-3 gap-4 mb-6">
                <div>
                  <p className="text-text-tertiary text-sm">Duration</p>
                  <p className="text-text-primary font-medium">{alert.duration}</p>
                </div>
                <div>
                  <p className="text-text-tertiary text-sm">Distance</p>
                  <p className="text-text-primary font-medium">{alert.reporterDistance}</p>
                </div>
                <div>
                  <p className="text-text-tertiary text-sm">Est. Altitude</p>
                  <p className="text-text-primary font-medium">{alert.estimatedAltitude}</p>
                </div>
              </div>
              
              {alert.enrichment?.conventionalExplanation && (
                <div className="bg-semantic-info bg-opacity-10 border border-semantic-info border-opacity-20 rounded-lg p-4 mb-4">
                  <h3 className="text-semantic-info font-semibold mb-2 flex items-center gap-2">
                    ℹ️ Analysis Update
                  </h3>
                  <p className="text-text-secondary text-sm">
                    <strong>Possible explanation:</strong> {alert.enrichment.conventionalExplanation}
                  </p>
                </div>
              )}
            </section>

            {/* Environmental Data */}
            {(alert.weatherData || alert.celestialData) && (
              <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h2 className="text-xl font-semibold text-text-primary mb-4">Environmental Context</h2>
                
                {alert.weatherData && (
                  <div className="mb-6">
                    <h3 className="text-lg font-medium text-brand-primary mb-3 flex items-center gap-2">
                      🌤️ Weather Conditions
                    </h3>
                    <div className="grid sm:grid-cols-3 gap-4">
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
                      <div>
                        <p className="text-text-tertiary text-sm">Humidity</p>
                        <p className="text-text-primary">{alert.weatherData.humidity}</p>
                      </div>
                      <div>
                        <p className="text-text-tertiary text-sm">Pressure</p>
                        <p className="text-text-primary">{alert.weatherData.barometric}</p>
                      </div>
                    </div>
                    {alert.enrichment?.weatherImpact && (
                      <div className="mt-3 p-3 bg-dark-background rounded border border-dark-border">
                        <p className="text-text-tertiary text-sm">
                          <strong>Weather Impact:</strong> {alert.enrichment.weatherImpact}
                        </p>
                      </div>
                    )}
                  </div>
                )}

                {alert.celestialData && (
                  <div>
                    <h3 className="text-lg font-medium text-brand-primary mb-3 flex items-center gap-2">
                      🌙 Celestial Information
                    </h3>
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
                        <p className="text-text-tertiary text-sm mb-1">Visible Planets</p>
                        <p className="text-text-primary">{alert.celestialData.nearbyPlanets.join(', ')}</p>
                      </div>
                      {alert.celestialData.satellites && (
                        <div className="sm:col-span-2">
                          <p className="text-text-tertiary text-sm mb-1">Satellite Activity</p>
                          <p className="text-text-secondary text-sm">{alert.celestialData.satellites.join(', ')}</p>
                        </div>
                      )}
                    </div>
                  </div>
                )}
              </section>
            )}

            {/* Aircraft Analysis */}
            {alert.enrichment && (
              <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h2 className="text-xl font-semibold text-text-primary mb-4 flex items-center gap-2">
                  ✈️ Aircraft Analysis
                </h2>
                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <span className="text-text-secondary">Known aircraft in area</span>
                    <span className={`font-medium ${
                      alert.enrichment.noKnownAircraft 
                        ? 'text-semantic-warning' 
                        : 'text-semantic-success'
                    }`}>
                      {alert.enrichment.noKnownAircraft ? 'None detected' : 'Aircraft present'}
                    </span>
                  </div>
                  
                  {alert.enrichment.possibleAircraft && (
                    <div className="p-3 bg-semantic-info bg-opacity-10 border border-semantic-info border-opacity-20 rounded">
                      <p className="text-semantic-info text-sm">
                        <strong>Note:</strong> {alert.enrichment.possibleAircraft}
                      </p>
                    </div>
                  )}
                  
                  <div className="text-text-tertiary text-sm">
                    <p>✓ Flight tracking data checked</p>
                    <p>✓ Military activity database consulted</p>
                    <p>✓ Commercial flight paths analyzed</p>
                  </div>
                </div>
              </section>
            )}

            {/* Matrix Transcript */}
            <MatrixTranscript 
              messages={matrixData.messages}
              roomInfo={matrixData.roomInfo}
              hasMatrixRoom={matrixData.hasMatrixRoom}
              maxMessages={10}
            />
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
              
              <div className="grid grid-cols-2 gap-2 mt-4">
                <button className="bg-brand-primary text-text-inverse py-2 px-3 rounded text-sm font-medium hover:bg-brand-primary-dark transition-colors">
                  Directions
                </button>
                <button className="bg-dark-background border border-dark-border text-text-primary py-2 px-3 rounded text-sm hover:bg-dark-border-light transition-colors">
                  Compass
                </button>
              </div>
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

            {/* Enhanced Stats */}
            <section className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h3 className="text-lg font-semibold text-text-primary mb-4">Sighting Metrics</h3>
              <div className="space-y-4">
                <div className="flex justify-between items-center">
                  <span className="text-text-tertiary flex items-center gap-2">
                    <span>👀</span> Views
                  </span>
                  <span className="text-text-primary font-medium">1,247</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-text-tertiary flex items-center gap-2">
                    <span>👥</span> Witnesses
                  </span>
                  <span className="text-text-primary font-medium">{alert.witnessCount}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-text-tertiary flex items-center gap-2">
                    <span>📸</span> Media Files
                  </span>
                  <span className="text-text-primary font-medium">{alert.mediaCount || 0}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-text-tertiary flex items-center gap-2">
                    <span>💬</span> Chat Messages
                  </span>
                  <span className="text-text-primary font-medium">28</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-text-tertiary flex items-center gap-2">
                    <span>🛡️</span> Status
                  </span>
                  <span className={`font-medium ${
                    alert.verified 
                      ? 'text-semantic-success' 
                      : alert.enrichment?.conventionalExplanation
                      ? 'text-semantic-info'
                      : 'text-semantic-warning'
                  }`}>
                    {alert.verified 
                      ? 'Verified' 
                      : alert.enrichment?.conventionalExplanation
                      ? 'Explained'
                      : 'Under Review'
                    }
                  </span>
                </div>
                
                <div className="pt-3 border-t border-dark-border">
                  <div className="text-text-tertiary text-xs space-y-1">
                    <p>✓ Location verified</p>
                    <p>✓ Timestamp confirmed</p>
                    <p>✓ Cross-referenced with databases</p>
                    {alert.enrichment?.aircraftChecked && <p>✓ Aircraft data analyzed</p>}
                  </div>
                </div>
              </div>
            </section>
          </div>
        </div>
      </div>
    </main>
  )
}