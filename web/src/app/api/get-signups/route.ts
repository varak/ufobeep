import { NextRequest, NextResponse } from 'next/server'
import fs from 'fs/promises'
import path from 'path'

// Force this route to be dynamic since it uses searchParams
export const runtime = 'nodejs'
export const dynamic = 'force-dynamic'

export async function GET(request: NextRequest) {
  try {
    // Check for a simple auth token in query params (you should change this)
    const token = request.nextUrl.searchParams.get('token')
    
    // Simple token check - CHANGE THIS IN PRODUCTION
    if (token !== 'ufobeep-admin-2024') {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      )
    }

    const dataDir = path.join(process.cwd(), 'data')
    const signupsFile = path.join(dataDir, 'email-signups.jsonl')
    
    try {
      const content = await fs.readFile(signupsFile, 'utf-8')
      const lines = content.trim().split('\n').filter(line => line)
      const signups = lines.map(line => JSON.parse(line))
      
      return NextResponse.json({
        total: signups.length,
        signups: signups
      })
    } catch (error) {
      // File doesn't exist yet
      return NextResponse.json({
        total: 0,
        signups: []
      })
    }
  } catch (error) {
    console.error('Error fetching signups:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}