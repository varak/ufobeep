import { NextRequest, NextResponse } from 'next/server'
import { Pool } from 'pg'

const API_BASE = 'http://127.0.0.1:8000'

// Force dynamic rendering - no caching
export const dynamic = 'force-dynamic'
export const revalidate = 0

// Database connection
const pool = new Pool({
  host: 'localhost',
  port: 5432,
  user: 'ufobeep_user',
  password: 'ufopostpass',
  database: 'ufobeep_db',
})

interface RouteContext {
  params: Promise<{
    id: string
  }>
}

export async function GET(
  request: NextRequest,
  context: RouteContext
) {
  try {
    const adminKey = request.headers.get('X-Admin-Key')
    if (!adminKey) {
      return NextResponse.json({ error: 'Admin key required' }, { status: 401 })
    }

    const { id: beepId } = await context.params

    const client = await pool.connect()

    try {
      // Get recipients from user_engagement table
      const result = await client.query(`
        SELECT
          ue.device_id,
          ue.timestamp as received_at,
          d.device_name,
          d.platform,
          d.lat as device_lat,
          d.lon as device_lon,
          u.username,
          u.email,
          s.public_latitude as beep_lat,
          s.public_longitude as beep_lon
        FROM user_engagement ue
        LEFT JOIN devices d ON ue.device_id = d.device_id
        LEFT JOIN users u ON d.user_id = u.id
        LEFT JOIN sightings s ON ue.sighting_id = s.id
        WHERE ue.sighting_id = $1
          AND ue.event_type = 'alert_sent'
        ORDER BY ue.timestamp DESC
      `, [beepId])

      // Calculate distances
      const recipients = result.rows.map(row => {
        let distance_km = null

        if (row.device_lat && row.device_lon && row.beep_lat && row.beep_lon) {
          // Haversine formula
          const lat1 = row.beep_lat * Math.PI / 180
          const lon1 = row.beep_lon * Math.PI / 180
          const lat2 = row.device_lat * Math.PI / 180
          const lon2 = row.device_lon * Math.PI / 180

          const dlat = lat2 - lat1
          const dlon = lon2 - lon1

          const a = Math.sin(dlat/2)**2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dlon/2)**2
          const c = 2 * Math.asin(Math.sqrt(a))
          distance_km = 6371 * c
        }

        return {
          device_id: row.device_id,
          received_at: row.received_at,
          device_name: row.device_name,
          platform: row.platform,
          device_lat: row.device_lat,
          device_lon: row.device_lon,
          username: row.username,
          email: row.email,
          distance_km
        }
      })

      return NextResponse.json({
        success: true,
        recipients
      })

    } finally {
      client.release()
    }

  } catch (error) {
    console.error('Beep distribution API error:', error)
    return NextResponse.json({
      error: 'Failed to fetch beep distribution',
      recipients: []
    }, { status: 500 })
  }
}
