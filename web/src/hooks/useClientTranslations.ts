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

  const t = (key: string, options?: { returnObjects?: boolean }) => {
    const keys = key.split('.')
    let value = translations
    
    for (const k of keys) {
      if (value && typeof value === 'object' && k in value) {
        value = value[k]
      } else {
        return key // Return the key if translation not found
      }
    }
    
    if (options?.returnObjects && typeof value === 'object') {
      return value
    }
    
    return typeof value === 'string' ? value : key
  }

  return { t, loading }
}