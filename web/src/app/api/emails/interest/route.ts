import { NextRequest, NextResponse } from 'next/server'
import { Pool } from 'pg'

const pool = new Pool({
  host: 'localhost',
  database: 'ufobeep_db',
  user: 'ufobeep_user',
  password: 'ufopostpass',
  port: 5432,
})

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData()
    const email = formData.get('email') as string
    const source = formData.get('source') as string || 'app_download_page'

    if (!email) {
      return NextResponse.json({ error: 'Email is required' }, { status: 400 })
    }

    const client = await pool.connect()
    
    try {
      await client.query(
        'INSERT INTO email_interests (email, source) VALUES ($1, $2)',
        [email, source]
      )
      
      return NextResponse.json({
        success: true,
        message: "Thanks! We'll notify you when the app launches."
      })
    } catch (error: any) {
      if (error.code === '23505') { // Unique violation
        return NextResponse.json({
          success: true,
          message: "You're already on our list! We'll notify you when the app launches."
        })
      }
      throw error
    } finally {
      client.release()
    }
  } catch (error) {
    console.error('Email signup error:', error)
    return NextResponse.json(
      { error: 'Failed to save email' },
      { status: 500 }
    )
  }
}