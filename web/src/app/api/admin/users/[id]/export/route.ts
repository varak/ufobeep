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
    const { Pool } = require('pg')

    const pool = new Pool({
      host: 'localhost',
      port: 5432,
      database: 'ufobeep_db',
      user: 'ufobeep_user',
      password: 'ufopostpass',
    })

    const client = await pool.connect()

    try {
      // Get user data
      const userResult = await client.query(`
        SELECT id, username, email, display_name, bio, location,
               created_at, last_login, is_verified, email_verified,
               preferred_language, alert_range_km, min_alert_level,
               push_notifications, email_notifications, share_location,
               public_profile, units_metric, is_active
        FROM users WHERE id = $1
      `, [params.id])

      if (userResult.rows.length === 0) {
        return NextResponse.json({ error: 'User not found' }, { status: 404 })
      }

      const user = userResult.rows[0]

      // Get user's sightings
      const sightingsResult = await client.query(`
        SELECT id, title, description, category, witness_count, is_public,
               tags, media_info, sensor_data, alert_level, status,
               created_at, updated_at, enrichment_data, reporter_id,
               firebase_uid, source
        FROM sightings WHERE reporter_id = $1
      `, [params.id])

      // Get user's comments
      const commentsResult = await client.query(`
        SELECT c.id, c.body, c.created_at, c.sighting_id, c.media_url,
               s.title as sighting_title
        FROM comments c
        LEFT JOIN sightings s ON c.sighting_id = s.id
        WHERE c.user_id = $1
      `, [params.id])

      // Get user's devices
      const devicesResult = await client.query(`
        SELECT device_id, platform, push_token, app_version, os_version,
               device_model, manufacturer, push_enabled, is_active,
               last_seen, timezone, locale, created_at, updated_at,
               lat, lon, alert_range_km
        FROM devices WHERE user_id = $1
      `, [params.id])

      // Get user's follows
      const followsResult = await client.query(`
        SELECT f.sighting_id, f.created_at, s.title as sighting_title
        FROM follows f
        LEFT JOIN sightings s ON f.sighting_id = s.id
        WHERE f.user_id = $1
      `, [params.id])

      const exportData = {
        export_metadata: {
          generated_at: new Date().toISOString(),
          user_id: user.id,
          username: user.username,
          export_version: '1.0',
          total_beeps: sightingsResult.rows.length,
          total_comments: commentsResult.rows.length,
          total_follows: followsResult.rows.length,
          total_devices: devicesResult.rows.length
        },
        user_profile: user,
        beeps: sightingsResult.rows,
        comments: commentsResult.rows,
        devices: devicesResult.rows,
        follows: followsResult.rows
      }

      if (format === 'csv') {
        let csvContent = `=== EXPORT METADATA ===\n`
        for (const [key, value] of Object.entries(exportData.export_metadata)) {
          csvContent += `${key},${value}\n`
        }

        csvContent += `\n=== USER PROFILE ===\n`
        for (const [key, value] of Object.entries(user)) {
          csvContent += `${key},${value || ''}\n`
        }

        csvContent += `\n=== BEEPS ===\n`
        if (sightingsResult.rows.length > 0) {
          const headers = Object.keys(sightingsResult.rows[0])
          csvContent += headers.join(',') + '\n'
          for (const row of sightingsResult.rows) {
            csvContent += headers.map(h => row[h] || '').join(',') + '\n'
          }
        }

        csvContent += `\n=== COMMENTS ===\n`
        if (commentsResult.rows.length > 0) {
          const headers = Object.keys(commentsResult.rows[0])
          csvContent += headers.join(',') + '\n'
          for (const row of commentsResult.rows) {
            csvContent += headers.map(h => row[h] || '').join(',') + '\n'
          }
        }

        return new NextResponse(csvContent, {
          headers: {
            'Content-Type': 'text/csv',
            'Content-Disposition': `attachment; filename=user_data_${user.username}_${new Date().toISOString().split('T')[0]}.csv`
          }
        })
      }

      return NextResponse.json(exportData)

    } finally {
      client.release()
      await pool.end()
    }

  } catch (error) {
    console.error('Admin export error:', error)
    return NextResponse.json({
      error: 'Failed to export user data',
      details: error instanceof Error ? error.message : String(error)
    }, { status: 500 })
  }
}