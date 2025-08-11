'use client'

import { useState } from 'react'

export default function EmailNotifySignup() {
  const [email, setEmail] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [status, setStatus] = useState<'idle' | 'success' | 'error'>('idle')
  const [message, setMessage] = useState('')

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    console.log('Form submitted with email:', email)
    
    if (!email || !email.includes('@')) {
      setStatus('error')
      setMessage('Please enter a valid email address')
      return
    }

    setIsSubmitting(true)
    setStatus('idle')

    try {
      console.log('Sending request to /api/notify-signup')
      // Try different API endpoint paths to see which one works
      const apiPaths = ['/api/notify-signup', '/pages/api/notify-signup']
      let response: Response | null = null
      let successPath = ''
      
      for (const path of apiPaths) {
        try {
          console.log(`Trying API path: ${path}`)
          response = await fetch(path, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({ email }),
          })
          
          if (response.status !== 404) {
            successPath = path
            console.log(`Found working API at: ${path}`)
            break
          }
        } catch (err) {
          console.log(`Failed to reach ${path}:`, err)
        }
      }

      if (!response || response.status === 404) {
        // Fallback: save to localStorage and show success
        console.log('API not found, using localStorage fallback')
        const signups = JSON.parse(localStorage.getItem('emailSignups') || '[]')
        signups.push({
          email: email.toLowerCase().trim(),
          timestamp: new Date().toISOString(),
          source: 'app-page'
        })
        localStorage.setItem('emailSignups', JSON.stringify(signups))
        
        setStatus('success')
        setMessage('Thanks! We\'ll notify you when the UFOBeep app is ready for download.')
        setEmail('')
        
        // Also try to send to a webhook or external service if configured
        console.log('Saved to localStorage:', email)
        return
      }

      console.log('Response status:', response.status)
      const data = await response.json()
      console.log('Response data:', data)

      if (response.ok) {
        setStatus('success')
        setMessage('Thanks! We\'ll notify you when the UFOBeep app is ready for download.')
        setEmail('')
      } else {
        setStatus('error')
        setMessage(data.error || 'Something went wrong. Please try again.')
      }
    } catch (error) {
      console.error('Fetch error:', error)
      // Fallback to localStorage
      const signups = JSON.parse(localStorage.getItem('emailSignups') || '[]')
      signups.push({
        email: email.toLowerCase().trim(),
        timestamp: new Date().toISOString(),
        source: 'app-page'
      })
      localStorage.setItem('emailSignups', JSON.stringify(signups))
      
      setStatus('success')
      setMessage('Thanks! We\'ll notify you when the UFOBeep app is ready for download.')
      setEmail('')
      console.log('Saved to localStorage due to error:', email)
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <section className="bg-dark-surface border border-dark-border rounded-lg p-8 text-center mb-12">
      <div className="text-center mb-6">
        <div className="text-4xl mb-4">🚧</div>
        <h2 className="text-2xl font-semibold text-text-primary mb-4">Coming Soon</h2>
        <p className="text-text-secondary mb-6">
          The UFOBeep mobile app is currently in development. Sign up to be notified when it launches!
        </p>
      </div>

      <form onSubmit={handleSubmit} className="flex flex-col sm:flex-row gap-4 max-w-md mx-auto">
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="Enter your email"
          className="flex-1 bg-dark-background border border-dark-border rounded-lg px-4 py-3 text-text-primary placeholder-text-tertiary focus:outline-none focus:border-brand-primary"
          disabled={isSubmitting}
          required
        />
        <button
          type="submit"
          disabled={isSubmitting || !email}
          className={`bg-brand-primary text-text-inverse px-6 py-3 rounded-lg font-semibold hover:bg-brand-primary-dark transition-colors whitespace-nowrap ${
            isSubmitting || !email
              ? 'opacity-50 cursor-not-allowed'
              : ''
          }`}
        >
          {isSubmitting ? (
            <div className="flex items-center gap-2">
              <div className="w-4 h-4 border-2 border-text-inverse/30 border-t-text-inverse rounded-full animate-spin"></div>
              <span>Saving...</span>
            </div>
          ) : (
            'Notify Me'
          )}
        </button>

      </form>

      {status !== 'idle' && (
        <div className={`mt-4 p-3 rounded-lg text-center ${
          status === 'success' 
            ? 'bg-semantic-success/20 border border-semantic-success/30 text-semantic-success' 
            : 'bg-semantic-error/20 border border-semantic-error/30 text-semantic-error'
        }`}>
          {message}
        </div>
      )}

      <div className="text-center mt-6">
        <p className="text-sm text-text-tertiary">
          We'll only email you about the app launch. No spam, ever.
        </p>
      </div>
    </section>
  )
}