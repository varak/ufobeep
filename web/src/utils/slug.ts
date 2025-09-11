export function generateSlug(title: string, location: string, date: string, id?: string, locale: string = 'en', translations?: any) {
  // Get translated terms from translations object
  const getTranslatedTerm = (key: string) => {
    if (translations?.slugs?.[key]) {
      return translations.slugs[key]
    }
    return ''
  }

  const titlePart = (title || '')
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, '')
    .replace(/\s+/g, '-')
    .substring(0, 30)

  const unknownTerm = getTranslatedTerm('unknown')
  
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
    // If ID is already a 5-character short URL, use it directly
    if (typeof id === 'string' && id.length === 5 && /^[23456789abcdefghjkmnpqrstuvwxyz]+$/.test(id)) {
      idPart = id
    } else {
      // Otherwise generate a new clean short ID
      idPart = generateCleanShortId(id)
    }
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
  short_url?: string
}

export function getAlertSlug(alert: SluggableAlertLike, locale: string = 'en', translations?: any, shortId?: string) {
  // Use the shared slug generator for consistency
  const { generateAlertSlug } = require('../../../shared/generate_slug.js')
  
  // Convert the web alert object to the format expected by shared generator
  const alertData = {
    id: alert.id,
    title: alert.title || '',
    created_at: alert.created_at,
    location: alert.location,
    source: alert.source || (alert.reporter_username === 'MUFON' ? 'mufon' : 'ufobeep'),
    short_url: (alert as any).short_url,
    shape: (alert as any).shape // Include shape data if available
  }
  
  return generateAlertSlug(alertData, locale, shortId)
}

// Import shared short hash function
const { getShortHash } = require('../../../shared/get_short_hash.js')

function generateCleanShortId(input: string): string {
  return getShortHash(input)
}

export function getShortAlertUrl(alert: any, locale: string = 'en'): string {
  // Use API-provided short_url if available, fallback to generating from ID
  let shortId: string
  if (alert.short_url) {
    shortId = alert.short_url
  } else {
    // Fallback for backwards compatibility
    const alertId = typeof alert === 'string' ? alert : alert.id
    shortId = generateCleanShortId(alertId)
  }
  
  // Return language-specific URL with optional locale suffix
  if (locale === 'en') {
    return `/${shortId}`  // Default English: just /b4uux
  } else {
    return `/${shortId}/${locale}`  // Other languages: /b4uux/es
  }
}

export function generateCleanShortIdFromAlert(alertId: string): string {
  // Export the clean short ID generator for external use
  return generateCleanShortId(alertId)
}

export function extractIdFromSlug(slug: string): string | null {
  // Extract the last 5-character part of the slug as the ID hash
  const parts = slug.split('-')
  const lastPart = parts[parts.length - 1]
  
  // Check if the last part looks like a clean short ID (5 chars, safe chars only)
  if (lastPart && lastPart.length === 5 && /^[23456789abcdefghjkmnpqrstuvwxyz]+$/.test(lastPart)) {
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

