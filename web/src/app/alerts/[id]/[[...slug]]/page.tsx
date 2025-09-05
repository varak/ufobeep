import type { Metadata } from 'next'
import { env } from '@/config/environment'
import AlertDetailClient from '@/components/AlertDetailClient'
import { getAlertSlug } from '@/utils/slug'
import { redirect } from 'next/navigation'

interface PageParams {
  id: string
  slug?: string[]
}

export async function generateMetadata({ params }: { params: PageParams }): Promise<Metadata> {
  // Best-effort canonical URL. We avoid server API calls here to keep it robust.
  // If a slug is present, use it; otherwise fall back to bare ID.
  const currentSlug = Array.isArray(params.slug) && params.slug.length > 0 ? params.slug[0] : undefined
  const canonicalPath = currentSlug
    ? `/alerts/${params.id}/${currentSlug}`
    : `/alerts/${params.id}`

  return {
    alternates: { canonical: canonicalPath },
    openGraph: { url: `${env.siteUrl}${canonicalPath}` },
    twitter: { card: 'summary_large_image' },
  }
}

export default async function Page({ params, searchParams }: { params: PageParams; searchParams?: Record<string, string | string[] | undefined> }) {
  // Try to find the alert server-side to enforce a canonical redirect
  try {
    const limit = 100
    const maxSearchPages = 10
    let currentOffset = 0
    let foundAlert: any = null

    for (let page = 0; page < maxSearchPages; page++) {
      const res = await fetch(`${process.env.NEXT_PUBLIC_SITE_BASE_URL ? process.env.NEXT_PUBLIC_SITE_BASE_URL : ''}/api/alerts?limit=${limit}&offset=${currentOffset}&verified_only=false`, { cache: 'no-store' })
      if (!res.ok) break
      const data = await res.json()
      const alerts = data?.data?.alerts || []
      foundAlert = alerts.find((a: any) => a.id === params.id) || null
      if (foundAlert) break
      if (alerts.length < limit) break
      currentOffset += limit
    }

    if (foundAlert) {
      const expectedSlug = getAlertSlug({
        id: foundAlert.id,
        title: foundAlert.title,
        created_at: foundAlert.created_at,
        location: { name: foundAlert.location?.name, latitude: foundAlert.location?.latitude, longitude: foundAlert.location?.longitude }
      })
      const currentSlug = Array.isArray(params.slug) && params.slug.length > 0 ? params.slug[0] : ''
      if (expectedSlug && expectedSlug !== currentSlug) {
        const qs = new URLSearchParams()
        if (searchParams) {
          for (const [k, v] of Object.entries(searchParams)) {
            if (Array.isArray(v)) v.forEach(val => qs.append(k, String(val)))
            else if (typeof v !== 'undefined') qs.append(k, String(v))
          }
        }
        const query = qs.toString()
        redirect(`/alerts/${foundAlert.id}/${expectedSlug}${query ? `?${query}` : ''}`)
      }
    }
  } catch (e) {
    // Best-effort: ignore and let client component handle
  }

  return <AlertDetailClient params={params} />
}
