'use client'

import { useEffect, useState, Suspense } from 'react'
import Link from 'next/link'
import { useAuth } from '@/contexts/AuthContext'

function SignInContent() {
  const { isAuthenticated, user, login, renderGoogleButton, renderAppleButton, googleInitialized } = useAuth()
  const [email, setEmail] = useState('')
  const [message, setMessage] = useState('')
  const [messageType, setMessageType] = useState<'success' | 'error' | ''>('')
  const [isSubmitting, setIsSubmitting] = useState(false)

  useEffect(() => {
    // Store return URL so we can send users back after login
    if (typeof window !== 'undefined' && !localStorage.getItem('auth_return_url')) {
      localStorage.setItem('auth_return_url', window.location.href)
    }
  }, [])

  useEffect(() => {
    // Render OAuth buttons once Google SDK is ready
    if (googleInitialized) {
      setTimeout(() => {
        renderGoogleButton('google-signin-button')
        renderAppleButton('apple-signin-button')
      }, 50)
    }
  }, [googleInitialized, renderGoogleButton, renderAppleButton])

  const handleEmailLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsSubmitting(true)
    setMessage('')
    setMessageType('')
    const res = await login(email)
    setMessage(res.message)
    setMessageType(res.success ? 'success' : 'error')
    setIsSubmitting(false)
    if (res.success) setEmail('')
  }

  return (
    <main className="min-h-screen py-8 px-4 md:px-8">
      <div className="max-w-md mx-auto">
        <div className="text-center mb-8">
          <Link href="/" className="inline-block text-brand-primary">← Back to Home</Link>
          <div className="text-5xl mt-4 mb-3">🛸</div>
          <h1 className="text-2xl font-bold">Sign in to UFOBeep</h1>
          <p className="text-text-secondary text-sm">Choose a sign-in method below</p>
        </div>

        {isAuthenticated ? (
          <div className="bg-dark-surface border border-dark-border rounded-xl p-6 text-center">
            <p className="text-text-primary mb-2">You are signed in as</p>
            <p className="text-brand-primary font-semibold">{user?.username}</p>
            <p className="text-text-tertiary text-sm mt-2">You can close this page.</p>
          </div>
        ) : (
          <div className="space-y-6">
            {/* Social login */}
            <div className="space-y-3">
              <div id="google-signin-button" className="w-full" />
              <div id="apple-signin-button" className="w-full" />
            </div>

            {/* Divider */}
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-dark-border"></div>
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-2 bg-dark-background text-text-tertiary">or</span>
              </div>
            </div>

            {/* Magic link email */}
            <form onSubmit={handleEmailLogin} className="space-y-3">
              <div>
                <label htmlFor="email" className="block text-sm font-medium text-text-primary mb-2">
                  Email for magic link
                </label>
                <input
                  id="email"
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="your@email.com"
                  className="w-full bg-dark-surface border border-dark-border rounded-lg px-4 py-3 text-text-primary placeholder-text-tertiary focus:outline-none focus:border-brand-primary"
                />
              </div>
              <button
                type="submit"
                disabled={isSubmitting}
                className="w-full bg-brand-primary hover:bg-brand-primary/90 disabled:bg-brand-primary/50 text-white py-3 px-4 rounded-lg font-medium transition-colors"
              >
                {isSubmitting ? 'Sending…' : 'Send Magic Link'}
              </button>
            </form>

            {message && (
              <div className={`p-3 rounded-lg text-sm ${messageType === 'success' ? 'bg-green-900/30 border border-green-700 text-green-300' : 'bg-red-900/30 border border-red-700 text-red-300'}`}>
                {message}
              </div>
            )}
          </div>
        )}
      </div>
    </main>
  )
}

export default function SignInPage() {
  return (
    <Suspense fallback={<main className="min-h-screen flex items-center justify-center"><div className="animate-spin rounded-full h-10 w-10 border-b-2 border-brand-primary" /></main>}>
      <SignInContent />
    </Suspense>
  )
}

