import { NextRequest, NextResponse } from 'next/server'
import { apiConfig } from '@/config/api'

// GET /api/beep - Fetch beeps (list/search)
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const queryString = searchParams.toString()
    
    // Use direct backend URL to avoid self-referencing
    const apiUrl = `http://localhost:8000/beep${queryString ? `?${queryString}` : ''}`
    
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
    
    // Use direct backend URL to avoid self-referencing
    const apiUrl = `http://localhost:8000/beep`
    
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