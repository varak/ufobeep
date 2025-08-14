'use client'

import { useState, useEffect, useRef } from 'react'
import MiniMap from './MiniMap'
import RecentAlertsSidebar from './RecentAlertsSidebar'

interface Alert {
  id: string
  title: string
  description: string
  category: string
  created_at: string
  location: {
    latitude: number
    longitude: number
    name: string
  }
  alert_level: string
  media_files: Array<{
    id: string
    type: string
    url: string
    thumbnail_url: string
  }>
  verification_score: number
}

export default function GlobalSightingNetwork() {
  const [alerts, setAlerts] = useState<Alert[]>([])
  const [loading, setLoading] = useState(false)
  const [hasLoaded, setHasLoaded] = useState(false)
  const sectionRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    // Delay data loading to improve initial page load
    const timer = setTimeout(() => {
      if (!hasLoaded) {
        fetchAlerts()
      }
    }, 2000) // Wait 2 seconds before loading data

    return () => clearTimeout(timer)
  }, [hasLoaded])

  const fetchAlerts = async () => {
    if (loading || hasLoaded) return
    
    setLoading(true)
    try {
      const response = await fetch('https://api.ufobeep.com/alerts?limit=12')
      const data = await response.json()
      
      if (data.success && data.data?.alerts) {
        setAlerts(data.data.alerts)
        setHasLoaded(true)
      }
    } catch (error) {
      console.error('Failed to fetch alerts:', error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <section ref={sectionRef} className="py-20 px-6 md:px-24 bg-dark-background">
      <div className="max-w-6xl mx-auto">
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold mb-6 text-text-primary">
            Global Sighting Network
          </h2>
          <p className="text-lg text-text-secondary max-w-3xl mx-auto">
            Explore real-time reports from observers around the world. Each pin represents a verified 
            sighting with community discussion, enrichment data, and navigation assistance.
          </p>
        </div>
        
        <div className="grid lg:grid-cols-3 gap-8 items-start">
          {/* Mini Map - takes up 2/3 on desktop */}
          <div className="lg:col-span-2">
            <MiniMap className="w-full" alerts={alerts} loading={loading} />
          </div>
          
          {/* Recent Activity Sidebar */}
          <RecentAlertsSidebar alerts={alerts.slice(0, 3)} loading={loading} />
        </div>
      </div>
    </section>
  )
}