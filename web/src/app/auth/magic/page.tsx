'use client'

import { useEffect, useState } from 'react'
import { useSearchParams } from 'next/navigation'

export default function MagicLinkHandler() {
  const searchParams = useSearchParams()
  const [status, setStatus] = useState<'processing' | 'success' | 'error'>('processing')
  const [message, setMessage] = useState('Verifying your magic link...')

  useEffect(() => {
    const token = searchParams.get('token')
    
    if (!token) {
      setStatus('error')
      setMessage('Invalid magic link. Please request a new one.')
      return
    }

    // Verify the token with the API
    verifyMagicLink(token)
  }, [searchParams])

  const verifyMagicLink = async (token: string) => {
    try {
      const response = await fetch('https://api.ufobeep.com/users/verify-magic-link', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ token }),
      })

      const data = await response.json()

      if (response.ok && data.success) {
        setStatus('success')
        setMessage('Successfully signed in! You can now open the UFOBeep app.')
        
        // Try to open the app with deep link
        setTimeout(() => {
          window.location.href = `ufobeep://auth/success?token=${token}`
        }, 2000)
      } else {
        setStatus('error')
        setMessage(data.message || 'Invalid or expired magic link. Please request a new one.')
      }
    } catch (error) {
      setStatus('error')
      setMessage('Something went wrong. Please try again.')
    }
  }

  return (
    <div className="min-h-screen bg-gray-900 flex items-center justify-center px-4">
      <div className="max-w-md w-full">
        <div className="bg-gray-800 rounded-lg shadow-xl p-8">
          <div className="text-center">
            {/* UFOBeep Logo */}
            <div className="mb-6">
              <span className="text-4xl">🛸</span>
            </div>
            
            <h1 className="text-2xl font-bold text-white mb-2">UFOBeep</h1>
            
            {status === 'processing' && (
              <>
                <div className="mt-6 mb-4">
                  <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-500 mx-auto"></div>
                </div>
                <p className="text-gray-300">{message}</p>
              </>
            )}
            
            {status === 'success' && (
              <>
                <div className="mt-6 mb-4">
                  <div className="rounded-full h-12 w-12 bg-green-500 mx-auto flex items-center justify-center">
                    <svg className="h-6 w-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                  </div>
                </div>
                <p className="text-green-400 font-semibold mb-2">Success!</p>
                <p className="text-gray-300">{message}</p>
                <p className="text-gray-400 text-sm mt-4">Redirecting to app...</p>
              </>
            )}
            
            {status === 'error' && (
              <>
                <div className="mt-6 mb-4">
                  <div className="rounded-full h-12 w-12 bg-red-500 mx-auto flex items-center justify-center">
                    <svg className="h-6 w-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </div>
                </div>
                <p className="text-red-400 font-semibold mb-2">Error</p>
                <p className="text-gray-300">{message}</p>
                <div className="mt-6">
                  <a 
                    href="ufobeep://auth/login"
                    className="inline-block bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700 transition"
                  >
                    Open UFOBeep App
                  </a>
                </div>
              </>
            )}
          </div>
        </div>
        
        <p className="text-center text-gray-500 text-sm mt-6">
          Real-time UFO sighting alerts
        </p>
      </div>
    </div>
  )
}