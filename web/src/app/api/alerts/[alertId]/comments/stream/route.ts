import { NextRequest } from 'next/server'
import { addSSEConnection, removeSSEConnection } from '@/utils/sse-broadcast'

export async function GET(
  request: NextRequest,
  { params }: { params: { alertId: string } }
) {
  const alertId = params.alertId

  console.log(`[SSE] New connection for alert ${alertId}`)

  const stream = new ReadableStream({
    start(controller) {
      // Add connection to alert's subscriber list
      addSSEConnection(alertId, controller)

      // Send initial connection message
      const initialMessage = `data: ${JSON.stringify({ type: 'connected', alertId })}\n\n`
      controller.enqueue(new TextEncoder().encode(initialMessage))

      // Keep connection alive with periodic heartbeat
      const heartbeat = setInterval(() => {
        try {
          controller.enqueue(new TextEncoder().encode(`data: ${JSON.stringify({ type: 'heartbeat' })}\n\n`))
        } catch (error) {
          clearInterval(heartbeat)
        }
      }, 30000)

      // Cleanup on close
      request.signal.addEventListener('abort', () => {
        console.log(`[SSE] Connection closed for alert ${alertId}`)
        clearInterval(heartbeat)
        removeSSEConnection(alertId, controller)
        try {
          controller.close()
        } catch {}
      })
    },
  })

  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Cache-Control',
    },
  })
}