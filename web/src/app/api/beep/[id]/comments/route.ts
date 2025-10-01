import { NextRequest, NextResponse } from 'next/server'
import { proxyToBackendAPI } from '@/utils/api-proxy'

export const dynamic = 'force-dynamic'
export const runtime = 'nodejs'

// GET /api/beep/[id]/comments - Get comments for alert
export async function GET(
  request: NextRequest,
  context: { params: Promise<{ id: string }> }
) {
  const { id } = await context.params
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
  context: { params: Promise<{ id: string }> }
) {
  const { id } = await context.params

  return proxyToBackendAPI(
    request,
    `/beep/${id}/comments`,
    'POST'
  )
}
