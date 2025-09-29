import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();

    // Forward to LibreTranslate Docker container
    const response = await fetch('http://localhost:5000/translate', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      throw new Error(`LibreTranslate returned ${response.status}`);
    }

    const result = await response.json();
    return NextResponse.json(result);

  } catch (error) {
    console.error('Translation proxy error:', error);
    return NextResponse.json(
      { error: 'Translation failed' },
      { status: 500 }
    );
  }
}

export async function GET() {
  return NextResponse.json({
    service: 'LibreTranslate Proxy',
    status: 'available'
  });
}