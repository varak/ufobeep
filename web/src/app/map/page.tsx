'use client'

import { useEffect, useState } from 'react'
import AlertsMap from '@/components/AlertsMap'
import Link from 'next/link'

interface Alert {
  id: string
  title: string | null
  description: string | null
  location: { latitude: number; longitude: number; name: string }
  alert_level: string
  created_at: string
}

export default function MapPage() {
  const [alerts, setAlerts] = useState<Alert[]>([])
  const [loading, setLoading] = useState(false) // Don't block map rendering
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchAlerts = async () => {
      try {
        // Use dedicated map endpoint that returns ALL points
        const response = await fetch('/api/beep/map-points')
        const data = await response.json()
        if (data.success && data.data?.alerts) {
          // All points are already validated by the API
          setAlerts(data.data.alerts)
        } else {
          setError('Failed to load alerts')
        }
      } catch (e) {
        setError('Failed to connect to API')
      } finally {
        setLoading(false)
      }
    }
    fetchAlerts()
  }, [])

  return (
    <main className="min-h-screen py-6 px-4 md:px-8">
      <div className="max-w-6xl mx-auto">
        <div className="mb-4">
          <Link href="/" className="text-brand-primary hover:text-brand-primary-light">← Back to Home</Link>
        </div>
        <div className="flex items-center justify-between mb-4">
          <h1 className="text-2xl md:text-3xl font-bold">Sightings Map</h1>
          <div className="text-sm text-text-tertiary">{alerts.length} sightings</div>
        </div>

        {loading && (
          <div className="text-center py-16">
            <div className="text-5xl mb-3">🗺️</div>
            <div className="text-text-secondary">Loading map data…</div>
          </div>
        )}

        {error && (
          <div className="text-center py-16">
            <div className="text-5xl mb-3">⚠️</div>
            <div className="text-text-secondary mb-4">{error}</div>
            <div className="text-text-tertiary text-sm">Try again or switch networks.</div>
          </div>
        )}

        {/* Always show map - don't wait for data */}
        <AlertsMap alerts={alerts as any} height="70vh" />
        
        {loading && (
          <div className="absolute top-4 right-4 bg-dark-surface border border-brand-primary/20 rounded-lg px-3 py-2">
            <div className="text-sm text-brand-primary">Loading markers...</div>
          </div>
        )}
      </div>
    </main>
  )
}

