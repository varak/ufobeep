import { NextRequest, NextResponse } from 'next/server'

const API_BASE = 'http://127.0.0.1:8000'

// Force dynamic rendering
export const dynamic = 'force-dynamic'

export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const adminKey = request.headers.get('X-Admin-Key')
    if (!adminKey) {
      return NextResponse.json({ error: 'Admin key required' }, { status: 401 })
    }

    const backendUrl = `${API_BASE}/api/admin/users/${params.id}`

    const response = await fetch(backendUrl, {
      method: 'DELETE',
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
    console.error('Admin delete user API error:', error)
    return NextResponse.json({ error: 'Failed to delete user' }, { status: 500 })
  }
}