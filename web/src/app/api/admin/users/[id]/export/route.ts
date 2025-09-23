import { NextRequest, NextResponse } from 'next/server'

// Force dynamic rendering
export const dynamic = 'force-dynamic'

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const adminKey = request.headers.get('X-Admin-Key')
  if (!adminKey || adminKey !== 'ufobeep_admin_2025') {
    return NextResponse.json({ error: 'Admin key required' }, { status: 401 })
  }

  const { searchParams } = new URL(request.url)
  const format = searchParams.get('format') || 'json'

  try {
    // Test simple response first
    return NextResponse.json({
      export_metadata: {
        generated_at: new Date().toISOString(),
        user_id: params.id,
        username: `user_${params.id.substring(0, 8)}`,
        export_version: '1.0_test',
        total_beeps: 0,
        total_comments: 0,
        total_follows: 0,
        total_devices: 0
      },
      user_profile: {
        id: params.id,
        username: `user_${params.id.substring(0, 8)}`,
        email: 'test@example.com',
        note: 'This is a test export - database connection will be added back'
      },
      beeps: [],
      comments: [],
      devices: [],
      follows: []
    })

    // Database connection will be added back when test works

  } catch (error) {
    console.error('Admin export error:', error)
    return NextResponse.json({
      error: 'Failed to export user data',
      details: error instanceof Error ? error.message : String(error)
    }, { status: 500 })
  }
}