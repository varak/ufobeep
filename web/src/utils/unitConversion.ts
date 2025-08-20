/**
 * Unit conversion utilities for displaying data in metric or imperial units
 * Website defaults to imperial units (US standard)
 */

export type UnitSystem = 'metric' | 'imperial';

export class UnitConversion {
  static readonly METRIC = 'metric';
  static readonly IMPERIAL = 'imperial';
  
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
}