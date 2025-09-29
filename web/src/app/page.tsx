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
            {t('heroTagline')}
          </p>
          <p className="text-lg text-text-tertiary mb-12 max-w-2xl mx-auto">
            {t('heroDescription')}
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
            <a href="#how-it-works" className="text-brand-primary hover:text-brand-primary-light transition-colors font-medium">
              {t('howItWorks')}
            </a>
            <span className="text-text-tertiary hidden sm:inline">|</span>
            <a href="#share-to-beep" className="text-brand-primary hover:text-brand-primary-light transition-colors font-medium">
              Share-to-Beep
            </a>
          </div>
        </div>
      </section>

      {/* Latest Updates Section */}
      <section className="py-16 px-6 md:px-24 bg-dark-surface border-t border-dark-border">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-2xl md:text-3xl font-bold mb-8 text-text-primary">
            🚀 Latest Updates (September 2025)
          </h2>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
            <div className="bg-dark-background p-4 rounded-lg border border-brand-primary/20">
              <div className="text-2xl mb-2">📸</div>
              <h3 className="text-sm font-semibold mb-2 text-brand-primary">Media Upload Complete</h3>
              <p className="text-xs text-text-secondary">
                Single-press photo/video upload with progress indicators and seamless UX
              </p>
            </div>
            <div className="bg-dark-background p-4 rounded-lg border border-brand-primary/20">
              <div className="text-2xl mb-2">🛸</div>
              <h3 className="text-sm font-semibold mb-2 text-brand-primary">MUFON Integration</h3>
              <p className="text-xs text-text-secondary">
                Professional UFO reports from MUFON database with media and enrichment data
              </p>
            </div>
            <div className="bg-dark-background p-4 rounded-lg border border-brand-primary/20">
              <div className="text-2xl mb-2">⚡</div>
              <h3 className="text-sm font-semibold mb-2 text-brand-primary">Performance Optimized</h3>
              <p className="text-xs text-text-secondary">
                Faster map loading, optimized imports, and streamlined user flows
              </p>
            </div>
          </div>
          <p className="text-sm text-brand-primary font-medium">
            Build 100 now available with complete media upload feature!
          </p>
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
              <div className="text-4xl mb-4">🧭</div>
              <h3 className="text-xl font-semibold mb-4 text-text-primary">Find It In The Sky</h3>
              <p className="text-text-secondary">
                Point your phone toward the sighting and our compass shows you exactly 
                where to look. No more &quot;it was over there somewhere&quot; - get precise 
                direction to spot what others are seeing.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Share-to-Beep Feature Info */}
      <section id="share-to-beep" className="py-20 px-6 md:px-24 bg-dark-surface">
        <div className="max-w-6xl mx-auto text-center">
          <h2 className="text-3xl md:text-4xl font-bold mb-6 text-text-primary">
            Share-to-Beep: Mobile Feature
          </h2>
          <p className="text-lg text-text-secondary mb-8 max-w-3xl mx-auto">
            Got a great photo or video on your phone? Share it directly to UFOBeep from any app! 
            This premium mobile feature makes reporting sightings incredibly easy.
          </p>
          <div className="flex justify-center items-center gap-2 text-brand-primary mb-8">
            <span className="text-2xl">✨</span>
            <span className="font-semibold">Record natively → Share to beep → Instant alert</span>
            <span className="text-2xl">✨</span>
          </div>
          <Link href="/app">
            <button className="bg-brand-primary text-text-inverse px-8 py-4 rounded-lg font-semibold hover:bg-brand-primary-dark transition-all duration-300 shadow-glow hover:shadow-xl hover:scale-105 transform">
              📱 Download to Try Share-to-Beep
            </button>
          </Link>
        </div>
      </section>

      {/* Community Section */}
      <section className="py-20 px-6 md:px-24">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-3xl md:text-4xl font-bold mb-8 text-text-primary">
            Join the Community
          </h2>
          <p className="text-lg text-text-secondary mb-12">
            Connect with observers worldwide through real-time comments, professional MUFON reports, 
            and community verification. Access both user submissions and verified MUFON database cases.
          </p>
          <div className="grid sm:grid-cols-3 gap-6 mb-12">
            <div className="bg-dark-surface p-6 rounded-lg border border-dark-border hover:border-brand-primary transition-colors group">
              <div className="text-3xl mb-4 group-hover:scale-110 transition-transform">🛸</div>
              <h3 className="text-lg font-semibold mb-2 text-brand-primary">MUFON Database</h3>
              <p className="text-text-secondary">
                Professional UFO reports from MUFON&apos;s verified database with detailed 
                case studies, witness accounts, and investigation findings.
              </p>
            </div>
            <div className="bg-dark-surface p-6 rounded-lg border border-dark-border hover:border-brand-primary transition-colors group">
              <div className="text-3xl mb-4 group-hover:scale-110 transition-transform">💬</div>
              <h3 className="text-lg font-semibold mb-2 text-brand-primary">Real-time Comments</h3>
              <p className="text-text-secondary">
                Each sighting has live comment threads with auto-refresh updates 
                and threaded discussions for community analysis.
              </p>
            </div>
            <div className="bg-dark-surface p-6 rounded-lg border border-dark-border hover:border-brand-primary transition-colors group">
              <div className="text-3xl mb-4 group-hover:scale-110 transition-transform">🔬</div>
              <h3 className="text-lg font-semibold mb-2 text-brand-primary">Smart Enrichment</h3>
              <p className="text-text-secondary">
                Automatic weather, celestial, aircraft, and satellite data enrichment 
                plus premium imagery from BlackSky and SkyFi.
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
          <div className="grid md:grid-cols-4 gap-8">
            <div>
              <h4 className="text-lg font-semibold mb-4 text-brand-primary">UFOBeep</h4>
              <p className="text-text-secondary text-sm">
                Real-time sighting alerts and community verification platform.
              </p>
            </div>
            <div>
              <h5 className="font-semibold mb-4 text-text-primary">Product</h5>
              <ul className="space-y-2 text-sm text-text-secondary">
                <li><Link href="/app" className="hover:text-brand-primary transition-colors">Download</Link></li>
                <li><Link href="#features" className="hover:text-brand-primary transition-colors">Features</Link></li>
                <li><a href="/beep" className="hover:text-brand-primary transition-colors">Recent Alerts</a></li>
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
                <li><a href="#" className="hover:text-brand-primary transition-colors">Discord</a></li>
                <li><a href="https://github.com/varak/ufobeep" className="hover:text-brand-primary transition-colors">GitHub</a></li>
                <li><a href="#" className="hover:text-brand-primary transition-colors">Support</a></li>
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
                  <p><strong>Search endpoint:</strong> <code className="bg-dark-surface px-2 py-1 rounded">http://ufobeep.com:8000/mcp/search</code></p>
                  <p><strong>Database stats:</strong> <code className="bg-dark-surface px-2 py-1 rounded">http://ufobeep.com:8000/mcp/stats</code></p>
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

          <div className="grid md:grid-cols-4 gap-8">
          </div>
          <div className="border-t border-dark-border mt-8 pt-8 text-center text-sm text-text-tertiary">
            <p>&copy; 2024 UFOBeep. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </main>
  )
}