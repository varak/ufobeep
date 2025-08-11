'use client'

import { useState } from 'react'

export default function EmailNotifySignup() {
  const [email, setEmail] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [status, setStatus] = useState<'idle' | 'success' | 'error'>('idle')
  const [message, setMessage] = useState('')

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!email || !email.includes('@')) {
      setStatus('error')
      setMessage('Please enter a valid email address')
      return
    }

    setIsSubmitting(true)
    setStatus('idle')

    try {
      // POST to FastAPI endpoint
      const formData = new FormData()
      formData.append('email', email)
      formData.append('source', 'app_download_page')
      
      const response = await fetch('/api/v1/emails/interest', {
        method: 'POST',
        body: formData,
      })

      if (response.ok) {
        // Success - don't try to parse response, just show success
        setStatus('success')
        setMessage('Thanks! We\'ll notify you when the UFOBeep app is ready for download.')
        setEmail('')
      } else {
        setStatus('error')
        setMessage('Something went wrong. Please try again.')
      }
    } catch (error) {
      console.error('Submission error:', error)
      setStatus('error')
      setMessage('Unable to submit. Please try again later.')
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