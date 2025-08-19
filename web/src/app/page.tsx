import Link from 'next/link'
import AppDownloadCTA from '@/components/AppDownloadCTA'
import GlobalSightingNetwork from '@/components/GlobalSightingNetwork'
import ShareToBeepPromo from '@/components/ShareToBeepPromo'

export default function Home() {
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
            Real-time UFO and anomaly sighting alerts
          </p>
          <p className="text-lg text-text-tertiary mb-12 max-w-2xl mx-auto">
            Join a global network of observers. Report sightings, get instant alerts, 
            and chat with witnesses in real-time using assisted navigation.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 items-center justify-center mb-16">
            <Link href="/download">
              <button className="bg-brand-primary text-text-inverse px-8 py-4 rounded-lg font-semibold hover:bg-brand-primary-dark transition-all duration-300 shadow-glow hover:shadow-xl hover:scale-105 transform">
                📱 Download App
              </button>
            </Link>
            <Link href="/alerts">
              <button className="border border-brand-primary text-brand-primary px-8 py-4 rounded-lg font-semibold hover:bg-brand-primary hover:text-text-inverse transition-all duration-300 hover:scale-105 transform">
                View Recent Alerts
              </button>
            </Link>
          </div>
          
          {/* Content navigation links */}
          <div className="flex flex-col sm:flex-row justify-center items-center gap-4 sm:gap-8 text-sm">
            <a href="#global-network" className="text-brand-primary hover:text-brand-primary-light transition-colors font-medium">
              Global Sighting Network
            </a>
            <span className="text-text-tertiary hidden sm:inline">|</span>
            <a href="#how-it-works" className="text-brand-primary hover:text-brand-primary-light transition-colors font-medium">
              How UFOBeep Works
            </a>
            <span className="text-text-tertiary hidden sm:inline">|</span>
            <a href="#share-to-beep" className="text-brand-primary hover:text-brand-primary-light transition-colors font-medium">
              Share-to-Beep
            </a>
          </div>
        </div>
      </section>

      {/* Live Map Section */}
      <div id="global-network">
        <GlobalSightingNetwork />
      </div>

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

      {/* Share-to-Beep Promotion */}
      <div id="share-to-beep">
        <ShareToBeepPromo />
      </div>

      {/* Community Section */}
      <section className="py-20 px-6 md:px-24">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-3xl md:text-4xl font-bold mb-8 text-text-primary">
            Join the Community
          </h2>
          <p className="text-lg text-text-secondary mb-12">
            Connect with thousands of observers worldwide through real-time chat, 
            share experiences, and help verify sightings through community moderation.
          </p>
          <div className="grid sm:grid-cols-2 gap-6 mb-12">
            <div className="bg-dark-surface p-6 rounded-lg border border-dark-border hover:border-brand-primary transition-colors group">
              <div className="text-3xl mb-4 group-hover:scale-110 transition-transform">💬</div>
              <h3 className="text-lg font-semibold mb-2 text-brand-primary">Real-time Chat</h3>
              <p className="text-text-secondary">
                Each sighting gets its own chat room powered by Matrix protocol 
                for secure, decentralized communication.
              </p>
            </div>
            <div className="bg-dark-surface p-6 rounded-lg border border-dark-border hover:border-brand-primary transition-colors group">
              <div className="text-3xl mb-4 group-hover:scale-110 transition-transform">🔬</div>
              <h3 className="text-lg font-semibold mb-2 text-brand-primary">Smart Enrichment</h3>
              <p className="text-text-secondary">
                Automatic weather, celestial, and satellite data enrichment 
                helps identify conventional explanations.
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
                <li><a href="/alerts" className="hover:text-brand-primary transition-colors">Recent Alerts</a></li>
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
          <div className="border-t border-dark-border mt-8 pt-8 text-center text-sm text-text-tertiary">
            <p>&copy; 2024 UFOBeep. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </main>
  )
}