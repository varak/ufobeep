interface DistanceFormatOptions {
  distanceKm: number
  useImperial?: boolean
  locale?: string
}

// Simple translations for distance units
const translations: Record<string, Record<string, string>> = {
  'en': { ft: 'ft', mi: 'mi', m: 'm', km: 'km', away: 'away' },
  'es': { ft: 'pies', mi: 'mi', m: 'm', km: 'km', away: 'de distancia' },
  'fr': { ft: 'pi', mi: 'mi', m: 'm', km: 'km', away: 'de distance' },
  'de': { ft: 'Fuß', mi: 'Mi', m: 'm', km: 'km', away: 'entfernt' },
  'it': { ft: 'ft', mi: 'mi', m: 'm', km: 'km', away: 'di distanza' },
  'pt': { ft: 'pés', mi: 'mi', m: 'm', km: 'km', away: 'de distância' },
  'ru': { ft: 'фт', mi: 'ми', m: 'м', km: 'км', away: 'на расстоянии' },
  'ja': { ft: 'フィート', mi: 'マイル', m: 'メートル', km: 'キロ', away: '離れて' },
  'zh': { ft: '英尺', mi: '英里', m: '米', km: '公里', away: '距离' }
}

function getTranslation(key: string, locale: string = 'en'): string {
  const lang = locale.split('-')[0].toLowerCase()
  return translations[lang]?.[key] || translations['en'][key] || key
}

export function formatDistance({ distanceKm, useImperial = false, locale = 'en' }: DistanceFormatOptions): string {
  if (useImperial) {
    // Convert to miles and feet
    const miles = distanceKm * 0.621371
    
    if (miles < 0.1) {
      // Show in feet for very short distances
      const feet = Math.round(distanceKm * 3280.84)
      return `${feet} ${getTranslation('ft', locale)} ${getTranslation('away', locale)}`
    } else if (miles < 1) {
      // Show in feet for distances under 1 mile
      const feet = Math.round(miles * 5280)
      return `${feet} ${getTranslation('ft', locale)} ${getTranslation('away', locale)}`
    } else {
      // Show in miles, no decimal
      return `${Math.round(miles)} ${getTranslation('mi', locale)} ${getTranslation('away', locale)}`
    }
  } else {
    // Metric system
    if (distanceKm < 1) {
      const meters = Math.round(distanceKm * 1000)
      return `${meters} ${getTranslation('m', locale)} ${getTranslation('away', locale)}`
    } else {
      // Show in km, no decimal
      return `${Math.round(distanceKm)} ${getTranslation('km', locale)} ${getTranslation('away', locale)}`
    }
  }
}

// Language-to-units mapping (matches mobile app)
const LANGUAGE_TO_IMPERIAL: Record<string, boolean> = {
  'en': true,   // English - primarily US/UK
  'es': false,  // Spanish - metric
  'de': false,  // German - metric  
  'fr': false,  // French - metric
  'it': false,  // Italian - metric
  'pt': false,  // Portuguese - metric
  'ru': false,  // Russian - metric
  'zh': false,  // Chinese - metric
  'ja': false,  // Japanese - metric
  'ko': false,  // Korean - metric
  'ar': false,  // Arabic - metric
  'hi': false,  // Hindi - metric
  'tr': false,  // Turkish - metric
  'nl': false,  // Dutch - metric
  'sv': false,  // Swedish - metric
  'da': false,  // Danish - metric
  'no': false,  // Norwegian - metric
  'fi': false,  // Finnish - metric
  'pl': false,  // Polish - metric
  'cs': false,  // Czech - metric
  'el': false,  // Greek - metric
  'he': false,  // Hebrew - metric
}

export function getUnitPreference(): boolean {
  if (typeof window === 'undefined') return false // SSR fallback to metric
  
  // Get browser language (e.g., 'en-US' -> 'en')
  const browserLang = window.navigator.language.split('-')[0].toLowerCase()
  
  // Use language-based preference, fall back to metric
  return LANGUAGE_TO_IMPERIAL[browserLang] ?? false
}

export function getUnitPreferenceForLanguage(languageCode: string): boolean {
  return LANGUAGE_TO_IMPERIAL[languageCode.toLowerCase()] ?? false
}