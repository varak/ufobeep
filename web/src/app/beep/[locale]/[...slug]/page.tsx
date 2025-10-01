import { notFound } from 'next/navigation'
import { Metadata } from 'next'
import { getAlertSlug } from '@/utils/slug'
import { AlertTitleUtils } from '@/utils/alert-title-utils'
import AlertHero from '@/components/alert-detail/AlertHero'
import AlertDetails from '@/components/alert-detail/AlertDetails'
import EnrichmentData from '@/components/alert-detail/EnrichmentData'
import AlertComments from '@/components/AlertComments'
import { getTranslations } from '@/utils/translations'

interface PageParams {
  locale: string
  slug: string[]
}

interface Alert {
  id: string
  title: string
  description: string
  location: {
    name: string
    latitude: number
    longitude: number
  }
  created_at: string
  alert_level: string
  witness_count: number
  total_confirmations: number
  source?: string
  reporter_username?: string
  enrichment?: {
    geocoding?: {
      latitude: number
      longitude: number
      location: string
      display_name: string
    }
    location_raw?: string
    mufon_case_id?: string
    classification?: {
      type: string
      keywords?: string[]
      confidence?: number
    }
    occurred_at?: string
    external_url?: string
    [key: string]: any
  }
  enrichment_data?: {
    [key: string]: any
  }
  media_files: Array<{
    id?: string
    type: string
    url: string
    thumbnail_url: string
    web_url?: string
    preview_url?: string
    filename?: string
  }>
  distance_km?: number
  short_url?: string
  occurred_at?: string
  external_url?: string
  external_id?: string
  original_language?: string
}

// Server-side fetch function for beep data
async function fetchBeepData(slug: string[]): Promise<Alert | null> {
  try {
    const fullSlug = slug.join('/')
    // Extract the short ID - either the last part after splitting on '-', or the whole slug if it's just the short ID
    let shortId
    if (fullSlug.includes('-')) {
      const slugParts = fullSlug.split('-')
      shortId = slugParts[slugParts.length - 1]
    } else {
      // If there are no dashes, this is likely just the short ID
      shortId = fullSlug
    }

    // Call backend API directly - supports both UUID and short URL automatically
    // In SSR context, we need to use localhost to hit the local API server
    const apiUrl = `http://localhost:8000/beep/${shortId}`
    const res = await fetch(apiUrl, {
      cache: 'no-store', // Always get fresh data for OG tags
      headers: {
        'Accept': 'application/json',
      }
    })

    if (!res.ok) {
      return null
    }

    const data = await res.json()
    if (data.success && data.data) {
      return data.data
    }

    return null
  } catch (error) {
    console.error('Error fetching beep data:', error)
    return null
  }
}

function getEnrichedLocation(alert: Alert, t: any): string {
  // Try enrichment_data geocoding first (primary data source)
  if (alert.enrichment_data?.geocoding?.display_name) {
    return alert.enrichment_data.geocoding.display_name
  }

  if (alert.enrichment_data?.geocoding?.location) {
    return alert.enrichment_data.geocoding.location
  }

  // Try enrichment geocoding (fallback)
  if (alert.enrichment?.geocoding?.location) {
    return alert.enrichment.geocoding.location
  }

  // Try raw location from enrichment
  if (alert.enrichment?.location_raw) {
    return alert.enrichment.location_raw
  }

  // Parse location from description for MUFON reports
  if (alert.description && alert.description.includes('📍 Location:')) {
    const locationMatch = alert.description.match(/📍 Location: ([^\n]+)/)
    if (locationMatch && locationMatch[1].trim()) {
      return locationMatch[1].trim()
    }
  }

  // Fall back to basic location name
  if (alert.location?.name && alert.location.name !== 'Unknown Location') {
    return alert.location.name
  }

  return t('unknownLocation')
}

function getClassifiedTitle(alert: Alert, t: any): string {
  return AlertTitleUtils.getContextualTitle(alert, t)
}

