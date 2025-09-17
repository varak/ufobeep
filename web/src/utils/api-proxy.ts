import { NextRequest, NextResponse } from 'next/server'
import { apiConfig } from '@/config/api'

export interface ProxyOptions {
  allowUnauthenticated?: boolean
}

/**
 * Shared utility to proxy requests to the backend API
 * Handles authentication forwarding and error handling
 */
export async function proxyToBackendAPI(
  request: NextRequest,
  backendPath: string,
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' = 'GET',
  options: ProxyOptions = {}
): Promise<NextResponse> {
  try {
    const authHeader = request.headers.get('authorization')

    // Check authentication if required
    if (!options.allowUnauthenticated && !authHeader) {
      return NextResponse.json(
        { error: 'Authorization header required' },
        { status: 401 }
      )
    }

    // Build API URL
    const apiUrl = `${apiConfig.fullUrl}${backendPath}`

    // Prepare headers
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    }
    if (authHeader) {
      headers['Authorization'] = authHeader
    }

    // Prepare request body for POST/PUT requests
    let body: string | undefined
    if (method === 'POST' || method === 'PUT') {
      body = JSON.stringify(await request.json())
    }

    // Make request to backend
    const response = await fetch(apiUrl, {
      method,
      headers,
      ...(body && { body })
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      return NextResponse.json(
        { error: `Failed to ${method.toLowerCase()} resource`, detail: errorData.detail },
        { status: response.status }
      )
    }

    const data = await response.json()

    return NextResponse.json(data)
  } catch (error) {
    console.error(`Error proxying ${method} request to ${backendPath}:`, error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

