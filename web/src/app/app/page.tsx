import Link from 'next/link'

export default function AppPage() {
  return (
    <main className="min-h-screen py-8 px-4 md:px-8">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="text-center mb-12">
          <Link 
            href="/" 
            className="text-brand-primary hover:text-brand-primary-light transition-colors mb-4 inline-block"
          >
            ← Back to Home
          </Link>
          
          <div className="text-6xl mb-6">📱</div>
          <h1 className="text-4xl md:text-5xl font-bold text-text-primary mb-4">
            Download UFOBeep
          </h1>
          <p className="text-xl text-text-secondary max-w-2xl mx-auto">
            Get the mobile app to report sightings, receive alerts, and navigate to incidents with AR compass technology.
          </p>
        </div>

        {/* App Store Buttons */}
        <div className="flex flex-col sm:flex-row gap-4 justify-center mb-16">
          <button className="bg-dark-surface border border-dark-border hover:border-brand-primary transition-colors rounded-lg p-6 flex items-center gap-4 min-w-[200px]">
            <div className="text-3xl">🍎</div>
            <div className="text-left">
              <p className="text-text-tertiary text-sm">Download on the</p>
              <p className="text-text-primary font-semibold">App Store</p>
            </div>
          </button>
          
          <button className="bg-dark-surface border border-dark-border hover:border-brand-primary transition-colors rounded-lg p-6 flex items-center gap-4 min-w-[200px]">
            <div className="text-3xl">🤖</div>
            <div className="text-left">
              <p className="text-text-tertiary text-sm">Get it on</p>
              <p className="text-text-primary font-semibold">Google Play</p>
            </div>
          </button>
        </div>

        {/* Coming Soon Notice */}
        <div className="bg-dark-surface border border-dark-border rounded-lg p-8 text-center mb-12">
          <div className="text-4xl mb-4">🚧</div>
          <h2 className="text-2xl font-semibold text-text-primary mb-4">Coming Soon</h2>
          <p className="text-text-secondary mb-6">
            The UFOBeep mobile app is currently in development. Sign up to be notified when it launches!
          </p>
          <div className="flex flex-col sm:flex-row gap-4 max-w-md mx-auto">
            <input
              type="email"
              placeholder="Enter your email"
              className="flex-1 bg-dark-background border border-dark-border rounded-lg px-4 py-3 text-text-primary placeholder-text-tertiary focus:outline-none focus:border-brand-primary"
            />
            <button className="bg-brand-primary text-text-inverse px-6 py-3 rounded-lg font-semibold hover:bg-brand-primary-dark transition-colors whitespace-nowrap">
              Notify Me
            </button>
          </div>
        </div>

        {/* Features Grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 mb-16">
          <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
            <div className="text-3xl mb-4">📸</div>
            <h3 className="text-lg font-semibold text-text-primary mb-2">Quick Reporting</h3>
            <p className="text-text-secondary text-sm">
              Capture and upload photos/videos instantly with automatic location tagging and metadata.
            </p>
          </div>
          
          <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
            <div className="text-3xl mb-4">🔔</div>
            <h3 className="text-lg font-semibold text-text-primary mb-2">Real-time Alerts</h3>
            <p className="text-text-secondary text-sm">
              Get instant notifications about sightings in your area with customizable range settings.
            </p>
          </div>
          
          <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
            <div className="text-3xl mb-4">🧭</div>
            <h3 className="text-lg font-semibold text-text-primary mb-2">AR Navigation</h3>
            <p className="text-text-secondary text-sm">
              Advanced compass with Standard and Pilot modes for precise navigation to sighting locations.
            </p>
          </div>
          
          <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
            <div className="text-3xl mb-4">💬</div>
            <h3 className="text-lg font-semibold text-text-primary mb-2">Matrix Chat</h3>
            <p className="text-text-secondary text-sm">
              Join secure, decentralized chat rooms for each sighting with end-to-end encryption.
            </p>
          </div>
          
          <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
            <div className="text-3xl mb-4">🌦️</div>
            <h3 className="text-lg font-semibold text-text-primary mb-2">Smart Enrichment</h3>
            <p className="text-text-secondary text-sm">
              Automatic weather, celestial, and satellite data to help identify conventional explanations.
            </p>
          </div>
          
          <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
            <div className="text-3xl mb-4">🛡️</div>
            <h3 className="text-lg font-semibold text-text-primary mb-2">Privacy First</h3>
            <p className="text-text-secondary text-sm">
              Your exact location is never shared publicly - coordinates are jittered for privacy protection.
            </p>
          </div>
        </div>

        {/* Requirements */}
        <div className="bg-dark-surface border border-dark-border rounded-lg p-8">
          <h2 className="text-2xl font-semibold text-text-primary mb-6 text-center">System Requirements</h2>
          
          <div className="grid md:grid-cols-2 gap-8">
            <div>
              <h3 className="text-lg font-semibold text-brand-primary mb-4 flex items-center gap-2">
                🍎 iOS Requirements
              </h3>
              <ul className="space-y-2 text-text-secondary">
                <li>• iOS 14.0 or later</li>
                <li>• iPhone 8 or newer</li>
                <li>• Camera access required</li>
                <li>• Location services required</li>
                <li>• Internet connection required</li>
              </ul>
            </div>
            
            <div>
              <h3 className="text-lg font-semibold text-brand-primary mb-4 flex items-center gap-2">
                🤖 Android Requirements
              </h3>
              <ul className="space-y-2 text-text-secondary">
                <li>• Android 7.0 (API level 24) or later</li>
                <li>• ARCore supported device recommended</li>
                <li>• Camera access required</li>
                <li>• Location services required</li>
                <li>• Internet connection required</li>
              </ul>
            </div>
          </div>
        </div>

        {/* Permissions Notice */}
        <div className="mt-8 bg-semantic-warning bg-opacity-10 border border-semantic-warning border-opacity-20 rounded-lg p-6">
          <h3 className="text-lg font-semibold text-semantic-warning mb-2 flex items-center gap-2">
            ⚠️ Permissions Required
          </h3>
          <p className="text-text-secondary text-sm">
            UFOBeep requires camera, location, and notification permissions to function properly. 
            Your privacy is protected - we only use your exact location for distance calculations 
            and never share it publicly without your consent.
          </p>
        </div>

        {/* Support */}
        <div className="mt-12 text-center">
          <p className="text-text-secondary mb-4">
            Questions about the mobile app?
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link href="/safety" className="text-brand-primary hover:text-brand-primary-light transition-colors">
              Safety Guidelines
            </Link>
            <Link href="/privacy" className="text-brand-primary hover:text-brand-primary-light transition-colors">
              Privacy Policy
            </Link>
            <a href="#" className="text-brand-primary hover:text-brand-primary-light transition-colors">
              Contact Support
            </a>
          </div>
        </div>
      </div>
    </main>
  )
}