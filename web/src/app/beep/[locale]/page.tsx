'use client'

import { notFound } from 'next/navigation'
import { use, useState, useEffect } from 'react'
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
  params: Promise<{ locale: string }>
}

export default function BeepLocalePage({ params }: BeepPageProps) {
  // Unwrap promise params using React's use() hook
  const { locale: urlLocale } = use(params)

  const [alerts, setAlerts] = useState<Alert[]>([])
  const [loading, setLoading] = useState(true)
  const [currentPage, setCurrentPage] = useState(1)
  const [totalPages, setTotalPages] = useState(1)
  const [totalCount, setTotalCount] = useState(0)
  const beepsPerPage = 20

  // Valid locales - should match your supported languages
  const validLocales = ['en', 'es', 'de', 'fr', 'pt', 'ru', 'ja', 'zh', 'it', 'ar', 'ko', 'tr', 'hi', 'pl', 'cs', 'nl', 'sv', 'da', 'no', 'fi', 'el', 'he']

  // Validate locale
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

  // Restore scroll position when navigating back
  useEffect(() => {
    // Check if we're coming back from a detail page
    if (typeof window !== 'undefined' && !loading) {
      const savedScrollY = sessionStorage.getItem('beepListScrollY')
      const savedUrl = sessionStorage.getItem('beepListUrl')

      // Only restore if we're on the same URL that was saved
      if (savedScrollY && savedUrl && window.location.href === savedUrl) {
        const scrollY = parseInt(savedScrollY, 10)
        // Use requestAnimationFrame to ensure DOM is rendered
        requestAnimationFrame(() => {
          window.scrollTo(0, scrollY)
          // Clear the saved positions after successful restoration
          sessionStorage.removeItem('beepListScrollY')
          sessionStorage.removeItem('beepListUrl')
        })
      }
    }
  }, [loading]) // Depend on loading so it runs after content is loaded
  
  return (
    <div className="min-h-screen bg-dark-background text-text-primary">
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-3xl font-bold text-text-primary mb-2">
            {t('recentUfoBeepsTitle', 'Recent Beeps')}
          </h1>
          <p className="text-text-secondary mb-8">
            {t('reportsFromCommunity', 'Live UFO sighting reports from our global community and')}{' '}
            <a href="https://mufon.com" target="_blank" rel="noopener noreferrer" className="text-brand-primary hover:underline">
              MUFON
            </a>{' '}
            {t('mufonDatabase', 'database')}
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
          
          {/* Advanced Pagination Controls */}
          {!loading && alerts.length > 0 && totalPages > 1 && (
            <div className="mt-8 py-6">
              {/* Page info */}
              <div className="text-center text-text-secondary mb-4">
                {t('pageOf', 'Page {currentPage} of {totalPages} ({totalCount} total beeps)')
                  .replace('{currentPage}', currentPage.toString())
                  .replace('{totalPages}', totalPages.toString())
                  .replace('{totalCount}', totalCount.toString())}
              </div>

              {/* Pagination controls */}
              <div className="flex justify-center items-center gap-2 flex-wrap">
                {/* First page and previous */}
                <button
                  onClick={() => setCurrentPage(1)}
                  disabled={currentPage === 1}
                  className={`px-3 py-2 rounded-lg font-medium ${
                    currentPage === 1
                      ? 'bg-gray-600 text-gray-400 cursor-not-allowed'
                      : 'bg-primary-600 hover:bg-primary-700 text-white'
                  }`}
                >
                  ← {t('firstPage', 'First')}
                </button>

                <button
                  onClick={() => setCurrentPage(prev => Math.max(1, prev - 5))}
                  disabled={currentPage <= 5}
                  className={`px-3 py-2 rounded-lg font-medium ${
                    currentPage <= 5
                      ? 'bg-gray-600 text-gray-400 cursor-not-allowed'
                      : 'bg-primary-600 hover:bg-primary-700 text-white'
                  }`}
                >
                  -5
                </button>

                <button
                  onClick={() => setCurrentPage(prev => Math.max(1, prev - 1))}
                  disabled={currentPage === 1}
                  className={`px-3 py-2 rounded-lg font-medium ${
                    currentPage === 1
                      ? 'bg-gray-600 text-gray-400 cursor-not-allowed'
                      : 'bg-primary-600 hover:bg-primary-700 text-white'
                  }`}
                >
                  -1
                </button>

                {/* Page numbers around current page */}
                {(() => {
                  const pages = []
                  const startPage = Math.max(1, currentPage - 2)
                  const endPage = Math.min(totalPages, currentPage + 2)

                  // Add first page if not in range
                  if (startPage > 1) {
                    pages.push(
                      <button
                        key={1}
                        onClick={() => setCurrentPage(1)}
                        className="px-3 py-2 rounded-lg font-medium bg-gray-700 hover:bg-gray-600 text-white"
                      >
                        1
                      </button>
                    )
                    if (startPage > 2) {
                      pages.push(
                        <span key="dots1" className="px-2 text-text-secondary">...</span>
                      )
                    }
                  }

                  // Add pages around current
                  for (let i = startPage; i <= endPage; i++) {
                    pages.push(
                      <button
                        key={i}
                        onClick={() => setCurrentPage(i)}
                        className={`px-3 py-2 rounded-lg font-medium ${
                          i === currentPage
                            ? 'bg-primary-500 text-white'
                            : 'bg-gray-700 hover:bg-gray-600 text-white'
                        }`}
                      >
                        {i}
                      </button>
                    )
                  }

                  // Add last page if not in range
                  if (endPage < totalPages) {
                    if (endPage < totalPages - 1) {
                      pages.push(
                        <span key="dots2" className="px-2 text-text-secondary">...</span>
                      )
                    }
                    pages.push(
                      <button
                        key={totalPages}
                        onClick={() => setCurrentPage(totalPages)}
                        className="px-3 py-2 rounded-lg font-medium bg-gray-700 hover:bg-gray-600 text-white"
                      >
                        {totalPages}
                      </button>
                    )
                  }

                  return pages
                })()}

                {/* Next and last page */}
                <button
                  onClick={() => setCurrentPage(prev => Math.min(totalPages, prev + 1))}
                  disabled={currentPage === totalPages}
                  className={`px-3 py-2 rounded-lg font-medium ${
                    currentPage === totalPages
                      ? 'bg-gray-600 text-gray-400 cursor-not-allowed'
                      : 'bg-primary-600 hover:bg-primary-700 text-white'
                  }`}
                >
                  +1
                </button>

                <button
                  onClick={() => setCurrentPage(prev => Math.min(totalPages, prev + 5))}
                  disabled={currentPage >= totalPages - 4}
                  className={`px-3 py-2 rounded-lg font-medium ${
                    currentPage >= totalPages - 4
                      ? 'bg-gray-600 text-gray-400 cursor-not-allowed'
                      : 'bg-primary-600 hover:bg-primary-700 text-white'
                  }`}
                >
                  +5
                </button>

                <button
                  onClick={() => setCurrentPage(totalPages)}
                  disabled={currentPage === totalPages}
                  className={`px-3 py-2 rounded-lg font-medium ${
                    currentPage === totalPages
                      ? 'bg-gray-600 text-gray-400 cursor-not-allowed'
                      : 'bg-primary-600 hover:bg-primary-700 text-white'
                  }`}
                >
                  {t('lastPage', 'Last')} →
                </button>
              </div>

              {/* Jump to page input */}
              <div className="flex justify-center items-center gap-2 mt-4">
                <label className="text-text-secondary">{t('jumpToPage', 'Jump to page')}:</label>
                <input
                  type="number"
                  min="1"
                  max={totalPages}
                  placeholder={currentPage.toString()}
                  className="w-20 px-3 py-1 rounded bg-gray-700 text-white border border-gray-600 focus:border-primary-500 focus:outline-none"
                  onKeyPress={(e) => {
                    if (e.key === 'Enter') {
                      const page = parseInt((e.target as HTMLInputElement).value)
                      if (page >= 1 && page <= totalPages) {
                        setCurrentPage(page)
                      }
                      ;(e.target as HTMLInputElement).value = ''
                    }
                  }}
                />
                <span className="text-text-secondary">of {totalPages}</span>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}