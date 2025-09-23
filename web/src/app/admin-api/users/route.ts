import { NextRequest, NextResponse } from 'next/server'

const API_BASE = 'http://127.0.0.1:8000'

// Force dynamic rendering
export const dynamic = 'force-dynamic'

export async function GET(request: NextRequest) {
  try {
    const adminKey = request.headers.get('X-Admin-Key')
    if (!adminKey) {
      return NextResponse.json({ error: 'Admin key required' }, { status: 401 })
    }

    const { searchParams } = new URL(request.url)
    const search = searchParams.get('search') || ''
    const limit = searchParams.get('limit') || '50'

    const backendUrl = `${API_BASE}/api/admin/users?search=${encodeURIComponent(search)}&limit=${limit}`

    const response = await fetch(backendUrl, {
      headers: {
        'X-Admin-Key': adminKey,
      },
    })

    if (!response.ok) {
      throw new Error(`Backend responded with ${response.status}`)
    }

    const data = await response.json()
    return NextResponse.json(data)

  } catch (error) {
    console.error('Admin users API error:', error)
    return NextResponse.json({ error: 'Failed to fetch users' }, { status: 500 })
  }
}