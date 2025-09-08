/**
 * Unit conversion utilities for displaying data in metric or imperial units
 * with automatic language/region detection for international users
 */

export type UnitSystem = 'metric' | 'imperial';

/**
 * Map of language codes to their typical unit systems
 * Imperial: US, UK (partially), Myanmar, Liberia  
 * Metric: Most of the world
 */
const LANGUAGE_TO_UNITS: Record<string, UnitSystem> = {
  'en': 'imperial',  // English (primarily US/UK)
  'es': 'metric',    // Spanish
  'de': 'metric',    // German
  'fr': 'metric',    // French
  'it': 'metric',    // Italian
  'pt': 'metric',    // Portuguese
  'ru': 'metric',    // Russian
  'zh': 'metric',    // Chinese
  'ja': 'metric',    // Japanese
  'ko': 'metric',    // Korean
  'ar': 'metric',    // Arabic
  'hi': 'metric',    // Hindi
  'tr': 'metric',    // Turkish
  'nl': 'metric',    // Dutch
  'sv': 'metric',    // Swedish
  'da': 'metric',    // Danish
  'no': 'metric',    // Norwegian
  'fi': 'metric',    // Finnish
  'pl': 'metric',    // Polish
  'cs': 'metric',    // Czech
  'el': 'metric',    // Greek
  'he': 'metric',    // Hebrew
};

export class UnitConversion {
  static readonly METRIC = 'metric';
  static readonly IMPERIAL = 'imperial';
  
  /**
   * Get the default unit system for a language code
   * Falls back to metric if language not found
   */
  static getDefaultUnitsForLanguage(languageCode: string): UnitSystem {
    return LANGUAGE_TO_UNITS[languageCode.toLowerCase()] || 'metric';
  }
  
  /**
   * Auto-detect user's preferred units from browser language
   */
  static getAutoUnits(): UnitSystem {
    if (typeof window === 'undefined') return 'metric'; // SSR fallback
    
    const browserLang = window.navigator.language.split('-')[0]; // e.g., 'en-US' -> 'en'
    return this.getDefaultUnitsForLanguage(browserLang);
  }
  
  /**
   * Check if a language typically uses imperial units
   */
  static languageUsesImperial(languageCode: string): boolean {
    return LANGUAGE_TO_UNITS[languageCode.toLowerCase()] === 'imperial';
  }
  
  /**
   * Convert temperature from Celsius to the preferred unit
   */
  static formatTemperature(tempC: number | null, units: UnitSystem = 'imperial'): string {
    if (tempC === null || tempC === undefined) {
      return units === 'imperial' ? '--°F' : '--°C';
    }
    
    if (units === 'imperial') {
      const tempF = (tempC * 9 / 5) + 32;
      return `${tempF.toFixed(1)}°F`;
    } else {
      return `${tempC.toFixed(1)}°C`;
    }
  }

  /**
   * Convert wind speed from m/s to the preferred unit
   */
  static formatWindSpeed(speedMs: number | null, units: UnitSystem = 'imperial'): string {
    if (speedMs === null || speedMs === undefined) return '--';
    
    if (units === 'imperial') {
      const speedMph = speedMs * 2.237; // m/s to mph
      return `${speedMph.toFixed(1)} mph`;
    } else {
      return `${speedMs.toFixed(1)} m/s`;
    }
  }

  /**
   * Convert visibility from km to the preferred unit
   */
  static formatVisibility(visibilityKm: number | null, units: UnitSystem = 'imperial'): string {
    if (visibilityKm === null || visibilityKm === undefined) return '--';
    
    if (units === 'imperial') {
      const visibilityMiles = visibilityKm * 0.621371; // km to miles
      return `${visibilityMiles.toFixed(1)} mi`;
    } else {
      return `${visibilityKm.toFixed(1)} km`;
    }
  }

