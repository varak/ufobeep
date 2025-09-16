import { NextRequest, NextResponse } from 'next/server'
import { addAlertsSSEConnection, removeAlertsSSEConnection } from '@/utils/sse-broadcast'

export const dynamic = 'force-dynamic'
export const runtime = 'nodejs'

// GET /api/alerts/stream - SSE stream for live alert adds
export async function GET(_request: NextRequest) {
  const encoder = new TextEncoder()
  let controller: ReadableStreamDefaultController<Uint8Array> | null = null

  const stream = new ReadableStream<Uint8Array>({
    start(ctrl) {
      controller = ctrl
      addAlertsSSEConnection(controller)
      // Initial message
      ctrl.enqueue(encoder.encode(`data: ${JSON.stringify({ type: 'connected' })}\n\n`))
      // Heartbeat to keep connections alive
      const iv = setInterval(() => {
        try { ctrl.enqueue(encoder.encode(`data: ${JSON.stringify({ type: 'heartbeat', t: Date.now() })}\n\n`)) } catch { clearInterval(iv) }
      }, 30000)
      ;(controller as any)._iv = iv
    },
    cancel() {
      if (controller) {
        removeAlertsSSEConnection(controller)
        const iv = (controller as any)._iv
        if (iv) clearInterval(iv)
      }
    }
  })

  return new NextResponse(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET',
      'Access-Control-Allow-Headers': 'Content-Type',
    },
  })
}
