'use client'

import { useEffect, useState } from 'react'
import { useAuth } from '@/contexts/AuthContext'
import { useClientTranslations } from '@/hooks/useClientTranslations'

interface Comment {
  id: number
  user_id: string
  username: string
  body: string
  media_url: string | null
  created_at: string
}

interface AlertCommentsProps {
  alertId: string
  locale?: string
}

export default function AlertComments({ alertId, locale = 'en' }: AlertCommentsProps) {
  const { user, isAuthenticated, login, getAuthToken, logout, renderGoogleButton, renderAppleButton, googleInitialized } = useAuth()
  const { t } = useClientTranslations('common', locale)
  const [comments, setComments] = useState<Comment[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  
  // Comment form states
  const [showLoginForm, setShowLoginForm] = useState(false)
  const [showCommentForm, setShowCommentForm] = useState(false)
  const [email, setEmail] = useState('')
  const [comment, setComment] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [message, setMessage] = useState('')
  const [messageType, setMessageType] = useState<'success' | 'error' | ''>('')
  const [isFollowing, setIsFollowing] = useState(false)
  const [followLoading, setFollowLoading] = useState(false)

  const fetchComments = async (silent = false) => {
    try {
      if (!silent) setLoading(true)
      const response = await fetch(`/api/beep/${alertId}/comments`)

      if (!response.ok) {
        throw new Error('Failed to fetch comments')
      }

      const data = await response.json()
      // Sort chronologically - oldest to newest for natural conversation flow
      const sortedComments = (data.items || []).sort((a: Comment, b: Comment) =>
        new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
      )
      setComments(sortedComments)
      setError(null)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    } finally {
      if (!silent) setLoading(false)
    }
  }

  useEffect(() => {
    fetchComments()
  }, [alertId])

  // Set up SSE for real-time comment updates
  useEffect(() => {
    let eventSource: EventSource | null = null

    const connectSSE = () => {
      try {
        eventSource = new EventSource(`/api/alerts/${alertId}/comments/stream`)

        eventSource.onopen = () => {
          console.log('[SSE] Connected to comment updates')
        }

        eventSource.onmessage = (event) => {
          try {
            const data = JSON.parse(event.data)

            if (data.type === 'comment_update' && data.alertId === alertId) {
              console.log('[SSE] Received comment update, refreshing comments')
              fetchComments(true) // Silent refresh
            }
          } catch (error) {
            console.error('[SSE] Error parsing message:', error)
          }
        }

        eventSource.onerror = (error) => {
          console.log('[SSE] Connection error, will retry:', error)
          eventSource?.close()
          // Reconnect after 5 seconds
          setTimeout(() => {
            if (eventSource?.readyState === EventSource.CLOSED) {
              connectSSE()
            }
          }, 5000)
        }

      } catch (error) {
        console.error('[SSE] Failed to create EventSource:', error)
      }
    }

    connectSSE()

    // Cleanup on unmount
    return () => {
      if (eventSource) {
        eventSource.close()
      }
    }
  }, [alertId])

  // Check follow status when user is authenticated
  useEffect(() => {
    if (isAuthenticated) {
      checkFollowStatus()
      // Close login form if user just authenticated
      setShowLoginForm(false)
      setMessage(t('successfullyLoggedIn', 'Successfully logged in!'))
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
        setMessage(t('failedToUpdateNotifications', 'Failed to update notification settings'))
        setMessageType('error')
      }
    } catch (error) {
      setMessage(t('networkError'))
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
        setMessage(t('commentPosted'))
        setMessageType('success')
        
        // Refresh comments
        const fetchCommentsResponse = await fetch(`/api/beep/${alertId}/comments`)
        if (fetchCommentsResponse.ok) {
          const data = await fetchCommentsResponse.json()
          const sortedComments = (data.items || []).sort((a: Comment, b: Comment) => 
            new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
          )
          setComments(sortedComments)
        }
      } else {
        const errorData = await response.json()
        setMessage(errorData.detail || 'Failed to post comment')
        setMessageType('error')
      }
    } catch (error) {
      setMessage(t('networkError'))
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

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  return (
    <div className="bg-dark-surface border border-dark-border rounded-xl p-6">
      <h3 className="text-lg font-semibold text-brand-primary mb-6 flex items-center gap-2">
        <svg className="w-5 h-5 text-brand-primary" fill="currentColor" viewBox="0 0 20 20">
          <path fillRule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clipRule="evenodd" />
        </svg>
        {t('commentsTitle')} {comments.length > 0 && `(${comments.length})`}
      </h3>

      {loading && (
        <div className="text-center py-8">
          <div className="animate-pulse text-text-secondary">{t('loadingComments')}</div>
        </div>
      )}

      {!loading && comments.length > 0 && (
        <div className="space-y-4 mb-6">
          {comments.map((comment) => (
            <div key={comment.id} className="border-l-2 border-brand-primary/30 pl-4 pb-3">
              <div className="flex items-start gap-3">
                {/* Column 1: Avatar + Username */}
                <div className="flex items-center gap-2 flex-shrink-0 min-w-0 w-32">
                  <div className="w-6 h-6 bg-brand-primary/20 rounded-full flex items-center justify-center flex-shrink-0">
                    <span className="text-brand-primary text-xs font-semibold">
                      {comment.username?.charAt(0).toUpperCase() || 'U'}
                    </span>
                  </div>
                  <div className="font-medium text-text-primary text-sm truncate">
                    {comment.username || 'Anonymous'}:
                  </div>
                </div>
                
                {/* Column 2: Comment Text */}
                <div className="flex-1 min-w-0">
                  <p className="text-text-secondary text-sm leading-relaxed whitespace-pre-wrap">
                    {comment.body}
                  </p>
                  
                  {comment.media_url && (
                    <div className="mt-2">
                      <img 
                        src={comment.media_url} 
                        alt={t('commentAttachment')} 
                        className="max-w-xs rounded-lg border border-dark-border"
                      />
                    </div>
                  )}
                </div>
                
                {/* Column 3: Timestamp */}
                <div className="text-text-tertiary text-xs flex-shrink-0 text-right min-w-0 w-20">
                  {formatDate(comment.created_at)}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {!loading && comments.length === 0 && (
        <div className="text-center py-6 mb-6 text-text-tertiary text-sm">
          {t('noCommentsYet')}
        </div>
      )}

      {/* Add Comment Section */}
      {!loading && (
        <div className="border-t border-dark-border pt-6">
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
              {t('loginToComment')}
            </button>
          )}

          {!showLoginForm && !showCommentForm && isAuthenticated && (
            <form onSubmit={handleCommentSubmit} className="space-y-4">
              <div>
                <textarea
                  id="comment"
                  value={comment}
                  onChange={(e) => setComment(e.target.value)}
                  placeholder={t('shareYourThoughts')}
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
                  {isSubmitting ? t('posting') : t('postComment')}
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
                  <span className="px-2 bg-dark-surface text-text-tertiary">{t('or')}</span>
                </div>
              </div>
              
              {/* Email Magic Link Form */}
              <form onSubmit={handleLogin} className="space-y-4">
                <div>
                  <label htmlFor="email" className="block text-sm font-medium text-text-primary mb-2">
                    {t('enterEmailForMagicLink')}
                  </label>
                  <input
                    type="email"
                    id="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder={t('emailPlaceholder')}
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
                    {isSubmitting ? t('sendingEllipsis') : t('sendMagicLink')}
                  </button>
                  <button
                    type="button"
                    onClick={handleCancel}
                    className="px-4 py-3 text-text-secondary hover:text-text-primary transition-colors"
                  >
                    {t('cancel')}
                  </button>
                </div>
              </form>
            </div>
          )}

          {isAuthenticated && !showCommentForm && (
            <div className="mt-4 pt-4 border-t border-dark-border space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-text-secondary text-sm">
                  {t('loggedInAs')} <span className="text-brand-primary">{user?.username}</span>
                </span>
                <button
                  onClick={() => {
                    logout()
                    setMessage('')
                  }}
                  className="text-text-tertiary hover:text-text-secondary text-sm"
                >
                  {t('logout')}
                </button>
              </div>
              
              <div className="flex items-center justify-between">
                <span className="text-text-tertiary text-sm">
                  {isFollowing ? '🔔 ' + t('followingForNotifications') : '🔕 ' + t('notFollowing')}
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
                  {followLoading ? '...' : (isFollowing ? t('unfollow') : t('follow'))}
                </button>
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  )
}