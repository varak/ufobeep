'use client'

import Link from 'next/link'
import { useState } from 'react'

export default function AppDownloadCTA() {
  const [hoveredStore, setHoveredStore] = useState<string | null>(null)

  const stores = [
    {
      id: 'ios',
      name: 'App Store',
      icon: '📱',
      subtitle: 'Download for iOS',
      color: 'bg-gradient-to-r from-blue-600 to-blue-700',
      hoverColor: 'hover:from-blue-500 hover:to-blue-600'
    },
    {
      id: 'android', 
      name: 'Google Play',
      icon: '🤖',
      subtitle: 'Get it on Android',
      color: 'bg-gradient-to-r from-green-600 to-green-700',
      hoverColor: 'hover:from-green-500 hover:to-green-600'
    }
  ]

  return (
    <section className="py-16 px-6 md:px-24 bg-gradient-to-br from-dark-background via-dark-surface to-dark-surface-elevated">
      <div className="max-w-4xl mx-auto text-center">
        {/* Header */}
        <div className="mb-12">
          <div className="text-5xl mb-4 animate-bounce">🚀</div>
          <h2 className="text-3xl md:text-4xl font-bold mb-4 text-text-primary">
            Ready to Start Exploring?
          </h2>
          <p className="text-lg text-text-secondary max-w-2xl mx-auto">
            Join thousands of observers worldwide. Download UFOBeep and be part of the next generation 
            of citizen science and anomaly investigation.
          </p>
        </div>

        {/* Download Options */}
        <div className="grid sm:grid-cols-2 gap-6 mb-12 max-w-xl mx-auto">
          {stores.map((store) => (
            <Link 
              key={store.id}
              href="/app"
              className="block group"
              onMouseEnter={() => setHoveredStore(store.id)}
              onMouseLeave={() => setHoveredStore(null)}
            >
              <div className={`
                relative p-6 rounded-xl border-2 transition-all duration-300 
                ${hoveredStore === store.id 
                  ? 'border-brand-primary bg-dark-surface-elevated transform scale-105 shadow-glow' 
                  : 'border-dark-border bg-dark-surface hover:border-dark-border-light'
                }
              `}>
                <div className="text-3xl mb-3">{store.icon}</div>
                <h3 className="font-semibold text-text-primary mb-1">{store.name}</h3>
                <p className="text-sm text-text-secondary">{store.subtitle}</p>
                
                {/* Hover effect indicator */}
                <div className={`
                  absolute inset-0 rounded-xl transition-opacity duration-300 pointer-events-none
                  bg-gradient-to-br from-brand-primary/5 to-brand-primary/10
                  ${hoveredStore === store.id ? 'opacity-100' : 'opacity-0'}
                `} />
              </div>
            </Link>
          ))}
        </div>

        {/* Features teaser */}
        <div className="grid sm:grid-cols-2 md:grid-cols-4 gap-4 mb-10">
          <div className="p-4 bg-dark-surface rounded-lg border border-dark-border">
            <div className="text-2xl mb-2">🔔</div>
            <div className="text-sm text-text-primary font-medium">Real-time Alerts</div>
          </div>
          <div className="p-4 bg-dark-surface rounded-lg border border-dark-border">
            <div className="text-2xl mb-2">🧭</div>
            <div className="text-sm text-text-primary font-medium">Assisted Navigation</div>
          </div>
          <div className="p-4 bg-dark-surface rounded-lg border border-dark-border">
            <div className="text-2xl mb-2">💬</div>
            <div className="text-sm text-text-primary font-medium">Community Chat</div>
          </div>
          <div className="p-4 bg-dark-surface rounded-lg border border-dark-border">
            <div className="text-2xl mb-2">📊</div>
            <div className="text-sm text-text-primary font-medium">Smart Analysis</div>
          </div>
        </div>

        {/* Version & Compatibility Info */}
        <div className="text-center">
          <p className="text-sm text-text-tertiary mb-4">
            Beta v1.0.0-beta.5 "the Nikolai Build" • Compatible with iOS 13+, Android 7+ • Free to download
          </p>
          <div className="flex justify-center gap-6 text-xs text-text-tertiary">
            <span>🔒 Privacy-focused</span>
            <span>📱 Real-time alerts</span>
            <span>🌍 Global network</span>
            <span>📸 Photo capture</span>
          </div>
        </div>
      </div>
    </section>
  )
}