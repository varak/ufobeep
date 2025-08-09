import Link from 'next/link'

export default function TermsPage() {
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
            Terms of Service
          </h1>
          <p className="text-lg text-text-secondary">
            Last updated: January 15, 2024
          </p>
        </div>

        {/* Content */}
        <div className="prose prose-invert max-w-none">
          <div className="bg-dark-surface border border-dark-border rounded-lg p-6 mb-8">
            <h2 className="text-2xl font-semibold text-brand-primary mb-4">Welcome to UFOBeep</h2>
            <p className="text-text-secondary">
              These Terms of Service govern your use of UFOBeep&apos;s mobile application, website, 
              and related services. By using UFOBeep, you agree to these terms in full.
            </p>
          </div>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">1. Acceptance of Terms</h2>
            
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <p className="text-text-secondary mb-4">
                By downloading, installing, or using the UFOBeep application or website, you agree to be bound by these Terms of Service and our Privacy Policy.
              </p>
              <ul className="text-text-secondary space-y-2">
                <li>• You must be at least 13 years old to use UFOBeep</li>
                <li>• If you&apos;re under 18, you need parental consent</li>
                <li>• You&apos;re responsible for maintaining account security</li>
                <li>• One account per person</li>
              </ul>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">2. Service Description</h2>
            
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6 mb-6">
              <h3 className="text-xl font-medium text-brand-primary mb-3">What UFOBeep Provides</h3>
              <ul className="text-text-secondary space-y-2">
                <li>• Platform for reporting and viewing sighting reports</li>
                <li>• Real-time alerts for nearby incidents</li>
                <li>• Community discussion via Matrix protocol</li>
                <li>• AR compass navigation to sighting locations</li>
                <li>• Environmental data enrichment (weather, celestial, satellites)</li>
              </ul>
            </div>

            <div className="bg-semantic-warning bg-opacity-10 border border-semantic-warning border-opacity-20 rounded-lg p-6">
              <h3 className="text-lg font-semibold text-semantic-warning mb-2">⚠️ Important Disclaimers</h3>
              <ul className="text-text-secondary space-y-2">
                <li>• UFOBeep is a community platform, not a scientific authority</li>
                <li>• We do not verify or validate the accuracy of user reports</li>
                <li>• Use navigation features at your own risk and follow local laws</li>
                <li>• Service availability may vary by location</li>
              </ul>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">3. User Responsibilities</h2>
            
            <div className="grid md:grid-cols-2 gap-6">
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-lg font-medium text-brand-primary mb-3">✅ You Agree To</h3>
                <ul className="text-text-secondary text-sm space-y-1">
                  <li>• Provide accurate information</li>
                  <li>• Respect other users and community guidelines</li>
                  <li>• Use the service lawfully</li>
                  <li>• Keep your account secure</li>
                  <li>• Report violations to our team</li>
                </ul>
              </div>
              
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-lg font-medium text-semantic-error mb-3">❌ You Agree NOT To</h3>
                <ul className="text-text-secondary text-sm space-y-1">
                  <li>• Post false, misleading, or harmful content</li>
                  <li>• Harass, threaten, or abuse other users</li>
                  <li>• Violate intellectual property rights</li>
                  <li>• Interfere with service operation</li>
                  <li>• Share inappropriate or illegal content</li>
                </ul>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">4. Content and Intellectual Property</h2>
            
            <div className="space-y-6">
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-xl font-medium text-brand-primary mb-3">Your Content</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• You retain ownership of photos, videos, and descriptions you upload</li>
                  <li>• You grant UFOBeep a license to display and distribute your content</li>
                  <li>• You&apos;re responsible for ensuring you have rights to content you share</li>
                  <li>• You can delete your content at any time through the app</li>
                </ul>
              </div>

              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-xl font-medium text-brand-primary mb-3">UFOBeep&apos;s Content</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• UFOBeep logo, design, and software are protected by copyright</li>
                  <li>• You may not copy, modify, or distribute our proprietary content</li>
                  <li>• API access requires separate agreement</li>
                  <li>• Third-party integrations subject to their own terms</li>
                </ul>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">5. Privacy and Data</h2>
            
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <p className="text-text-secondary mb-4">
                Your privacy is important to us. Our data collection and use practices are detailed in our 
                <Link href="/privacy" className="text-brand-primary hover:text-brand-primary-light transition-colors mx-1">
                  Privacy Policy
                </Link>
                , which forms part of these terms.
              </p>
              <div className="grid md:grid-cols-2 gap-6">
                <div>
                  <h4 className="font-semibold text-brand-primary mb-2">Key Points:</h4>
                  <ul className="text-text-secondary text-sm space-y-1">
                    <li>• Location data is jittered for privacy</li>
                    <li>• No personal data sales or advertising</li>
                    <li>• Matrix integration for secure chat</li>
                    <li>• Data portability rights</li>
                  </ul>
                </div>
                <div>
                  <h4 className="font-semibold text-brand-primary mb-2">Your Controls:</h4>
                  <ul className="text-text-secondary text-sm space-y-1">
                    <li>• Adjust privacy settings anytime</li>
                    <li>• Delete individual reports</li>
                    <li>• Export your data</li>
                    <li>• Close account permanently</li>
                  </ul>
                </div>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">6. Community Guidelines & Moderation</h2>
            
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6 mb-6">
              <h3 className="text-xl font-medium text-brand-primary mb-3">Community Standards</h3>
              <p className="text-text-secondary mb-4">
                UFOBeep is a platform for serious discussion of anomalous sightings. We encourage:
              </p>
              <ul className="text-text-secondary space-y-2">
                <li>• Respectful, constructive dialogue</li>
                <li>• Accurate reporting with context</li>
                <li>• Healthy skepticism and open minds</li>
                <li>• Support for fellow community members</li>
              </ul>
            </div>

            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h3 className="text-xl font-medium text-brand-primary mb-3">Moderation Policy</h3>
              <div className="grid md:grid-cols-2 gap-6">
                <div>
                  <h4 className="font-semibold text-text-primary mb-2">We May Remove:</h4>
                  <ul className="text-text-secondary text-sm space-y-1">
                    <li>• Spam or duplicate content</li>
                    <li>• Harassment or personal attacks</li>
                    <li>• Dangerous misinformation</li>
                    <li>• Copyright violations</li>
                    <li>• NSFW content without warnings</li>
                  </ul>
                </div>
                <div>
                  <h4 className="font-semibold text-text-primary mb-2">Enforcement Actions:</h4>
                  <ul className="text-text-secondary text-sm space-y-1">
                    <li>• Content removal or hiding</li>
                    <li>• Temporary account suspension</li>
                    <li>• Permanent account termination</li>
                    <li>• IP banning for severe violations</li>
                    <li>• Report to authorities if required</li>
                  </ul>
                </div>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">7. Disclaimers and Limitation of Liability</h2>
            
            <div className="bg-semantic-warning bg-opacity-10 border border-semantic-warning border-opacity-20 rounded-lg p-6 mb-6">
              <h3 className="text-lg font-semibold text-semantic-warning mb-3">⚠️ Service Disclaimer</h3>
              <p className="text-text-secondary text-sm mb-3">
                UFOBeep is provided &quot;as is&quot; without warranties of any kind. We make no guarantees about:
              </p>
              <ul className="text-text-secondary text-sm space-y-1">
                <li>• Accuracy of user-generated content</li>
                <li>• Service availability or uptime</li>
                <li>• Functionality of third-party integrations</li>
                <li>• Compatibility with all devices</li>
              </ul>
            </div>

            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h3 className="text-xl font-medium text-brand-primary mb-3">Liability Limitations</h3>
              <p className="text-text-secondary mb-4">
                To the maximum extent permitted by law, UFOBeep and its operators are not liable for:
              </p>
              <div className="grid md:grid-cols-2 gap-6">
                <div>
                  <h4 className="font-semibold text-text-primary mb-2">Direct Damages:</h4>
                  <ul className="text-text-secondary text-sm space-y-1">
                    <li>• Data loss or corruption</li>
                    <li>• Service interruptions</li>
                    <li>• Security breaches</li>
                    <li>• Technical malfunctions</li>
                  </ul>
                </div>
                <div>
                  <h4 className="font-semibold text-text-primary mb-2">Indirect Damages:</h4>
                  <ul className="text-text-secondary text-sm space-y-1">
                    <li>• Lost profits or opportunities</li>
                    <li>• Reputation damage</li>
                    <li>• Consequential losses</li>
                    <li>• Third-party claims</li>
                  </ul>
                </div>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">8. Termination</h2>
            
            <div className="grid md:grid-cols-2 gap-6">
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-lg font-medium text-brand-primary mb-3">Your Rights</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• Delete your account anytime</li>
                  <li>• Stop using the service without penalty</li>
                  <li>• Request data deletion</li>
                  <li>• Export your content before leaving</li>
                </ul>
              </div>
              
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-lg font-medium text-brand-primary mb-3">Our Rights</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• Suspend accounts for violations</li>
                  <li>• Terminate service with notice</li>
                  <li>• Remove content that violates terms</li>
                  <li>• Refuse service to repeat violators</li>
                </ul>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">9. Changes to Terms</h2>
            
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <p className="text-text-secondary mb-4">
                We may update these Terms of Service from time to time to reflect:
              </p>
              <ul className="text-text-secondary space-y-2 mb-4">
                <li>• Changes in our services</li>
                <li>• Legal or regulatory requirements</li>
                <li>• Community feedback and improvements</li>
                <li>• Security or privacy enhancements</li>
              </ul>
              <div className="border-t border-dark-border pt-4">
                <h4 className="font-semibold text-brand-primary mb-2">When Terms Change:</h4>
                <ul className="text-text-secondary text-sm space-y-1">
                  <li>• 30-day notice for material changes</li>
                  <li>• Email notification to registered users</li>
                  <li>• In-app notification on next launch</li>
                  <li>• Previous versions available on GitHub</li>
                </ul>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">10. Contact and Legal</h2>
            
            <div className="space-y-6">
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-xl font-medium text-brand-primary mb-3">Contact Information</h3>
                <p className="text-text-secondary mb-4">
                  Questions about these terms or our services? Reach out to us:
                </p>
                <ul className="text-text-secondary space-y-2">
                  <li>• <strong>Email:</strong> legal@ufobeep.com</li>
                  <li>• <strong>Matrix:</strong> @legal:ufobeep.com</li>
                  <li>• <strong>Mail:</strong> UFOBeep Legal Department, [Address]</li>
                </ul>
              </div>

              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-xl font-medium text-brand-primary mb-3">Governing Law</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• These terms are governed by [Jurisdiction] law</li>
                  <li>• Disputes resolved through binding arbitration</li>
                  <li>• Small claims court available for individual disputes</li>
                  <li>• Class action waiver applies</li>
                </ul>
              </div>
            </div>
          </section>

          <div className="mt-12 text-center">
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/privacy" className="text-brand-primary hover:text-brand-primary-light transition-colors">
                Privacy Policy
              </Link>
              <Link href="/safety" className="text-brand-primary hover:text-brand-primary-light transition-colors">
                Safety Guidelines
              </Link>
              <a href="mailto:legal@ufobeep.com" className="text-brand-primary hover:text-brand-primary-light transition-colors">
                Contact Legal Team
              </a>
            </div>
          </div>
        </div>
      </div>
    </main>
  )
}