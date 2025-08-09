import Link from 'next/link'

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
          <p className="text-lg text-text-secondary">
            Last updated: January 15, 2024
          </p>
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
                <li>• <strong>Precise Location:</strong> Used internally for distance calculations and alert targeting</li>
                <li>• <strong>Jittered Location:</strong> Public coordinates are randomly offset by 100-300 meters</li>
                <li>• <strong>No Historical Tracking:</strong> We don't store location history or track your movements</li>
                <li>• <strong>Opt-out Available:</strong> You can disable location services and enter coordinates manually</li>
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

            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h3 className="text-xl font-medium text-brand-primary mb-3">Account Information</h3>
              <ul className="text-text-secondary space-y-2">
                <li>• Email address (optional, for notifications only)</li>
                <li>• Display name (pseudonym encouraged)</li>
                <li>• App preferences and settings</li>
                <li>• Push notification tokens</li>
              </ul>
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
                  <li>• Location tracking or surveillance</li>
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

            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h3 className="text-xl font-medium text-brand-primary mb-3">We May Share Data When:</h3>
              <ul className="text-text-secondary space-y-2">
                <li>• <strong>Legal Requirements:</strong> Complying with valid legal process</li>
                <li>• <strong>Safety Concerns:</strong> Preventing harm to users or others</li>
                <li>• <strong>Service Providers:</strong> Third-party services that help us operate (with data processing agreements)</li>
                <li>• <strong>Business Transfer:</strong> In case of merger or acquisition (users will be notified)</li>
              </ul>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">Matrix Protocol Integration</h2>
            
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <p className="text-text-secondary mb-4">
                UFOBeep uses the Matrix protocol for chat functionality, which provides:
              </p>
              <ul className="text-text-secondary space-y-2">
                <li>• <strong>End-to-end Encryption:</strong> Your messages are encrypted between participants</li>
                <li>• <strong>Decentralized:</strong> No single point of control or failure</li>
                <li>• <strong>Federation:</strong> You can use your existing Matrix account or we'll create one</li>
                <li>• <strong>Data Portability:</strong> Your chat history belongs to you</li>
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
                  <li>• Export your sighting reports</li>
                  <li>• Delete individual reports</li>
                  <li>• Adjust privacy settings</li>
                </ul>
              </div>
              
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-lg font-medium text-brand-primary mb-3">Account Deletion</h3>
                <ul className="text-text-secondary text-sm space-y-1">
                  <li>• Permanently delete your account</li>
                  <li>• Remove personal information</li>
                  <li>• Anonymous reports remain public</li>
                  <li>• Matrix chat data handled separately</li>
                </ul>
              </div>
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
                <li>• <strong>Location Data:</strong> Precise coordinates discarded after jittering (within 24 hours)</li>
                <li>• <strong>Analytics Data:</strong> Aggregated and anonymized, retained for 2 years maximum</li>
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
                <li>• <strong>Email:</strong> privacy@ufobeep.com</li>
                <li>• <strong>Matrix:</strong> @privacy:ufobeep.com</li>
                <li>• <strong>Mail:</strong> UFOBeep Privacy Officer, [Address]</li>
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
                <li>• We'll update the "Last updated" date at the top</li>
                <li>• We'll notify users of material changes via email or app notification</li>
                <li>• Previous versions will be available in our GitHub repository</li>
                <li>• You'll have 30 days to review changes before they take effect</li>
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
              <a href="mailto:privacy@ufobeep.com" className="text-brand-primary hover:text-brand-primary-light transition-colors">
                Contact Privacy Team
              </a>
            </div>
          </div>
        </div>
      </div>
    </main>
  )
}