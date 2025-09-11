import { NextRequest, NextResponse } from 'next/server'
import { apiConfig } from '@/config/api'

// GET /api/beep/[shortId] - Fetch single beep by short URL
export async function GET(
  request: NextRequest,
  { params }: { params: { shortId: string } }
) {
  try {
    const { shortId } = params
    
    // Use the by-short-url endpoint that already exists on the backend
    const apiUrl = `${apiConfig.fullUrl}/beep/by-short-url/${shortId}`
    
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