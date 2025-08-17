'use client'

import { useState } from 'react'
import Image from 'next/image'

export default function ShareToBeepPromo() {
  const [selectedTab, setSelectedTab] = useState<'photo' | 'video'>('photo')

  return (
    <section className="py-20 px-6 md:px-24 bg-dark-surface">
      <div className="max-w-6xl mx-auto">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-bold mb-6 text-text-primary">
            Share-to-Beep: Premium Workflow
          </h2>
          <p className="text-lg text-text-secondary mb-8 max-w-3xl mx-auto">
            Got a great photo or video on your phone? Share it directly to UFOBeep from any app! 
            This is our premium feature that makes reporting sightings incredibly easy.
          </p>
          <div className="flex justify-center items-center gap-2 text-brand-primary">
            <span className="text-2xl">✨</span>
            <span className="font-semibold">Record natively → Share to beep → Instant alert</span>
            <span className="text-2xl">✨</span>
          </div>
        </div>

        {/* Tab Selection */}
        <div className="flex justify-center mb-12">
          <div className="bg-dark-background rounded-lg p-1 border border-dark-border">
            <button
              onClick={() => setSelectedTab('photo')}
              className={`px-6 py-3 rounded-md font-medium transition-all ${
                selectedTab === 'photo'
                  ? 'bg-brand-primary text-text-inverse shadow-md'
                  : 'text-text-secondary hover:text-text-primary'
              }`}
            >
              📷 Photos
            </button>
            <button
              onClick={() => setSelectedTab('video')}
              className={`px-6 py-3 rounded-md font-medium transition-all ${
                selectedTab === 'video'
                  ? 'bg-brand-primary text-text-inverse shadow-md'
                  : 'text-text-secondary hover:text-text-primary'
              }`}
            >
              🎥 Videos
            </button>
          </div>
        </div>

        {/* Content based on selected tab */}
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Instructions */}
          <div>
            <h3 className="text-2xl font-bold mb-6 text-text-primary">
              How to Share {selectedTab === 'photo' ? 'Photos' : 'Videos'} to UFOBeep
            </h3>
            
            <div className="space-y-6">
              <div className="flex gap-4">
                <div className="flex-shrink-0 w-8 h-8 bg-brand-primary text-text-inverse rounded-full flex items-center justify-center font-bold">
                  1
                </div>
                <div>
                  <h4 className="font-semibold text-text-primary mb-2">
                    {selectedTab === 'photo' ? 'Take a Photo' : 'Record a Video'}
                  </h4>
                  <p className="text-text-secondary">
                    {selectedTab === 'photo' 
                      ? 'Use your native camera app to capture high-quality photos. Native cameras often have higher megapixel counts and better image processing.'
                      : 'Record videos with your native camera app for the best quality and length. Native recording gives you full control over resolution and duration.'
                    }
                  </p>
                </div>
              </div>

              <div className="flex gap-4">
                <div className="flex-shrink-0 w-8 h-8 bg-brand-primary text-text-inverse rounded-full flex items-center justify-center font-bold">
                  2
                </div>
                <div>
                  <h4 className="font-semibold text-text-primary mb-2">
                    Find the Share Button
                  </h4>
                  <p className="text-text-secondary">
                    In your gallery or camera app, tap the share button (usually looks like 
                    <span className="inline-block mx-1 px-2 py-1 bg-dark-background rounded text-brand-primary">📤</span>
                    or three connected dots).
                  </p>
                </div>
              </div>

              <div className="flex gap-4">
                <div className="flex-shrink-0 w-8 h-8 bg-brand-primary text-text-inverse rounded-full flex items-center justify-center font-bold">
                  3
                </div>
                <div>
                  <h4 className="font-semibold text-text-primary mb-2">
                    Select UFOBeep
                  </h4>
                  <p className="text-text-secondary">
                    Look for the UFOBeep app in your share sheet and tap it. The {selectedTab} will be 
                    automatically imported with all metadata preserved.
                  </p>
                </div>
              </div>

              <div className="flex gap-4">
                <div className="flex-shrink-0 w-8 h-8 bg-brand-primary text-text-inverse rounded-full flex items-center justify-center font-bold">
                  4
                </div>
                <div>
                  <h4 className="font-semibold text-text-primary mb-2">
                    Add Description & Send
                  </h4>
                  <p className="text-text-secondary">
                    UFOBeep opens with your {selectedTab} ready to send. Add a description of what you saw, 
                    and tap &ldquo;Send Beep!&rdquo; to alert nearby observers instantly.
                  </p>
                </div>
              </div>
            </div>

            <div className="mt-8 p-6 bg-dark-background rounded-lg border border-brand-primary/30">
              <div className="flex items-center gap-3 mb-3">
                <span className="text-2xl">💡</span>
                <h4 className="font-semibold text-brand-primary">Pro Tip</h4>
              </div>
              <p className="text-text-secondary">
                {selectedTab === 'photo' 
                  ? 'Photos shared this way keep all their GPS and camera metadata, making them perfect for astronomical identification services and precise location tracking.'
                  : 'Videos shared from your gallery can be any length and quality. For quick captures, you can also record short videos directly in the UFOBeep app.'
                }
              </p>
            </div>
          </div>

          {/* Visual demonstration */}
          <div className="relative">
            <div className="bg-gradient-to-br from-brand-primary/20 to-brand-primary/5 rounded-2xl p-8 border border-brand-primary/30">
              <div className="text-center">
                <div className="text-6xl mb-6">
                  {selectedTab === 'photo' ? '📸' : '🎥'}
                </div>
                <h4 className="text-xl font-bold text-text-primary mb-4">
                  Share from Any App
                </h4>
                <div className="grid grid-cols-3 gap-4 mb-6">
                  <div className="bg-dark-surface p-3 rounded-lg text-center">
                    <div className="text-2xl mb-2">📱</div>
                    <div className="text-sm text-text-secondary">Camera</div>
                  </div>
                  <div className="bg-dark-surface p-3 rounded-lg text-center">
                    <div className="text-2xl mb-2">🖼️</div>
                    <div className="text-sm text-text-secondary">Gallery</div>
                  </div>
                  <div className="bg-dark-surface p-3 rounded-lg text-center">
                    <div className="text-2xl mb-2">☁️</div>
                    <div className="text-sm text-text-secondary">Cloud</div>
                  </div>
                </div>
                
                <div className="flex items-center justify-center gap-3 mb-6">
                  <div className="text-2xl">📤</div>
                  <div className="flex-1 h-1 bg-brand-primary rounded"></div>
                  <div className="text-2xl">🛸</div>
                </div>
                
                <div className="bg-brand-primary/10 border border-brand-primary/30 rounded-lg p-4">
                  <div className="text-brand-primary font-semibold">
                    ⚡ Instant Alert Sent!
                  </div>
                  <div className="text-sm text-text-secondary mt-1">
                    Nearby observers notified in &lt;2 seconds
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Download CTA */}
        <div className="text-center mt-16">
          <div className="bg-dark-background rounded-2xl p-8 border border-brand-primary/30 max-w-2xl mx-auto">
            <h3 className="text-2xl font-bold text-text-primary mb-4">
              Ready to Try Share-to-Beep?
            </h3>
            <p className="text-text-secondary mb-6">
              Download UFOBeep and experience the easiest way to report sightings. 
              Your first shared {selectedTab} is just three taps away.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <a
                href="/app"
                className="bg-brand-primary text-text-inverse px-8 py-3 rounded-lg font-semibold hover:bg-brand-primary-dark transition-all duration-300 shadow-glow hover:shadow-xl hover:scale-105 transform"
              >
                Download UFOBeep
              </a>
              <a
                href="/alerts"
                className="border border-brand-primary text-brand-primary px-8 py-3 rounded-lg font-semibold hover:bg-brand-primary hover:text-text-inverse transition-all duration-300 hover:scale-105 transform"
              >
                See Recent Alerts
              </a>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}