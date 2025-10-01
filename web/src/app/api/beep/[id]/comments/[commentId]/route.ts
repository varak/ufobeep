import { NextRequest } from 'next/server'
import { proxyToBackendAPI } from '@/utils/api-proxy'

export const dynamic = 'force-dynamic'
export const runtime = 'nodejs'

// DELETE /api/beep/[id]/comments/[commentId] - Delete a comment
export async function DELETE(
  request: NextRequest,
  context: { params: Promise<{ id: string; commentId: string }> }
) {
  const { id, commentId } = await context.params

  return proxyToBackendAPI(
    request,
    `/beep/${id}/comments/${commentId}`,
    'DELETE'
  )
}
