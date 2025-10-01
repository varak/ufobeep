import { NextRequest } from 'next/server'
import { proxyToBackendAPI } from '@/utils/api-proxy'

export const dynamic = 'force-dynamic'

// GET /api/beep/[id]/follow - Check follow status
export async function GET(
  request: NextRequest,
  context: { params: Promise<{ id: string }> }
) {
  const { id } = await context.params
  return proxyToBackendAPI(request, `/beep/${id}/follow`, 'GET')
}

// POST /api/beep/[id]/follow - Follow alert
export async function POST(
  request: NextRequest,
  context: { params: Promise<{ id: string }> }
) {
  const { id } = await context.params
  return proxyToBackendAPI(request, `/beep/${id}/follow`, 'POST')
}

// DELETE /api/beep/[id]/follow - Unfollow alert
export async function DELETE(
  request: NextRequest,
  context: { params: Promise<{ id: string }> }
) {
  const { id } = await context.params
  return proxyToBackendAPI(request, `/beep/${id}/follow`, 'DELETE')
}