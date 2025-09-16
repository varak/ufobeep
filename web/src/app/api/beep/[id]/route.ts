import { NextRequest } from 'next/server'
import { proxyToBackendAPI } from '@/utils/api-proxy'

// GET /api/beep/[id] - Fetch single beep by ID via backend proxy
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const { id } = params
  // Reuse the standard proxy helper for proper env routing and headers
  return proxyToBackendAPI(request, `/beep/${id}`, 'GET', { allowUnauthenticated: true })
}
