// In-memory store for SSE connections per alert
const alertConnections = new Map<string, Set<ReadableStreamDefaultController>>()

// Helper to broadcast to all connections for an alert
export function broadcastCommentUpdate(alertId: string) {
  const connections = alertConnections.get(alertId)
  if (connections) {
    const message = `data: ${JSON.stringify({ type: 'comment_update', alertId })}\n\n`

    // Send to all connections, remove dead ones
    const deadConnections: ReadableStreamDefaultController[] = []

    connections.forEach(controller => {
      try {
        controller.enqueue(new TextEncoder().encode(message))
      } catch (error) {
        deadConnections.push(controller)
      }
    })

    // Clean up dead connections
    deadConnections.forEach(dead => {
      connections.delete(dead)
    })

    if (connections.size === 0) {
      alertConnections.delete(alertId)
    }

    console.log(`[SSE] Broadcast to ${connections.size} connections for alert ${alertId}`)
  }
}

// Helper to add connection to alert's subscriber list
export function addSSEConnection(alertId: string, controller: ReadableStreamDefaultController) {
  if (!alertConnections.has(alertId)) {
    alertConnections.set(alertId, new Set())
  }
  alertConnections.get(alertId)!.add(controller)
}

// Helper to remove connection from alert's subscriber list
export function removeSSEConnection(alertId: string, controller: ReadableStreamDefaultController) {
  alertConnections.get(alertId)?.delete(controller)
  if (alertConnections.get(alertId)?.size === 0) {
    alertConnections.delete(alertId)
  }
}