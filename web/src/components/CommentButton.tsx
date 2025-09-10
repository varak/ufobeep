'use client'

import { useState, useEffect } from 'react'
import { useAuth } from '@/contexts/AuthContext'

interface CommentButtonProps {
  alertId: string
  onCommentAdded?: () => void
}

export default function CommentButton({ alertId, onCommentAdded }: CommentButtonProps) {
  const { user, isAuthenticated, login, getAuthToken, logout, renderGoogleButton, renderAppleButton, googleInitialized } = useAuth()
  const [showLoginForm, setShowLoginForm] = useState(false)
  const [showCommentForm, setShowCommentForm] = useState(false)
  const [email, setEmail] = useState('')
  const [comment, setComment] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [message, setMessage] = useState('')
  const [messageType, setMessageType] = useState<'success' | 'error' | ''>('')
  const [isFollowing, setIsFollowing] = useState(false)
  const [followLoading, setFollowLoading] = useState(false)

  // Check follow status when user is authenticated
  useEffect(() => {
    if (isAuthenticated) {
      checkFollowStatus()
      // Close login form if user just authenticated
      setShowLoginForm(false)
      setMessage('Successfully logged in!')
      setMessageType('success')
    }
  }, [isAuthenticated, alertId])

  const checkFollowStatus = async () => {
    if (!isAuthenticated) return
    
    try {
      const token = getAuthToken()
      const response = await fetch(`/api/alerts/${alertId}/follow`, {
        headers: {
          'Authorization': `Bearer ${token}`
        },
      })
      
      if (response.ok) {
        const data = await response.json()
        setIsFollowing(data.following)
      }
    } catch (error) {
      console.error('Failed to check follow status:', error)
    }
  }

  const handleFollowToggle = async () => {
    if (!isAuthenticated) return
    
    setFollowLoading(true)
    try {
      const token = getAuthToken()
      const method = isFollowing ? 'DELETE' : 'POST'
      const response = await fetch(`/api/alerts/${alertId}/follow`, {
        method,
        headers: {
          'Authorization': `Bearer ${token}`
        },
      })

      if (response.ok) {
        const data = await response.json()
        setIsFollowing(!isFollowing)
        setMessage(data.message)
        setMessageType('success')
      } else {
        setMessage('Failed to update notification settings')
        setMessageType('error')
      }
    } catch (error) {
      setMessage('Network error. Please try again.')
      setMessageType('error')
    }
    setFollowLoading(false)
  }

  const handleCommentClick = () => {
    if (isAuthenticated) {
      setShowCommentForm(true)
    } else {
      setShowLoginForm(true)
    }
  }

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsSubmitting(true)
    
    const result = await login(email)
    setMessage(result.message)
    setMessageType(result.success ? 'success' : 'error')
    
    if (result.success) {
      setEmail('')
      setShowLoginForm(false)
    }
    
    setIsSubmitting(false)
  }
  
  // Render OAuth buttons when login form is shown
  useEffect(() => {
    if (showLoginForm && googleInitialized) {
      // Small delay to ensure DOM is ready
      setTimeout(() => {
        renderGoogleButton('google-signin-button')
        renderAppleButton('apple-signin-button')
      }, 100)
    }
  }, [showLoginForm, googleInitialized, renderGoogleButton, renderAppleButton])
  
  // Listen for storage changes (when auth happens in popup/tab)
  useEffect(() => {
    const handleStorageChange = () => {
      // Check if user data was added to localStorage
      const userData = localStorage.getItem('user_data')
      if (userData && !isAuthenticated) {
        // Force component to re-check auth state
        window.location.reload()
      }
    }
    
    window.addEventListener('storage', handleStorageChange)
    return () => window.removeEventListener('storage', handleStorageChange)
  }, [isAuthenticated])

  const handleCommentSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!comment.trim() || !isAuthenticated) return

    setIsSubmitting(true)
    
    try {
      const token = getAuthToken()
      const response = await fetch(`/api/beep/${alertId}/comments`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          body: comment.trim()
        }),
      })

      if (response.ok) {
        setComment('')
        setShowCommentForm(false)
        setMessage('Comment posted successfully!')
        setMessageType('success')
        
        // Notify parent component to refresh comments
        if (onCommentAdded) {
          onCommentAdded()
        }
      } else {
        const errorData = await response.json()
        setMessage(errorData.detail || 'Failed to post comment')
        setMessageType('error')
      }
    } catch (error) {
      setMessage('Network error. Please try again.')
      setMessageType('error')
    }
    
    setIsSubmitting(false)
  }

  const handleCancel = () => {
    setShowLoginForm(false)
    setShowCommentForm(false)
    setEmail('')
    setComment('')
    setMessage('')
    setMessageType('')
  }

  // Clear message after 5 seconds
  if (message) {
    setTimeout(() => {
      setMessage('')
      setMessageType('')
    }, 5000)
  }

  return (
    <div className="bg-dark-surface border border-dark-border rounded-xl p-6">
      <h3 className="text-lg font-semibold text-brand-primary mb-4 flex items-center gap-2">
        <svg className="w-5 h-5 text-brand-primary" fill="currentColor" viewBox="0 0 20 20">
          <path fillRule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clipRule="evenodd" />
        </svg>
        Add Comment
      </h3>

      {message && (
        <div className={`mb-4 p-3 rounded-lg text-sm ${
          messageType === 'success' 
            ? 'bg-green-900/30 border border-green-700 text-green-300'
            : 'bg-red-900/30 border border-red-700 text-red-300'
        }`}>
          {message}
        </div>
      )}

      {!showLoginForm && !showCommentForm && !isAuthenticated && (
        <button
          onClick={handleCommentClick}
          className="w-full border-2 border-brand-primary hover:border-brand-primary/90 hover:bg-brand-primary/10 text-brand-primary py-3 px-4 rounded-lg font-medium transition-colors bg-transparent"
        >
          Login to Comment
        </button>
      )}

      {!showLoginForm && !showCommentForm && isAuthenticated && (
        <form onSubmit={handleCommentSubmit} className="space-y-4">
          <div>
            <textarea
              id="comment"
              value={comment}
              onChange={(e) => setComment(e.target.value)}
              placeholder="Share your thoughts about this sighting..."
              required
              rows={4}
              className="w-full bg-dark-background border border-dark-border rounded-lg px-4 py-3 text-text-primary placeholder-text-tertiary focus:outline-none focus:border-brand-primary resize-vertical"
            />
          </div>
          <div className="flex gap-3">
            <button
              type="submit"
              disabled={isSubmitting || !comment.trim()}
              className="flex-1 bg-brand-primary hover:bg-brand-primary/90 disabled:bg-brand-primary/50 text-white py-3 px-4 rounded-lg font-medium transition-colors"
            >
              {isSubmitting ? 'Posting...' : 'Post Comment'}
            </button>
          </div>
        </form>
      )}

      {showLoginForm && (
        <div className="space-y-4">
          {/* Social Login Options */}
          <div className="space-y-3">
            {/* Google Sign-In Button */}
            <div id="google-signin-button" className="w-full"></div>
            
            {/* Apple Sign-In Button */}
            <div id="apple-signin-button" className="w-full"></div>
          </div>
          
          <div className="relative">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-dark-border"></div>
            </div>
            <div className="relative flex justify-center text-sm">
              <span className="px-2 bg-dark-surface text-text-tertiary">or</span>
            </div>
          </div>
          
          {/* Email Magic Link Form */}
          <form onSubmit={handleLogin} className="space-y-4">
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-text-primary mb-2">
                Enter your email to receive a magic link
              </label>
              <input
                type="email"
                id="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your.email@example.com"
                required
                className="w-full bg-dark-background border border-dark-border rounded-lg px-4 py-3 text-text-primary placeholder-text-tertiary focus:outline-none focus:border-brand-primary"
              />
            </div>
            <div className="flex gap-3">
              <button
                type="submit"
                disabled={isSubmitting}
                className="flex-1 bg-brand-primary hover:bg-brand-primary/90 disabled:bg-brand-primary/50 text-white py-3 px-4 rounded-lg font-medium transition-colors"
              >
                {isSubmitting ? 'Sending...' : 'Send Magic Link'}
              </button>
              <button
                type="button"
                onClick={handleCancel}
                className="px-4 py-3 text-text-secondary hover:text-text-primary transition-colors"
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
      )}

      {showCommentForm && (
        <form onSubmit={handleCommentSubmit} className="space-y-4">
          <div>
            <textarea
              id="comment"
              value={comment}
              onChange={(e) => setComment(e.target.value)}
              placeholder="Share your thoughts about this sighting..."
              required
              rows={4}
              className="w-full bg-dark-background border border-dark-border rounded-lg px-4 py-3 text-text-primary placeholder-text-tertiary focus:outline-none focus:border-brand-primary resize-vertical"
            />
          </div>
          <div className="flex gap-3">
            <button
              type="submit"
              disabled={isSubmitting || !comment.trim()}
              className="flex-1 bg-brand-primary hover:bg-brand-primary/90 disabled:bg-brand-primary/50 text-white py-3 px-4 rounded-lg font-medium transition-colors"
            >
              {isSubmitting ? 'Posting...' : 'Post Comment'}
            </button>
            <button
              type="button"
              onClick={handleCancel}
              className="px-4 py-3 text-text-secondary hover:text-text-primary transition-colors"
            >
              Cancel
            </button>
          </div>
        </form>
      )}

      {isAuthenticated && !showCommentForm && (
        <div className="mt-4 pt-4 border-t border-dark-border space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-text-secondary text-sm">
              Logged in as <span className="text-brand-primary">{user?.username}</span>
            </span>
            <button
              onClick={() => {
                logout()
                setMessage('')
              }}
              className="text-text-tertiary hover:text-text-secondary text-sm"
            >
              Logout
            </button>
          </div>
          
          <div className="flex items-center justify-between">
            <span className="text-text-tertiary text-sm">
              {isFollowing ? '🔔 Following for notifications' : '🔕 Not following'}
            </span>
            <button
              onClick={handleFollowToggle}
              disabled={followLoading}
              className={`text-sm px-3 py-1 rounded transition-colors ${
                isFollowing 
                  ? 'text-orange-400 hover:text-orange-300 bg-orange-900/20 hover:bg-orange-900/30'
                  : 'text-blue-400 hover:text-blue-300 bg-blue-900/20 hover:bg-blue-900/30'
              } disabled:opacity-50`}
            >
              {followLoading ? '...' : (isFollowing ? 'Unfollow' : 'Follow')}
            </button>
          </div>
        </div>
      )}
    </div>
  )
}