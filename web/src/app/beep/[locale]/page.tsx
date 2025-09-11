'use client'

import { notFound } from 'next/navigation'
import { useState, useEffect } from 'react'
import { useClientTranslations } from '@/hooks/useClientTranslations'
import AlertCard from '@/components/AlertCard'

interface Alert {
  id: string
  title: string | null
  description: string | null
  category: string
  created_at: string
  location: {
    latitude: number
    longitude: number
    name: string
  }
  alert_level: string
  witness_count: number
  total_confirmations: number
  media_files: Array<{
    id: string
    type: string
    url: string
    thumbnail_url: string
    is_primary: boolean
    upload_order: number
    display_priority: number
  }>
  verification_score: number
  short_id?: string
}

interface BeepPageProps {
  params: { locale: string }
}

export default function BeepLocalePage({ params }: BeepPageProps) {
  // This route handles /beep/[locale] for language-specific beep listings
  const { locale: urlLocale } = params
  const [alerts, setAlerts] = useState<Alert[]>([])
  const [loading, setLoading] = useState(true)
  
  // Valid locales - should match your supported languages
  const validLocales = ['en', 'es', 'de', 'fr', 'pt', 'ru', 'ja', 'zh', 'it', 'ar', 'ko', 'tr', 'hi', 'pl', 'cs', 'nl', 'sv', 'da', 'no', 'fi', 'el', 'he']
  
  if (!validLocales.includes(urlLocale)) {
    notFound()
  }

  // Detect effective locale with priority: localStorage → URL → browser → 'en'
  const getEffectiveLocale = () => {
    if (typeof window === 'undefined') {
      return urlLocale
    }
    
    // Check localStorage preference first
    const storedLocale = localStorage.getItem('preferred-language')
    if (storedLocale && validLocales.includes(storedLocale)) {
      return storedLocale
    }
    
    // Fall back to URL locale
    return urlLocale
  }
  
  const locale = getEffectiveLocale()
  const { t } = useClientTranslations('beep', locale)

  useEffect(() => {
    const fetchAlerts = async () => {
      setLoading(true)
      try {
        const response = await fetch('/api/beep?limit=50')
        const data = await response.json()
        
        if (data.success && data.data?.alerts) {
          setAlerts(data.data.alerts)
        }
      } catch (error) {
        console.error('Failed to fetch alerts:', error)
      } finally {
        setLoading(false)
      }
    }

    fetchAlerts()
  }, [])
  
  return (
    <div className="min-h-screen bg-dark-background text-text-primary">
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-3xl font-bold text-text-primary mb-2">
            {t('title', 'Recent Beeps')}
          </h1>
          <p className="text-text-secondary mb-8">
            {t('subtitle', 'Live UFO sighting reports from our global community')}
          </p>
          
          {loading ? (
            <div className="text-center py-12">
              <div className="text-lg text-text-secondary">
                {t('loadingBeeps', 'Loading recent beeps...')}
              </div>
            </div>
          ) : (
            <div className="space-y-6">
              {alerts.length > 0 ? (
                alerts.map((alert) => (
                  <AlertCard 
                    key={alert.id} 
                    alert={alert}
                  />
                ))
              ) : (
                <div className="text-center py-12">
                  <div className="text-lg text-text-secondary">
                    No beeps available at the moment.
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}