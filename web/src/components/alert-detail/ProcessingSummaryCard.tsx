'use client'

import { useClientTranslations } from '@/hooks/useClientTranslations'

interface ProcessingSummary {
  total_processors?: number
  successful_processors?: number
  failed_processors?: number
  processing_time_ms?: number
}

interface ProcessingSummaryCardProps {
  summary: ProcessingSummary
  locale?: string
}

export default function ProcessingSummaryCard({ summary, locale = 'en' }: ProcessingSummaryCardProps) {
  const { t } = useClientTranslations('common', locale)

  return (
    <div className="bg-dark-surface border border-dark-border rounded-lg p-6">
      <div className="flex items-center gap-2 mb-4">
        <span className="text-brand-primary">⚙️</span>
        <h2 className="text-lg font-semibold text-brand-primary">{t('processingStatusTitle')}</h2>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {summary.successful_processors !== undefined && (
          <div>
            <div className="text-text-tertiary text-xs">{t('successfulProcessors')}</div>
            <div className="text-text-primary text-sm text-green-400">{summary.successful_processors}</div>
          </div>
        )}

        {summary.failed_processors !== undefined && (
          <div>
            <div className="text-text-tertiary text-xs">{t('failedProcessors')}</div>
            <div className="text-text-primary text-sm text-red-400">{summary.failed_processors}</div>
          </div>
        )}

        {summary.total_processors !== undefined && (
          <div>
            <div className="text-text-tertiary text-xs">Total</div>
            <div className="text-text-primary text-sm">{summary.total_processors}</div>
          </div>
        )}

        {summary.processing_time_ms !== undefined && (
          <div>
            <div className="text-text-tertiary text-xs">{t('processingTime')}</div>
            <div className="text-text-primary text-sm">{summary.processing_time_ms}ms</div>
          </div>
        )}
      </div>
    </div>
  )
}