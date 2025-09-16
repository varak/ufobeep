import { NextResponse } from 'next/server'

export const dynamic = 'force-dynamic'
export const runtime = 'nodejs'

export async function GET() {
  try {
    const g: any = globalThis as any
    const alertMap = g.__ufobeep_alertConnections as Map<string, Set<ReadableStreamDefaultController>> | undefined
    const alertsSet = g.__ufobeep_alertsConnections as Set<ReadableStreamDefaultController> | undefined
    const perAlert: Record<string, number> = {}
    if (alertMap) {
      for (const [k, v] of alertMap.entries()) perAlert[k] = v.size
    }
    return NextResponse.json({
      success: true,
      perAlert,
      alertsStreamConnections: alertsSet ? alertsSet.size : 0,
      keys: Object.keys(perAlert),
    })
  } catch (e: any) {
    return NextResponse.json({ success: false, error: String(e?.message || e) }, { status: 500 })
  }
}

