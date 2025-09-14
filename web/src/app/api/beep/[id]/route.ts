import { NextResponse } from 'next/server'
import { apiConfig } from '@/config/api'

// GET /api/beep/[id] - Fetch single alert by ID
export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const apiUrl = `${apiConfig.fullUrl}/beep/${params.id}`

    const response = await fetch(apiUrl, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
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