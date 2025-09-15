import { NextRequest } from 'next/server'
import { proxyToBackendAPI } from '@/utils/api-proxy'

export const dynamic = 'force-dynamic'

// GET /api/beep/[id]/follow - Check follow status
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const { id } = params
  return proxyToBackendAPI(request, `/beep/${id}/follow`, 'GET')
}

// POST /api/beep/[id]/follow - Follow alert
export async function POST(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const { id } = params
  return proxyToBackendAPI(request, `/beep/${id}/follow`, 'POST')
}

// DELETE /api/beep/[id]/follow - Unfollow alert
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const { id } = params
  return proxyToBackendAPI(request, `/beep/${id}/follow`, 'DELETE')
}