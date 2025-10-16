import Link from 'next/link'
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Privacy Policy',
  description: 'UFOBeep privacy policy explaining how we collect, use, and protect your personal information while providing real-time sighting alerts.',
  openGraph: {
    title: 'Privacy Policy | UFOBeep',
    description: 'Learn how UFOBeep protects your privacy while providing real-time UFO sighting alerts and community features.',
  },
  twitter: {
    title: 'Privacy Policy | UFOBeep',
    description: 'Learn how UFOBeep protects your privacy while providing real-time UFO sighting alerts.',
  },
}

export default function PrivacyPage() {
  return (
    <main className="min-h-screen py-8 px-4 md:px-8">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="mb-12">
          <Link 
            href="/" 
            className="text-brand-primary hover:text-brand-primary-light transition-colors mb-4 inline-block"
          >
            ← Back to Home
          </Link>
          
          <h1 className="text-4xl md:text-5xl font-bold text-text-primary mb-4">
            Privacy Policy
          </h1>
          <p className="text-lg text-text-secondary mb-6">
            Last updated: October 16, 2025
          </p>
          
          <div className="bg-brand-primary bg-opacity-10 border border-brand-primary border-opacity-20 rounded-lg p-6">
            <div className="flex items-start gap-3">
              <div className="text-2xl">🛡️</div>
              <div>
                <h2 className="text-lg font-semibold text-brand-primary mb-2">Privacy-First Approach</h2>
                <p className="text-text-secondary text-sm">
                  UFOBeep is designed with privacy as a core principle. We collect minimal data, 
                  protect your location through coordinate jittering, and use end-to-end encryption 
                  for all communications.
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="prose prose-invert max-w-none">
          <div className="bg-dark-surface border border-dark-border rounded-lg p-6 mb-8">
            <h2 className="text-2xl font-semibold text-brand-primary mb-4">Our Commitment to Privacy</h2>
            <p className="text-text-secondary">
              UFOBeep is built with privacy at its core. We understand the sensitive nature of sighting reports 
              and are committed to protecting your personal information while enabling community verification 
              and discussion.
            </p>
          </div>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">Information We Collect</h2>
            
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6 mb-6">
              <h3 className="text-xl font-medium text-brand-primary mb-3">Location Data</h3>
              <ul className="text-text-secondary space-y-2">
                <li>• <strong>Current Location:</strong> Used for proximity alerts when UFO sightings happen nearby</li>
                <li>• <strong>Background Monitoring:</strong> We monitor your location in the background to send accurate proximity alerts when you move</li>
                <li>• <strong>Movement Detection:</strong> Location is updated when you move more than 1km from your last known position</li>
                <li>• <strong>Battery Efficient:</strong> Uses intelligent geofencing technology with &lt;3% battery impact</li>
                <li>• <strong>Rate Limited:</strong> Location updates are limited to once every 10 minutes maximum</li>
                <li>• <strong>Jittered Public Display:</strong> When you report sightings, coordinates are randomly offset by 100-300 meters for privacy</li>
                <li>• <strong>No Historical Storage:</strong> We only store your current location, not location history or movement patterns</li>
              </ul>
            </div>

            <div className="bg-dark-surface border border-dark-border rounded-lg p-6 mb-6">
              <h3 className="text-xl font-medium text-brand-primary mb-3">Sighting Data</h3>
              <ul className="text-text-secondary space-y-2">
                <li>• Photos and videos you choose to upload</li>
                <li>• Sighting descriptions and timestamps</li>
                <li>• Environmental data (weather, celestial information)</li>
                <li>• Metadata from uploaded media (camera settings, timestamps)</li>
              </ul>
            </div>

            <div className="bg-dark-surface border border-dark-border rounded-lg p-6 mb-6">
              <h3 className="text-xl font-medium text-brand-primary mb-3">Account Information</h3>
              <ul className="text-text-secondary space-y-2">
                <li>• Email address (optional, for notifications only)</li>
                <li>• Display name (pseudonym encouraged)</li>
                <li>• App preferences and settings</li>
                <li>• Push notification tokens</li>
              </ul>
            </div>

            <div className="bg-dark-surface border border-dark-border rounded-lg p-6 mb-6">
              <h3 className="text-xl font-medium text-brand-primary mb-3">Google Sign-In Data</h3>
              <p className="text-text-secondary mb-3">
                When you sign in with Google, we receive and store:
              </p>
              <ul className="text-text-secondary space-y-2">
                <li>• <strong>Email Address:</strong> Used for account identification and notifications</li>
                <li>• <strong>Profile Name:</strong> Displayed as your username unless you change it</li>
                <li>• <strong>Profile Photo:</strong> Optional display picture for your account</li>
                <li>• <strong>Google Account ID:</strong> Unique identifier for linking your Google account</li>
              </ul>
              <p className="text-text-secondary text-sm mt-3">
                We only access this information with your explicit permission through Google&apos;s authentication flow.
                You can disconnect your Google account at any time through your account settings.
              </p>
            </div>

            <div className="bg-dark-surface border border-dark-border rounded-lg p-6 mb-6">
              <h3 className="text-xl font-medium text-brand-primary mb-3">Device Information</h3>
              <p className="text-text-secondary mb-3">
                To provide support and optimize app performance, we collect technical information about your device:
              </p>
              <ul className="text-text-secondary space-y-2">
                <li>• <strong>Device Model:</strong> Phone or tablet model (e.g., &quot;Pixel 9a&quot;, &quot;iPhone 14 Pro&quot;)</li>
                <li>• <strong>Manufacturer:</strong> Device maker (e.g., Google, Apple, Samsung)</li>
                <li>• <strong>Operating System:</strong> OS version (e.g., &quot;Android 14&quot;, &quot;iOS 17.1&quot;)</li>
                <li>• <strong>App Version:</strong> UFOBeep version you&apos;re running</li>
                <li>• <strong>Screen Resolution:</strong> Display dimensions for UI optimization</li>
                <li>• <strong>Device Memory:</strong> RAM capacity for performance tuning</li>
                <li>• <strong>Available Storage:</strong> Free storage space for media uploads</li>
                <li>• <strong>Network Type:</strong> Connection type (WiFi, 5G, 4G) for debugging</li>
                <li>• <strong>Language Preference:</strong> Device language for automatic localization</li>
                <li>• <strong>Timezone:</strong> Local timezone for accurate timestamp display</li>
                <li>• <strong>Battery Optimization Status:</strong> Android power management settings</li>
                <li>• <strong>Location Permission Type:</strong> Whether location is &quot;Always&quot;, &quot;While in Use&quot;, or denied</li>
              </ul>
              <p className="text-text-secondary text-sm mt-3">
                This information helps us troubleshoot issues, optimize performance for different devices,
                and ensure the app works correctly on your specific device configuration.
              </p>
            </div>

            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h3 className="text-xl font-medium text-brand-primary mb-3">Analytics & Error Tracking</h3>
              <p className="text-text-secondary mb-3">
                We use industry-standard analytics tools to improve the app:
              </p>
              <ul className="text-text-secondary space-y-2">
                <li>• <strong>Google Analytics:</strong> Website traffic, user acquisition sources, and feature usage</li>
                <li>• <strong>Firebase Analytics:</strong> Mobile app usage patterns, screen views, and user flows</li>
                <li>• <strong>Sentry Error Tracking:</strong> Crash reports, error logs, and performance monitoring</li>
              </ul>
              <p className="text-text-secondary text-sm mt-3">
                All analytics data is aggregated and anonymized. We use this information to identify bugs,
                improve performance, and understand which features are most valuable to users. You can opt out
                of analytics in your device settings.
              </p>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">Cookies and Tracking Technologies</h2>

            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <p className="text-text-secondary mb-4">
                Our website uses cookies and similar technologies:
              </p>
              <ul className="text-text-secondary space-y-3">
                <li>
                  • <strong>Essential Cookies:</strong> Required for website functionality, authentication,
                  and security. These cannot be disabled.
                </li>
                <li>
                  • <strong>Analytics Cookies:</strong> Google Analytics tracks page views, session duration,
                  and navigation patterns to help us improve the website experience.
                </li>
                <li>
                  • <strong>No Advertising Cookies:</strong> We do not use cookies for advertising or
                  third-party marketing purposes.
                </li>
              </ul>
              <p className="text-text-secondary text-sm mt-3">
                You can control cookie preferences through your browser settings. Note that disabling cookies
                may affect website functionality.
              </p>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">How We Use Your Information</h2>
            
            <div className="grid md:grid-cols-2 gap-6">
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-lg font-medium text-brand-primary mb-3">Core Functionality</h3>
                <ul className="text-text-secondary text-sm space-y-1">
                  <li>• Calculating distances to sightings</li>
                  <li>• Sending location-based alerts</li>
                  <li>• Enriching reports with environmental data</li>
                  <li>• Enabling community discussion</li>
                </ul>
              </div>
              
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-lg font-medium text-brand-primary mb-3">Never Used For</h3>
                <ul className="text-text-secondary text-sm space-y-1">
                  <li>• Advertising or marketing</li>
                  <li>• Selling to third parties</li>
                  <li>• Building user profiles</li>
                  <li>• Tracking your movements or creating location history</li>
                </ul>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">Data Sharing and Disclosure</h2>
            
            <div className="bg-semantic-warning bg-opacity-10 border border-semantic-warning border-opacity-20 rounded-lg p-6 mb-6">
              <h3 className="text-lg font-semibold text-semantic-warning mb-2">Public Information</h3>
              <p className="text-text-secondary text-sm">
                Sighting reports, jittered coordinates, and chat messages are public by default. 
                Photos/videos are only shared if you explicitly choose to upload them.
              </p>
            </div>

            <div className="bg-dark-surface border border-dark-border rounded-lg p-6 mb-6">
              <h3 className="text-xl font-medium text-brand-primary mb-3">We May Share Data When:</h3>
              <ul className="text-text-secondary space-y-2">
                <li>• <strong>Legal Requirements:</strong> Complying with valid legal process</li>
                <li>• <strong>Safety Concerns:</strong> Preventing harm to users or others</li>
                <li>• <strong>Service Providers:</strong> Third-party services that help us operate (with data processing agreements)</li>
                <li>• <strong>Business Transfer:</strong> In case of merger or acquisition (users will be notified)</li>
              </ul>
            </div>

            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h3 className="text-xl font-medium text-brand-primary mb-3">Third-Party Service Providers</h3>
              <p className="text-text-secondary mb-3">
                We work with trusted service providers who process data on our behalf:
              </p>
              <ul className="text-text-secondary space-y-2">
                <li>• <strong>Google (Firebase, Analytics):</strong> Authentication, analytics, and push notifications</li>
                <li>• <strong>Sentry:</strong> Error tracking and performance monitoring</li>
                <li>• <strong>Cloud Infrastructure:</strong> Hosting and data storage providers</li>
              </ul>
              <p className="text-text-secondary text-sm mt-3">
                All third-party providers are required to maintain appropriate security measures and
                use data only for the purposes we specify. We carefully vet all service providers for
                GDPR compliance and data protection standards.
              </p>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">Background Location Monitoring</h2>

            <div className="bg-brand-primary bg-opacity-10 border border-brand-primary border-opacity-20 rounded-lg p-6 mb-6">
              <h3 className="text-lg font-semibold text-brand-primary mb-2">🛸 Why We Monitor Location</h3>
              <p className="text-text-secondary text-sm">
                UFOBeep monitors your location in the background to send you proximity alerts when UFO sightings
                happen near your current location, even when you&apos;re away from home or traveling.
              </p>
            </div>

            <div className="bg-dark-surface border border-dark-border rounded-lg p-6 mb-6">
              <h3 className="text-xl font-medium text-brand-primary mb-3">How Background Monitoring Works</h3>
              <ul className="text-text-secondary space-y-2">
                <li>• <strong>Intelligent Geofencing:</strong> Creates invisible 2km boundaries around your location</li>
                <li>• <strong>Movement Detection:</strong> Only activates when you cross geofence boundaries</li>
                <li>• <strong>1km Threshold:</strong> Location updates only when you move more than 1km</li>
                <li>• <strong>Rate Limited:</strong> Maximum one update every 10 minutes to prevent server overload</li>
                <li>• <strong>Battery Optimized:</strong> Uses system-managed geofences with &lt;3% battery impact</li>
                <li>• <strong>Always Permission:</strong> Requires &quot;Always Allow&quot; location permission for background operation</li>
              </ul>
            </div>

            <div className="bg-semantic-info bg-opacity-10 border border-semantic-info border-opacity-20 rounded-lg p-6">
              <h3 className="text-lg font-semibold text-semantic-info mb-2">🔋 Battery & Privacy</h3>
              <ul className="text-text-secondary text-sm space-y-2">
                <li>• <strong>No Continuous GPS:</strong> Uses system geofences instead of constant location polling</li>
                <li>• <strong>No Location History:</strong> Only your current location is stored, not where you&apos;ve been</li>
                <li>• <strong>User Control:</strong> Can be disabled anytime in app settings</li>
                <li>• <strong>Transparent Operation:</strong> Location tracking status visible in app settings</li>
              </ul>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">Comments and Discussion</h2>

            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <p className="text-text-secondary mb-4">
                UFOBeep includes a commenting system for sighting discussions:
              </p>
              <ul className="text-text-secondary space-y-2">
                <li>• <strong>Public Comments:</strong> Comments on sightings are visible to all users</li>
                <li>• <strong>Moderation:</strong> Comments are subject to community guidelines</li>
                <li>• <strong>User Control:</strong> You can edit or delete your own comments</li>
                <li>• <strong>Data Storage:</strong> Comments are stored securely on our servers</li>
              </ul>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">Your Rights and Controls</h2>
            
            <div className="grid md:grid-cols-2 gap-6">
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-lg font-medium text-brand-primary mb-3">Access & Control</h3>
                <ul className="text-text-secondary text-sm space-y-1">
                  <li>• View all data we have about you</li>
                  <li>• Export your sighting reports and account data</li>
                  <li>• Delete individual reports</li>
                  <li>• Adjust privacy settings</li>
                  <li>• Disconnect Google Sign-In</li>
                  <li>• Opt out of analytics (device settings)</li>
                </ul>
              </div>

              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-lg font-medium text-brand-primary mb-3">Account Deletion</h3>
                <ul className="text-text-secondary text-sm space-y-1">
                  <li>• Permanently delete your account</li>
                  <li>• Remove personal information</li>
                  <li>• Delete device information</li>
                  <li>• Remove Google Sign-In connection</li>
                  <li>• Anonymous reports remain public</li>
                  <li>• Comments on reports remain public</li>
                </ul>
              </div>
            </div>

            <div className="bg-semantic-info bg-opacity-10 border border-semantic-info border-opacity-20 rounded-lg p-6 mt-6">
              <h3 className="text-lg font-semibold text-semantic-info mb-2">GDPR Rights</h3>
              <p className="text-text-secondary text-sm mb-3">
                If you&apos;re in the European Economic Area, you have additional rights under GDPR:
              </p>
              <ul className="text-text-secondary text-sm space-y-1">
                <li>• <strong>Right to Access:</strong> Request a copy of all your personal data</li>
                <li>• <strong>Right to Rectification:</strong> Correct inaccurate personal data</li>
                <li>• <strong>Right to Erasure:</strong> Request deletion of your personal data</li>
                <li>• <strong>Right to Portability:</strong> Receive your data in a machine-readable format</li>
                <li>• <strong>Right to Object:</strong> Object to processing of your personal data</li>
                <li>• <strong>Right to Restrict:</strong> Request restriction of processing</li>
              </ul>
              <p className="text-text-secondary text-sm mt-3">
                To exercise any of these rights, contact us at support@ufobeep.com
              </p>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">Data Security</h2>
            
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <div className="grid md:grid-cols-3 gap-6">
                <div>
                  <h4 className="font-semibold text-brand-primary mb-2">🔐 Encryption</h4>
                  <p className="text-text-secondary text-sm">
                    All data encrypted in transit and at rest using industry-standard protocols.
                  </p>
                </div>
                <div>
                  <h4 className="font-semibold text-brand-primary mb-2">🛡️ Access Control</h4>
                  <p className="text-text-secondary text-sm">
                    Strict access controls and regular security audits of our systems.
                  </p>
                </div>
                <div>
                  <h4 className="font-semibold text-brand-primary mb-2">🔍 Monitoring</h4>
                  <p className="text-text-secondary text-sm">
                    Continuous monitoring for unauthorized access or data breaches.
                  </p>
                </div>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">Data Retention</h2>
            
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <ul className="text-text-secondary space-y-3">
                <li>• <strong>Sighting Reports:</strong> Retained indefinitely for research and community benefit</li>
                <li>• <strong>Account Data:</strong> Deleted within 30 days of account closure</li>
                <li>• <strong>Location Data:</strong> Current location only; precise coordinates discarded after jittering (within 24 hours)</li>
                <li>• <strong>Device Information:</strong> Updated when app version changes; deleted with account closure</li>
                <li>• <strong>Google Sign-In Data:</strong> Email and profile stored until account deletion or disconnect</li>
                <li>• <strong>Analytics Data:</strong> Aggregated and anonymized, retained for 26 months (Google/Firebase standard)</li>
                <li>• <strong>Error Logs:</strong> Sentry crash reports retained for 90 days</li>
                <li>• <strong>Cookies:</strong> Website cookies expire after 13 months (analytics) or session end (essential)</li>
              </ul>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">Contact Information</h2>
            
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <p className="text-text-secondary mb-4">
                Questions about this privacy policy or your data? Contact us at:
              </p>
              <ul className="text-text-secondary space-y-2">
                <li>• <strong>Email:</strong> support@ufobeep.com</li>
              </ul>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-text-primary mb-4">Changes to This Policy</h2>
            
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <p className="text-text-secondary mb-3">
                We may update this privacy policy from time to time. When we do:
              </p>
              <ul className="text-text-secondary space-y-2">
                <li>• We&apos;ll update the &quot;Last updated&quot; date at the top</li>
                <li>• We&apos;ll notify users of material changes via email or app notification</li>
                <li>• Previous versions will be available in our GitHub repository</li>
                <li>• You&apos;ll have 30 days to review changes before they take effect</li>
              </ul>
            </div>
          </section>

          <div className="mt-12 text-center">
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/terms" className="text-brand-primary hover:text-brand-primary-light transition-colors">
                Terms of Service
              </Link>
              <Link href="/safety" className="text-brand-primary hover:text-brand-primary-light transition-colors">
                Safety Guidelines
              </Link>
              <a href="mailto:support@ufobeep.com" className="text-brand-primary hover:text-brand-primary-light transition-colors">
                Contact Support
              </a>
            </div>
          </div>
        </div>
      </div>
    </main>
  )
}