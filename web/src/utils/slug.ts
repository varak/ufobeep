export function generateSlug(title: string, location: string, date: string, id?: string, locale: string = 'en', translations?: any, source?: string, shape?: string) {
  // Get translated terms from translations object
  const getTranslatedTerm = (key: string) => {
    if (translations?.slugs?.[key]) {
      return translations.slugs[key]
    }
    return ''
  }

  // Get translated terms  
  const mufonTerm = getTranslatedTerm('mufon') || 'mufon'
  const ufoTerm = getTranslatedTerm('ufo') || 'ufo' 
  const sightingTerm = getTranslatedTerm('sighting') || 'sighting'
  const reportTerm = getTranslatedTerm('report') || 'report'

  // Build title part based on source and classification (match shared generator)
  const isMufon = source === 'mufon'
  let titlePart = ''
  
  if (isMufon) {
    // MUFON: "mufon-sphere-ufo-sighting" or "mufon-ufo-sighting"
    if (shape && shape !== 'unknown') {
      const shapeTranslation = getTranslatedTerm(shape) || shape.toLowerCase()
      titlePart = `${mufonTerm}-${shapeTranslation}-${ufoTerm}-${sightingTerm}`
    } else {
      titlePart = `${mufonTerm}-${ufoTerm}-${sightingTerm}`
    }
  } else {
    // Regular: "sphere-ufo-sighting" or "ufo-sighting"
    if (shape && shape !== 'unknown') {
      const shapeTranslation = getTranslatedTerm(shape) || shape.toLowerCase()
      titlePart = `${shapeTranslation}-${ufoTerm}-${sightingTerm}`
    } else {
      titlePart = `${ufoTerm}-${sightingTerm}`
    }
  }

  const unknownTerm = getTranslatedTerm('unknown')
  
  // Extract city and state from "Bensalem, PA" format
  let locationPart = ''
  if (location && location !== unknownTerm) {
    const locationParts = location.split(',').map(p => p.trim())
    const city = locationParts[0]?.toLowerCase().replace(/[^a-z0-9\s]/g, '').replace(/\s+/g, '-') || ''
    const state = locationParts[1]?.toLowerCase().replace(/[^a-z0-9]/g, '') || ''
    
    if (city) {
      locationPart = state ? `${city}-${state}` : city
      locationPart = locationPart.substring(0, 25) // Slightly longer for city-state
    }
  }

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
  enrichment_data?: any
}

export function getAlertSlug(alert: SluggableAlertLike, locale: string = 'en', translations?: any, shortId?: string) {
  // Browser-compatible slug generation (matches shared/generate_slug.js behavior)
  const title = alert.title || ''

  // Use geocoding data for proper location names in slugs
  console.log('SLUG DEBUG: alert.location?.name =', alert.location?.name)
  console.log('SLUG DEBUG: enrichment_data =', (alert as any).enrichment_data)
  console.log('SLUG DEBUG: geocoding =', (alert as any).enrichment_data?.geocoding)

  const location = (alert as any).enrichment_data?.geocoding?.location_name ||
                   (alert as any).enrichment_data?.geocoding?.formatted_address ||
                   (alert as any).enrichment_data?.geocoding?.display_name ||
                   alert.location?.name ||
                   'unknown-location'

  console.log('SLUG DEBUG: final location =', location)
  const date = alert.created_at
  const id = shortId || alert.short_url || alert.id
  const source = alert.source || ''
  
  // Extract shape from enrichment data or title
  let shape = ''
  if (source === 'mufon' && title) {
    // Extract shape from MUFON title: "MUFON Light Report" -> "light"
    const titleLower = title.toLowerCase()
    if (titleLower.includes('triangle')) shape = 'triangle'
    else if (titleLower.includes('disc')) shape = 'disc'
    else if (titleLower.includes('sphere')) shape = 'sphere'
    else if (titleLower.includes('cigar')) shape = 'cigar'
    else if (titleLower.includes('light')) shape = 'light'
    else if (titleLower.includes('boomerang')) shape = 'boomerang'
    else if (titleLower.includes('diamond')) shape = 'diamond'
    else if (titleLower.includes('rectangle')) shape = 'rectangle'
    else if (titleLower.includes('oval')) shape = 'oval'
    else if (titleLower.includes('cone')) shape = 'cone'
    else if (titleLower.includes('cross')) shape = 'cross'
    else if (titleLower.includes('cylinder')) shape = 'cylinder'
    else if (titleLower.includes('dumbbell')) shape = 'dumbbell'
    else if (titleLower.includes('teardrop')) shape = 'teardrop'
    else if (titleLower.includes('tic-tac')) shape = 'tic-tac'
    else if (titleLower.includes('bullet')) shape = 'bullet'
    else if (titleLower.includes('saturn')) shape = 'saturn'
    else if (titleLower.includes('starlike')) shape = 'starlike'
    else if (titleLower.includes('blimp')) shape = 'blimp'
  }
  
  return generateSlug(title, location, date, id, locale, translations, source, shape)
}

// Browser-compatible short hash implementation (extracted from shared module)
const SAFE_CHARS = '23456789abcdefghjkmnpqrstuvwxyz';

function getShortHash(input: string): string {
  if (!input) return '';
  
  // Generate hash using the canonical algorithm from shared module
  let hash = 0;
  for (let i = 0; i < input.length; i++) {
    const char = input.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash; // Convert to 32-bit integer
  }
  
  // Convert hash to base-29 using safe characters  
  let shortId = '';
  let num = Math.abs(hash);
  
  for (let i = 0; i < 5; i++) {
    shortId = SAFE_CHARS[num % SAFE_CHARS.length] + shortId;
    num = Math.floor(num / SAFE_CHARS.length);
  }
  
  return shortId;
}

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

