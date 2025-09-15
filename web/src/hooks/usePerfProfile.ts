import { useEffect, useMemo, useState } from 'react'

type PerfOverride = 'low' | 'high' | 'auto'

export interface PerfProfile {
  isLowEnd: boolean
  saveData: boolean
  effectiveType?: string
  reducedMotion: boolean
  override: PerfOverride
}

export function usePerfProfile(): PerfProfile {
  const [override, setOverride] = useState<PerfOverride>('auto')
  const [isLowEndAuto, setIsLowEndAuto] = useState(false)
  const [conn, setConn] = useState<any>(undefined)
  const [reducedMotion, setReducedMotion] = useState(false)

  useEffect(() => {
    try {
      const stored = localStorage.getItem('ufobeep:perf') as PerfOverride | null
      if (stored === 'low' || stored === 'high' || stored === 'auto') setOverride(stored)
    } catch {}
  }, [])

  useEffect(() => {
    try {
      // Connection info
      const c = (navigator as any).connection || (navigator as any).mozConnection || (navigator as any).webkitConnection
      setConn(c)
      const handleChange = () => setConn({ ...c })
      c?.addEventListener?.('change', handleChange)
      return () => c?.removeEventListener?.('change', handleChange)
    } catch {}
  }, [])

  useEffect(() => {
    try {
      const mq = window.matchMedia('(prefers-reduced-motion: reduce)')
      setReducedMotion(mq.matches)
      const cb = () => setReducedMotion(mq.matches)
      mq.addEventListener?.('change', cb)
      return () => mq.removeEventListener?.('change', cb)
    } catch {}
  }, [])

  useEffect(() => {
    // Compute auto low-end status
    try {
      const cores = (navigator as any).hardwareConcurrency || 4
      const mem = (navigator as any).deviceMemory // may be undefined
      const saveData = !!conn?.saveData
      const type = (conn?.effectiveType || '').toLowerCase()
      const slowNet = type === 'slow-2g' || type === '2g' || type === '3g'
      const lowCores = cores <= 4
      const lowMem = typeof mem === 'number' ? mem <= 2 : false
      setIsLowEndAuto(lowCores || lowMem || saveData || slowNet)
    } catch {
      setIsLowEndAuto(false)
    }
  }, [conn])

  const isLowEnd = useMemo(() => {
    if (override === 'low') return true
    if (override === 'high') return false
    return isLowEndAuto
  }, [override, isLowEndAuto])

  return {
    isLowEnd,
    saveData: !!conn?.saveData,
    effectiveType: conn?.effectiveType,
    reducedMotion,
    override,
  }
}

