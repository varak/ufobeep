'use client'

import { notFound } from 'next/navigation'
import { useClientTranslations } from '@/hooks/useClientTranslations'
import GlobalSightingNetwork from '@/components/GlobalSightingNetwork'

interface BeepPageProps {
  params: { locale: string }
}

export default function BeepLocalePage({ params }: BeepPageProps) {
  const { locale } = params
  const { t } = useClientTranslations('beep', locale)
  
  // Valid locales - should match your supported languages
  const validLocales = ['en', 'es', 'de', 'fr', 'pt', 'ru', 'ja', 'zh', 'it', 'ar', 'ko', 'tr', 'hi', 'pl', 'cs', 'nl', 'sv', 'da', 'no', 'fi', 'el', 'he']
  
  if (!validLocales.includes(locale)) {
    notFound()
  }
  
  return (
    <div className="min-h-screen bg-dark-background text-text-primary">
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-6xl mx-auto">
          <h1 className="text-3xl font-bold text-text-primary mb-2">
            {t('title')}
          </h1>
          <p className="text-text-secondary mb-8">
            {t('subtitle')}
          </p>
          
          <GlobalSightingNetwork />
        </div>
      </div>
    </div>
  )
}