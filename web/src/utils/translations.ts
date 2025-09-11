// Import pre-generated static translations (Edge Runtime compatible)
import staticTranslations from '../translations/static-translations.json'

/**
 * Get translated term with fallback to English
 */
export function getTranslatedTerm(key: string, locale: string, fallback?: string): string {
  const translations = staticTranslations[locale as keyof typeof staticTranslations]
  
  if (translations && translations[key as keyof typeof translations]) {
    return translations[key as keyof typeof translations]
  }
  
  // Fallback to English if not found in target language
  if (locale !== 'en') {
    const englishTranslations = staticTranslations.en
    if (englishTranslations[key as keyof typeof englishTranslations]) {
      return englishTranslations[key as keyof typeof englishTranslations]
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
    slugs: {
      ufoSighting: getTranslatedTerm('ufoSighting', locale, 'UFO Sighting'),
      ufo: getTranslatedTerm('ufoSighting', locale, 'UFO Sighting'),
      sighting: '',  // Already included in ufoSighting
      unknown: getTranslatedTerm('unknown', locale, 'unknown'),
      mufon: getTranslatedTerm('mufon', locale, 'mufon'),
      report: getTranslatedTerm('report', locale, 'report')
    }
  }
}