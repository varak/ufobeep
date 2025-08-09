import Link from 'next/link'
import MiniMap from '@/components/MiniMap'
import AppDownloadCTA from '@/components/AppDownloadCTA'

export default function Home() {
  return (
    <main className="min-h-screen">
      {/* Hero Section */}
      <section className="flex min-h-screen flex-col items-center justify-center p-6 md:p-24">
        <div className="text-center max-w-4xl mx-auto">
          <div className="text-6xl md:text-8xl mb-8 animate-pulse">👽</div>
          <h1 className="text-4xl md:text-6xl font-bold mb-6 text-text-primary">
            UFOBeep
          </h1>
          <p className="text-xl md:text-2xl text-text-secondary mb-4">
            Real-time UFO and anomaly sighting alerts
          </p>
          <p className="text-lg text-text-tertiary mb-12 max-w-2xl mx-auto">
            Join a global network of observers. Report sightings, get instant alerts, 
            and chat with witnesses in real-time using AR navigation.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 items-center justify-center mb-16">
            <Link href="/app">
              <button className="bg-brand-primary text-text-inverse px-8 py-4 rounded-lg font-semibold hover:bg-brand-primary-dark transition-all duration-300 shadow-glow hover:shadow-xl hover:scale-105 transform">
                Download App
              </button>
            </Link>
            <button className="border border-brand-primary text-brand-primary px-8 py-4 rounded-lg font-semibold hover:bg-brand-primary hover:text-text-inverse transition-all duration-300 hover:scale-105 transform">
              View Live Map
            </button>
          </div>
          
          {/* Trust indicators */}
          <div className="flex flex-col sm:flex-row justify-center items-center gap-4 sm:gap-8 text-sm text-text-tertiary">
            <div className="flex items-center gap-2">
              <span className="text-brand-primary">✓</span>
              <span className="whitespace-nowrap">15,000+ Active Users</span>
            </div>
            <div className="flex items-center gap-2">
              <span className="text-brand-primary">✓</span>
              <span className="whitespace-nowrap">Real-time Global Network</span>
            </div>
            <div className="flex items-center gap-2">
              <span className="text-brand-primary">✓</span>
              <span className="whitespace-nowrap">Privacy-First Design</span>
            </div>
          </div>
        </div>
      </section>

      {/* Live Map Section */}
      <section className="py-20 px-6 md:px-24 bg-dark-background">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl font-bold mb-6 text-text-primary">
              Global Sighting Network
            </h2>
            <p className="text-lg text-text-secondary max-w-3xl mx-auto">
              Explore real-time reports from observers around the world. Each pin represents a verified 
              sighting with community discussion, enrichment data, and navigation assistance.
            </p>
          </div>
          
          <div className="grid lg:grid-cols-3 gap-8 items-start">
            {/* Mini Map - takes up 2/3 on desktop */}
            <div className="lg:col-span-2">
              <MiniMap className="w-full" />
            </div>
            
            {/* Recent Activity Sidebar */}
            <div className="space-y-4">
              <h3 className="text-xl font-semibold text-text-primary mb-4">Latest Activity</h3>
              
              <div className="space-y-3">
                <div className="p-4 bg-dark-surface rounded-lg border border-dark-border hover:border-brand-primary transition-colors">
                  <div className="flex items-start justify-between">
                    <div>
                      <h4 className="font-medium text-text-primary text-sm">Triangle Formation</h4>
                      <p className="text-text-secondary text-xs mt-1">Phoenix, AZ</p>
                      <div className="flex items-center gap-2 mt-2">
                        <span className="text-brand-primary text-xs">⚡ Live Chat Active</span>
                        <span className="text-text-tertiary text-xs">•</span>
                        <span className="text-text-tertiary text-xs">12 min ago</span>
                      </div>
                    </div>
                    <div className="w-2 h-2 bg-brand-primary rounded-full animate-pulse"></div>
                  </div>
                </div>
                
                <div className="p-4 bg-dark-surface rounded-lg border border-dark-border hover:border-brand-primary transition-colors">
                  <div className="flex items-start justify-between">
                    <div>
                      <h4 className="font-medium text-text-primary text-sm">Bright Flash</h4>
                      <p className="text-text-secondary text-xs mt-1">London, UK</p>
                      <div className="flex items-center gap-2 mt-2">
                        <span className="text-semantic-warning text-xs">📊 Analyzing</span>
                        <span className="text-text-tertiary text-xs">•</span>
                        <span className="text-text-tertiary text-xs">1h ago</span>
                      </div>
                    </div>
                  </div>
                </div>
                
                <div className="p-4 bg-dark-surface rounded-lg border border-dark-border hover:border-brand-primary transition-colors">
                  <div className="flex items-start justify-between">
                    <div>
                      <h4 className="font-medium text-text-primary text-sm">Silent Object</h4>
                      <p className="text-text-secondary text-xs mt-1">Tokyo, Japan</p>
                      <div className="flex items-center gap-2 mt-2">
                        <span className="text-semantic-info text-xs">✓ Verified</span>
                        <span className="text-text-tertiary text-xs">•</span>
                        <span className="text-text-tertiary text-xs">3h ago</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              
              <Link href="/alerts">
                <button className="w-full mt-4 p-3 border border-brand-primary text-brand-primary rounded-lg hover:bg-brand-primary hover:text-text-inverse transition-colors font-medium">
                  View All Reports →
                </button>
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 px-6 md:px-24 bg-dark-surface">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-3xl md:text-4xl font-bold text-center mb-16 text-text-primary">
            How UFOBeep Works
          </h2>
          <div className="grid md:grid-cols-3 gap-8">
            <div className="text-center p-6">
              <div className="text-4xl mb-4">📸</div>
              <h3 className="text-xl font-semibold mb-4 text-text-primary">Beep & Report</h3>
              <p className="text-text-secondary">
                Capture photos or videos of unusual sightings and instantly share them 
                with the community for verification and discussion.
              </p>
            </div>
            <div className="text-center p-6">
              <div className="text-4xl mb-4">🔔</div>
              <h3 className="text-xl font-semibold mb-4 text-text-primary">Get Alerts</h3>
              <p className="text-text-secondary">
                Receive real-time notifications about sightings near you, including 
                weather data, celestial information, and satellite tracking.
              </p>
            </div>
            <div className="text-center p-6">
              <div className="text-4xl mb-4">🧭</div>
              <h3 className="text-xl font-semibold mb-4 text-text-primary">Navigate with AR</h3>
              <p className="text-text-secondary">
                Use our advanced AR compass to navigate to sighting locations with 
                Standard and Pilot modes for precise vectoring.
              </p>
            </div>
          </div>
        </div>
      </section>

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
                <li><a href="#" className="hover:text-brand-primary transition-colors">GitHub</a></li>
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