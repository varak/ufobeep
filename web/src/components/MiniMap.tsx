'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import AlertsMap from './AlertsMap'

interface Alert {
  id: string
  title: string
  description: string
  location: {
    latitude: number
    longitude: number
    name: string
  }
  alert_level: string
  created_at: string
}

interface MiniMapProps {
  className?: string
}

export default function MiniMap({ className = '' }: MiniMapProps) {
  const [alerts, setAlerts] = useState<Alert[]>([])
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState({
    today: 0,
    thisWeek: 0,
    total: 0
  })

  useEffect(() => {
    fetchAlerts()
  }, [])

  const fetchAlerts = async () => {
    try {
      const response = await fetch('/api/alerts?limit=20')
      const data = await response.json()
      
      if (data.success && data.data?.alerts) {
        setAlerts(data.data.alerts)
        calculateStats(data.data.alerts)
      }
    } catch (error) {
      console.error('Failed to fetch alerts:', error)
      // Use fallback data if API fails
      setAlerts([])
    } finally {
      setLoading(false)
    }
  }

  const calculateStats = (alertsList: Alert[]) => {
    const now = new Date()
    const today = new Date(now.setHours(0, 0, 0, 0))
    const weekAgo = new Date(now.setDate(now.getDate() - 7))
    
    let todayCount = 0
    let weekCount = 0
    
    alertsList.forEach(alert => {
      const alertDate = new Date(alert.created_at)
      if (alertDate >= today) todayCount++
      if (alertDate >= weekAgo) weekCount++
    })
    
    setStats({
      today: todayCount,
      thisWeek: weekCount,
      total: alertsList.length
    })
  }

  const handleAlertClick = (alert: Alert) => {
    // Navigate to alert detail page
    window.location.href = `/alerts/${alert.id}`
  }

  return (
    <div className={`relative overflow-hidden rounded-xl border border-dark-border bg-dark-surface ${className}`}>
      {/* Map Header */}
      <div className="p-4 border-b border-dark-border">
        <div className="flex items-center justify-between">
          <h3 className="text-lg font-semibold text-text-primary">Recent Sightings</h3>
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 bg-brand-primary rounded-full animate-pulse"></div>
            <span className="text-sm text-brand-primary">Live</span>
          </div>
        </div>
        <p className="text-sm text-text-secondary mt-1">Real-time community reports worldwide</p>
      </div>

      {/* Map Area */}
      {loading ? (
        <div className="h-80 flex items-center justify-center bg-dark-background">
          <div className="text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-brand-primary mx-auto mb-4"></div>
            <p className="text-text-secondary">Loading map data...</p>
          </div>
        </div>
      ) : (
        <AlertsMap 
          alerts={alerts}
          height="320px"
          showControls={true}
          onAlertClick={handleAlertClick}
        />
      )}

      {/* Stats Footer */}
      <div className="p-4 border-t border-dark-border bg-dark-surface-elevated">
        <div className="flex justify-between items-center">
          <div className="flex gap-6">
            <div className="text-center">
              <div className="text-lg font-bold text-brand-primary">{stats.today}</div>
              <div className="text-xs text-text-secondary">Today</div>
            </div>
            <div className="text-center">
              <div className="text-lg font-bold text-text-primary">{stats.thisWeek}</div>
              <div className="text-xs text-text-secondary">This Week</div>
            </div>
            <div className="text-center">
              <div className="text-lg font-bold text-text-primary">{stats.total}</div>
              <div className="text-xs text-text-secondary">Showing</div>
            </div>
          </div>
          <Link href="/alerts" className="text-sm text-brand-primary hover:text-brand-primary-light transition-colors">
            View All →
          </Link>
        </div>
      </div>
    </div>
  )
}