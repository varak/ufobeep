import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData()
    const email = formData.get('email') as string
    const source = formData.get('source') as string || 'app_download_page'

    if (!email) {
      return NextResponse.json({ error: 'Email is required' }, { status: 400 })
    }

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
      await client.end()
    }
  } catch (error) {
    console.error('Email signup error:', error)
    return NextResponse.json(
      { error: 'Failed to save email' },
      { status: 500 }
    )
  }
}