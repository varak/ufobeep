import { NextRequest, NextResponse } from 'next/server'

const API_BASE_URL = 'http://localhost:8000'

// GET /api/beep - Fetch beeps (list/search)
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const queryString = searchParams.toString()
    
    // Use new unified /beep endpoint
    const apiUrl = `${API_BASE_URL}/beep${queryString ? `?${queryString}` : ''}`
    
    const response = await fetch(apiUrl, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    })
    
    if (!response.ok) {
      return NextResponse.json(
        { error: 'Failed to fetch beeps' },
        { status: response.status }
      )
    }
    
    const data = await response.json()
    
    // Transform response for frontend compatibility: alerts -> beeps
    if (data.success && data.data?.alerts) {
      data.data.beeps = data.data.alerts
      delete data.data.alerts
    }
    
    return NextResponse.json(data)
  } catch (error) {
    console.error('Error fetching beeps:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

// POST /api/beep - Create new beep
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    // Use new unified /beep endpoint
    const apiUrl = `${API_BASE_URL}/beep`
    
    const response = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body)
    })
    
    if (!response.ok) {
      return NextResponse.json(
        { error: 'Failed to create beep' },
        { status: response.status }
      )
    }
    
    const data = await response.json()
    
    // Transform response for frontend compatibility: alerts -> beeps
    if (data.success && data.data?.alerts) {
      data.data.beeps = data.data.alerts
      delete data.data.alerts
    }
    
    return NextResponse.json(data)
  } catch (error) {
    console.error('Error creating beep:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}