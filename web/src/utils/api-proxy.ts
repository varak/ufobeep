import { NextRequest, NextResponse } from 'next/server'
import { apiConfig } from '@/config/api'
import { broadcastCommentUpdate, broadcastCommentAdd, broadcastCommentDelete } from '@/utils/sse-broadcast'

export interface ProxyOptions {
  triggerSSEBroadcast?: boolean
  allowUnauthenticated?: boolean
}

/**
 * Shared utility to proxy requests to the backend API
 * Handles authentication forwarding, error handling, and optional SSE broadcasting
 */
export async function proxyToBackendAPI(
  request: NextRequest,
  backendPath: string,
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' = 'GET',
  options: ProxyOptions = {}
): Promise<NextResponse> {
  try {
    const authHeader = request.headers.get('authorization')

    // Check authentication if required
    if (!options.allowUnauthenticated && !authHeader) {
      return NextResponse.json(
        { error: 'Authorization header required' },
        { status: 401 }
      )
    }

    // Build API URL
    const apiUrl = `${apiConfig.fullUrl}${backendPath}`

    // Prepare headers
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    }
    if (authHeader) {
      headers['Authorization'] = authHeader
    }

    // Prepare request body for POST/PUT requests
    let body: string | undefined
    if (method === 'POST' || method === 'PUT') {
      body = JSON.stringify(await request.json())
    }

    // Make request to backend
    const response = await fetch(apiUrl, {
      method,
      headers,
      ...(body && { body })
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      return NextResponse.json(
        { error: `Failed to ${method.toLowerCase()} resource`, detail: errorData.detail },
        { status: response.status }
      )
    }

    const data = await response.json()

    // Trigger SSE broadcast if requested (surgical deltas for comments)
    if (options.triggerSSEBroadcast && backendPath.includes('/comments')) {
      const addMatch = backendPath.match(/\/beep\/([^\/]+)\/comments(\/?$)/)
      const delMatch = backendPath.match(/\/beep\/([^\/]+)\/comments\/([^\/]+)/)
      if (method === 'POST' && addMatch) {
        const alertId = addMatch[1]
        const comment = (data && (data.item || data.data || data))
        if (comment && (comment.id != null || comment.comment_id != null)) {
          broadcastCommentAdd(alertId, comment)
        } else {
          // Fallback for backends that don't return the created comment
          broadcastCommentUpdate(alertId)
        }
      } else if (method === 'DELETE' && delMatch) {
        const alertId = delMatch[1]
        const commentId = delMatch[2]
        if (commentId) broadcastCommentDelete(alertId, commentId)
        else broadcastCommentUpdate(alertId)
      } else {
        const idMatch = backendPath.match(/\/beep\/([^\/]+)\//)
        if (idMatch) broadcastCommentUpdate(idMatch[1])
      }
    }

    return NextResponse.json(data)
  } catch (error) {
    console.error(`Error proxying ${method} request to ${backendPath}:`, error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

/**
 * Handle special broadcast-only requests from the backend
 */
export async function handleBroadcastRequest(
  request: NextRequest,
  alertId: string
): Promise<NextResponse | null> {
  try {
    const body = await request.json()
    console.log(`[SSE] handleBroadcastRequest for alert ${alertId}:`, body)
    if (body.broadcast_only) {
      console.log(`[SSE] Broadcasting comment_update to all clients for alert ${alertId}`)
      broadcastCommentUpdate(alertId)
      console.log(`[SSE] Broadcast complete for alert ${alertId}`)
      return NextResponse.json({ message: 'Broadcast sent' })
    }
  } catch (error) {
    console.log(`[SSE] handleBroadcastRequest parse error for alert ${alertId}:`, error)
    // Not a JSON request, continue with normal processing
  }
  return null
}
