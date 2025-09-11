import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { code } = body

    if (!code) {
      return NextResponse.json(
        { detail: 'Missing authentication code' }, 
        { status: 400 }
      )
    }

    // In a real implementation, you would:
    // 1. Verify the code with your backend
    // 2. Exchange it for user data and tokens
    // 3. Return the user data and access_token
    
    // For now, return a mock response to prevent crashes
    return NextResponse.json({
      access_token: 'mock_token',
      user: {
        id: 'mock_user_id',
        username: 'mock_user',
        email: 'mock@example.com'
      }
    })

  } catch (error) {
    console.error('Auth exchange error:', error)
    return NextResponse.json(
      { detail: 'Internal server error' }, 
      { status: 500 }
    )
  }
}