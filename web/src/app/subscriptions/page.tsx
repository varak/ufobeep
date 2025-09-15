'use client'

import { useEffect, useState, useCallback } from 'react'
import Link from 'next/link'
import { useAuth } from '@/contexts/AuthContext'

interface Subscription {
  sighting_id: string
  title: string
  location_name: string
  comment_count: number
  created_at: string
}

export default function SubscriptionsPage() {
  const [subscriptions, setSubscriptions] = useState<Subscription[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const { isAuthenticated, getAuthToken } = useAuth()

  useEffect(() => {
    fetchSubscriptions()
  }, [fetchSubscriptions])

  const fetchSubscriptions = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)

      if (!isAuthenticated) {
        setError('Please sign in to view your subscriptions')
        return
      }

      const token = getAuthToken()
      if (!token) {
        setError('Authentication token not found')
        return
      }

      const response = await fetch('/api/beep/following', {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        }
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const data = await response.json()
      setSubscriptions(data.subscriptions || [])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch subscriptions')
      console.error('Error fetching subscriptions:', err)
    } finally {
      setLoading(false)
    }
  }, [isAuthenticated, getAuthToken])

  const unfollow = async (alertId: string) => {
    try {
      const token = getAuthToken()
      if (!token) {
        alert('Authentication required to unfollow alerts')
        return
      }

      const response = await fetch(`/api/alerts/${alertId}/follow`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        }
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      // Remove from local state
      setSubscriptions(prev => prev.filter(sub => sub.sighting_id !== alertId))

      // Show success message
      const alertTitle = subscriptions.find(s => s.sighting_id === alertId)?.title || 'Alert'
      alert(`Unfollowed "${alertTitle}" - you won&apos;t receive comment notifications anymore`)
    } catch (err) {
      console.error('Error unfollowing alert:', err)
      alert('Failed to unfollow alert. Please try again.')
    }
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-900 text-white">
        <div className="container mx-auto px-4 py-8">
          <div className="max-w-4xl mx-auto">
            <h1 className="text-3xl font-bold mb-8">My Subscriptions</h1>
            <div className="flex justify-center">
              <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-500"></div>
            </div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-4xl mx-auto">
          <div className="flex items-center justify-between mb-8">
            <div>
              <h1 className="text-3xl font-bold">My Subscriptions</h1>
              <p className="text-gray-400 mt-2">
                Alerts you&apos;re following for comment notifications
              </p>
            </div>
            <Link
              href="/beep"
              className="px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded-lg transition-colors"
            >
              Browse Alerts
            </Link>
          </div>

          {error && (
            <div className="bg-red-900/50 border border-red-600 rounded-lg p-4 mb-6">
              <div className="flex items-center">
                <svg className="w-5 h-5 text-red-400 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <div>
                  <h3 className="text-red-400 font-medium">Error Loading Subscriptions</h3>
                  <p className="text-red-300 text-sm mt-1">{error}</p>
                  {error.includes('401') || error.includes('403') ? (
                    <p className="text-red-300 text-sm mt-2">
                      Please sign in to view your subscriptions.
                    </p>
                  ) : (
                    <button
                      onClick={fetchSubscriptions}
                      className="text-red-400 hover:text-red-300 text-sm underline mt-2"
                    >
                      Try again
                    </button>
                  )}
                </div>
              </div>
            </div>
          )}

          {subscriptions.length === 0 && !error ? (
            <div className="text-center py-12">
              <div className="w-24 h-24 mx-auto mb-4 opacity-50">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" className="w-full h-full">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M15 17h5l-5 5-5-5h5v-12h0z"/>
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M9 7H4l5-5 5 5H9v12H9z"/>
                </svg>
              </div>
              <h2 className="text-xl font-semibold text-gray-400 mb-2">No Subscriptions Yet</h2>
              <p className="text-gray-500 mb-6">
                You&apos;re not following any alerts for comment notifications.
              </p>
              <Link
                href="/beep"
                className="inline-flex items-center px-6 py-3 bg-blue-600 hover:bg-blue-700 rounded-lg transition-colors"
              >
                <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
                Browse Alerts to Follow
              </Link>
            </div>
          ) : (
            <div className="space-y-4">
              {subscriptions.map((subscription) => (
                <div
                  key={subscription.sighting_id}
                  className="bg-gray-800 rounded-lg p-6 border border-gray-700 hover:border-gray-600 transition-colors"
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center space-x-3 mb-3">
                        <Link
                          href={`/beep/en/${subscription.sighting_id}`}
                          className="text-xl font-semibold text-blue-400 hover:text-blue-300 transition-colors"
                        >
                          {subscription.title}
                        </Link>
                        <span className="px-2 py-1 bg-blue-900/50 text-blue-400 text-xs rounded-full">
                          Following
                        </span>
                      </div>
                      
                      <div className="flex items-center text-sm text-gray-400 space-x-4 mb-3">
                        <div className="flex items-center">
                          <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                          </svg>
                          {subscription.location_name}
                        </div>
                        
                        <div className="flex items-center">
                          <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                          </svg>
                          {subscription.comment_count} comments
                        </div>
                        
                        <div className="flex items-center">
                          <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                          </svg>
                          Alert: {formatDate(subscription.created_at)}
                        </div>
                      </div>
                    </div>
                    
                    <div className="flex items-center space-x-2 ml-4">
                      <Link
                        href={`/beep/en/${subscription.sighting_id}`}
                        className="px-3 py-1 text-sm bg-gray-700 hover:bg-gray-600 rounded transition-colors"
                      >
                        View Alert
                      </Link>
                      <button
                        onClick={() => unfollow(subscription.sighting_id)}
                        className="px-3 py-1 text-sm bg-red-900/50 hover:bg-red-900 text-red-400 rounded transition-colors"
                      >
                        Unfollow
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}

          <div className="mt-12 p-6 bg-gray-800/50 rounded-lg border border-gray-700">
            <h2 className="text-lg font-semibold mb-3">About Subscriptions</h2>
            <div className="text-gray-400 space-y-2 text-sm">
              <p>• When you comment on an alert, you automatically follow it for notifications</p>
              <p>• You&apos;ll receive push notifications when others comment on alerts you follow</p>
              <p>• You can unfollow any alert to stop receiving notifications</p>
              <p>• Manage notification settings including Do Not Disturb in the mobile app</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}