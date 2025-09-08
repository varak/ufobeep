export function generateSlug(title: string, location: string, date: string, id?: string) {
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

  // Add short ID hash for uniqueness while keeping URL clean
  const idPart = id ? id.substring(0, 4) : ''

  return `${titlePart}-${locationPart}-${datePart}-${idPart}`
    .replace(/--+/g, '-')
    .replace(/^-|-$/g, '')
}

export interface SluggableAlertLike {
  id: string
  title?: string | null
  created_at: string
  location: { name?: string; latitude?: number; longitude?: number }
  reporter_username?: string | null
  description?: string | null
  source?: string | null
}

export function getAlertSlug(alert: SluggableAlertLike) {
  let locName = alert.location?.name
  
  // Handle MUFON alerts specially
  const isMufon = alert.reporter_username === 'MUFON' || alert.source === 'mufon'
  
  if (isMufon) {
    // Extract location from MUFON description if available
    const locationMatch = alert.description?.match(/📍 Location: ([^\n]+)/)
    if (locationMatch) {
      locName = locationMatch[1].trim()
      // Clean up location (remove country suffix for shorter slug)
      locName = locName.replace(/, US$/, '').replace(/, United States$/, '')
    }
  }
  
  // Skip empty, null, or placeholder location names
  if (!locName || locName === 'Unknown Location' || locName.trim() === '') {
    // Fallback to coordinates if available
    if (typeof alert.location?.latitude === 'number' && typeof alert.location?.longitude === 'number') {
      locName = `${alert.location.latitude.toFixed(4)}, ${alert.location.longitude.toFixed(4)}`
    } else {
      locName = 'unknown'
    }
  }
  
  // Add source prefix for differentiation
  let title = alert.title || 'UFO Sighting'
  if (isMufon) {
    title = 'mufon-' + (alert.title?.toLowerCase().replace('mufon ', '') || 'report')
  }
  
  return generateSlug(title, locName, alert.created_at, alert.id)
}

export function getShortAlertUrl(alertId: string): string {
  // Return short 4-character URL for sharing (beep branding)
  return `/beep/${alertId.substring(0, 4)}`
}

export function extractIdFromSlug(slug: string): string | null {
  // Extract the last 4-character part of the slug as the ID hash
  const parts = slug.split('-')
  const lastPart = parts[parts.length - 1]
  
  // Check if the last part looks like an ID (4 chars, alphanumeric)
  if (lastPart && lastPart.length === 4 && /^[a-z0-9]+$/.test(lastPart)) {
    return lastPart
  }
  
  return null
}

export async function findAlertBySlug(slug: string): Promise<any | null> {
  try {
    const idHash = extractIdFromSlug(slug)
    if (!idHash) return null
    
    // Search through alerts to find one with matching ID prefix
    const limit = 100
    const maxSearchPages = 10
    let currentOffset = 0

    for (let page = 0; page < maxSearchPages; page++) {
      const baseUrl = process.env.NEXT_PUBLIC_SITE_BASE_URL || 'https://ufobeep.com'
      const res = await fetch(`${baseUrl}/api/alerts?limit=${limit}&offset=${currentOffset}&verified_only=false`, { cache: 'no-store' })
      if (!res.ok) break
      
      const data = await res.json()
      const alerts = data?.data?.alerts || []
      
      const foundAlert = alerts.find((alert: any) => alert.id?.startsWith(idHash))
      if (foundAlert) return foundAlert
      
      if (alerts.length < limit) break
      currentOffset += limit
    }
    
    return null
  } catch (error) {
    console.error('Error finding alert by slug:', error)
    return null
  }
}

