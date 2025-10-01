import { redirect } from 'next/navigation'
import { findAlertBySlug, getAlertSlug } from '@/utils/slug'

interface PageParams {
  id: string
}

export default async function ShortAlertRedirect({ params }: { params: Promise<PageParams> }) {
  // Find alert by the 6-character ID
  const resolvedParams = await params
  const alert = await findAlertByIdHash(resolvedParams.id)
  
  if (!alert) {
    // If not found, redirect to main alerts page
    redirect('/beep')
  }

  // Generate the full slug and redirect to the proper SEO-friendly URL
  const fullSlug = getAlertSlug({
    id: alert.id,
    title: alert.title,
    created_at: alert.created_at,
    location: alert.location,
    reporter_username: alert.reporter_username,
    description: alert.description,
    source: alert.source
  })

  // Redirect to the full slug URL
  redirect(`/beep/${fullSlug}`)
}

async function findAlertByIdHash(idHash: string): Promise<any | null> {
  try {
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
    console.error('Error finding alert by ID hash:', error)
    return null
  }
}