'use client'

import { useState, useEffect } from 'react'
import { useAuth } from '@/contexts/AuthContext'

interface CommentButtonProps {
  alertId: string
  onCommentAdded?: () => void
}

export default function CommentButton({ alertId, onCommentAdded }: CommentButtonProps) {
  const { user, isAuthenticated, login, loginWithGoogle, loginWithApple, getAuthToken, logout } = useAuth()
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
    }
  }, [isAuthenticated, alertId])

  const checkFollowStatus = async () => {
    if (!isAuthenticated) return
    
    try {
      const token = getAuthToken()
      const response = await fetch(`https://api.ufobeep.com/alerts/${alertId}/follow`, {
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
      const response = await fetch(`https://api.ufobeep.com/alerts/${alertId}/follow`, {
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
  
  const handleGoogleLogin = async () => {
    setIsSubmitting(true)
    const result = await loginWithGoogle()
    setMessage(result.message)
    setMessageType(result.success ? 'success' : 'error')
    setIsSubmitting(false)
  }
  
  const handleAppleLogin = async () => {
    setIsSubmitting(true)
    const result = await loginWithApple()
    setMessage(result.message)
    setMessageType(result.success ? 'success' : 'error')
    setIsSubmitting(false)
  }

  const handleCommentSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!comment.trim() || !isAuthenticated) return

    setIsSubmitting(true)
    
    try {
      const token = getAuthToken()
      const response = await fetch(`https://api.ufobeep.com/alerts/${alertId}/comments`, {
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

      {!showLoginForm && !showCommentForm && (
        <button
          onClick={handleCommentClick}
          className="w-full bg-brand-primary hover:bg-brand-primary/90 text-white py-3 px-4 rounded-lg font-medium transition-colors"
        >
          {isAuthenticated ? `Comment as ${user?.username}` : 'Login to Comment'}
        </button>
      )}

      {showLoginForm && (
        <div className="space-y-4">
          {/* Social Login Options */}
          <div className="space-y-3">
            <button
              onClick={handleGoogleLogin}
              disabled={isSubmitting}
              className="w-full bg-white hover:bg-gray-50 disabled:bg-gray-100 text-gray-800 py-3 px-4 rounded-lg font-medium transition-colors flex items-center justify-center gap-3 border border-gray-300"
            >
              <svg className="w-5 h-5" viewBox="0 0 24 24">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
              </svg>
              {isSubmitting ? 'Connecting...' : 'Continue with Google'}
            </button>
            
            <button
              onClick={handleAppleLogin}
              disabled={isSubmitting}
              className="w-full bg-black hover:bg-gray-900 disabled:bg-gray-800 text-white py-3 px-4 rounded-lg font-medium transition-colors flex items-center justify-center gap-3"
            >
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
              </svg>
              {isSubmitting ? 'Connecting...' : 'Continue with Apple'}
            </button>
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
            <label htmlFor="comment" className="block text-sm font-medium text-text-primary mb-2">
              Your comment
            </label>
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