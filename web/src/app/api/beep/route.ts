import { NextRequest, NextResponse } from 'next/server'
import { apiConfig } from '@/config/api'
import { broadcastAlertAdd } from '@/utils/sse-broadcast'

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

    try {
      const created: any = (data && (data.data || data.item || data))
      // Normalize minimal alert payload
      const alert = {
        id: created?.id || created?.alert?.id,
        created_at: created?.created_at || created?.createdAt || new Date().toISOString(),
        source: created?.source,
        alert_level: created?.alert_level || created?.level,
        title: created?.title,
        location: created?.location || (
          (created?.latitude != null && created?.longitude != null) ? { latitude: created.latitude, longitude: created.longitude } : undefined
        )
      }
      if (alert.id && alert.location && Number.isFinite(Number(alert.location.latitude)) && Number.isFinite(Number(alert.location.longitude))) {
        broadcastAlertAdd(alert)
      }
    } catch (e) {
      console.error('broadcast alert_add failed', e)
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
