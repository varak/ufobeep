'use client'

import { useState } from 'react'

export default function EmailNotifySignup() {
  const [name, setName] = useState('')
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
      formData.append('name', name)
      formData.append('email', email)
      formData.append('source', 'beta_signup')
      
      const response = await fetch('/api/emails/interest', {
        method: 'POST',
        body: formData,
      })

      if (response.ok) {
        // Success - don't try to parse response, just show success
        setStatus('success')
        setMessage('Thanks! We\'ll add you to the beta program and send instructions to your email.')
        setName('')
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
    <form onSubmit={handleSubmit} className="flex flex-col gap-4 max-w-md mx-auto">
      <input
        type="text"
        value={name}
        onChange={(e) => setName(e.target.value)}
        placeholder="Your name"
        className="w-full bg-dark-background border border-dark-border rounded-lg px-4 py-3 text-text-primary placeholder-text-tertiary focus:outline-none focus:border-brand-primary"
        disabled={isSubmitting}
        required
      />
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Your email"
        className="w-full bg-dark-background border border-dark-border rounded-lg px-4 py-3 text-text-primary placeholder-text-tertiary focus:outline-none focus:border-brand-primary"
        disabled={isSubmitting}
        required
      />
      <button
        type="submit"
        disabled={isSubmitting || !email || !name}
        className={`bg-brand-primary text-text-inverse px-6 py-3 rounded-lg font-semibold hover:bg-brand-primary-dark transition-colors ${
          isSubmitting || !email || !name
            ? 'opacity-50 cursor-not-allowed'
            : ''
        }`}
      >
        {isSubmitting ? (
          <div className="flex items-center justify-center gap-2">
            <div className="w-4 h-4 border-2 border-text-inverse/30 border-t-text-inverse rounded-full animate-spin"></div>
            <span>Submitting...</span>
          </div>
        ) : (
          'Request Beta Access'
        )}
      </button>

      {status !== 'idle' && (
        <div className={`p-3 rounded-lg text-center ${
          status === 'success'
            ? 'bg-semantic-success/20 border border-semantic-success/30 text-semantic-success'
            : 'bg-semantic-error/20 border border-semantic-error/30 text-semantic-error'
        }`}>
          {message}
        </div>
      )}
    </form>
  )
}