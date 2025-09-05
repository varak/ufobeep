'use client'

import { useEffect, useState } from 'react'
import { useSearchParams, useRouter } from 'next/navigation'
import Link from 'next/link'

export default function AuthCompletePage() {
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading')
  const [message, setMessage] = useState('')
  const [user, setUser] = useState<{ username: string } | null>(null)
  const searchParams = useSearchParams()
  const router = useRouter()
  
  useEffect(() => {
    const completeAuth = async () => {
      const code = searchParams.get('code')
      
      if (!code) {
        setStatus('error')
        setMessage('Invalid or missing authentication code.')
        return
      }

      try {
        const response = await fetch('https://api.ufobeep.com/auth/magic/exchange', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ code }),
        })

        const data = await response.json()

        if (response.ok) {
          // Store auth data
          localStorage.setItem('auth_token', data.access_token)
          localStorage.setItem('user_data', JSON.stringify(data.user))
          
          setStatus('success')
          setMessage('Successfully logged in!')
          setUser(data.user)
          
          // Redirect to home page after 3 seconds
          setTimeout(() => {
            router.push('/')
          }, 3000)
        } else {
          setStatus('error')
          setMessage(data.detail || 'Failed to complete login')
        }
      } catch (error) {
        setStatus('error')
        setMessage('Network error. Please try again.')
      }
    }

    completeAuth()
  }, [searchParams, router])

  return (
    <div className="min-h-screen bg-dark-background flex items-center justify-center p-4">
      <div className="bg-dark-surface border border-dark-border rounded-xl p-8 max-w-md w-full text-center">
        <div className="mb-6">
          <Link href="/" className="inline-block">
            <div className="text-2xl font-bold text-brand-primary">UFOBeep</div>
          </Link>
        </div>
        
        {status === 'loading' && (
          <div>
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-brand-primary mx-auto mb-4"></div>
            <h2 className="text-xl font-semibold text-text-primary mb-2">Completing Login...</h2>
            <p className="text-text-secondary">Please wait while we verify your magic link.</p>
          </div>
        )}
        
        {status === 'success' && (
          <div>
            <div className="rounded-full h-12 w-12 bg-green-500 mx-auto mb-4 flex items-center justify-center">
              <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
              </svg>
            </div>
            <h2 className="text-xl font-semibold text-text-primary mb-2">Welcome back!</h2>
            <p className="text-text-secondary mb-4">
              You're now logged in as <span className="text-brand-primary font-medium">{user?.username}</span>
            </p>
            <p className="text-text-tertiary text-sm">
              Redirecting you to the home page...
            </p>
          </div>
        )}
        
        {status === 'error' && (
          <div>
            <div className="rounded-full h-12 w-12 bg-red-500 mx-auto mb-4 flex items-center justify-center">
              <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </div>
            <h2 className="text-xl font-semibold text-text-primary mb-2">Login Failed</h2>
            <p className="text-text-secondary mb-6">{message}</p>
            <Link 
              href="/" 
              className="inline-block bg-brand-primary hover:bg-brand-primary/90 text-white py-3 px-6 rounded-lg font-medium transition-colors"
            >
              Return to Home
            </Link>
          </div>
        )}
      </div>
    </div>
  )
}