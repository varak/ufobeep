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
    // Simple mock export data for now - this needs to be replaced with actual database queries
    const exportData = {
      export_metadata: {
        generated_at: new Date().toISOString(),
        user_id: params.id,
        username: `user_${params.id.substring(0, 8)}`,
        export_version: '1.0',
        total_beeps: 0,
        total_comments: 0,
        total_follows: 0,
        total_devices: 0
      },
      user_profile: {
        id: params.id,
        username: `user_${params.id.substring(0, 8)}`,
        email: 'user@example.com',
        created_at: new Date().toISOString()
      },
      beeps: [],
      comments: [],
      devices: [],
      follows: []
    }

    if (format === 'csv') {
      let csvContent = `=== EXPORT METADATA ===\n`
      for (const [key, value] of Object.entries(exportData.export_metadata)) {
        csvContent += `${key},${value}\n`
      }

      csvContent += `\n=== USER PROFILE ===\n`
      for (const [key, value] of Object.entries(exportData.user_profile)) {
        csvContent += `${key},${value || ''}\n`
      }

      return new NextResponse(csvContent, {
        headers: {
          'Content-Type': 'text/csv',
          'Content-Disposition': `attachment; filename=user_data_${exportData.user_profile.username}_${new Date().toISOString().split('T')[0]}.csv`
        }
      })
    }

    return NextResponse.json(exportData)

  } catch (error) {
    console.error('Admin export error:', error)
    return NextResponse.json({
      error: 'Failed to export user data',
      details: error instanceof Error ? error.message : String(error)
    }, { status: 500 })
  }
}