import Link from 'next/link'

export default function SafetyPage() {
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
            Safety Guidelines
          </h1>
          <p className="text-lg text-text-secondary">
            Your safety and well-being come first. Always.
          </p>
        </div>

        {/* Critical Safety Notice */}
        <div className="bg-semantic-error bg-opacity-10 border-2 border-semantic-error border-opacity-30 rounded-lg p-8 mb-8">
          <div className="flex items-start gap-4">
            <div className="text-4xl">🚨</div>
            <div>
              <h2 className="text-2xl font-semibold text-semantic-error mb-4">Critical Safety Notice</h2>
              <p className="text-text-secondary text-lg mb-4">
                <strong>Never put yourself in danger to investigate a sighting.</strong> UFOBeep is designed to help you report and discuss anomalous events safely, not to encourage risky behavior.
              </p>
              <ul className="text-text-secondary space-y-2">
                <li>• If you feel unsafe, leave the area immediately and contact authorities</li>
                <li>• Don't trespass on private property or enter restricted areas</li>
                <li>• Never approach aircraft, vehicles, or unknown objects directly</li>
                <li>• Use common sense and trust your instincts</li>
              </ul>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="prose prose-invert max-w-none">
          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">🛡️ Personal Safety First</h2>
            
            <div className="grid md:grid-cols-2 gap-6">
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-lg font-medium text-brand-primary mb-3">Before Investigating</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• Tell someone where you're going and when you'll return</li>
                  <li>• Bring a fully charged phone and emergency supplies</li>
                  <li>• Check weather conditions and dress appropriately</li>
                  <li>• Don't investigate alone, especially at night</li>
                  <li>• Research the area for potential hazards</li>
                </ul>
              </div>
              
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-lg font-medium text-brand-primary mb-3">While Investigating</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• Maintain a safe distance from any objects or phenomena</li>
                  <li>• Don't touch or disturb anything you find</li>
                  <li>• Be aware of your surroundings at all times</li>
                  <li>• If you feel unwell or disoriented, leave immediately</li>
                  <li>• Document from a distance using zoom features</li>
                </ul>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">🧭 Navigation Safety</h2>
            
            <div className="bg-semantic-warning bg-opacity-10 border border-semantic-warning border-opacity-20 rounded-lg p-6 mb-6">
              <h3 className="text-lg font-semibold text-semantic-warning mb-3">⚠️ Compass & AR Navigation Warnings</h3>
              <p className="text-text-secondary mb-3">
                UFOBeep's compass and AR features are tools to assist navigation, not replace common sense or safety precautions.
              </p>
            </div>

            <div className="grid md:grid-cols-2 gap-6">
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-lg font-medium text-brand-primary mb-3">Standard Mode Safety</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• Don't stare at your phone while walking</li>
                  <li>• Look up frequently to avoid obstacles</li>
                  <li>• Use voice navigation when possible</li>
                  <li>• Stop navigation if you enter unsafe terrain</li>
                  <li>• Compass accuracy can be affected by magnetic interference</li>
                </ul>
              </div>
              
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-lg font-medium text-brand-primary mb-3">Pilot Mode Safety</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• <strong>Ground use only</strong> - never use while actually piloting</li>
                  <li>• Magnetic declination may affect accuracy</li>
                  <li>• Don't rely solely on app for aviation navigation</li>
                  <li>• Follow all aviation regulations and safety protocols</li>
                  <li>• Cross-reference with official aviation tools</li>
                </ul>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">🚗 Transportation Safety</h2>
            
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <h3 className="text-xl font-medium text-brand-primary mb-3">Driving to Sightings</h3>
              <div className="grid md:grid-cols-2 gap-6">
                <div>
                  <h4 className="font-semibold text-text-primary mb-2">Safe Driving Practices:</h4>
                  <ul className="text-text-secondary text-sm space-y-1">
                    <li>• Pull over safely to check app notifications</li>
                    <li>• Use hands-free navigation only</li>
                    <li>• Don't drive to remote areas alone at night</li>
                    <li>• Ensure your vehicle is in good condition</li>
                    <li>• Bring emergency supplies and tools</li>
                  </ul>
                </div>
                <div>
                  <h4 className="font-semibold text-text-primary mb-2">Parking & Access:</h4>
                  <ul className="text-text-secondary text-sm space-y-1">
                    <li>• Park legally and safely</li>
                    <li>• Don't block emergency access roads</li>
                    <li>• Respect private property boundaries</li>
                    <li>• Leave no trace - clean up after yourself</li>
                    <li>• Be considerate of local residents</li>
                  </ul>
                </div>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">📱 Digital Safety & Privacy</h2>
            
            <div className="space-y-6">
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-xl font-medium text-brand-primary mb-3">Protecting Your Privacy</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• Your exact location is automatically jittered (offset) for privacy</li>
                  <li>• Use pseudonyms rather than real names when possible</li>
                  <li>• Be cautious about sharing identifying details in photos</li>
                  <li>• Review privacy settings regularly</li>
                  <li>• Consider what metadata your photos might contain</li>
                </ul>
              </div>

              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-xl font-medium text-brand-primary mb-3">Online Interactions</h3>
                <div className="grid md:grid-cols-2 gap-6">
                  <div>
                    <h4 className="font-semibold text-text-primary mb-2">In Chat Rooms:</h4>
                    <ul className="text-text-secondary text-sm space-y-1">
                      <li>• Don't share personal information</li>
                      <li>• Report harassment or abuse immediately</li>
                      <li>• Block users who make you uncomfortable</li>
                      <li>• Don't arrange private meetups with strangers</li>
                    </ul>
                  </div>
                  <div>
                    <h4 className="font-semibold text-text-primary mb-2">Sharing Content:</h4>
                    <ul className="text-text-secondary text-sm space-y-1">
                      <li>• Remove identifying details from photos</li>
                      <li>• Don't include license plates, addresses, or faces</li>
                      <li>• Be mindful of what's in the background</li>
                      <li>• Respect others' privacy in your reports</li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">🏛️ Legal Considerations</h2>
            
            <div className="grid md:grid-cols-2 gap-6">
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-lg font-medium text-brand-primary mb-3">Property Rights</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• Never trespass on private property</li>
                  <li>• Respect "No Trespassing" signs</li>
                  <li>• Stay on public roads and paths</li>
                  <li>• Ask permission before entering private land</li>
                  <li>• Know your local right-to-roam laws</li>
                </ul>
              </div>
              
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-lg font-medium text-brand-primary mb-3">Photography & Recording</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• Follow local photography laws</li>
                  <li>• Don't photograph people without consent</li>
                  <li>• Respect no-photography zones</li>
                  <li>• Be aware of aviation photography restrictions</li>
                  <li>• Consider others' privacy when posting</li>
                </ul>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">🚁 Aviation & Military Considerations</h2>
            
            <div className="bg-semantic-warning bg-opacity-10 border border-semantic-warning border-opacity-20 rounded-lg p-6 mb-6">
              <h3 className="text-lg font-semibold text-semantic-warning mb-3">⚠️ Special Precautions</h3>
              <p className="text-text-secondary">
                Many sightings occur near airports or military installations. Exercise extreme caution in these areas.
              </p>
            </div>

            <div className="space-y-6">
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-xl font-medium text-brand-primary mb-3">Near Airports & Aircraft</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• Stay away from active runways and taxiways</li>
                  <li>• Don't use bright lights or lasers that could blind pilots</li>
                  <li>• Report suspected drone activity to authorities</li>
                  <li>• Follow all airport perimeter restrictions</li>
                  <li>• Never attempt to approach aircraft</li>
                </ul>
              </div>

              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-xl font-medium text-brand-primary mb-3">Near Military Installations</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• Respect all restricted area boundaries</li>
                  <li>• Don't photograph military equipment or personnel</li>
                  <li>• Be aware that some areas have use-of-force authorization</li>
                  <li>• If approached by security, comply immediately</li>
                  <li>• Research restricted areas before traveling</li>
                </ul>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">🌙 Night Safety</h2>
            
            <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
              <div className="grid md:grid-cols-2 gap-6">
                <div>
                  <h3 className="text-lg font-medium text-brand-primary mb-3">Essential Night Equipment</h3>
                  <ul className="text-text-secondary space-y-2">
                    <li>• Red flashlight (preserves night vision)</li>
                    <li>• Extra batteries and backup light</li>
                    <li>• Reflective clothing or vest</li>
                    <li>• Emergency whistle</li>
                    <li>• First aid supplies</li>
                  </ul>
                </div>
                <div>
                  <h3 className="text-lg font-medium text-brand-primary mb-3">Night Safety Protocols</h3>
                  <ul className="text-text-secondary space-y-2">
                    <li>• Never investigate alone after dark</li>
                    <li>• Stick to well-lit, familiar areas</li>
                    <li>• Let others know your exact location</li>
                    <li>• Set a check-in schedule</li>
                    <li>• Trust your instincts about unsafe situations</li>
                  </ul>
                </div>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">📞 Emergency Procedures</h2>
            
            <div className="space-y-6">
              <div className="bg-semantic-error bg-opacity-10 border border-semantic-error border-opacity-20 rounded-lg p-6">
                <h3 className="text-xl font-semibold text-semantic-error mb-3">🚨 When to Contact Authorities</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• <strong>Immediate danger to yourself or others</strong></li>
                  <li>• Aircraft in distress or making emergency landings</li>
                  <li>• Suspicious activity near critical infrastructure</li>
                  <li>• Environmental hazards (fires, chemical spills, etc.)</li>
                  <li>• When asked to leave an area by officials</li>
                </ul>
              </div>

              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-xl font-medium text-brand-primary mb-3">Emergency Contacts</h3>
                <div className="grid md:grid-cols-2 gap-6">
                  <div>
                    <h4 className="font-semibold text-text-primary mb-2">Primary Emergency:</h4>
                    <ul className="text-text-secondary space-y-1">
                      <li>• <strong>911</strong> (US) or local emergency number</li>
                      <li>• Poison Control: 1-800-222-1222</li>
                      <li>• Coast Guard: Channel 16 (VHF)</li>
                    </ul>
                  </div>
                  <div>
                    <h4 className="font-semibold text-text-primary mb-2">Aviation:</h4>
                    <ul className="text-text-secondary space-y-1">
                      <li>• FAA: 1-866-835-5322</li>
                      <li>• NTSB: 844-373-9922</li>
                      <li>• Local airport control tower</li>
                    </ul>
                  </div>
                </div>
              </div>

              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-xl font-medium text-brand-primary mb-3">What to Tell Dispatchers</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• Your exact location (GPS coordinates if available)</li>
                  <li>• Nature of the emergency or situation</li>
                  <li>• Number of people involved</li>
                  <li>• Any immediate dangers or hazards</li>
                  <li>• Your contact information</li>
                </ul>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">🤝 Community Safety</h2>
            
            <div className="space-y-6">
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-xl font-medium text-brand-primary mb-3">Looking Out for Each Other</h3>
                <div className="grid md:grid-cols-2 gap-6">
                  <div>
                    <h4 className="font-semibold text-text-primary mb-2">In the Field:</h4>
                    <ul className="text-text-secondary text-sm space-y-1">
                      <li>• Check on other investigators in your area</li>
                      <li>• Share safety information and local hazards</li>
                      <li>• Help others who seem lost or in distress</li>
                      <li>• Report unsafe behavior to moderators</li>
                    </ul>
                  </div>
                  <div>
                    <h4 className="font-semibold text-text-primary mb-2">Online:</h4>
                    <ul className="text-text-secondary text-sm space-y-1">
                      <li>• Report harassment or threats immediately</li>
                      <li>• Don't share others' personal information</li>
                      <li>• Support newcomers with safety advice</li>
                      <li>• Promote responsible investigation practices</li>
                    </ul>
                  </div>
                </div>
              </div>

              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-xl font-medium text-brand-primary mb-3">Reporting Safety Concerns</h3>
                <p className="text-text-secondary mb-4">
                  If you witness or experience unsafe behavior related to UFOBeep usage:
                </p>
                <ul className="text-text-secondary space-y-2">
                  <li>• Use the in-app reporting feature</li>
                  <li>• Email safety@ufobeep.com with details</li>
                  <li>• Contact local authorities if there's immediate danger</li>
                  <li>• Document incidents with screenshots when safe to do so</li>
                </ul>
              </div>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-text-primary mb-4">📚 Additional Resources</h2>
            
            <div className="grid md:grid-cols-2 gap-6">
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-lg font-medium text-brand-primary mb-3">Safety Training</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• Wilderness first aid certification</li>
                  <li>• Land navigation and orienteering courses</li>
                  <li>• Photography safety workshops</li>
                  <li>• Local astronomy club safety guidelines</li>
                </ul>
              </div>
              
              <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
                <h3 className="text-lg font-medium text-brand-primary mb-3">Useful Apps & Tools</h3>
                <ul className="text-text-secondary space-y-2">
                  <li>• Weather apps with radar and alerts</li>
                  <li>• Offline GPS and mapping software</li>
                  <li>• Emergency beacon apps (if available)</li>
                  <li>• Star charts and astronomy apps</li>
                </ul>
              </div>
            </div>
          </section>

          <div className="mt-12 text-center">
            <div className="bg-brand-primary bg-opacity-10 border border-brand-primary border-opacity-20 rounded-lg p-8">
              <h3 className="text-2xl font-semibold text-brand-primary mb-4">Remember</h3>
              <p className="text-text-secondary text-lg">
                No sighting is worth risking your safety or breaking the law. 
                UFOBeep is about building a responsible community of observers who prioritize safety, respect, and scientific curiosity.
              </p>
            </div>
            
            <div className="flex flex-col sm:flex-row gap-4 justify-center mt-8">
              <Link href="/terms" className="text-brand-primary hover:text-brand-primary-light transition-colors">
                Terms of Service
              </Link>
              <Link href="/privacy" className="text-brand-primary hover:text-brand-primary-light transition-colors">
                Privacy Policy
              </Link>
              <a href="mailto:safety@ufobeep.com" className="text-brand-primary hover:text-brand-primary-light transition-colors">
                Contact Safety Team
              </a>
            </div>
          </div>
        </div>
      </div>
    </main>
  )
}