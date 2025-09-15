import { NextRequest } from 'next/server'
import { proxyToBackendAPI } from '@/utils/api-proxy'

export const dynamic = 'force-dynamic'

// GET /api/beep/[alertId]/follow - Check follow status
export async function GET(
  request: NextRequest,
  { params }: { params: { alertId: string } }
) {
  const { alertId } = params
  return proxyToBackendAPI(request, `/beep/${alertId}/follow`, 'GET')
}

// POST /api/beep/[alertId]/follow - Follow alert
export async function POST(
  request: NextRequest,
  { params }: { params: { alertId: string } }
) {
  const { alertId } = params
  return proxyToBackendAPI(request, `/beep/${alertId}/follow`, 'POST')
}

// DELETE /api/beep/[alertId]/follow - Unfollow alert
export async function DELETE(
  request: NextRequest,
  { params }: { params: { alertId: string } }
) {
  const { alertId } = params
  return proxyToBackendAPI(request, `/beep/${alertId}/follow`, 'DELETE')
}