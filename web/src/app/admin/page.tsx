'use client'

import { useEffect } from 'react'

export default function AdminRedirectPage() {
  useEffect(() => {
    // Redirect to the admin users page
    window.location.href = '/admin/users'
  }, [])

  return (
    <div className="min-h-screen bg-dark-background flex items-center justify-center p-4">
      <div className="max-w-md mx-auto text-center">
        <div className="text-6xl mb-6">🛸</div>
        <h1 className="text-2xl font-bold text-text-primary mb-4">Redirecting to Admin Panel</h1>
        <p className="text-text-tertiary mb-8">
          Taking you to the admin interface...
        </p>
        <a
          href="/admin/users"
          className="inline-block bg-brand-primary hover:bg-brand-primary-dark text-text-inverse px-6 py-3 rounded-lg transition-colors"
        >
          Continue to Admin Panel
        </a>
      </div>
    </div>
  )
}