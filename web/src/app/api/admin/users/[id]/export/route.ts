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

    const { searchParams } = new URL(request.url)
    const format = searchParams.get('format') || 'json'

    const backendUrl = `${API_BASE}/api/admin/users/${params.id}/export?format=${format}`

    const response = await fetch(backendUrl, {
      headers: {
        'X-Admin-Key': adminKey,
      },
    })

    if (!response.ok) {
      throw new Error(`Backend responded with ${response.status}`)
    }

    if (format === 'csv') {
      const csvData = await response.text()
      return new NextResponse(csvData, {
        headers: {
          'Content-Type': 'text/csv',
          'Content-Disposition': response.headers.get('Content-Disposition') || 'attachment; filename=user_data.csv',
        },
      })
    } else {
      const data = await response.json()
      return NextResponse.json(data)
    }

  } catch (error) {
    console.error('Admin export user data API error:', error)
    return NextResponse.json({ error: 'Failed to export user data' }, { status: 500 })
  }
}