// Generate metadata for SEO and social media previews
export async function generateMetadata({ params }: { params: Promise<PageParams> }): Promise<Metadata> {
  const resolvedParams = await params
  const slug = resolvedParams?.slug as string[]
  if (!slug || slug.length === 0) {
    return {
      title: 'Beep Not Found',
    }
  }

  const alert = await fetchBeepData(slug)

  if (!alert) {
    return {
      title: 'Beep Not Found',
    }
  }

  const locale = resolvedParams?.locale || 'en'
  const t = await getTranslations(locale, 'common')

  const title = getClassifiedTitle(alert, t)
  const location = getEnrichedLocation(alert, t)
  const date = new Date(alert.created_at).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })

  const description = alert.description
    ? alert.description.substring(0, 160)
    : `UFO sighting reported in ${location} on ${date}`

  // Get first media file for og:image
  const ogImage = alert.media_files && alert.media_files.length > 0
    ? (alert.media_files[0].web_url || alert.media_files[0].thumbnail_url || alert.media_files[0].url)
    : '/og-image.png' // Fallback to default

  // Build canonical URL using short URL if available
  const shortId = alert.short_url || ''
  const canonicalUrl = shortId
    ? `https://ufobeep.com/${shortId}`
    : `https://ufobeep.com/beep/${locale}/${slug.join('/')}`

  return {
    title: `${title} - ${location}`,
    description,
    openGraph: {
      type: 'article',
      url: canonicalUrl,
      title: `${title} - ${location}`,
      description,
      images: [
        {
          url: ogImage,
          width: 1200,
          height: 630,
          alt: title,
        },
      ],
      siteName: 'UFOBeep',
      locale: locale === 'en' ? 'en_US' : `${locale}_${locale.toUpperCase()}`,
    },
    twitter: {
      card: 'summary_large_image',
      title: `${title} - ${location}`,
      description,
      images: [ogImage],
    },
    alternates: {
      canonical: canonicalUrl,
    },
  }
}

// Server Component (async)
export default async function AlertDetailPage({ params, searchParams }: { params: Promise<PageParams>, searchParams: Promise<{ [key: string]: string | string[] | undefined }> }) {
  const resolvedParams = await params
  const resolvedSearchParams = await searchParams
  const slug = resolvedParams?.slug as string[]
  if (!slug || slug.length === 0) {
    notFound()
  }

  const alert = await fetchBeepData(slug)

  if (!alert) {
    notFound()
  }

  const locale = resolvedParams?.locale || 'en'
  const t = await getTranslations(locale, 'common')

  // Get openImage parameter for direct image linking
  const openImageParam = resolvedSearchParams.openImage
  const openImageIndex = openImageParam ? parseInt(openImageParam as string, 10) : undefined

  // Enhance the alert with classified title and enriched location for display
  const enhancedAlert = {
    ...alert,
    title: getClassifiedTitle(alert, t),
    location: {
      latitude: alert.location?.latitude || 0,
      longitude: alert.location?.longitude || 0,
      name: getEnrichedLocation(alert, t)
    },
    media_files: alert.media_files || [],
    enrichment_data: alert.enrichment_data
  }

  return (
    <main className="min-h-screen py-8 px-4 md:px-8">
      <div className="max-w-4xl mx-auto">
        <div className="mb-8">
          <a
            href={`/beep/${locale}#alert-${enhancedAlert.id}`}
            className="text-brand-primary hover:text-brand-primary-light transition-colors mb-4 inline-block"
          >
            {t('backToBeeps')}
          </a>
        </div>

        {/* Hero Section with Media Gallery */}
        <AlertHero alert={enhancedAlert} openImageIndex={openImageIndex} locale={locale} />

        {/* Details Section */}
        <AlertDetails alert={enhancedAlert} locale={locale} />

        {/* Enrichment Data */}
        <EnrichmentData alert={enhancedAlert} enrichment={enhancedAlert.enrichment_data} locale={locale} />

        {/* Comments Section for all reports */}
        <AlertComments alertId={enhancedAlert.id} locale={locale} />
      </div>
    </main>
  )
}
