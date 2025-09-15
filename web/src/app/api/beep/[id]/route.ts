import { NextRequest, NextResponse } from 'next/server'
import { apiConfig } from '@/config/api'

// GET /api/beep/[id] - Fetch single beep by ID
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params

    // Always use direct backend URL
    const apiUrl = `http://localhost:8000/beep/${id}`

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
    
    const raw = await response.json()

    // Normalize to { success: true, data: {...} } for frontend consistency
    let normalized: any
    if (raw && raw.success && raw.data) {
      normalized = raw.data
    } else if (raw && raw.data) {
      normalized = raw.data
    } else if (raw && (raw.alert || raw.beep)) {
      normalized = raw.alert || raw.beep
    } else {
      normalized = raw
    }

    // Optional: field fallbacks to improve client robustness
    if (normalized) {
      // Ensure created_at has a value if backend used a different key
      normalized.created_at = normalized.created_at || normalized.occurred_at || normalized.timestamp || normalized.date || null
      // Normalize media files container shape
      if (normalized.media_files && normalized.media_files.files) {
        normalized.media_files = normalized.media_files.files
      }
    }

    return NextResponse.json({ success: true, data: normalized })
  } catch (error) {
    console.error('Error fetching beep by short URL:', error)
    console.error('Error details:', error instanceof Error ? error.message : error)
    return NextResponse.json(
      { error: 'Internal server error', details: error instanceof Error ? error.message : 'Unknown error' },
      { status: 500 }
    )
  }
}
