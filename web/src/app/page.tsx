'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { useClientTranslations } from '@/hooks/useClientTranslations'
import AppDownloadCTA from '@/components/AppDownloadCTA'

export default function Home() {
  const pathname = usePathname()
  
  // Detect locale from browser settings with fallback
  const getBrowserLocale = () => {
    if (typeof window === 'undefined') return 'en'
    
    // Check localStorage preference first
    const storedLocale = localStorage.getItem('preferred-language')
    if (storedLocale) {
      const validLocales = ['en', 'es', 'de', 'fr', 'pt', 'ru', 'ja', 'zh', 'it', 'ar', 'ko', 'tr', 'hi', 'pl', 'cs', 'nl', 'sv', 'da', 'no', 'fi', 'el', 'he']
      if (validLocales.includes(storedLocale)) return storedLocale
    }
    
    // Detect from browser
    const browserLang = navigator.language.split('-')[0].toLowerCase()
    const validLocales = ['en', 'es', 'de', 'fr', 'pt', 'ru', 'ja', 'zh', 'it', 'ar', 'ko', 'tr', 'hi', 'pl', 'cs', 'nl', 'sv', 'da', 'no', 'fi', 'el', 'he']
    return validLocales.includes(browserLang) ? browserLang : 'en'
  }
  
  const locale = getBrowserLocale()
  const { t } = useClientTranslations('common', locale)
  
  return (
    <main className="min-h-screen">
      {/* Hero Section */}
      <section className="flex min-h-screen flex-col items-center justify-center p-6 md:p-24">
        <div className="text-center max-w-4xl mx-auto">
          <div className="text-6xl md:text-8xl mb-8 animate-pulse">🛸</div>
          <h1 className="text-4xl md:text-6xl font-bold mb-6 text-text-primary">
            UFOBeep
          </h1>
          <p className="text-xl md:text-2xl text-text-secondary mb-4">
            {t('heroMainTagline')}
          </p>
          <p className="text-lg text-text-tertiary mb-12 max-w-2xl mx-auto">
            Never miss another UFO sighting in your area.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 items-center justify-center mb-16">
            <Link href="/download">
              <button className="bg-brand-primary text-text-inverse px-8 py-4 rounded-lg font-semibold hover:bg-brand-primary-dark transition-all duration-300 shadow-glow hover:shadow-xl hover:scale-105 transform">
                {t('downloadApp')}
              </button>
            </Link>
            <Link href="/beep">
              <button className="border border-brand-primary text-brand-primary px-8 py-4 rounded-lg font-semibold hover:bg-brand-primary hover:text-text-inverse transition-all duration-300 hover:scale-105 transform">
                {t('viewAllBeeps')}
              </button>
            </Link>
          </div>

          {/* Content navigation links */}
          <div className="flex flex-col sm:flex-row justify-center items-center gap-4 sm:gap-8 text-sm">
            <a href="#trailer" className="text-brand-primary hover:text-brand-primary-light transition-colors font-medium">
              Watch the Trailer
            </a>
            <a href="#how-it-works" className="text-brand-primary hover:text-brand-primary-light transition-colors font-medium">
              {t('howItWorks')}
            </a>
          </div>
        </div>
      </section>

      {/* Trailer Section */}
      <section id="trailer" className="py-20 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <div className="text-center mb-8">
            <h2 className="text-3xl md:text-4xl font-bold mb-4 text-text-primary">
              See UFOBeep in Action
            </h2>
            <p className="text-lg text-text-secondary">
              13 seconds that explain everything
            </p>
          </div>

          <div className="bg-dark-surface rounded-lg border border-brand-primary overflow-hidden shadow-glow">
            <video
              controls
              autoPlay
              loop
              muted
              playsInline
              className="w-full"
            >
              <source src="/trailer.mp4" type="video/mp4" />
              Your browser does not support the video tag.
            </video>
          </div>

          <div className="text-center mt-6">
            <Link
              href="/download"
              className="inline-block bg-brand-primary text-text-inverse px-8 py-4 rounded-lg font-semibold hover:bg-brand-primary-dark transition-all shadow-glow hover:shadow-xl hover:scale-105 transform"
            >
              Download UFOBeep Now
            </Link>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="how-it-works" className="py-20 px-6 md:px-24 bg-dark-surface">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-3xl md:text-4xl font-bold text-center mb-16 text-text-primary">
            How UFOBeep Works
          </h2>
          <div className="grid md:grid-cols-3 gap-8">
            <div className="text-center p-6">
              <div className="text-4xl mb-4">👀</div>
              <h3 className="text-xl font-semibold mb-4 text-text-primary">See Something? Beep It!</h3>
              <p className="text-text-secondary">
                Spot something unusual in the sky? Instantly alert everyone nearby to
                look up and see it too! Share photos/videos and get others looking
                at the same phenomenon in real-time.
              </p>
            </div>
            <div className="text-center p-6">
              <div className="text-4xl mb-4">🚨</div>
              <h3 className="text-xl font-semibold mb-4 text-text-primary">Drop Everything & Look Up!</h3>
              <p className="text-text-secondary">
                Get instant alerts when someone near you sees something weird in the sky.
                &quot;LOOK UP NOW!&quot; notifications help you catch sightings as they happen
                instead of hearing about them hours later.
              </p>
            </div>
            <div className="text-center p-6">
              <div className="text-4xl mb-4">🔬</div>
              <h3 className="text-xl font-semibold mb-4 text-text-primary">Automatic Data Capture</h3>
              <p className="text-text-secondary">
                Every beep automatically records weather conditions, aircraft positions,
                satellite tracking, and celestial objects at the exact moment of the sighting.
                No manual entry - just instant scientific context.
              </p>
            </div>
          </div>

          {/* Link to detailed page */}
          <div className="text-center mt-12">
            <Link
              href="/how-it-works"
              className="inline-block text-brand-primary hover:text-brand-primary-light font-semibold text-lg transition-colors"
            >
              Read the full technical deep-dive →
            </Link>
          </div>
        </div>
      </section>

      {/* Live Enrichment Section */}
      <section className="py-20 px-6 md:px-24">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-3xl md:text-4xl font-bold text-center mb-8 text-text-primary">
            Real-Time Sighting Enrichment
          </h2>
          <p className="text-lg text-text-secondary text-center mb-12 max-w-3xl mx-auto">
            When a live sighting happens, UFOBeep instantly captures comprehensive environmental
            data to help verify and understand what&apos;s being observed. Every beep is automatically
            enriched with scientific context at the exact moment of the sighting.
          </p>
          <div className="grid md:grid-cols-2 gap-8">
            <div className="bg-dark-surface p-8 rounded-lg border border-dark-border">
              <div className="flex items-start gap-4">
                <div className="text-3xl">☁️</div>
                <div>
                  <h3 className="text-xl font-semibold mb-3 text-brand-primary">Weather Conditions</h3>
                  <p className="text-text-secondary mb-3">
                    Exact atmospheric conditions captured in real-time: cloud cover, visibility,
                    temperature, wind speed, and precipitation. Helps rule out weather phenomena
                    and validates witness observations.
                  </p>
                </div>
              </div>
            </div>
            <div className="bg-dark-surface p-8 rounded-lg border border-dark-border">
              <div className="flex items-start gap-4">
                <div className="text-3xl">✈️</div>
                <div>
                  <h3 className="text-xl font-semibold mb-3 text-brand-primary">Aircraft & Satellites</h3>
                  <p className="text-text-secondary mb-3">
                    Real-time tracking of all aircraft and satellites in the sky above the sighting
                    location. Automatically identifies and filters known objects to focus on
                    truly unidentified phenomena.
                  </p>
                </div>
              </div>
            </div>
            <div className="bg-dark-surface p-8 rounded-lg border border-dark-border">
              <div className="flex items-start gap-4">
                <div className="text-3xl">🌙</div>
                <div>
                  <h3 className="text-xl font-semibold mb-3 text-brand-primary">Celestial Objects</h3>
                  <p className="text-text-secondary mb-3">
                    Positions of the sun, moon, planets, and bright stars at the exact time and
                    location. Rules out astronomical objects and provides context for what should
                    naturally be visible in that part of the sky.
                  </p>
                </div>
              </div>
            </div>
            <div className="bg-dark-surface p-8 rounded-lg border border-dark-border">
              <div className="flex items-start gap-4">
                <div className="text-3xl">📍</div>
                <div>
                  <h3 className="text-xl font-semibold mb-3 text-brand-primary">Precise Location & Time</h3>
                  <p className="text-text-secondary mb-3">
                    GPS coordinates, altitude, compass bearing, and exact timestamp. Enables
                    multiple witnesses to correlate their observations and verify they saw
                    the same object from different vantage points.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>


      {/* Data & Community Section */}
      <section className="py-20 px-6 md:px-24">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-3xl md:text-4xl font-bold mb-8 text-text-primary">
            Real-Time Community UFO Alerts
          </h2>
          <p className="text-lg text-text-secondary mb-12">
            UFOBeep empowers citizen scientists to document and share UFO sightings as they happen.
            Our platform enables instant community alerts when someone near you witnesses something unusual
            in the sky, creating a global network of real-time observers. Share your sightings, collaborate
            with other witnesses, and access automatic scientific context for every reported phenomenon.
          </p>
          <div className="grid sm:grid-cols-3 gap-6 mb-12">
            <div className="bg-dark-surface p-6 rounded-lg border border-dark-border hover:border-brand-primary transition-colors group">
              <div className="text-3xl mb-4 group-hover:scale-110 transition-transform">🛸</div>
              <h3 className="text-lg font-semibold mb-2 text-brand-primary">Community Reports</h3>
              <p className="text-text-secondary">
                Browse and analyze UFO sighting reports from our growing community of observers.
                Each report includes enriched environmental data and witness testimony to help
                identify patterns and understand unexplained aerial phenomena.
              </p>
            </div>
            <div className="bg-dark-surface p-6 rounded-lg border border-dark-border hover:border-brand-primary transition-colors group">
              <div className="text-3xl mb-4 group-hover:scale-110 transition-transform">💬</div>
              <h3 className="text-lg font-semibold mb-2 text-brand-primary">Live Community</h3>
              <p className="text-text-secondary">
                Join real-time discussions with witnesses worldwide. Each sighting has live comment
                threads with auto-refresh updates and threaded conversations for collaborative analysis.
              </p>
            </div>
            <div className="bg-dark-surface p-6 rounded-lg border border-dark-border hover:border-brand-primary transition-colors group">
              <div className="text-3xl mb-4 group-hover:scale-110 transition-transform">🔬</div>
              <h3 className="text-lg font-semibold mb-2 text-brand-primary">Smart Data Capture</h3>
              <p className="text-text-secondary">
                Every sighting automatically records environmental context: weather conditions,
                celestial object positions, aircraft traffic, and visible satellites at the exact
                time and location for scientific analysis.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Enhanced Download CTA */}
      <AppDownloadCTA />

      {/* Footer */}
      <footer className="bg-dark-surface border-t border-dark-border py-12 px-6 md:px-24">
        <div className="max-w-6xl mx-auto">
          <div className="grid md:grid-cols-5 gap-8">
            <div>
              <h4 className="text-lg font-semibold mb-4 text-brand-primary">UFOBeep</h4>
              <p className="text-text-secondary text-sm">
                Real-time sighting alerts and community verification platform.
              </p>
            </div>
            <div>
              <h5 className="font-semibold mb-4 text-text-primary">Product</h5>
              <ul className="space-y-2 text-sm text-text-secondary">
                <li><Link href="/download" className="hover:text-brand-primary transition-colors">Download</Link></li>
                <li><Link href="#how-it-works" className="hover:text-brand-primary transition-colors">Features</Link></li>
                <li><a href="/beep" className="hover:text-brand-primary transition-colors">Recent Alerts</a></li>
              </ul>
            </div>
            <div>
              <h5 className="font-semibold mb-4 text-text-primary">Learn</h5>
              <ul className="space-y-2 text-sm text-text-secondary">
                <li><Link href="/how-it-works" className="hover:text-brand-primary transition-colors">How It Works</Link></li>
                <li><Link href="/the-math" className="hover:text-brand-primary transition-colors">The Math</Link></li>
                <li><Link href="/faq" className="hover:text-brand-primary transition-colors">FAQ</Link></li>
              </ul>
            </div>
            <div>
              <h5 className="font-semibold mb-4 text-text-primary">Legal</h5>
              <ul className="space-y-2 text-sm text-text-secondary">
                <li><Link href="/privacy" className="hover:text-brand-primary transition-colors">Privacy Policy</Link></li>
                <li><Link href="/terms" className="hover:text-brand-primary transition-colors">Terms of Service</Link></li>
                <li><Link href="/safety" className="hover:text-brand-primary transition-colors">Safety Guidelines</Link></li>
              </ul>
            </div>
            <div>
              <h5 className="font-semibold mb-4 text-text-primary">Community</h5>
              <ul className="space-y-2 text-sm text-text-secondary">
                <li><a href="https://github.com/varak/ufobeep" className="hover:text-brand-primary transition-colors">GitHub</a></li>
                <li><a href="mailto:support@ufobeep.com" className="hover:text-brand-primary transition-colors">Contact</a></li>
              </ul>
            </div>
          </div>

          {/* Developers Section - Off main scroll */}
          <div className="border-t border-dark-border mt-8 pt-8">
            <div className="grid md:grid-cols-2 gap-8">
              <div>
                <h5 className="font-semibold mb-4 text-text-primary flex items-center">
                  🤖 For AI Researchers
                </h5>
                <p className="text-text-secondary text-sm mb-3">
                  Access UFOBeep&apos;s database through our MCP server for AI analysis and pattern recognition.
                </p>
                <div className="space-y-1 text-xs text-text-tertiary">
                  <p><strong>Search endpoint:</strong> <code className="bg-dark-surface px-2 py-1 rounded">https://ufobeep.com/api/mcp/search</code></p>
                  <p><strong>Database stats:</strong> <code className="bg-dark-surface px-2 py-1 rounded">https://ufobeep.com/api/mcp/stats</code></p>
                </div>
                <a
                  href="https://github.com/varak/ufobeep/blob/main/docs/MCP_SERVER.md"
                  className="inline-block mt-3 text-blue-400 hover:text-blue-300 text-sm"
                >
                  View MCP Documentation →
                </a>
              </div>
              <div>
                <h5 className="font-semibold mb-4 text-text-primary">Example AI Queries</h5>
                <ul className="space-y-1 text-xs text-text-secondary">
                  <li>• &quot;Find UFO sightings near Area 51&quot;</li>
                  <li>• &quot;Show triangular UFOs in Nevada&quot;</li>
                  <li>• &quot;Analyze sighting patterns during clear weather&quot;</li>
                  <li>• &quot;UFO activity in the last 48 hours&quot;</li>
                </ul>
              </div>
            </div>
          </div>

          <div className="border-t border-dark-border mt-8 pt-8 text-center text-sm text-text-tertiary">
            <p>&copy; 2025 UFOBeep. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </main>
  )
}