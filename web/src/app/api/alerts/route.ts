import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams
    const limit = parseInt(searchParams.get('limit') || '10')
    const offset = parseInt(searchParams.get('offset') || '0')
    
    // Dynamic import to avoid build-time issues
    const { Client } = await import('pg')
    
    const client = new Client({
      host: 'localhost',
      database: 'ufobeep_db',
      user: 'ufobeep_user',
      password: 'ufopostpass',
      port: 5432,
    })
    
    await client.connect()
    
    try {
      const query = `
        SELECT 
          id,
          title,
          description,
          category,
          created_at,
          latitude,
          longitude,
          location_name,
          alert_level,
          verification_score,
          media_url,
          thumbnail_url
        FROM alerts
        ORDER BY created_at DESC
        LIMIT $1 OFFSET $2
      `
      
      const result = await client.query(query, [limit, offset])
      
      // Transform data to match expected format
      const alerts = result.rows.map(row => ({
        id: row.id.toString(),
        title: row.title,
        description: row.description,
        category: row.category,
        created_at: row.created_at,
        location: {
          latitude: parseFloat(row.latitude),
          longitude: parseFloat(row.longitude),
          name: row.location_name
        },
        alert_level: row.alert_level,
        media_files: row.media_url ? [{
          id: '1',
          type: 'image',
          url: row.media_url,
          thumbnail_url: row.thumbnail_url || row.media_url
        }] : [],
        verification_score: row.verification_score
      }))
      
      return NextResponse.json({
        success: true,
        data: {
          alerts: alerts,
          total: alerts.length
        }
      })
    } finally {
      await client.end()
    }
  } catch (error) {
    console.error('Alerts API error:', error)
    return NextResponse.json(
      { 
        success: false,
        error: 'Failed to fetch alerts' 
      },
      { status: 500 }
    )
  }
}