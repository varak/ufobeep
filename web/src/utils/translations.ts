import * as fs from 'fs'
import * as path from 'path'

// Cache for loaded translations to avoid reading files repeatedly
const translationCache = new Map<string, Record<string, string>>()

/**
 * Load translations from ARB files (single source of truth)
 */
export function loadTranslations(locale: string): Record<string, string> {
  if (translationCache.has(locale)) {
    return translationCache.get(locale)!
  }

  try {
    // Path to the ARB file in the mobile app
    const arbPath = path.join(process.cwd(), '../app/lib/l10n', `app_${locale}.arb`)
    
    if (!fs.existsSync(arbPath)) {
      console.warn(`Translation file not found: ${arbPath}`)
      return {}
    }

    const arbContent = fs.readFileSync(arbPath, 'utf-8')
    const translations = JSON.parse(arbContent)
    
    // Cache the translations
    translationCache.set(locale, translations)
    
    return translations
  } catch (error) {
    console.error(`Error loading translations for ${locale}:`, error)
    return {}
  }
}

/**
 * Get translated term with fallback to English
 */
export function getTranslatedTerm(key: string, locale: string, fallback?: string): string {
  const translations = loadTranslations(locale)
  
  if (translations[key]) {
    return translations[key]
  }
  
  // Fallback to English if not found in target language
  if (locale !== 'en') {
    const englishTranslations = loadTranslations('en')
    if (englishTranslations[key]) {
      return englishTranslations[key]
    }
  }
  
  // Final fallback to provided fallback or key itself
  return fallback || key
}

/**
 * Get slug-specific translations for middleware use
 */
export function getSlugTranslations(locale: string) {
  return {
    ufo: getTranslatedTerm('ufoSighting', locale, 'UFO Sighting'),
    sighting: '',  // Already included in ufoSighting
    unknown: getTranslatedTerm('unknown', locale, 'unknown'),
    mufon: getTranslatedTerm('mufon', locale, 'mufon'),
    report: getTranslatedTerm('report', locale, 'report')
  }
}