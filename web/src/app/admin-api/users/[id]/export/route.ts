import { NextRequest, NextResponse } from 'next/server'

const API_BASE = 'http://127.0.0.1:8000'

// Force dynamic rendering
export const dynamic = 'force-dynamic'

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const adminKey = request.headers.get('X-Admin-Key')
    if (!adminKey) {
      return NextResponse.json({ error: 'Admin key required' }, { status: 401 })
    }

    const { id } = params

    // Get format from query params (default to json)
    const { searchParams } = new URL(request.url)
    const format = searchParams.get('format') || 'json'

    const backendUrl = `${API_BASE}/api/admin/users/${id}/export?format=${format}`

    const response = await fetch(backendUrl, {
      method: 'GET',
      headers: {
        'X-Admin-Key': adminKey,
      },
    })

    if (!response.ok) {
      throw new Error(`Backend responded with ${response.status}`)
    }

    if (format === 'csv') {
      // For CSV format, return the raw text with appropriate headers
      const csvData = await response.text()
      return new NextResponse(csvData, {
        status: 200,
        headers: {
          'Content-Type': 'text/csv',
          'Content-Disposition': response.headers.get('Content-Disposition') || 'attachment; filename=user_data.csv'
        }
      })
    } else {
      // For JSON format, return JSON response
      const data = await response.json()
      return NextResponse.json(data)
    }

  } catch (error: any) {
    console.error('Admin export user API error:', {
      message: error.message,
      stack: error.stack,
      cause: error.cause
    })
    return NextResponse.json({
      error: 'Failed to export user data',
      details: error.message
    }, { status: 500 })
  }
}