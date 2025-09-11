import { NextRequest, NextResponse } from 'next/server'

const API_BASE_URL = 'http://localhost:8000'

// GET /api/beep/[shortUrl] - Fetch single beep by short URL
export async function GET(request: NextRequest, { params }: { params: { shortUrl: string } }) {
  try {
    const { shortUrl } = params
    
    // Use backend endpoint to get single beep by short_url
    const apiUrl = `${API_BASE_URL}/beep/by-short-url/${shortUrl}`
    
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
    
    // Transform response for frontend compatibility: alert -> beep
    if (data.success && data.data?.alert) {
      data.data.beep = data.data.alert
      delete data.data.alert
    }
    
    return NextResponse.json(data)
  } catch (error) {
    console.error('Error fetching beep by short URL:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}