'use client'

import { notFound, redirect } from 'next/navigation'

interface BeepPageProps {
  params: { locale: string }
}

export default function BeepLocalePage({ params }: BeepPageProps) {
  const { locale } = params
  
  // Valid locales - should match your supported languages
  const validLocales = ['en', 'es', 'de', 'fr', 'pt', 'ru', 'ja', 'zh', 'it', 'ar', 'ko', 'tr', 'hi', 'pl', 'cs', 'nl', 'sv', 'da', 'no', 'fi', 'el', 'he']
  
  if (!validLocales.includes(locale)) {
    notFound()
  }
  
  // Redirect to the alerts list view - assuming this is what /beep should show
  redirect(`/beep/${locale}/alerts`)
}