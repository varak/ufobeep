import { NextRequest, NextResponse } from 'next/server'
import { apiConfig } from '@/config/api'

// GET /api/beep/[id] - Fetch single beep by ID
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params

    const baseUrl = process.env.NODE_ENV === 'production'
      ? 'https://ufobeep.com/api'
      : 'http://localhost:8000'

    const apiUrl = `${baseUrl}/beep/${id}`

    const response = await fetch(apiUrl, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    })
    
    if (!response.ok) {
      return NextResponse.json(
        { error: 'Beep not found' },
        { status: response.status }
      )
    }
    
    const data = await response.json()

    // Transform response for frontend compatibility
    // The backend returns data directly, not nested under 'alert' or 'beep'
    if (data.success && data.data) {
      // Return data as-is since it's already in the right format
      return NextResponse.json(data)
    }

    return NextResponse.json(data)
  } catch (error) {
    console.error('Error fetching beep by short URL:', error)
    console.error('Error details:', error instanceof Error ? error.message : error)
    return NextResponse.json(
      { error: 'Internal server error', details: error instanceof Error ? error.message : 'Unknown error' },
      { status: 500 }
    )
  }
}