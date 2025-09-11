// Import pre-generated static translations (Edge Runtime compatible)
import staticTranslations from '../translations/static-translations.json'

/**
 * Get translated term with fallback to English
 */
export function getTranslatedTerm(key: string, locale: string): string {
  const translations = staticTranslations[locale as keyof typeof staticTranslations]
  
  if (translations && translations[key as keyof typeof translations]) {
    return translations[key as keyof typeof translations]
  }
  
  // Return empty string if translation doesn't exist - no fallbacks
  return ''
}

/**
 * Get slug-specific translations for middleware use
 */
export function getSlugTranslations(locale: string) {
  return {
    slugs: {
      ufoSighting: getTranslatedTerm('ufoSighting', locale),
      ufo: getTranslatedTerm('ufo', locale),
      sighting: getTranslatedTerm('sighting', locale),
      unknown: getTranslatedTerm('unknown', locale),
      mufon: getTranslatedTerm('mufon', locale),
      report: getTranslatedTerm('report', locale),
      // UFO shape classifications from MUFON
      triangle: getTranslatedTerm('shapeTriangle', locale),
      disc: getTranslatedTerm('shapeDisc', locale),
      disk: getTranslatedTerm('shapeDisk', locale),
      sphere: getTranslatedTerm('shapeSphere', locale),
      cigar: getTranslatedTerm('shapeCigar', locale),
      light: getTranslatedTerm('shapeLight', locale),
      boomerang: getTranslatedTerm('shapeBoomerang', locale),
      diamond: getTranslatedTerm('shapeDiamond', locale),
      rectangle: getTranslatedTerm('shapeRectangle', locale),
      oval: getTranslatedTerm('shapeOval', locale),
      cone: getTranslatedTerm('shapeCone', locale),
      cross: getTranslatedTerm('shapeCross', locale),
      cylinder: getTranslatedTerm('shapeCylinder', locale),
      dumbbell: getTranslatedTerm('shapeDumbbell', locale),
      teardrop: getTranslatedTerm('shapeTeardrop', locale),
      'tic-tac': getTranslatedTerm('shapeTicTac', locale),
      bullet: getTranslatedTerm('shapeBullet', locale),
      saturn: getTranslatedTerm('shapeSaturn', locale),
      starlike: getTranslatedTerm('shapeStarlike', locale),
      blimp: getTranslatedTerm('shapeBlimp', locale),
      fireball: getTranslatedTerm('shapeFireball', locale),
      formation: getTranslatedTerm('shapeFormation', locale)
    }
  }
}