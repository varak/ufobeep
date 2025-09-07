import type { Metadata } from 'next'
import { notFound } from 'next/navigation'
import { env } from '@/config/environment'
import AlertDetailClient from '@/components/AlertDetailClient'
import { findAlertBySlug, getAlertSlug } from '@/utils/slug'

interface PageParams {
  slug: string
}

export async function generateMetadata({ params }: { params: PageParams }): Promise<Metadata> {
  const alert = await findAlertBySlug(params.slug)
  
  if (!alert) {
    return {
      title: 'Alert Not Found',
      alternates: { canonical: `/alerts/${params.slug}` },
    }
  }

  const title = alert.title || 'UFO Sighting'
  const description = alert.description ? 
    alert.description.substring(0, 160) + (alert.description.length > 160 ? '...' : '') :
    `UFO sighting reported at ${alert.location?.name || 'unknown location'}`

  return {
    title: `${title} - UFOBeep`,
    description,
    alternates: { canonical: `/alerts/${params.slug}` },
    openGraph: { 
      url: `${env.siteUrl}/alerts/${params.slug}`,
      title,
      description,
      type: 'article',
    },
    twitter: { 
      card: 'summary_large_image',
      title,
      description,
    },
  }
}

export default async function Page({ params, searchParams }: { 
  params: PageParams
  searchParams?: Record<string, string | string[] | undefined> 
}) {
  const alert = await findAlertBySlug(params.slug)
  
  if (!alert) {
    notFound()
  }

  // Check if the current slug matches the expected slug
  const expectedSlug = getAlertSlug({
    id: alert.id,
    title: alert.title,
    created_at: alert.created_at,
    location: { 
      name: alert.location?.name, 
      latitude: alert.location?.latitude, 
      longitude: alert.location?.longitude 
    }
  })

  // If the slug doesn't match exactly, we could redirect, but for now just render
  // This handles cases where location data might have changed

  const openImageIndex = typeof searchParams?.openImage === 'string' 
    ? parseInt(searchParams.openImage, 10) 
    : undefined

  return (
    <AlertDetailClient 
      alertId={alert.id} 
      openImageIndex={openImageIndex}
    />
  )
}