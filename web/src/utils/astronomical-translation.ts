/**
 * Astronomical Translation Utility for UFOBeep Web
 * Provides smart templates for celestial objects, satellites, and aircraft
 * Synchronized with mobile app translation logic
 */

interface TranslationFunction {
  (key: string, params?: Record<string, any>): string
}

export class AstronomicalTranslations {

  /**
   * Translate planet names to localized versions
   */
  static translatePlanetName(planetName: string, t: TranslationFunction): string {
    switch (planetName.toLowerCase()) {
      case 'venus':
        return t('planetVenus')
      case 'jupiter':
        return t('planetJupiter')
      case 'saturn':
        return t('planetSaturn')
      case 'mars':
        return t('planetMars')
      case 'mercury':
        return t('planetMercury')
      case 'uranus':
        return t('planetUranus')
      case 'neptune':
        return t('planetNeptune')
      default:
        return planetName // Keep unknown planets as-is
    }
  }

  /**
   * Translate star names to localized versions
   */
  static translateStarName(starName: string, t: TranslationFunction): string {
    switch (starName.toLowerCase()) {
      case 'sirius':
        return t('starSirius')
      case 'canopus':
        return t('starCanopus')
      case 'arcturus':
        return t('starArcturus')
      case 'vega':
        return t('starVega')
      case 'capella':
        return t('starCapella')
      case 'rigel':
        return t('starRigel')
      case 'procyon':
        return t('starProcyon')
      case 'betelgeuse':
        return t('starBetelgeuse')
      default:
        return starName // Keep unknown stars as-is
    }
  }

  /**
   * Generate smart description for planet based on altitude and prominence
   */
  static translatePlanetDescription(
    planetName: string,
    altitude: number,
    isProminent: boolean,
    t: TranslationFunction
  ): string {
    const translatedName = this.translatePlanetName(planetName, t)

    if (altitude < 0) {
      return t('planetBelowHorizon', { planet: translatedName })
    } else if (altitude < 15) {
      return t('planetLowHorizon', { planet: translatedName, altitude: altitude.toFixed(0) })
    } else if (altitude > 45 && isProminent) {
      return t('planetHighOverheadProminent', { planet: translatedName, altitude: altitude.toFixed(0) })
    } else if (altitude > 45) {
      return t('planetHighOverhead', { planet: translatedName, altitude: altitude.toFixed(0) })
    } else if (isProminent) {
      return t('planetMidSkyProminent', { planet: translatedName, altitude: altitude.toFixed(0) })
    } else {
      return t('planetMidSky', { planet: translatedName, altitude: altitude.toFixed(0) })
    }
  }

  /**
   * Generate smart description for star based on altitude and brightness
   */
  static translateStarDescription(
    starName: string,
    altitude: number,
    t: TranslationFunction,
    magnitude?: number
  ): string {
    const translatedName = this.translateStarName(starName, t)
    const altitudeStr = altitude.toFixed(0)

    if (magnitude != null && magnitude < 1.0) {
      return t('starVeryBright', { star: translatedName, altitude: altitudeStr })
    } else if (altitude > 30) {
      return t('starProminent', { star: translatedName, altitude: altitudeStr })
    } else {
      return t('starVisible', { star: translatedName, altitude: altitudeStr })
    }
  }

  /**
   * Generate satellite summary based on count and visibility
   */
  static translateSatelliteSummary(
    totalCount: number,
    visibleCount: number,
    couldExplainSighting: boolean,
    t: TranslationFunction
  ): string {
    if (visibleCount === 0) {
      return t('noSatellitesVisible')
    } else if (couldExplainSighting) {
      return t('satellitesVisibleMightExplain', { count: visibleCount })
    } else {
      return t('satellitesVisibleUnlikelyExplain', { count: visibleCount })
    }
  }

  /**
   * Generate aircraft summary based on detection results
   */
  static translateAircraftSummary(
    aircraftCount: number,
    t: TranslationFunction,
    radiusKm?: number
  ): string {
    if (aircraftCount === 0) {
      return t('noAircraftDetected')
    } else {
      const radius = radiusKm?.toFixed(0) ?? '50'
      return t('aircraftDetectedInRadius', { count: aircraftCount, radius })
    }
  }

  /**
   * Generate moon description based on phase and visibility
   */
  static translateMoonDescription(
    phaseName: string,
    illumination: number,
    altitude: number,
    t: TranslationFunction
  ): string {
    const translatedPhase = this.translateMoonPhase(phaseName, t)

    if (altitude < 0) {
      return t('moonBelowHorizon', { phase: translatedPhase })
    } else {
      return t('moonVisible', { phase: translatedPhase, illumination: illumination.toFixed(1) })
    }
  }

  /**
   * Translate moon phase names
   */
  static translateMoonPhase(phase: string, t: TranslationFunction): string {
    switch (phase.toLowerCase()) {
      case 'new moon':
        return t('moonPhaseNew')
      case 'waxing crescent':
        return t('moonPhaseWaxingCrescent')
      case 'first quarter':
        return t('moonPhaseFirstQuarter')
      case 'waxing gibbous':
        return t('moonPhaseWaxingGibbous')
      case 'full moon':
        return t('moonPhaseFull')
      case 'waning gibbous':
        return t('moonPhaseWaningGibbous')
      case 'third quarter':
        return t('moonPhaseThirdQuarter')
      case 'waning crescent':
        return t('moonPhaseWaningCrescent')
      default:
        return phase
    }
  }
}