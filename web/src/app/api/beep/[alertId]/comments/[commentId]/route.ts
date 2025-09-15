import { NextRequest } from 'next/server'
import { proxyToBackendAPI } from '@/utils/api-proxy'

export const dynamic = 'force-dynamic'

// DELETE /api/beep/[alertId]/comments/[commentId] - Delete a comment
export async function DELETE(
  request: NextRequest,
  { params }: { params: { alertId: string; commentId: string } }
) {
  const { alertId, commentId } = params

  return proxyToBackendAPI(
    request,
    `/beep/${alertId}/comments/${commentId}`,
    'DELETE',
    { triggerSSEBroadcast: true }
  )
}