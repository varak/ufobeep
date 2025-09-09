import { notFound } from 'next/navigation'
import { useTranslation } from 'next-i18next'

interface PageParams {
  locale: string
  slug: string[]
}

async function getAlertBySlug(slug: string) {
  try {
    const baseUrl = process.env.NEXT_PUBLIC_SITE_BASE_URL || 'https://ufobeep.com'
    const res = await fetch(`${baseUrl}/api/alerts/${slug}`, { cache: 'no-store' })
    if (!res.ok) return null
    
    const data = await res.json()
    return data.success ? data.data : null
  } catch (error) {
    console.error('Error fetching alert:', error)
    return null
  }
}

export default async function AlertDetailPage({ params }: { params: PageParams }) {
  const fullSlug = params.slug.join('/')
  const alert = await getAlertBySlug(fullSlug)
  
  if (!alert) {
    notFound()
  }

  return (
    <main className="min-h-screen py-8 px-4 md:px-8">
      <div className="max-w-4xl mx-auto">
        <div className="mb-8">
          <a 
            href={`/beep/${params.locale}`}
            className="text-brand-primary hover:text-brand-primary-light transition-colors mb-4 inline-block"
          >
            ← Back to Alerts
          </a>
        </div>
        
        <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
          <h1 className="text-3xl font-bold text-text-primary mb-4">
            {alert.title}
          </h1>
          
          <div className="text-text-secondary mb-4">
            {alert.location?.name && (
              <div className="mb-2">📍 {alert.location.name}</div>
            )}
            <div>📅 {new Date(alert.created_at).toLocaleString()}</div>
          </div>
          
          {alert.description && (
            <div className="text-text-primary mb-6">
              <p className="whitespace-pre-wrap">{alert.description}</p>
            </div>
          )}
          
          {alert.media_files && alert.media_files.length > 0 && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
              {alert.media_files.map((media: any) => (
                <div key={media.id} className="bg-dark-background rounded-lg p-2">
                  {media.type === 'image' ? (
                    <img 
                      src={media.url} 
                      alt="Alert media"
                      className="w-full h-auto rounded"
                    />
                  ) : media.type === 'video' ? (
                    <video 
                      src={media.url} 
                      controls
                      className="w-full h-auto rounded"
                    />
                  ) : null}
                </div>
              ))}
            </div>
          )}
          
          <div className="flex items-center gap-4 text-sm text-text-tertiary">
            <span>🔍 Alert Level: {alert.alert_level}</span>
            <span>👥 Witnesses: {alert.witness_count || 0}</span>
            <span>✅ Confirmations: {alert.total_confirmations || 0}</span>
          </div>
        </div>
      </div>
    </main>
  )
}