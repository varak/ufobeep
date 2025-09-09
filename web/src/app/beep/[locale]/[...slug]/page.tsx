'use client'

import { notFound } from 'next/navigation'
import { useEffect, useState } from 'react'
import { useParams } from 'next/navigation'
import { generateCleanShortIdFromAlert } from '@/utils/slug'

interface PageParams {
  locale: string
  slug: string[]
}

interface Alert {
  id: string
  title: string
  description: string
  location?: {
    name: string
    latitude: number
    longitude: number
  }
  created_at: string
  alert_level: string
  witness_count: number
  total_confirmations: number
  media_files?: Array<{
    id: string
    type: string
    url: string
  }>
}

export default function AlertDetailPage() {
  const params = useParams()
  const [alert, setAlert] = useState<Alert | null>(null)
  const [loading, setLoading] = useState(true)
  
  useEffect(() => {
    async function fetchAlert() {
      try {
        const slug = params?.slug as string[]
        const locale = params?.locale as string
        if (!slug) return
        
        const fullSlug = slug.join('/')
        // Extract the first part which should be the short ID
        const shortId = fullSlug.split('-')[0]
        
        // Search through alerts to find one that generates the same short ID
        let found = false
        let offset = 0
        const limit = 100
        let targetAlert = null
        
        while (!found && offset < 500) { // Search up to 500 alerts
          const res = await fetch(`/api/alerts?limit=${limit}&offset=${offset}&verified_only=false`)
          if (!res.ok) break
          
          const data = await res.json()
          if (data.success && data.data?.alerts) {
            // Find alert whose ID generates the same clean short ID
            const matchingAlert = data.data.alerts.find((a: any) => 
              generateCleanShortIdFromAlert(a.id) === shortId
            )
            
            if (matchingAlert) {
              targetAlert = matchingAlert
              found = true
              break
            }
            
            // If we got fewer alerts than the limit, we've reached the end
            if (data.data.alerts.length < limit) break
            offset += limit
          } else {
            break
          }
        }
        
        setAlert(targetAlert)
      } catch (error) {
        console.error('Error fetching alert:', error)
        setAlert(null)
      } finally {
        setLoading(false)
      }
    }
    
    fetchAlert()
  }, [params])
  
  if (loading) {
    return (
      <main className="min-h-screen py-8 px-4 md:px-8">
        <div className="max-w-4xl mx-auto text-center">
          <div className="text-6xl mb-6">🛸</div>
          <p className="text-text-secondary">Loading beep details...</p>
        </div>
      </main>
    )
  }

  if (!alert) {
    notFound()
  }

  return (
    <main className="min-h-screen py-8 px-4 md:px-8">
      <div className="max-w-4xl mx-auto">
        <div className="mb-8">
          <a 
            href={`/beep/${params?.locale || 'en'}`}
            className="text-brand-primary hover:text-brand-primary-light transition-colors mb-4 inline-block"
          >
            ← Back to Beeps
          </a>
        </div>
        
        <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
          <h1 className="text-3xl font-bold text-text-primary mb-4">
            {alert.title}
          </h1>
          
          <div className="text-text-secondary mb-4">
            {alert.location?.name && (
              <div className="mb-2">📍 {alert.location.name}</div>
            )}
            <div>📅 {new Date(alert.created_at).toLocaleString()}</div>
          </div>
          
          {alert.description && (
            <div className="text-text-primary mb-6">
              <p className="whitespace-pre-wrap">{alert.description}</p>
            </div>
          )}
          
          {alert.media_files && alert.media_files.length > 0 && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
              {alert.media_files.map((media: any) => (
                <div key={media.id} className="bg-dark-background rounded-lg p-2">
                  {media.type === 'image' ? (
                    <img 
                      src={media.url} 
                      alt="Alert media"
                      className="w-full h-auto rounded"
                    />
                  ) : media.type === 'video' ? (
                    <video 
                      src={media.url} 
                      controls
                      className="w-full h-auto rounded"
                    />
                  ) : null}
                </div>
              ))}
            </div>
          )}
          
          <div className="flex items-center gap-4 text-sm text-text-tertiary">
            <span>🔍 Alert Level: {alert.alert_level}</span>
            <span>👥 Witnesses: {alert.witness_count || 0}</span>
            <span>✅ Confirmations: {alert.total_confirmations || 0}</span>
          </div>
        </div>
      </div>
    </main>
  )
}