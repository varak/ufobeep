import { NextRequest, NextResponse } from 'next/server'
import { apiConfig } from '@/config/api'

// GET /api/beep/map-points - Fetch ALL alert points for map
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const minimal = searchParams.get('minimal') === 'true'

    // In production, use direct backend URL to avoid self-referencing
    const apiUrl = `http://localhost:8000/beep/map-points${minimal ? '?minimal=true' : ''}`

    const response = await fetch(apiUrl, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
      // No cache - always get fresh data
      cache: 'no-store'
    })

    if (!response.ok) {
      return NextResponse.json(
        { error: 'Failed to fetch map points' },
        { status: response.status }
      )
    }

    const data = await response.json()
    return NextResponse.json(data)
  } catch (error) {
    console.error('Error fetching map points:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}