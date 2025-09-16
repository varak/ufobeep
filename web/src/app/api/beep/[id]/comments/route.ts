import { NextRequest } from 'next/server'
import { proxyToBackendAPI, handleBroadcastRequest } from '@/utils/api-proxy'

export const dynamic = 'force-dynamic'
export const runtime = 'nodejs'

// GET /api/beep/[id]/comments - Get comments for alert
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const { id } = params
  const { searchParams } = new URL(request.url)
  const limit = searchParams.get('limit') || '30'

  return proxyToBackendAPI(
    request,
    `/beep/${id}/comments?limit=${limit}`,
    'GET',
    { allowUnauthenticated: true }
  )
}

// POST /api/beep/[id]/comments - Create comment for alert
export async function POST(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const { id } = params

  // Handle broadcast-only requests from FastAPI
  const broadcastResponse = await handleBroadcastRequest(request, id)
  if (broadcastResponse) {
    return broadcastResponse
  }

  return proxyToBackendAPI(
    request,
    `/beep/${id}/comments`,
    'POST',
    { triggerSSEBroadcast: true }
  )
}
