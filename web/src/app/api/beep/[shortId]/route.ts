import { NextRequest, NextResponse } from 'next/server'
import { apiConfig } from '@/config/api'

// GET /api/beep/[shortId] - Fetch single beep by short URL
export async function GET(
  request: NextRequest,
  { params }: { params: { shortId: string } }
) {
  try {
    const { shortId } = params
    
    // Debug logging
    console.log('API endpoint called with shortId:', shortId)
    
    // Use the by-short-url endpoint that already exists on the backend
    // In production, need to call the actual backend API, not the frontend proxy
    const baseUrl = process.env.NODE_ENV === 'production' 
      ? 'https://ufobeep.com/api' 
      : 'http://localhost:8000'
    const apiUrl = `${baseUrl}/beep/by-short-url/${shortId}`
    
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
    
    // Transform response for frontend compatibility: alert -> beep
    if (data.success && data.data?.alert) {
      data.data.beep = data.data.alert
      delete data.data.alert
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