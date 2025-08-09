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
          
          <div className="grid md:grid-cols-3 gap-8">
            <div>
              <h3 className="text-lg font-semibold text-brand-primary mb-4 flex items-center gap-2">
                🍎 iOS Requirements
              </h3>
              <ul className="space-y-2 text-text-secondary">
                <li>• iOS 14.0 or later</li>
                <li>• iPhone 8 or newer (iPhone X+ recommended)</li>
                <li>• 64-bit processor</li>
                <li>• 50MB free storage</li>
                <li>• Internet connection</li>
                <li>• Camera & Location permissions</li>
              </ul>
              <div className="mt-4 p-3 bg-dark-background rounded border border-dark-border">
                <p className="text-xs text-text-tertiary">
                  <strong>Best experience:</strong> iPhone 12+ with iOS 15+ for advanced AR features
                </p>
              </div>
            </div>
            
            <div>
              <h3 className="text-lg font-semibold text-brand-primary mb-4 flex items-center gap-2">
                🤖 Android Requirements
              </h3>
              <ul className="space-y-2 text-text-secondary">
                <li>• Android 7.0 (API level 24) or later</li>
                <li>• ARCore supported device (recommended)</li>
                <li>• 64-bit ARM or x86 processor</li>
                <li>• 50MB free storage</li>
                <li>• Internet connection</li>
                <li>• Camera & Location permissions</li>
              </ul>
              <div className="mt-4 p-3 bg-dark-background rounded border border-dark-border">
                <p className="text-xs text-text-tertiary">
                  <strong>Check ARCore support:</strong> Visit g.co/arcore to verify device compatibility
                </p>
              </div>
            </div>
            
            <div>
              <h3 className="text-lg font-semibold text-brand-primary mb-4 flex items-center gap-2">
                🌐 Progressive Web App
              </h3>
              <ul className="space-y-2 text-text-secondary">
                <li>• Modern browser (Chrome, Firefox, Safari)</li>
                <li>• JavaScript enabled</li>
                <li>• Camera API support</li>
                <li>• Geolocation API support</li>
                <li>• Service Worker support</li>
                <li>• 10MB browser storage</li>
              </ul>
              <div className="mt-4 p-3 bg-dark-background rounded border border-dark-border">
                <p className="text-xs text-text-tertiary">
                  <strong>Install as app:</strong> Use &quot;Add to Home Screen&quot; option in browser
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Detailed Permissions Rationale */}
        <div className="mt-8 bg-dark-surface border border-dark-border rounded-lg p-8">
          <h2 className="text-2xl font-semibold text-text-primary mb-6 text-center flex items-center justify-center gap-3">
            🛡️ App Permissions Explained
          </h2>
          
          <div className="space-y-8">
            {/* Camera Permission */}
            <div className="border-l-4 border-brand-primary pl-6">
              <div className="flex items-start gap-4">
                <div className="text-3xl">📸</div>
                <div className="flex-1">
                  <h3 className="text-lg font-semibold text-text-primary mb-2">Camera Access</h3>
                  <p className="text-text-secondary mb-3">
                    <strong>Why we need it:</strong> To capture photos and videos of sightings for evidence and analysis.
                  </p>
                  <p className="text-text-tertiary text-sm">
                    <strong>How it&apos;s used:</strong> Only activated when you tap &quot;Beep&quot; to report a sighting. 
                    Images are processed locally first, then uploaded securely with your consent.
                  </p>
                  <p className="text-brand-primary text-sm mt-2">
                    ✅ Never accessed without your explicit action
                  </p>
                </div>
              </div>
            </div>

            {/* Location Permission */}
            <div className="border-l-4 border-brand-primary pl-6">
              <div className="flex items-start gap-4">
                <div className="text-3xl">📍</div>
                <div className="flex-1">
                  <h3 className="text-lg font-semibold text-text-primary mb-2">Location Services</h3>
                  <p className="text-text-secondary mb-3">
                    <strong>Why we need it:</strong> To determine your distance from sightings, provide relevant alerts, and enable compass navigation.
                  </p>
                  <p className="text-text-tertiary text-sm">
                    <strong>Privacy protection:</strong> Your exact coordinates are jittered (slightly randomized) before being shared publicly. 
                    Only general area information is displayed to protect your privacy.
                  </p>
                  <p className="text-brand-primary text-sm mt-2">
                    ✅ Exact location never shared publicly • ✅ Data jittered for privacy
                  </p>
                </div>
              </div>
            </div>

            {/* Notification Permission */}
            <div className="border-l-4 border-brand-primary pl-6">
              <div className="flex items-start gap-4">
                <div className="text-3xl">🔔</div>
                <div className="flex-1">
                  <h3 className="text-lg font-semibold text-text-primary mb-2">Push Notifications</h3>
                  <p className="text-text-secondary mb-3">
                    <strong>Why we need it:</strong> To send you real-time alerts about new sightings in your area based on your range preferences.
                  </p>
                  <p className="text-text-tertiary text-sm">
                    <strong>Your control:</strong> Fully customizable alert range (1-100km). You can disable notifications 
                    entirely or adjust frequency settings at any time in the app.
                  </p>
                  <p className="text-brand-primary text-sm mt-2">
                    ✅ Fully customizable • ✅ Can be disabled anytime
                  </p>
                </div>
              </div>
            </div>

            {/* Optional Permissions */}
            <div className="bg-dark-background border border-dark-border rounded-lg p-6 mt-6">
              <h3 className="text-lg font-semibold text-text-primary mb-4 flex items-center gap-2">
                🔧 Optional Permissions
              </h3>
              <div className="space-y-3">
                <div className="flex items-center gap-3">
                  <div className="text-xl">🧭</div>
                  <div>
                    <span className="text-text-primary font-medium">Compass/Sensors:</span>
                    <span className="text-text-secondary ml-2">For advanced AR navigation features (Pilot Mode)</span>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <div className="text-xl">🎤</div>
                  <div>
                    <span className="text-text-primary font-medium">Microphone:</span>
                    <span className="text-text-secondary ml-2">Only for voice notes (if you choose to record them)</span>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <div className="text-xl">📱</div>
                  <div>
                    <span className="text-text-primary font-medium">Device Motion:</span>
                    <span className="text-text-secondary ml-2">For compass calibration and AR overlay accuracy</span>
                  </div>
                </div>
              </div>
            </div>

            {/* Privacy Guarantee */}
            <div className="bg-brand-primary bg-opacity-10 border border-brand-primary border-opacity-20 rounded-lg p-6">
              <h3 className="text-lg font-semibold text-brand-primary mb-3 flex items-center gap-2">
                🛡️ Privacy Guarantee
              </h3>
              <ul className="space-y-2 text-text-secondary text-sm">
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary mt-1">•</span>
                  <span>No data is collected without your explicit consent</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary mt-1">•</span>
                  <span>Location coordinates are jittered before public sharing</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary mt-1">•</span>
                  <span>You can delete your data or disable features at any time</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary mt-1">•</span>
                  <span>Open source - you can verify our privacy practices</span>
                </li>
              </ul>
            </div>
          </div>
        </div>

        {/* Platform-Specific Installation Guides */}
        <div className="mt-12 space-y-8">
          <h2 className="text-2xl font-semibold text-text-primary text-center mb-8">
            Step-by-Step Installation Guide
          </h2>
          
          <div className="grid lg:grid-cols-3 gap-8">
            {/* iOS Installation */}
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <div className="flex items-center gap-3 mb-4">
                <div className="text-3xl">🍎</div>
                <h3 className="text-xl font-semibold text-text-primary">iOS Installation</h3>
              </div>
              
              <div className="space-y-4">
                <div className="flex gap-3">
                  <div className="bg-brand-primary text-text-inverse rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold flex-shrink-0 mt-0.5">1</div>
                  <div>
                    <p className="text-text-primary font-medium">Open App Store</p>
                    <p className="text-text-tertiary text-sm">Tap the App Store icon on your home screen</p>
                  </div>
                </div>
                
                <div className="flex gap-3">
                  <div className="bg-brand-primary text-text-inverse rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold flex-shrink-0 mt-0.5">2</div>
                  <div>
                    <p className="text-text-primary font-medium">Search &quot;UFOBeep&quot;</p>
                    <p className="text-text-tertiary text-sm">Use the search tab at the bottom</p>
                  </div>
                </div>
                
                <div className="flex gap-3">
                  <div className="bg-brand-primary text-text-inverse rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold flex-shrink-0 mt-0.5">3</div>
                  <div>
                    <p className="text-text-primary font-medium">Tap &quot;Get&quot; or &quot;Install&quot;</p>
                    <p className="text-text-tertiary text-sm">May require Face ID, Touch ID, or password</p>
                  </div>
                </div>
                
                <div className="flex gap-3">
                  <div className="bg-brand-primary text-text-inverse rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold flex-shrink-0 mt-0.5">4</div>
                  <div>
                    <p className="text-text-primary font-medium">Grant Permissions</p>
                    <p className="text-text-tertiary text-sm">Allow camera, location, and notifications when prompted</p>
                  </div>
                </div>
                
                <div className="bg-brand-primary bg-opacity-10 border border-brand-primary border-opacity-20 rounded p-3 mt-4">
                  <p className="text-xs text-brand-primary">
                    ℹ️ <strong>First Time Setup:</strong> The app will guide you through permission setup and let you customize your alert range.
                  </p>
                </div>
              </div>
            </div>

            {/* Android Installation */}
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <div className="flex items-center gap-3 mb-4">
                <div className="text-3xl">🤖</div>
                <h3 className="text-xl font-semibold text-text-primary">Android Installation</h3>
              </div>
              
              <div className="space-y-4">
                <div className="flex gap-3">
                  <div className="bg-brand-primary text-text-inverse rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold flex-shrink-0 mt-0.5">1</div>
                  <div>
                    <p className="text-text-primary font-medium">Open Google Play Store</p>
                    <p className="text-text-tertiary text-sm">Find the Play Store app in your app drawer</p>
                  </div>
                </div>
                
                <div className="flex gap-3">
                  <div className="bg-brand-primary text-text-inverse rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold flex-shrink-0 mt-0.5">2</div>
                  <div>
                    <p className="text-text-primary font-medium">Search &quot;UFOBeep&quot;</p>
                    <p className="text-text-tertiary text-sm">Tap the search icon and type the app name</p>
                  </div>
                </div>
                
                <div className="flex gap-3">
                  <div className="bg-brand-primary text-text-inverse rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold flex-shrink-0 mt-0.5">3</div>
                  <div>
                    <p className="text-text-primary font-medium">Tap &quot;Install&quot;</p>
                    <p className="text-text-tertiary text-sm">Review permissions and confirm installation</p>
                  </div>
                </div>
                
                <div className="flex gap-3">
                  <div className="bg-brand-primary text-text-inverse rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold flex-shrink-0 mt-0.5">4</div>
                  <div>
                    <p className="text-text-primary font-medium">Complete Setup</p>
                    <p className="text-text-tertiary text-sm">Allow permissions and customize your preferences</p>
                  </div>
                </div>
                
                <div className="bg-semantic-warning bg-opacity-10 border border-semantic-warning border-opacity-20 rounded p-3 mt-4">
                  <p className="text-xs text-semantic-warning">
                    ⚠️ <strong>ARCore Check:</strong> Some features work best on ARCore-supported devices. Check g.co/arcore for compatibility.
                  </p>
                </div>
              </div>
            </div>

            {/* PWA Installation */}
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <div className="flex items-center gap-3 mb-4">
                <div className="text-3xl">🌐</div>
                <h3 className="text-xl font-semibold text-text-primary">Web App (PWA)</h3>
              </div>
              
              <div className="space-y-4">
                <div className="flex gap-3">
                  <div className="bg-brand-primary text-text-inverse rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold flex-shrink-0 mt-0.5">1</div>
                  <div>
                    <p className="text-text-primary font-medium">Visit ufobeep.com</p>
                    <p className="text-text-tertiary text-sm">Open in Chrome, Firefox, Safari, or Edge</p>
                  </div>
                </div>
                
                <div className="flex gap-3">
                  <div className="bg-brand-primary text-text-inverse rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold flex-shrink-0 mt-0.5">2</div>
                  <div>
                    <p className="text-text-primary font-medium">Look for Install Prompt</p>
                    <p className="text-text-tertiary text-sm">Browser will show &quot;Add to Home Screen&quot; or install banner</p>
                  </div>
                </div>
                
                <div className="flex gap-3">
                  <div className="bg-brand-primary text-text-inverse rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold flex-shrink-0 mt-0.5">3</div>
                  <div>
                    <p className="text-text-primary font-medium">Install as App</p>
                    <p className="text-text-tertiary text-sm">Tap &quot;Install&quot; or &quot;Add to Home Screen&quot;</p>
                  </div>
                </div>
                
                <div className="flex gap-3">
                  <div className="bg-brand-primary text-text-inverse rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold flex-shrink-0 mt-0.5">4</div>
                  <div>
                    <p className="text-text-primary font-medium">Allow Permissions</p>
                    <p className="text-text-tertiary text-sm">Grant camera and location access when requested</p>
                  </div>
                </div>
                
                <div className="bg-brand-primary bg-opacity-10 border border-brand-primary border-opacity-20 rounded p-3 mt-4">
                  <p className="text-xs text-brand-primary">
                    ✨ <strong>Full App Experience:</strong> PWA works offline and feels like a native app once installed.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Troubleshooting */}
        <div className="mt-16 bg-dark-surface border border-dark-border rounded-lg p-8">
          <h2 className="text-2xl font-semibold text-text-primary mb-6 text-center">
            🤔 Installation Troubleshooting
          </h2>
          
          <div className="grid md:grid-cols-2 gap-8">
            <div>
              <h3 className="text-lg font-semibold text-brand-primary mb-4">Common Issues</h3>
              <div className="space-y-4">
                <div>
                  <p className="text-text-primary font-medium mb-1">⚠️ App not found in store</p>
                  <p className="text-text-tertiary text-sm">Check your device compatibility and region. The app may be rolling out gradually.</p>
                </div>
                
                <div>
                  <p className="text-text-primary font-medium mb-1">🔒 Permission denied errors</p>
                  <p className="text-text-tertiary text-sm">Go to device Settings &gt; Apps &gt; UFOBeep &gt; Permissions and enable required permissions manually.</p>
                </div>
                
                <div>
                  <p className="text-text-primary font-medium mb-1">🌍 PWA install button missing</p>
                  <p className="text-text-tertiary text-sm">Try visiting the site in Chrome/Edge. Look for the install icon in the address bar.</p>
                </div>
              </div>
            </div>
            
            <div>
              <h3 className="text-lg font-semibold text-brand-primary mb-4">Getting Help</h3>
              <div className="space-y-4">
                <div className="flex items-center gap-3">
                  <div className="text-xl">📞</div>
                  <div>
                    <p className="text-text-primary font-medium">Technical Support</p>
                    <p className="text-text-tertiary text-sm">Email: support@ufobeep.com</p>
                  </div>
                </div>
                
                <div className="flex items-center gap-3">
                  <div className="text-xl">💬</div>
                  <div>
                    <p className="text-text-primary font-medium">Community Help</p>
                    <p className="text-text-tertiary text-sm">Join our Matrix chat for user support</p>
                  </div>
                </div>
                
                <div className="flex items-center gap-3">
                  <div className="text-xl">📄</div>
                  <div>
                    <p className="text-text-primary font-medium">Documentation</p>
                    <p className="text-text-tertiary text-sm">Check our FAQ and setup guides</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
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