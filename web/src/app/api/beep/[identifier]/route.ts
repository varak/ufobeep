import { NextRequest, NextResponse } from 'next/server'
import { apiConfig } from '@/config/api'

// GET /api/beep/[shortId] - Fetch single beep by ID or short URL
export async function GET(
  request: NextRequest,
  { params }: { params: { shortId: string } }
) {
  try {
    const { shortId } = params

    // Debug logging
    console.log('API endpoint called with shortId:', shortId)

    // Check if it's a UUID or short URL
    const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(shortId)

    const baseUrl = process.env.NODE_ENV === 'production'
      ? 'https://ufobeep.com/api'
      : 'http://localhost:8000'

    // Use different endpoint based on whether it's UUID or short URL
    const apiUrl = isUuid
      ? `${baseUrl}/beep/${shortId}`  // UUID endpoint
      : `${baseUrl}/beep/by-short-url/${shortId}`  // Short URL endpoint

    console.log('Calling backend API:', apiUrl)

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