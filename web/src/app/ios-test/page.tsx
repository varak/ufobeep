import Link from 'next/link'

export default function IOSTestPage() {
  return (
    <main className="min-h-screen py-8 px-4 md:px-8">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="text-center mb-12">
          <Link 
            href="/app" 
            className="text-brand-primary hover:text-brand-primary-light transition-colors mb-4 inline-block"
          >
            ← Back to Downloads
          </Link>
          
          <div className="text-6xl mb-6">🍎</div>
          <h1 className="text-4xl md:text-5xl font-bold text-text-primary mb-4">
            iOS Beta Testing Instructions
          </h1>
          <p className="text-xl text-text-secondary max-w-2xl mx-auto">
            How to test UFOBeep Beta on iPhone - for friends and beta testers
          </p>
        </div>

        {/* TestFlight Coming Soon */}
        <div className="bg-gradient-to-r from-brand-primary/20 to-purple-600/20 border border-brand-primary/30 rounded-xl p-8 mb-12">
          <div className="text-center">
            <div className="inline-block bg-brand-primary text-text-inverse px-4 py-2 rounded-full text-sm font-semibold mb-4">
              🚀 TESTFLIGHT COMING SOON
            </div>
            <h2 className="text-2xl font-bold text-text-primary mb-4">
              Easier Testing on the Way!
            </h2>
            <p className="text-text-secondary max-w-2xl mx-auto mb-6">
              We&apos;re working on getting UFOBeep on TestFlight for easy installation. 
              Sign up below to get notified when it&apos;s available!
            </p>
            <a 
              href="/app"
              className="inline-block bg-brand-primary hover:bg-brand-primary-dark text-text-inverse px-8 py-3 rounded-lg font-semibold transition-colors"
            >
              Get Notified →
            </a>
          </div>
        </div>

        {/* Instructions for Mac Users */}
        <div className="bg-dark-surface border border-dark-border rounded-lg p-8 mb-8">
          <h2 className="text-2xl font-semibold text-text-primary mb-6 flex items-center gap-3">
            💻 For Friends with a Mac
          </h2>
          
          <div className="space-y-6">
            <div className="bg-dark-background border border-dark-border rounded-lg p-6">
              <h3 className="text-lg font-semibold text-brand-primary mb-4">Quick Setup Steps</h3>
              <ol className="space-y-4">
                <li className="flex gap-3">
                  <span className="text-brand-primary font-bold">1.</span>
                  <div>
                    <p className="text-text-primary font-medium">Install Xcode</p>
                    <p className="text-text-tertiary text-sm">Download free from Mac App Store</p>
                  </div>
                </li>
                <li className="flex gap-3">
                  <span className="text-brand-primary font-bold">2.</span>
                  <div>
                    <p className="text-text-primary font-medium">Get the Code</p>
                    <code className="text-sm bg-dark-surface px-2 py-1 rounded">
                      git clone https://github.com/varak/ufobeep.git
                    </code>
                  </div>
                </li>
                <li className="flex gap-3">
                  <span className="text-brand-primary font-bold">3.</span>
                  <div>
                    <p className="text-text-primary font-medium">Install Flutter</p>
                    <p className="text-text-tertiary text-sm">Follow instructions at flutter.dev/docs/get-started/install/macos</p>
                  </div>
                </li>
                <li className="flex gap-3">
                  <span className="text-brand-primary font-bold">4.</span>
                  <div>
                    <p className="text-text-primary font-medium">Run on Your iPhone</p>
                    <div className="mt-2 space-y-1">
                      <code className="block text-sm bg-dark-surface px-2 py-1 rounded">cd ufobeep/app</code>
                      <code className="block text-sm bg-dark-surface px-2 py-1 rounded">flutter pub get</code>
                      <code className="block text-sm bg-dark-surface px-2 py-1 rounded">flutter run</code>
                    </div>
                  </div>
                </li>
              </ol>
            </div>

            <div className="bg-semantic-warning/10 border border-semantic-warning/20 rounded-lg p-6">
              <div className="flex items-start gap-3">
                <div className="text-xl">⚠️</div>
                <div>
                  <p className="text-semantic-warning font-semibold mb-2">Device Trust Required</p>
                  <p className="text-text-secondary text-sm">
                    After installing, go to iPhone Settings → General → Device Management → 
                    Trust your developer account to allow the app to run.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Instructions for Non-Mac Users */}
        <div className="bg-dark-surface border border-dark-border rounded-lg p-8 mb-8">
          <h2 className="text-2xl font-semibold text-text-primary mb-6 flex items-center gap-3">
            📱 For Friends without a Mac
          </h2>
          
          <div className="space-y-6">
            <div className="p-6 bg-dark-background border border-dark-border rounded-lg">
              <h3 className="text-lg font-semibold text-text-primary mb-3">Current Options</h3>
              <div className="space-y-4">
                <div className="flex items-start gap-3">
                  <div className="text-green-400 mt-1">✓</div>
                  <div>
                    <p className="text-text-primary font-medium">Wait for TestFlight</p>
                    <p className="text-text-tertiary text-sm">
                      Easiest option - we&apos;re working on it! Sign up at the download page to get notified.
                    </p>
                  </div>
                </div>
                
                <div className="flex items-start gap-3">
                  <div className="text-yellow-400 mt-1">○</div>
                  <div>
                    <p className="text-text-primary font-medium">Use a Cloud Testing Service</p>
                    <p className="text-text-tertiary text-sm">
                      Services like Appetize.io can run iOS apps in browser (limited functionality)
                    </p>
                  </div>
                </div>
                
                <div className="flex items-start gap-3">
                  <div className="text-yellow-400 mt-1">○</div>
                  <div>
                    <p className="text-text-primary font-medium">Borrow a Friend&apos;s Mac</p>
                    <p className="text-text-tertiary text-sm">
                      If you can access a Mac temporarily, follow the Mac instructions above
                    </p>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-brand-primary/10 border border-brand-primary/20 rounded-lg p-6">
              <p className="text-text-primary text-center">
                <strong>🎯 Best Option:</strong> Sign up for notifications and we&apos;ll let you know 
                as soon as TestFlight is available!
              </p>
            </div>
          </div>
        </div>

        {/* Technical Details */}
        <div className="bg-dark-surface border border-dark-border rounded-lg p-8 mb-8">
          <h2 className="text-2xl font-semibold text-text-primary mb-6">
            🔧 Technical Requirements
          </h2>
          
          <div className="grid md:grid-cols-2 gap-6">
            <div>
              <h3 className="text-lg font-semibold text-brand-primary mb-3">iPhone Requirements</h3>
              <ul className="space-y-2 text-text-secondary">
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary mt-1">•</span>
                  <span>iOS 14.0 or later</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary mt-1">•</span>
                  <span>iPhone 8 or newer</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary mt-1">•</span>
                  <span>~50MB free storage</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary mt-1">•</span>
                  <span>Internet connection</span>
                </li>
              </ul>
            </div>
            
            <div>
              <h3 className="text-lg font-semibold text-brand-primary mb-3">Mac Requirements (for building)</h3>
              <ul className="space-y-2 text-text-secondary">
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary mt-1">•</span>
                  <span>macOS 10.15 or later</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary mt-1">•</span>
                  <span>Xcode 13 or later</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary mt-1">•</span>
                  <span>~10GB free storage</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-brand-primary mt-1">•</span>
                  <span>Apple ID (free)</span>
                </li>
              </ul>
            </div>
          </div>
        </div>

        {/* Features to Test */}
        <div className="bg-dark-surface border border-dark-border rounded-lg p-8 mb-8">
          <h2 className="text-2xl font-semibold text-text-primary mb-6">
            ✅ What to Test
          </h2>
          
          <div className="grid md:grid-cols-2 gap-4">
            <label className="flex items-center gap-3 text-text-secondary hover:text-text-primary cursor-pointer">
              <input type="checkbox" className="w-5 h-5 text-brand-primary" />
              <span>Camera capture (photo/video)</span>
            </label>
            <label className="flex items-center gap-3 text-text-secondary hover:text-text-primary cursor-pointer">
              <input type="checkbox" className="w-5 h-5 text-brand-primary" />
              <span>Location services</span>
            </label>
            <label className="flex items-center gap-3 text-text-secondary hover:text-text-primary cursor-pointer">
              <input type="checkbox" className="w-5 h-5 text-brand-primary" />
              <span>Push notifications</span>
            </label>
            <label className="flex items-center gap-3 text-text-secondary hover:text-text-primary cursor-pointer">
              <input type="checkbox" className="w-5 h-5 text-brand-primary" />
              <span>Compass navigation</span>
            </label>
            <label className="flex items-center gap-3 text-text-secondary hover:text-text-primary cursor-pointer">
              <input type="checkbox" className="w-5 h-5 text-brand-primary" />
              <span>Alert viewing</span>
            </label>
            <label className="flex items-center gap-3 text-text-secondary hover:text-text-primary cursor-pointer">
              <input type="checkbox" className="w-5 h-5 text-brand-primary" />
              <span>Media upload</span>
            </label>
            <label className="flex items-center gap-3 text-text-secondary hover:text-text-primary cursor-pointer">
              <input type="checkbox" className="w-5 h-5 text-brand-primary" />
              <span>App performance</span>
            </label>
            <label className="flex items-center gap-3 text-text-secondary hover:text-text-primary cursor-pointer">
              <input type="checkbox" className="w-5 h-5 text-brand-primary" />
              <span>Dark mode support</span>
            </label>
          </div>
        </div>

        {/* Footer */}
        <div className="text-center mt-12">
          <p className="text-text-secondary mb-6">
            Ready to help test UFOBeep on iOS? 
          </p>
          <a 
            href="/app"
            className="inline-block bg-brand-primary hover:bg-brand-primary-dark text-text-inverse px-8 py-3 rounded-lg font-semibold transition-colors"
          >
            Sign Up for Updates
          </a>
          
          <div className="mt-8 flex flex-col sm:flex-row gap-4 justify-center">
            <Link href="/app" className="text-brand-primary hover:text-brand-primary-light transition-colors">
              ← Back to Downloads
            </Link>
            <a 
              href="https://github.com/varak/ufobeep" 
              target="_blank" 
              rel="noopener noreferrer"
              className="text-brand-primary hover:text-brand-primary-light transition-colors"
            >
              View Source Code →
            </a>
          </div>
        </div>
      </div>
    </main>
  )
}