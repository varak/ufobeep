'use client'

import { useClientTranslations } from '@/hooks/useClientTranslations'

interface LocationData {
  address?: string
  city?: string
  state?: string
  country?: string
  timezone?: string
  latitude?: number
  longitude?: number
}

interface LocationCardProps {
  location: LocationData
  locale?: string
}

export default function LocationCard({ location, locale = 'en' }: LocationCardProps) {
  const { t } = useClientTranslations('common', locale)

  return (
    <div className="bg-dark-surface/50 border border-dark-border/50 rounded-xl p-5 shadow-sm hover:bg-dark-surface/70 transition-colors">
      <div className="flex items-center gap-2 mb-4">
        <span className="text-brand-primary">📍</span>
        <h2 className="text-lg font-semibold text-brand-primary">{t('locationEnrichmentTitle')}</h2>
      </div>

      <div className="grid grid-cols-2 gap-4">
        {location.city && (
          <div>
            <div className="text-text-tertiary text-xs">{t('city')}</div>
            <div className="text-text-primary text-sm">{location.city}</div>
          </div>
        )}

        {location.state && (
          <div>
            <div className="text-text-tertiary text-xs">{t('state')}</div>
            <div className="text-text-primary text-sm">{location.state}</div>
          </div>
        )}

        {location.country && (
          <div>
            <div className="text-text-tertiary text-xs">{t('country')}</div>
            <div className="text-text-primary text-sm">{location.country}</div>
          </div>
        )}

        {location.timezone && (
          <div>
            <div className="text-text-tertiary text-xs">{t('timezone')}</div>
            <div className="text-text-primary text-sm">{location.timezone}</div>
          </div>
        )}

        {location.latitude !== undefined && location.longitude !== undefined && (
          <div className="col-span-2">
            <div className="text-text-tertiary text-xs">{t('coordinatesLabel')}</div>
            <div className="text-text-primary text-sm">
              {location.latitude.toFixed(6)}, {location.longitude.toFixed(6)}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}