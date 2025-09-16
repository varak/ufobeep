import { NextRequest, NextResponse } from 'next/server'
import { addSSEConnection, removeSSEConnection } from '@/utils/sse-broadcast'

export const dynamic = 'force-dynamic'
export const runtime = 'nodejs'

// GET /api/beep/[id]/comments/stream - SSE stream for real-time comment updates
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const { id } = params

  // Create SSE response
  const encoder = new TextEncoder()
  let controller: ReadableStreamDefaultController<Uint8Array> | null = null

  const stream = new ReadableStream({
    start(ctrl) {
      controller = ctrl

      // Register with shared broadcaster so proxy hooks can reach this stream
      addSSEConnection(id, controller)

      // Send initial connection message
      const initMessage = `data: ${JSON.stringify({ type: 'connected', alertId: id })}\n\n`
      controller.enqueue(encoder.encode(initMessage))

      // Set up heartbeat
      const heartbeatInterval = setInterval(() => {
        try {
          const heartbeatMessage = `data: ${JSON.stringify({ type: 'heartbeat', timestamp: Date.now() })}\n\n`
          controller!.enqueue(encoder.encode(heartbeatMessage))
        } catch (error) {
          clearInterval(heartbeatInterval)
          // Remove dead connection
          removeSSEConnection(id, controller!)
        }
      }, 30000) // 30 second heartbeat

      // Store interval for cleanup
      ;(controller as any)._heartbeatInterval = heartbeatInterval
    },

    cancel() {
      // Clean up this connection
      if (controller) {
        removeSSEConnection(id, controller)
        // Clear heartbeat
        if ((controller as any)._heartbeatInterval) {
          clearInterval((controller as any)._heartbeatInterval)
        }
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
