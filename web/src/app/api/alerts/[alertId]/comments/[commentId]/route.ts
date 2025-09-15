import { NextRequest, NextResponse } from 'next/server'
import { apiConfig } from '@/config/api'
import { broadcastCommentUpdate } from '@/utils/sse-broadcast'

export const dynamic = 'force-dynamic'

// DELETE /api/alerts/[alertId]/comments/[commentId] - Delete a comment
export async function DELETE(
  request: NextRequest,
  { params }: { params: { alertId: string; commentId: string } }
) {
  try {
    const { alertId, commentId } = params
    const authHeader = request.headers.get('authorization')

    if (!authHeader) {
      return NextResponse.json(
        { error: 'Authorization header required' },
        { status: 401 }
      )
    }

    const apiUrl = `${apiConfig.fullUrl}/beep/${alertId}/comments/${commentId}`

    const response = await fetch(apiUrl, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authHeader
      },
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      return NextResponse.json(
        { error: 'Failed to delete comment', detail: errorData.detail },
        { status: response.status }
      )
    }

    const data = await response.json()

    // Broadcast to SSE connections that a comment was deleted
    broadcastCommentUpdate(alertId)

    return NextResponse.json(data)
  } catch (error) {
    console.error('Error deleting comment:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}