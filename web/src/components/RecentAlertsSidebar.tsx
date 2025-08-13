'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import AlertCard from './AlertCard'

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

interface RecentAlertsSidebarProps {
  alerts?: Alert[]
  loading?: boolean
}

export default function RecentAlertsSidebar({ alerts = [], loading = false }: RecentAlertsSidebarProps) {

  if (loading) {
    return (
      <div className="space-y-4">
        <h3 className="text-xl font-semibold text-text-primary mb-4">Latest Activity</h3>
        <div className="space-y-3">
          {[1, 2, 3].map((i) => (
            <div key={i} className="p-4 bg-dark-surface rounded-lg border border-dark-border animate-pulse">
              <div className="h-4 bg-dark-border rounded w-3/4 mb-2"></div>
              <div className="h-3 bg-dark-border rounded w-1/2 mb-2"></div>
              <div className="h-3 bg-dark-border rounded w-2/3"></div>
            </div>
          ))}
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-4">
      <h3 className="text-xl font-semibold text-text-primary mb-4">Latest Activity</h3>
      
      {alerts.length === 0 ? (
        <div className="text-center py-8">
          <div className="text-3xl mb-2">👁️</div>
          <p className="text-text-secondary text-sm">No recent alerts</p>
        </div>
      ) : (
        <div className="space-y-3">
          {alerts.map((alert) => (
            <AlertCard key={alert.id} alert={alert} compact={true} />
          ))}
        </div>
      )}
      
      <Link href="/alerts">
        <button className="w-full mt-4 p-3 border border-brand-primary text-brand-primary rounded-lg hover:bg-brand-primary hover:text-text-inverse transition-colors font-medium">
          View All Reports →
        </button>
      </Link>
    </div>
  )
}