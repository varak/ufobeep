'use client'

import Link from 'next/link'

export default function HowItWorks() {
  return (
    <main className="min-h-screen bg-dark-background">
      {/* Header */}
      <div className="bg-dark-surface border-b border-dark-border">
        <div className="max-w-6xl mx-auto px-6 py-6">
          <Link href="/" className="text-brand-primary hover:text-brand-primary-dark">
            ← Back to Home
          </Link>
        </div>
      </div>

      {/* Hero */}
      <section className="py-16 px-6 md:px-24">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-text-primary">
            How UFOBeep Works
          </h1>
          <p className="text-xl text-text-secondary">
            A deep dive into the technology, architecture, and algorithms that power real-time UFO sighting alerts
          </p>
        </div>
      </section>

      {/* The Concept */}
      <section className="py-12 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">The Concept</h2>
          <div className="bg-dark-surface p-8 rounded-lg border border-dark-border">
            <p className="text-text-secondary text-lg leading-relaxed mb-4">
              UFOBeep is a real-time alert network that notifies nearby users when someone reports a UFO sighting.
              Think of it as a &ldquo;NOW&rdquo; button for the sky - when something unexplained appears, witnesses can immediately
              alert others in a 50-mile radius to look up and verify.
            </p>
            <p className="text-text-secondary text-lg leading-relaxed">
              The key innovation is <strong className="text-brand-primary">immediate proximity alerts</strong>.
              Traditional UFO reporting happens hours or days after the fact. UFOBeep enables real-time community
              verification while the object is still visible.
            </p>
          </div>
        </div>
      </section>

      {/* How Alerts Work */}
      <section className="py-12 px-6 md:px-24 bg-dark-surface">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">How Alerts Work</h2>

          <div className="space-y-6">
            <div className="bg-dark-background p-6 rounded-lg border border-dark-border">
              <h3 className="text-xl font-semibold mb-3 text-text-primary flex items-center gap-2">
                <span className="text-2xl">📍</span>
                Step 1: Witness Reports a Sighting
              </h3>
              <p className="text-text-secondary">
                User opens the app, captures photo/video (optional), and hits &ldquo;Beep Now&rdquo;. The app records:
              </p>
              <ul className="list-disc list-inside text-text-secondary mt-2 space-y-1 ml-4">
                <li>GPS coordinates (latitude/longitude)</li>
                <li>Precise timestamp (UTC)</li>
                <li>Compass bearing and altitude</li>
                <li>Device sensors (if available)</li>
              </ul>
            </div>

            <div className="bg-dark-background p-6 rounded-lg border border-dark-border">
              <h3 className="text-xl font-semibold mb-3 text-text-primary flex items-center gap-2">
                <span className="text-2xl">🤖</span>
                Step 2: Automatic Enrichment
              </h3>
              <p className="text-text-secondary mb-3">
                Our backend immediately enriches the report with real-time environmental data:
              </p>
              <div className="grid sm:grid-cols-2 gap-3">
                <div className="bg-dark-surface p-4 rounded border border-dark-border">
                  <div className="font-semibold text-brand-primary mb-1">☁️ Weather</div>
                  <p className="text-sm text-text-secondary">Cloud cover, visibility, wind, temperature from OpenWeather API</p>
                </div>
                <div className="bg-dark-surface p-4 rounded border border-dark-border">
                  <div className="font-semibold text-brand-primary mb-1">✈️ Aircraft</div>
                  <p className="text-sm text-text-secondary">All planes in the sky from OpenSky Network</p>
                </div>
                <div className="bg-dark-surface p-4 rounded border border-dark-border">
                  <div className="font-semibold text-brand-primary mb-1">🛰️ Satellites</div>
                  <p className="text-sm text-text-secondary">Visible satellites from CelesTrak TLE data</p>
                </div>
                <div className="bg-dark-surface p-4 rounded border border-dark-border">
                  <div className="font-semibold text-brand-primary mb-1">🌙 Celestial</div>
                  <p className="text-sm text-text-secondary">Sun, moon, planets, bright stars positions</p>
                </div>
                <div className="bg-dark-surface p-4 rounded border border-dark-border">
                  <div className="font-semibold text-brand-primary mb-1">🤖 AI Analysis</div>
                  <p className="text-sm text-text-secondary">Gemini AI provides intelligent analysis and summaries of sighting reports for better understanding</p>
                </div>
              </div>
            </div>

            <div className="bg-dark-background p-6 rounded-lg border border-dark-border">
              <h3 className="text-xl font-semibold mb-3 text-text-primary flex items-center gap-2">
                <span className="text-2xl">🔔</span>
                Step 3: Push Notifications
              </h3>
              <p className="text-text-secondary mb-3">
                Firebase Cloud Messaging sends push notifications to all users within a 50-mile radius:
              </p>
              <div className="bg-dark-surface p-4 rounded border border-brand-primary">
                <p className="text-text-primary font-mono text-sm">
                  &ldquo;UFO Sighting Alert! 🛸<br/>
                  12.3 miles SW from you<br/>
                  Tap to view and verify&rdquo;
                </p>
              </div>
              <p className="text-text-secondary mt-3">
                Users can tap the notification to see the full details, photos, and join the live discussion.
              </p>
            </div>

            <div className="bg-dark-background p-6 rounded-lg border border-dark-border">
              <h3 className="text-xl font-semibold mb-3 text-text-primary flex items-center gap-2">
                <span className="text-2xl">👥</span>
                Step 4: Community Verification
              </h3>
              <p className="text-text-secondary">
                Multiple witnesses can confirm or provide additional details in real-time. The app shows:
              </p>
              <ul className="list-disc list-inside text-text-secondary mt-2 space-y-1 ml-4">
                <li>How many nearby users saw it</li>
                <li>Different photos/videos from multiple angles</li>
                <li>Live comment thread for discussion</li>
                <li>Distance and bearing from each witness</li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Tech Stack */}
      <section className="py-12 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">Technology Stack</h2>

          <div className="grid md:grid-cols-2 gap-6">
            {/* Mobile App */}
            <div className="bg-dark-surface p-6 rounded-lg border border-dark-border">
              <h3 className="text-xl font-semibold mb-4 text-text-primary">📱 Mobile App</h3>
              <ul className="space-y-2 text-text-secondary">
                <li><strong className="text-brand-primary">Flutter:</strong> Cross-platform (iOS & Android)</li>
                <li><strong className="text-brand-primary">Dart:</strong> Modern, fast, type-safe</li>
                <li><strong className="text-brand-primary">Riverpod:</strong> State management</li>
                <li><strong className="text-brand-primary">GoRouter:</strong> Navigation</li>
                <li><strong className="text-brand-primary">Dio:</strong> HTTP client</li>
                <li><strong className="text-brand-primary">Firebase Messaging:</strong> Push notifications</li>
                <li><strong className="text-brand-primary">Geolocator:</strong> GPS & location services</li>
                <li><strong className="text-brand-primary">Camera/ImagePicker:</strong> Media capture</li>
              </ul>
            </div>

            {/* Backend */}
            <div className="bg-dark-surface p-6 rounded-lg border border-dark-border">
              <h3 className="text-xl font-semibold mb-4 text-text-primary">⚙️ Backend API</h3>
              <ul className="space-y-2 text-text-secondary">
                <li><strong className="text-brand-primary">FastAPI:</strong> Python web framework</li>
                <li><strong className="text-brand-primary">PostgreSQL:</strong> Primary database</li>
                <li><strong className="text-brand-primary">PostGIS:</strong> Geospatial queries</li>
                <li><strong className="text-brand-primary">Firebase Admin:</strong> Push notification server</li>
                <li><strong className="text-brand-primary">MinIO:</strong> S3-compatible media storage</li>
                <li><strong className="text-brand-primary">Redis:</strong> Caching layer</li>
                <li><strong className="text-brand-primary">JWT:</strong> Authentication</li>
                <li><strong className="text-brand-primary">Nginx:</strong> Reverse proxy</li>
              </ul>
            </div>

            {/* Website */}
            <div className="bg-dark-surface p-6 rounded-lg border border-dark-border">
              <h3 className="text-xl font-semibold mb-4 text-text-primary">🌐 Website</h3>
              <ul className="space-y-2 text-text-secondary">
                <li><strong className="text-brand-primary">Next.js 14:</strong> React framework</li>
                <li><strong className="text-brand-primary">TypeScript:</strong> Type safety</li>
                <li><strong className="text-brand-primary">Tailwind CSS:</strong> Styling</li>
                <li><strong className="text-brand-primary">next-intl:</strong> 22 languages</li>
                <li><strong className="text-brand-primary">React Leaflet:</strong> Interactive maps</li>
              </ul>
            </div>

            {/* Data Sources */}
            <div className="bg-dark-surface p-6 rounded-lg border border-dark-border">
              <h3 className="text-xl font-semibold mb-4 text-text-primary">📊 Data Sources</h3>
              <ul className="space-y-2 text-text-secondary">
                <li><strong className="text-brand-primary">OpenWeather:</strong> Real-time weather</li>
                <li><strong className="text-brand-primary">OpenSky Network:</strong> Aircraft tracking</li>
                <li><strong className="text-brand-primary">CelesTrak:</strong> Satellite TLE data</li>
                <li><strong className="text-brand-primary">Skyfield:</strong> Celestial calculations</li>
                <li><strong className="text-brand-primary">Community:</strong> User-submitted sighting reports</li>
              </ul>
            </div>

            {/* Development */}
            <div className="bg-dark-surface p-6 rounded-lg border border-dark-border">
              <h3 className="text-xl font-semibold mb-4 text-text-primary">👨‍💻 Development</h3>
              <ul className="space-y-2 text-text-secondary">
                <li><strong className="text-brand-primary">Built by:</strong> <a href="mailto:mike@ufobeep.com" className="text-brand-primary hover:underline">Mike</a> (creator) with AI assistance</li>
                <li><strong className="text-brand-primary">Claude Code:</strong> Primary development AI</li>
                <li><strong className="text-brand-primary">ChatGPT:</strong> Mathematical analysis & consulting</li>
                <li><strong className="text-brand-primary">Gemini AI:</strong> In-app report summaries for brevity & readability</li>
                <li><strong className="text-brand-primary">Open Source:</strong> Full codebase on GitHub</li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Architecture */}
      <section className="py-12 px-6 md:px-24 bg-dark-surface">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">System Architecture</h2>

          <div className="bg-dark-background p-8 rounded-lg border border-dark-border">
            <pre className="text-sm text-text-secondary overflow-x-auto">
{`┌─────────────────┐
│  Mobile App     │
│  (Flutter)      │
└────────┬────────┘
         │ HTTPS/JWT
         ├─────────────────────┐
         │                     │
┌────────▼────────┐   ┌───────▼────────┐
│  FastAPI        │   │  Firebase      │
│  Backend        │   │  Cloud         │
│  (Python)       │   │  Messaging     │
└────────┬────────┘   └────────────────┘
         │
    ┌────┴────┐
    │         │
┌───▼──┐  ┌──▼───┐
│ Post │  │ MinIO│
│ greSQL  │  │ (S3) │
│+PostGIS│  └──────┘
└────────┘

External APIs:
├─ OpenWeather (weather data)
├─ OpenSky Network (aircraft)
├─ CelesTrak (satellites)
└─ Astronomical calculations (Skyfield)`}
            </pre>
          </div>

          <div className="mt-6 bg-dark-background p-6 rounded-lg border border-dark-border">
            <h3 className="text-lg font-semibold mb-3 text-text-primary">Key Design Decisions</h3>
            <ul className="space-y-3 text-text-secondary">
              <li>
                <strong className="text-brand-primary">PostGIS for geospatial queries:</strong> Efficiently finds all users within 50-mile radius using spatial indexes
              </li>
              <li>
                <strong className="text-brand-primary">Firebase for push notifications:</strong> Reliable delivery across iOS & Android with minimal setup
              </li>
              <li>
                <strong className="text-brand-primary">MinIO for media storage:</strong> S3-compatible, self-hosted, cost-effective for photos/videos
              </li>
              <li>
                <strong className="text-brand-primary">Real-time enrichment:</strong> All environmental data captured at exact moment of sighting, not retroactively
              </li>
            </ul>
          </div>
        </div>
      </section>

      {/* The Math */}
      <section className="py-12 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">Network Density & Coverage</h2>

          <div className="bg-dark-surface p-8 rounded-lg border border-dark-border">
            <p className="text-text-secondary text-lg mb-4">
              How many users does UFOBeep need for the network to be effective? We did the math.
            </p>
            <p className="text-text-secondary mb-6">
              Using Poisson distribution and real US population density data, we calculated the minimum number
              of users needed for reliable proximity alerts. The analysis accounts for urban clustering,
              notification reach rates, and the 50-mile alert radius.
            </p>
            <Link
              href="/the-math"
              className="inline-block bg-brand-primary text-text-inverse px-6 py-3 rounded-lg font-semibold hover:bg-brand-primary-dark transition-all"
            >
              Read the Full Mathematical Analysis →
            </Link>
          </div>
        </div>
      </section>

      {/* Open Source */}
      <section className="py-12 px-6 md:px-24 bg-dark-surface">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">Open Source</h2>

          <div className="bg-dark-background p-8 rounded-lg border border-dark-border">
            <p className="text-text-secondary text-lg mb-4">
              UFOBeep is open source and available on GitHub. The entire codebase - mobile app, backend API,
              website, and data processing scripts - is publicly available.
            </p>
            <a
              href="https://github.com/varak/ufobeep"
              className="inline-block bg-dark-surface text-brand-primary px-6 py-3 rounded-lg font-semibold hover:bg-dark-border transition-all border border-dark-border"
              target="_blank"
              rel="noopener noreferrer"
            >
              View on GitHub →
            </a>
          </div>
        </div>
      </section>

      {/* Footer Navigation */}
      <section className="py-12 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <div className="bg-dark-surface p-6 rounded-lg border border-dark-border">
            <h3 className="text-lg font-semibold mb-4 text-text-primary">Learn More</h3>
            <div className="flex flex-wrap gap-4">
              <Link href="/the-math" className="text-brand-primary hover:underline">
                The Math: Network Coverage Analysis →
              </Link>
              <Link href="/faq" className="text-brand-primary hover:underline">
                Frequently Asked Questions →
              </Link>
              <Link href="/" className="text-brand-primary hover:underline">
                Back to Home →
              </Link>
            </div>
          </div>
        </div>
      </section>
    </main>
  )
}
