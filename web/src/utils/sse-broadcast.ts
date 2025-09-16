// In-memory store for SSE connections per alert
const alertConnections = new Map<string, Set<ReadableStreamDefaultController>>()

// Internal helper to send a payload to all subscribers of an alert
function sendToAlert(alertId: string, payload: any) {
  const connections = alertConnections.get(alertId)
  if (!connections || connections.size === 0) return
  const message = `data: ${JSON.stringify(payload)}\n\n`
  const enc = new TextEncoder()
  const dead: ReadableStreamDefaultController[] = []
  connections.forEach(ctrl => {
    try { ctrl.enqueue(enc.encode(message)) } catch { dead.push(ctrl) }
  })
  dead.forEach(d => connections.delete(d))
  if (connections.size === 0) alertConnections.delete(alertId)
  try { console.log(`[SSE] Broadcast ${payload.type} to ${connections.size} for alert ${alertId}`) } catch {}
}

// Backward-compatible ping (kept for any existing callers)
export function broadcastCommentUpdate(alertId: string) {
  sendToAlert(alertId, { type: 'comment_update', alertId })
}

// Surgical deltas for comments
export function broadcastCommentAdd(alertId: string, comment: any) {
  sendToAlert(alertId, { type: 'comment_add', alertId, comment })
}

export function broadcastCommentDelete(alertId: string, commentId: string | number) {
  sendToAlert(alertId, { type: 'comment_delete', alertId, commentId })
}

// Helper to add connection to alert's subscriber list
export function addSSEConnection(alertId: string, controller: ReadableStreamDefaultController) {
  if (!alertConnections.has(alertId)) alertConnections.set(alertId, new Set())
  alertConnections.get(alertId)!.add(controller)
}

// Helper to remove connection from alert's subscriber list
export function removeSSEConnection(alertId: string, controller: ReadableStreamDefaultController) {
  alertConnections.get(alertId)?.delete(controller)
  if (alertConnections.get(alertId)?.size === 0) alertConnections.delete(alertId)
}

// ===== Global Alerts Stream (for live map) =====
const alertsConnections = new Set<ReadableStreamDefaultController>()

function sendToAlertsAll(payload: any) {
  if (alertsConnections.size === 0) return
  const enc = new TextEncoder()
  const msg = `data: ${JSON.stringify(payload)}\n\n`
  const dead: ReadableStreamDefaultController[] = []
  alertsConnections.forEach(ctrl => { try { ctrl.enqueue(enc.encode(msg)) } catch { dead.push(ctrl) } })
  dead.forEach(d => alertsConnections.delete(d))
}

export function addAlertsSSEConnection(controller: ReadableStreamDefaultController) {
  alertsConnections.add(controller)
}

export function removeAlertsSSEConnection(controller: ReadableStreamDefaultController) {
  alertsConnections.delete(controller)
}

export function broadcastAlertAdd(alert: any) {
  // Emit minimal payload to keep traffic low
  const payload = {
    type: 'alert_add',
    alert: alert,
  }
  sendToAlertsAll(payload)
}
