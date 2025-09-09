'use client'

import { useState, useEffect } from 'react'

interface Translations {
  [key: string]: any
}

export function useClientTranslations(namespace: string, locale: string = 'en') {
  const [translations, setTranslations] = useState<Translations>({})
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function loadTranslations() {
      try {
        const response = await fetch(`/locales/${locale}/${namespace}.json`)
        if (response.ok) {
          const data = await response.json()
          setTranslations(data)
        }
      } catch (error) {
        console.error(`Failed to load translations for ${locale}/${namespace}:`, error)
        // Fallback to English
        if (locale !== 'en') {
          try {
            const fallbackResponse = await fetch(`/locales/en/${namespace}.json`)
            if (fallbackResponse.ok) {
              const fallbackData = await fallbackResponse.json()
              setTranslations(fallbackData)
            }
          } catch (fallbackError) {
            console.error('Failed to load fallback translations:', fallbackError)
          }
        }
      } finally {
        setLoading(false)
      }
    }

    loadTranslations()
  }, [namespace, locale])

  const t = (key: string, options?: { returnObjects?: boolean }): any => {
    // If translations are still loading, return a loading placeholder instead of the key
    if (loading) {
      return '...' 
    }
    
    const keys = key.split('.')
    let value = translations
    
    for (const k of keys) {
      if (value && typeof value === 'object' && k in value) {
        value = value[k]
      } else {
        // Return appropriate fallback based on key
        const fallbacks: Record<string, string> = {
          'title': 'Recent UFO Beeps',
          'subtitle': 'Live UFOBeep community reports & MUFON database sightings', 
          'description': 'This feed combines real-time UFOBeep "beeps" from our mobile app users with historical reports from the MUFON database.',
          'loadingBeeps': 'Loading recent beeps...',
          'backToHome': '← Back to Home'
        }
        return fallbacks[key] || key
      }
    }
    
    if (options?.returnObjects && typeof value === 'object') {
      return value
    }
    
    return typeof value === 'string' ? value : key
  }

  return { t, loading }
}