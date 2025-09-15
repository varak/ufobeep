import { NextRequest } from 'next/server'
import { proxyToBackendAPI } from '@/utils/api-proxy'

export async function GET(request: NextRequest) {
  return proxyToBackendAPI(request, '/users/me')
}