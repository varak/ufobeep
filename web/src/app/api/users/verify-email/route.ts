import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { token } = body

    if (!token) {
      return NextResponse.json(
        { success: false, detail: 'Missing verification token' }, 
        { status: 400 }
      )
    }

    // In a real implementation, you would:
    // 1. Verify the token with your backend
    // 2. Mark the email as verified in the database
    // 3. Return success with user info
    
    // For now, return a mock response to prevent crashes
    return NextResponse.json({
      success: true,
      message: 'Email verified successfully!',
      username: 'mock_user'
    })

  } catch (error) {
    console.error('Email verification error:', error)
    return NextResponse.json(
      { success: false, detail: 'Internal server error' }, 
      { status: 500 }
    )
  }
}