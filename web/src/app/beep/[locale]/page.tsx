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
  const [currentPage, setCurrentPage] = useState(1)
  const [totalPages, setTotalPages] = useState(1)
  const [totalCount, setTotalCount] = useState(0)
  const beepsPerPage = 20
  
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
  const { t } = useClientTranslations('common', locale)

  useEffect(() => {
    const fetchAlerts = async () => {
      setLoading(true)
      try {
        const offset = (currentPage - 1) * beepsPerPage
        const response = await fetch(`/api/beep?limit=${beepsPerPage}&offset=${offset}`)
        const data = await response.json()
        
        if (data.success && data.data?.alerts) {
          setAlerts(data.data.alerts)
          setTotalCount(data.data.total || data.data.alerts.length)
          setTotalPages(Math.ceil((data.data.total || data.data.alerts.length) / beepsPerPage))
        }
      } catch (error) {
        console.error('Failed to fetch alerts:', error)
      } finally {
        setLoading(false)
      }
    }

    fetchAlerts()
  }, [currentPage, beepsPerPage])
  
  return (
    <div className="min-h-screen bg-dark-background text-text-primary">
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-3xl font-bold text-text-primary mb-2">
            {t('recentUfoBeepsTitle', 'Recent Beeps')}
          </h1>
          <p className="text-text-secondary mb-8">
            {t('recentUfoBeepsSubtitle', 'Live UFO sighting reports from our global community')}
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
                    locale={urlLocale}
                  />
                ))
              ) : (
                <div className="text-center py-12">
                  <div className="text-lg text-text-secondary">
                    {t('noBeepsAvailable', 'No beeps available at the moment.')}
                  </div>
                </div>
              )}
            </div>
          )}
          
          {/* Pagination Controls */}
          {!loading && alerts.length > 0 && totalPages > 1 && (
            <div className="flex justify-center items-center gap-4 mt-8 py-6">
              <button
                onClick={() => setCurrentPage(prev => Math.max(1, prev - 1))}
                disabled={currentPage === 1}
                className={`px-4 py-2 rounded-lg font-medium ${
                  currentPage === 1 
                    ? 'bg-gray-600 text-gray-400 cursor-not-allowed' 
                    : 'bg-primary-600 hover:bg-primary-700 text-white'
                }`}
              >
                ← {t('previousPage', 'Previous')}
              </button>
              
              <span className="text-text-secondary">
                {t('pageOf', 'Page {currentPage} of {totalPages} ({totalCount} total beeps)')
                  .replace('{currentPage}', currentPage.toString())
                  .replace('{totalPages}', totalPages.toString())
                  .replace('{totalCount}', totalCount.toString())}
              </span>
              
              <button
                onClick={() => setCurrentPage(prev => Math.min(totalPages, prev + 1))}
                disabled={currentPage === totalPages}
                className={`px-4 py-2 rounded-lg font-medium ${
                  currentPage === totalPages 
                    ? 'bg-gray-600 text-gray-400 cursor-not-allowed' 
                    : 'bg-primary-600 hover:bg-primary-700 text-white'
                }`}
              >
                {t('nextPage', 'Next')} →
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}