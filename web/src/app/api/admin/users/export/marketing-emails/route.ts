import { NextRequest, NextResponse } from 'next/server'

const API_BASE = process.env.API_BASE_URL || 'http://localhost:8000'

export async function GET(request: NextRequest) {
  try {
    const adminKey = request.headers.get('X-Admin-Key')
    if (!adminKey) {
      return NextResponse.json({ error: 'Admin key required' }, { status: 401 })
    }

    const { searchParams } = new URL(request.url)
    const format = searchParams.get('format') || 'csv'

    const backendUrl = `${API_BASE}/api/admin/users/export/marketing-emails?format=${format}`

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
          'Content-Disposition': 'attachment; filename=marketing-emails.csv',
        },
      })
    } else {
      const data = await response.json()
      return NextResponse.json(data)
    }

  } catch (error) {
    console.error('Admin export API error:', error)
    return NextResponse.json({ error: 'Failed to export emails' }, { status: 500 })
  }
}