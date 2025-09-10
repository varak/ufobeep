export function generateSlug(title: string, location: string, date: string, id?: string, locale: string = 'en', translations?: any) {
  // Get translated fallback terms
  const getTranslatedTerm = (key: string, fallback: string) => {
    if (translations?.slugs?.[key]) {
      return translations.slugs[key]
    }
    return fallback
  }

  const ufoTerm = getTranslatedTerm('ufo', 'ufo')
  const sightingTerm = getTranslatedTerm('sighting', 'sighting')
  
  const titlePart = (title || `${ufoTerm}-${sightingTerm}`)
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, '')
    .replace(/\s+/g, '-')
    .substring(0, 30)

  const unknownTerm = getTranslatedTerm('unknown', 'unknown')
  
  const locationPart = (location || unknownTerm)
    .split(',')[0]
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, '')
    .replace(/\s+/g, '-')
    .substring(0, 20)

  const datePart = new Date(date || Date.now()).toISOString().split('T')[0]

  // Add clean short ID for uniqueness (uses safe characters, no o0i1l)
  let idPart = ''
  if (id) {
    idPart = generateCleanShortId(id)
  }

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
  external_url?: string | null
}

export function getAlertSlug(alert: SluggableAlertLike, locale: string = 'en', translations?: any) {
  let locName = alert.location?.name
  let uniqueId = alert.id
  
  // Handle MUFON alerts specially
  const isMufon = alert.reporter_username === 'MUFON' || alert.source === 'mufon'
  
  if (isMufon) {
    // Extract location from MUFON description if available
    const locationMatch = alert.description?.match(/📍 Location: ([^\n]+)/)
    if (locationMatch) {
      locName = locationMatch[1].trim()
      // Keep state info but remove country suffix for shorter slug
      locName = locName.replace(/, US$/, '').replace(/, United States$/, '')
    }
    
    // For MUFON alerts, try to extract case ID from external sources
    let caseIdMatch: RegExpMatchArray | null = null
    
    // Check if we have external_url that might contain case ID
    if (alert.external_url) {
      caseIdMatch = alert.external_url.match(/case[^0-9]*([0-9]+)/i)
      if (caseIdMatch) {
        uniqueId = caseIdMatch[1] // Use just the numeric case ID
      }
    }
    
    // Fallback: extract from any external_id field if passed through
    // (This would need to be added to interface calls, but providing fallback)
    const externalId = (alert as any).external_id
    if (!caseIdMatch && externalId && typeof externalId === 'string') {
      const idMatch = externalId.match(/mufon_([0-9]+)/)
      if (idMatch) {
        uniqueId = idMatch[1] // Use just the numeric case ID
      }
    }
  } else {
    // For UFOBeep alerts, enhance location with state info if available
    if (alert.location?.name) {
      locName = alert.location.name
      // Remove country suffix but keep state
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
  
  // Get translated fallback terms
  const getTranslatedTerm = (key: string, fallback: string) => {
    if (translations?.slugs?.[key]) {
      return translations.slugs[key]
    }
    return fallback
  }

  // Add source prefix for differentiation
  let title = alert.title || `${getTranslatedTerm('ufo', 'UFO')} ${getTranslatedTerm('sighting', 'Sighting')}`
  if (isMufon) {
    const mufonTerm = getTranslatedTerm('mufon', 'mufon')
    const reportTerm = getTranslatedTerm('report', 'report')
    title = `${mufonTerm}-` + (alert.title?.toLowerCase().replace('mufon ', '') || reportTerm)
  }
  
  return generateSlug(title, locName, alert.created_at, uniqueId, locale, translations)
}

// Characters safe for short IDs (excludes o, 0, i, 1, l for clarity)
const SAFE_CHARS = '23456789abcdefghjkmnpqrstuvwxyz'

function generateCleanShortId(input: string): string {
  // Generate a 4-character clean ID from input string
  let hash = 0
  for (let i = 0; i < input.length; i++) {
    const char = input.charCodeAt(i)
    hash = ((hash << 5) - hash) + char
    hash = hash & hash // Convert to 32-bit integer
  }
  
  // Convert hash to base-29 using safe characters
  let shortId = ''
  const absHash = Math.abs(hash)
  let num = absHash
  
  for (let i = 0; i < 4; i++) {
    shortId = SAFE_CHARS[num % SAFE_CHARS.length] + shortId
    num = Math.floor(num / SAFE_CHARS.length)
  }
  
  return shortId
}

export function getShortAlertUrl(alertId: string, locale: string = 'en'): string {
  // Generate clean 4-character URL for sharing with language support
  const cleanShortId = generateCleanShortId(alertId)
  
  // Return language-specific URL
  if (locale === 'en') {
    return `/${cleanShortId}`  // Default English: just /ehf3
  } else {
    return `/${cleanShortId}/${locale}`  // Other languages: /ehf3/es
  }
}

export function generateCleanShortIdFromAlert(alertId: string): string {
  // Export the clean short ID generator for external use
  return generateCleanShortId(alertId)
}

export function extractIdFromSlug(slug: string): string | null {
  // Extract the last 4-character part of the slug as the ID hash
  const parts = slug.split('-')
  const lastPart = parts[parts.length - 1]
  
  // Check if the last part looks like a clean short ID (4 chars, safe chars only)
  if (lastPart && lastPart.length === 4 && /^[23456789abcdefghjkmnpqrstuvwxyz]+$/.test(lastPart)) {
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
      const res = await fetch(`${baseUrl}/api/beep?limit=${limit}&offset=${currentOffset}&verified_only=false`, { cache: 'no-store' })
      if (!res.ok) break
      
      const data = await res.json()
      const alerts = data?.data?.beeps || data?.data?.alerts || []
      
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

