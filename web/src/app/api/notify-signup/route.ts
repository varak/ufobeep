import { NextRequest, NextResponse } from 'next/server'

// Email signup utilities (simplified for App Router)
interface EmailSignup {
  email: string
  timestamp: string
  source: 'app-page' | 'homepage' | 'other'
  userAgent?: string
  referrer?: string
}

function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

async function saveSignup(signup: EmailSignup): Promise<void> {
  try {
    const fs = require('fs').promises
    const path = require('path')
    
    const dataDir = path.join(process.cwd(), 'data')
    await fs.mkdir(dataDir, { recursive: true })
    
    const signupsFile = path.join(dataDir, 'email-signups.jsonl')
    const entry = JSON.stringify(signup) + '\n'
    
    await fs.appendFile(signupsFile, entry)
    console.log(`Email signup saved: ${signup.email}`)
  } catch (error) {
    console.error('Error saving email signup:', error)
  }
}

export async function POST(request: NextRequest) {
  try {
    const { email } = await request.json()

    if (!email || !isValidEmail(email)) {
      return NextResponse.json(
        { error: 'Valid email address required' },
        { status: 400 }
      )
    }

    // Create signup record
    const signup: EmailSignup = {
      email: email.toLowerCase().trim(),
      timestamp: new Date().toISOString(),
      source: 'app-page',
      userAgent: request.headers.get('user-agent') || undefined,
      referrer: request.headers.get('referer') || undefined
    }

    // Save the signup
    await saveSignup(signup)

    console.log(`New email signup processed: ${email}`)

    return NextResponse.json({ 
      success: true, 
      message: "Thanks! We'll notify you when the UFOBeep app is ready for download." 
    })
    
  } catch (error) {
    console.error('Email signup error:', error)
    return NextResponse.json(
      { error: 'Something went wrong. Please try again later.' },
      { status: 500 }
    )
  }
}

export async function GET() {
  return NextResponse.json(
    { error: 'Method not allowed' },
    { status: 405 }
  )
}