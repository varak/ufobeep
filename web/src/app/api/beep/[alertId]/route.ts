import { NextResponse } from 'next/server'
import { apiConfig } from '@/config/api'

// GET /api/beep/[alertId] - Fetch single alert by ID
export async function GET(
  request: Request,
  { params }: { params: { alertId: string } }
) {
  try {
    const apiUrl = `${apiConfig.fullUrl}/beep/${params.alertId}`

    const response = await fetch(apiUrl, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
      cache: 'no-store'
    })

    if (!response.ok) {
      return NextResponse.json(
        { error: 'Failed to fetch alert' },
        { status: response.status }
      )
    }

    const data = await response.json()
    return NextResponse.json(data)
  } catch (error) {
    console.error('Error fetching alert:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}