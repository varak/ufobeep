'use client'

import { useEffect } from 'react'

export default function AdminRedirect() {
  useEffect(() => {
    // Redirect to API admin interface
    window.location.href = 'https://api.ufobeep.com/admin'
  }, [])

  return (
    <div className="min-h-screen bg-dark-background flex items-center justify-center">
      <div className="text-center">
        <div className="animate-pulse">
          <h1 className="text-2xl font-bold text-brand-primary mb-4">🛸 UFOBeep Admin</h1>
          <p className="text-text-secondary mb-4">Redirecting to admin interface...</p>
          <div className="w-6 h-6 border-2 border-brand-primary border-t-transparent rounded-full animate-spin mx-auto"></div>
        </div>
        <p className="text-text-tertiary text-sm mt-8">
          If you're not redirected automatically, 
          <a href="https://api.ufobeep.com/admin" className="text-brand-primary hover:underline ml-1">
            click here
          </a>
        </p>
      </div>
    </div>
  )
}