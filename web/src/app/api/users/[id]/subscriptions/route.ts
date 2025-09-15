import { NextRequest } from 'next/server'
import { proxyToBackendAPI } from '@/utils/api-proxy'

export async function GET(request: NextRequest, { params }: { params: { id: string } }) {
  const { id } = params
  return proxyToBackendAPI(request, `/users/${id}/subscriptions`)
}