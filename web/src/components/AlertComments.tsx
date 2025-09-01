'use client'

import { useEffect, useState } from 'react'

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
}

export default function AlertComments({ alertId }: AlertCommentsProps) {
  const [comments, setComments] = useState<Comment[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchComments = async () => {
      try {
        const response = await fetch(`https://api.ufobeep.com/alerts/${alertId}/comments`)
        
        if (!response.ok) {
          throw new Error('Failed to fetch comments')
        }
        
        const data = await response.json()
        setComments(data.items || [])
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error')
      } finally {
        setLoading(false)
      }
    }

    fetchComments()
  }, [alertId])

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

  if (loading) {
    return (
      <div className="bg-dark-surface border border-dark-border rounded-xl p-6">
        <h3 className="text-lg font-semibold text-text-primary mb-4 flex items-center gap-2">
          <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
            <path fillRule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clipRule="evenodd" />
          </svg>
          Comments
        </h3>
        <div className="text-center py-8">
          <div className="animate-pulse text-text-secondary">Loading comments...</div>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="bg-dark-surface border border-dark-border rounded-xl p-6">
        <h3 className="text-lg font-semibold text-text-primary mb-4 flex items-center gap-2">
          <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
            <path fillRule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clipRule="evenodd" />
          </svg>
          Comments
        </h3>
        <div className="text-center py-8 text-text-secondary">
          Failed to load comments: {error}
        </div>
      </div>
    )
  }

  return (
    <div className="bg-dark-surface border border-dark-border rounded-xl p-6">
      <h3 className="text-lg font-semibold text-text-primary mb-6 flex items-center gap-2">
        <svg className="w-5 h-5 text-brand-primary" fill="currentColor" viewBox="0 0 20 20">
          <path fillRule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clipRule="evenodd" />
        </svg>
        Comments ({comments.length})
      </h3>

      {comments.length === 0 ? (
        <div className="text-center py-8">
          <div className="text-4xl mb-4">💬</div>
          <p className="text-text-secondary">No comments yet</p>
          <p className="text-text-tertiary text-sm mt-2">Be the first to comment on this sighting</p>
        </div>
      ) : (
        <div className="space-y-4">
          {comments.map((comment) => (
            <div key={comment.id} className="border-l-2 border-brand-primary/30 pl-4 pb-4">
              <div className="flex items-start justify-between mb-2">
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 bg-brand-primary/20 rounded-full flex items-center justify-center">
                    <span className="text-brand-primary text-sm font-semibold">
                      {comment.username?.charAt(0).toUpperCase() || 'U'}
                    </span>
                  </div>
                  <div>
                    <div className="font-medium text-text-primary text-sm">
                      {comment.username || 'Anonymous'}
                    </div>
                    <div className="text-text-tertiary text-xs">
                      {formatDate(comment.created_at)}
                    </div>
                  </div>
                </div>
              </div>
              
              <div className="ml-11">
                <p className="text-text-secondary text-sm leading-relaxed whitespace-pre-wrap">
                  {comment.body}
                </p>
                
                {comment.media_url && (
                  <div className="mt-3">
                    <img 
                      src={comment.media_url} 
                      alt="Comment attachment" 
                      className="max-w-xs rounded-lg border border-dark-border"
                    />
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Call to action */}
      <div className="mt-8 pt-6 border-t border-dark-border">
        <div className="text-center">
          <div className="text-text-secondary text-sm mb-3">
            Want to add your comment or witness account?
          </div>
          <a 
            href="/app" 
            className="inline-flex items-center gap-2 bg-brand-primary text-text-inverse px-4 py-2 rounded-lg text-sm font-medium hover:bg-brand-primary-dark transition-colors"
          >
            <span>📱</span>
            Download UFOBeep App
          </a>
          <div className="text-text-tertiary text-xs mt-2">
            Join the conversation and share your sighting
          </div>
        </div>
      </div>
    </div>
  )
}