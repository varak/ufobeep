'use client'

import { useEffect, useMemo, useRef, useState } from 'react'

interface CommentItemProps {
  id: number
  body: string
  expanded: boolean
  onToggle: (id: number) => void
  onCopyLink?: (id: number) => void
  copied?: boolean
}

export default function CommentItem({ id, body, expanded, onToggle, onCopyLink, copied }: CommentItemProps) {
  const containerRef = useRef<HTMLDivElement | null>(null)
  const [isTruncated, setIsTruncated] = useState(false)

  // Measure if the content would be truncated when not expanded
  const measure = () => {
    const el = containerRef.current
    if (!el) return
    // Temporarily apply clamp classes to measure potential truncation
    const wasExpanded = expanded
    if (wasExpanded) el.dataset.forceClamp = '1'
    const prevClass = el.className
    if (wasExpanded) {
      el.className = prevClass + ' clamp-4 md:clamp-8'
    }
    // Use a rAF to ensure layout is up-to-date
    requestAnimationFrame(() => {
      try {
        const truncated = el.scrollHeight > el.clientHeight + 2 // small tolerance
        setIsTruncated(truncated)
      } finally {
        if (wasExpanded) {
          el.className = prevClass
          delete el.dataset.forceClamp
        }
      }
    })
  }

  useEffect(() => {
    measure()
    const ro = new ResizeObserver(() => measure())
    if (containerRef.current) ro.observe(containerRef.current)
    return () => ro.disconnect()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const anchorId = useMemo(() => `c-${id}`, [id])

  return (
    <div id={anchorId} className="group relative">
      <div
        ref={containerRef}
        className={[
          'text-text-secondary text-sm leading-relaxed whitespace-pre-wrap break-words',
          !expanded && 'clamp-4 md:clamp-8',
        ].filter(Boolean).join(' ')}
        aria-expanded={expanded}
      >
        {body}
      </div>
      {!expanded && isTruncated && (
        <div className="pointer-events-none fade-gradient"></div>
      )}
      <div className="mt-2 flex items-center gap-3">
        {isTruncated && (
          <button
            type="button"
            onClick={() => onToggle(id)}
            className="text-xs text-brand-primary hover:text-brand-primary/90"
            aria-expanded={expanded}
            aria-controls={anchorId}
          >
            {expanded ? 'Show less' : 'Show more'}
          </button>
        )}
        <button
          type="button"
          onClick={() => onCopyLink?.(id)}
          className="text-xs text-text-tertiary hover:text-text-secondary"
        >
          {copied ? 'Copied' : 'Copy link'}
        </button>
      </div>
    </div>
  )
}

