export function generateSlug(title: string, location: string, date: string) {
  const titlePart = (title || 'ufo-sighting')
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, '')
    .replace(/\s+/g, '-')
    .substring(0, 30)

  const locationPart = (location || 'unknown')
    .split(',')[0]
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, '')
    .replace(/\s+/g, '-')
    .substring(0, 20)

  const datePart = new Date(date || Date.now()).toISOString().split('T')[0]

  return `${titlePart}-${locationPart}-${datePart}`
    .replace(/--+/g, '-')
    .replace(/^-|-$/g, '')
}

export interface SluggableAlertLike {
  id: string
  title?: string | null
  created_at: string
  location: { name?: string; latitude?: number; longitude?: number }
}

export function getAlertSlug(alert: SluggableAlertLike) {
  let locName = alert.location?.name
  
  // Skip empty, null, or placeholder location names
  if (!locName || locName === 'Unknown Location' || locName.trim() === '') {
    // Fallback to coordinates if available
    if (typeof alert.location?.latitude === 'number' && typeof alert.location?.longitude === 'number') {
      locName = `${alert.location.latitude.toFixed(4)}, ${alert.location.longitude.toFixed(4)}`
    } else {
      locName = 'unknown'
    }
  }
  
  return generateSlug(alert.title || 'UFO Sighting', locName, alert.created_at)
}