  /**
   * Convert distance from meters to the preferred unit
   */
  static formatDistance(distanceM: number, units: UnitSystem = 'imperial'): string {
    if (units === 'imperial') {
      if (distanceM < 1609.34) { // Less than 1 mile, show in feet
        const distanceFt = distanceM * 3.28084;
        return `${distanceFt.toFixed(0)} ft`;
      } else {
        const distanceMiles = distanceM / 1609.34;
        return `${distanceMiles.toFixed(1)} mi`;
      }
    } else {
      if (distanceM < 1000) {
        return `${distanceM.toFixed(0)} m`;
      } else {
        const distanceKm = distanceM / 1000;
        return `${distanceKm.toFixed(1)} km`;
      }
    }
  }

  /**
   * Convert distance from km to the preferred unit (for alerts list)
   */
  static formatDistanceFromKm(distanceKm: number, units: UnitSystem = 'imperial'): string {
    return this.formatDistance(distanceKm * 1000, units);
  }

  /**
   * Convert altitude from meters to the preferred unit
   */
  static formatAltitude(altitudeM: number, units: UnitSystem = 'imperial'): string {
    if (units === 'imperial') {
      const altitudeFt = altitudeM * 3.28084;
      return `${altitudeFt.toFixed(0)} ft`;
    } else {
      return `${altitudeM.toFixed(0)} m`;
    }
  }

  /**
   * Format speed in the preferred unit (for general use)
   */
  static formatSpeed(speedMs: number, units: UnitSystem = 'imperial'): string {
    if (units === 'imperial') {
      const speedMph = speedMs * 2.237;
      return `${speedMph.toFixed(1)} mph`;
    } else {
      const speedKmh = speedMs * 3.6;
      return `${speedKmh.toFixed(1)} km/h`;
    }
  }

  /**
   * Get the appropriate distance unit label
   */
  static getDistanceUnit(units: UnitSystem = 'imperial'): string {
    return units === 'imperial' ? 'mi' : 'km';
  }

  /**
   * Get the appropriate speed unit label
   */
  static getSpeedUnit(units: UnitSystem = 'imperial'): string {
    return units === 'imperial' ? 'mph' : 'km/h';
  }

  /**
   * Get the appropriate temperature unit label
   */
  static getTemperatureUnit(units: UnitSystem = 'imperial'): string {
    return units === 'imperial' ? '°F' : '°C';
  }

  /**
   * Convert weather data object to display-ready format
   */
  static convertWeatherData(weatherData: any, units: UnitSystem = 'imperial') {
    return {
      temperature: this.formatTemperature(weatherData.temperature_c, units),
      windSpeed: this.formatWindSpeed(weatherData.wind_speed_ms, units),
      visibility: this.formatVisibility(weatherData.visibility_km, units),
      humidity: weatherData.humidity_percent ? `${weatherData.humidity_percent}%` : '--%',
      cloudCover: weatherData.cloud_cover_percent ? `${weatherData.cloud_cover_percent}%` : '--%',
    };
  }
  
  // ============ LANGUAGE-AWARE METHODS ============
  
  /**
   * Format distance with automatic unit detection from language
   */
  static formatDistanceAuto(distanceM: number, languageCode?: string): string {
    const units = languageCode ? 
      this.getDefaultUnitsForLanguage(languageCode) : 
      this.getAutoUnits();
    return this.formatDistance(distanceM, units);
  }
  
  /**
   * Format temperature with automatic unit detection from language  
   */
  static formatTemperatureAuto(tempC: number | null, languageCode?: string): string {
    const units = languageCode ? 
      this.getDefaultUnitsForLanguage(languageCode) : 
      this.getAutoUnits();
    return this.formatTemperature(tempC, units);
  }
  
  /**
   * Format speed with automatic unit detection from language
   */
  static formatSpeedAuto(speedMs: number, languageCode?: string): string {
    const units = languageCode ? 
      this.getDefaultUnitsForLanguage(languageCode) : 
      this.getAutoUnits();
    return this.formatSpeed(speedMs, units);
  }
  
  /**
   * Format altitude with automatic unit detection from language
   */
  static formatAltitudeAuto(altitudeM: number, languageCode?: string): string {
    const units = languageCode ? 
      this.getDefaultUnitsForLanguage(languageCode) : 
      this.getAutoUnits();
    return this.formatAltitude(altitudeM, units);
  }
}