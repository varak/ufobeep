interface DistanceFormatOptions {
  distanceKm: number
  useImperial?: boolean
}

export function formatDistance({ distanceKm, useImperial = false }: DistanceFormatOptions): string {
  if (useImperial) {
    // Convert to miles and feet
    const miles = distanceKm * 0.621371
    
    if (miles < 0.1) {
      // Show in feet for very short distances
      const feet = Math.round(distanceKm * 3280.84)
      return `${feet} ft away`
    } else if (miles < 1) {
      // Show in feet for distances under 1 mile
      const feet = Math.round(miles * 5280)
      return `${feet} ft away`
    } else {
      // Show in miles, no decimal
      return `${Math.round(miles)} mi away`
    }
  } else {
    // Metric system
    if (distanceKm < 1) {
      const meters = Math.round(distanceKm * 1000)
      return `${meters} m away`
    } else {
      // Show in km, no decimal
      return `${Math.round(distanceKm)} km away`
    }
  }
}

export function getUnitPreference(): boolean {
  // Check if user is in US/imperial countries based on browser locale
  const locale = typeof window !== 'undefined' ? navigator.language : 'en-US'
  const imperialCountries = ['US', 'LR', 'MM'] // United States, Liberia, Myanmar
  
  // Extract country code from locale (e.g., 'en-US' -> 'US')
  const countryCode = locale.split('-')[1]
  
  // Default to imperial for US users, metric for others
  return imperialCountries.includes(countryCode)
}