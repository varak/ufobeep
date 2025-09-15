import { NextRequest } from 'next/server'
import { proxyToBackendAPI, handleBroadcastRequest } from '@/utils/api-proxy'

export const dynamic = 'force-dynamic'

// GET /api/beep/[alertId]/comments - Get comments for alert
export async function GET(
  request: NextRequest,
  { params }: { params: { alertId: string } }
) {
  const { alertId } = params
  const { searchParams } = new URL(request.url)
  const limit = searchParams.get('limit') || '30'

  return proxyToBackendAPI(
    request,
    `/beep/${alertId}/comments?limit=${limit}`,
    'GET',
    { allowUnauthenticated: true }
  )
}

// POST /api/beep/[alertId]/comments - Create comment for alert
export async function POST(
  request: NextRequest,
  { params }: { params: { alertId: string } }
) {
  const { alertId } = params

  // Handle broadcast-only requests from FastAPI
  const broadcastResponse = await handleBroadcastRequest(request, alertId)
  if (broadcastResponse) {
    return broadcastResponse
  }

  return proxyToBackendAPI(
    request,
    `/beep/${alertId}/comments`,
    'POST',
    { triggerSSEBroadcast: true }
  )
}