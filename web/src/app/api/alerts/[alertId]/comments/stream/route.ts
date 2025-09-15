import { NextRequest } from 'next/server'

// In-memory store for SSE connections per alert
const alertConnections = new Map<string, Set<ReadableStreamDefaultController>>()

// Helper to broadcast to all connections for an alert
export function broadcastCommentUpdate(alertId: string) {
  const connections = alertConnections.get(alertId)
  if (connections) {
    const message = `data: ${JSON.stringify({ type: 'comment_update', alertId })}\n\n`

    // Send to all connections, remove dead ones
    const deadConnections: ReadableStreamDefaultController[] = []

    for (const controller of connections) {
      try {
        controller.enqueue(new TextEncoder().encode(message))
      } catch (error) {
        deadConnections.push(controller)
      }
    }

    // Clean up dead connections
    for (const dead of deadConnections) {
      connections.delete(dead)
    }

    if (connections.size === 0) {
      alertConnections.delete(alertId)
    }

    console.log(`[SSE] Broadcast to ${connections.size} connections for alert ${alertId}`)
  }
}

export async function GET(
  request: NextRequest,
  { params }: { params: { alertId: string } }
) {
  const alertId = params.alertId

  console.log(`[SSE] New connection for alert ${alertId}`)

  const stream = new ReadableStream({
    start(controller) {
      // Add connection to alert's subscriber list
      if (!alertConnections.has(alertId)) {
        alertConnections.set(alertId, new Set())
      }
      alertConnections.get(alertId)!.add(controller)

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
        alertConnections.get(alertId)?.delete(controller)
        if (alertConnections.get(alertId)?.size === 0) {
          alertConnections.delete(alertId)
        }
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