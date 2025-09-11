import { NextRequest, NextResponse } from 'next/server'
import { apiConfig } from '@/config/api'

// GET /api/alerts/[alertId]/follow - Check follow status
export async function GET(
  request: NextRequest,
  { params }: { params: { alertId: string } }
) {
  try {
    const { alertId } = params
    const authHeader = request.headers.get('authorization')
    
    const apiUrl = `${apiConfig.fullUrl}/beep/${alertId}/follow`
    
    const response = await fetch(apiUrl, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...(authHeader && { 'Authorization': authHeader })
      },
    })
    
    if (!response.ok) {
      return NextResponse.json(
        { error: 'Failed to check follow status' },
        { status: response.status }
      )
    }
    
    const data = await response.json()
    return NextResponse.json(data)
  } catch (error) {
    console.error('Error checking follow status:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

// POST /api/alerts/[alertId]/follow - Follow alert
export async function POST(
  request: NextRequest,
  { params }: { params: { alertId: string } }
) {
  try {
    const { alertId } = params
    const authHeader = request.headers.get('authorization')
    
    const apiUrl = `${apiConfig.fullUrl}/beep/${alertId}/follow`
    
    const response = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(authHeader && { 'Authorization': authHeader })
      },
    })
    
    if (!response.ok) {
      return NextResponse.json(
        { error: 'Failed to follow alert' },
        { status: response.status }
      )
    }
    
    const data = await response.json()
    return NextResponse.json(data)
  } catch (error) {
    console.error('Error following alert:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

// DELETE /api/alerts/[alertId]/follow - Unfollow alert
export async function DELETE(
  request: NextRequest,
  { params }: { params: { alertId: string } }
) {
  try {
    const { alertId } = params
    const authHeader = request.headers.get('authorization')
    
    const apiUrl = `${apiConfig.fullUrl}/beep/${alertId}/follow`
    
    const response = await fetch(apiUrl, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        ...(authHeader && { 'Authorization': authHeader })
      },
    })
    
    if (!response.ok) {
      return NextResponse.json(
        { error: 'Failed to unfollow alert' },
        { status: response.status }
      )
    }
    
    const data = await response.json()
    return NextResponse.json(data)
  } catch (error) {
    console.error('Error unfollowing alert:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}