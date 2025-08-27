'use client'

import { useEffect, useState, Suspense } from 'react'
import { useSearchParams } from 'next/navigation'

function MagicLinkContent() {
  const searchParams = useSearchParams()
  const [status, setStatus] = useState<'processing' | 'success' | 'error'>('processing')
  const [message, setMessage] = useState('Verifying your magic link...')

  useEffect(() => {
    const token = searchParams.get('token')
    const userId = searchParams.get('user_id')
    const username = searchParams.get('username')
    const email = searchParams.get('email')
    const isNewUser = searchParams.get('is_new_user')
    
    if (!token || !userId || !username) {
      setStatus('error')
      setMessage('Invalid magic link. Please request a new one.')
      return
    }

    // Magic link has been verified by the backend, now try to open the app
    handleAppLaunch(token, userId, username, email, isNewUser)
  }, [searchParams])

  const handleAppLaunch = (token: string, userId: string, username: string, email?: string | null, isNewUser?: string | null) => {
    setStatus('success')
    setMessage('Successfully signed in! Opening UFOBeep app...')
    
    // Create the deep link URL with all auth data
    const deepLinkUrl = new URL('ufobeep://auth/complete')
    deepLinkUrl.searchParams.set('token', token)
    deepLinkUrl.searchParams.set('user_id', userId)
    deepLinkUrl.searchParams.set('username', username)
    if (email) deepLinkUrl.searchParams.set('email', email)
    if (isNewUser) deepLinkUrl.searchParams.set('is_new_user', isNewUser)
    
    // Try to open app immediately
    window.location.href = deepLinkUrl.toString()
    
    // Fallback: show manual open button after delay
    setTimeout(() => {
      setMessage('Having trouble? Tap the button below to open UFOBeep.')
    }, 3000)
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
                <p className="text-gray-300 mb-4">{message}</p>
                {message.includes('Having trouble') && (
                  <div className="mt-4">
                    <button 
                      onClick={() => {
                        const token = searchParams.get('token')
                        const userId = searchParams.get('user_id')
                        const username = searchParams.get('username')
                        const email = searchParams.get('email')
                        const isNewUser = searchParams.get('is_new_user')
                        
                        const deepLinkUrl = new URL('ufobeep://auth/complete')
                        if (token) deepLinkUrl.searchParams.set('token', token)
                        if (userId) deepLinkUrl.searchParams.set('user_id', userId)
                        if (username) deepLinkUrl.searchParams.set('username', username)
                        if (email) deepLinkUrl.searchParams.set('email', email)
                        if (isNewUser) deepLinkUrl.searchParams.set('is_new_user', isNewUser)
                        
                        window.location.href = deepLinkUrl.toString()
                      }}
                      className="bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700 transition"
                    >
                      Open UFOBeep App
                    </button>
                  </div>
                )}
                {!message.includes('Having trouble') && (
                  <p className="text-gray-400 text-sm mt-4">Redirecting to app...</p>
                )}
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
                  <button 
                    onClick={() => window.location.href = "ufobeep://"}
                    className="inline-block bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700 transition"
                  >
                    Open UFOBeep App
                  </button>
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

export default function MagicLinkHandler() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-500"></div>
      </div>
    }>
      <MagicLinkContent />
    </Suspense>
  )
}