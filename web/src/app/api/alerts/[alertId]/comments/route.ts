import { NextRequest, NextResponse } from 'next/server'

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

// GET /api/alerts/[alertId]/comments - Fetch comments for an alert
export async function GET(
  request: NextRequest,
  { params }: { params: { alertId: string } }
) {
  try {
    const { alertId } = params
    
    const apiUrl = `${API_BASE_URL}/beep/${alertId}/comments`
    
    const response = await fetch(apiUrl, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    })
    
    if (!response.ok) {
      return NextResponse.json(
        { error: 'Failed to fetch comments' },
        { status: response.status }
      )
    }
    
    const data = await response.json()
    return NextResponse.json(data)
  } catch (error) {
    console.error('Error fetching comments:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

// POST /api/alerts/[alertId]/comments - Create new comment
export async function POST(
  request: NextRequest,
  { params }: { params: { alertId: string } }
) {
  try {
    const { alertId } = params
    const body = await request.json()
    const authHeader = request.headers.get('authorization')
    
    const apiUrl = `${API_BASE_URL}/beep/${alertId}/comments`
    
    const response = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(authHeader && { 'Authorization': authHeader })
      },
      body: JSON.stringify(body)
    })
    
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      return NextResponse.json(
        { error: 'Failed to create comment', detail: errorData.detail },
        { status: response.status }
      )
    }
    
    const data = await response.json()
    return NextResponse.json(data)
  } catch (error) {
    console.error('Error creating comment:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}