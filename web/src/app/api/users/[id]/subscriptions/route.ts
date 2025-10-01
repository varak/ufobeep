import { NextRequest } from 'next/server'
import { proxyToBackendAPI } from '@/utils/api-proxy'

export async function GET(request: NextRequest, context: { params: Promise<{ id: string }> }) {
  const { id } = await context.params
  return proxyToBackendAPI(request, `/users/${id}/subscriptions`)
}