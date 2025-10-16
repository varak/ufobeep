'use client'

import { useState } from 'react'
import Link from 'next/link'

interface BeepInfo {
  id: string
  title: string
  description: string
  created_at: string
  source: string
  reporter_username: string | null
  reporter_email: string | null
  short_url: string
  public_latitude: number | null
  public_longitude: number | null
}

interface Recipient {
  device_id: string
  received_at: string
  device_name: string | null
  platform: string | null
  device_lat: number | null
  device_lon: number | null
  username: string | null
  email: string | null
  distance_km: number | null
}

export default function BeepDistributionPage() {
  const [beepId, setBeepId] = useState('')
  const [beepInfo, setBeepInfo] = useState<BeepInfo | null>(null)
  const [recipients, setRecipients] = useState<Recipient[]>([])
  const [recentBeeps, setRecentBeeps] = useState<any[]>([])
  const [loading, setLoading] = useState(false)
  const [adminKey, setAdminKey] = useState('')
  const [authenticated, setAuthenticated] = useState(false)

  const authenticate = () => {
    if (adminKey === 'ufobeep_admin_2025') {
      setAuthenticated(true)
      loadRecentBeeps()
    } else {
      alert('Invalid admin key')
    }
  }

  const loadRecentBeeps = async () => {
    try {
      const response = await fetch('/api/beep?limit=10')
      const data = await response.json()
      if (data.success && data.data?.alerts) {
        setRecentBeeps(data.data.alerts)
      }
    } catch (error) {
      console.error('Error loading recent beeps:', error)
    }
  }

  const searchBeep = async (id?: string) => {
    const searchId = id || beepId
    if (!searchId.trim()) {
      alert('Please enter a beep ID')
      return
    }

    setLoading(true)
    try {
      // Fetch recipients from user_engagement table via admin API
      const recipientsResponse = await fetch(`/admin-api/beep-distribution/${searchId}`, {
        headers: { 'X-Admin-Key': adminKey }
      })

      if (!recipientsResponse.ok) {
        alert('Failed to load beep distribution data')
        return
      }

      const recipientsData = await recipientsResponse.json()

      if (!recipientsData.success) {
        alert('Beep distribution data not available')
        return
      }

      // Use beep_info from the distribution API which has more complete data
      const info = recipientsData.beep_info
      setBeepInfo({
        id: info.id,
        title: info.title || 'Untitled',
        description: info.description || 'No description',
        created_at: info.created_at,
        source: info.source || 'UFOBeep',
        reporter_username: info.reporter_username,
        reporter_email: info.reporter_email,
        short_url: info.short_url || '',
        public_latitude: info.public_latitude,
        public_longitude: info.public_longitude
      })

      setRecipients(recipientsData.recipients || [])

    } catch (error) {
      console.error('Error searching beep:', error)
      alert('Error loading beep distribution')
    } finally {
      setLoading(false)
    }
  }

  if (!authenticated) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="bg-gray-800 p-8 rounded-lg border border-gray-700 max-w-md w-full">
          <h1 className="text-2xl font-bold text-white mb-6 text-center">
            🛸 Beep Distribution Admin
          </h1>
          <div className="space-y-4">
            <input
              type="password"
              placeholder="Admin Key"
              value={adminKey}
              onChange={(e) => setAdminKey(e.target.value)}
              className="w-full p-3 bg-gray-700 text-white rounded border border-gray-600 focus:border-blue-500"
              onKeyPress={(e) => e.key === 'Enter' && authenticate()}
            />
            <button
              onClick={authenticate}
              className="w-full bg-blue-600 hover:bg-blue-700 text-white p-3 rounded font-semibold"
            >
              Access Admin Panel
            </button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-900 text-white p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <Link href="/admin/users" className="text-blue-400 hover:underline mb-4 inline-block">
            ← Back to Admin
          </Link>
          <h1 className="text-3xl font-bold mb-2">🛸 Beep Distribution</h1>
          <p className="text-gray-400">View who sent a beep and who received it</p>
        </div>

        {/* Search Box */}
        <div className="bg-gray-800 rounded-lg border border-gray-700 p-6 mb-6">
          <h3 className="text-xl font-semibold mb-4">Search by Beep ID</h3>
          <div className="flex gap-3">
            <input
              type="text"
              placeholder="Enter beep ID (UUID or short URL)"
              value={beepId}
              onChange={(e) => setBeepId(e.target.value)}
              className="flex-1 p-3 bg-gray-700 border border-gray-600 rounded text-white"
              onKeyPress={(e) => e.key === 'Enter' && searchBeep()}
            />
            <button
              onClick={() => searchBeep()}
              disabled={loading}
              className="bg-green-600 hover:bg-green-700 px-6 py-3 rounded font-semibold disabled:bg-gray-600"
            >
              {loading ? '🔄 Loading...' : '🔍 Search'}
            </button>
          </div>
        </div>

        {/* Beep Info */}
        {beepInfo && (
          <>
            <div className="bg-gray-800 rounded-lg border border-gray-700 p-6 mb-6">
              <h2 className="text-2xl font-bold mb-4 text-green-400">📡 Beep Information</h2>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <span className="text-gray-400">Beep ID:</span>
                  <div className="font-mono text-sm">{beepInfo.id}</div>
                </div>
                <div>
                  <span className="text-gray-400">Title:</span>
                  <div>{beepInfo.title}</div>
                </div>
                <div>
                  <span className="text-gray-400">Created:</span>
                  <div>{new Date(beepInfo.created_at).toLocaleString()}</div>
                </div>
                <div>
                  <span className="text-gray-400">Source:</span>
                  <div>{beepInfo.source}</div>
                </div>
                <div>
                  <span className="text-gray-400">Reporter:</span>
                  <div>{beepInfo.reporter_username || 'Anonymous'}</div>
                </div>
                <div>
                  <span className="text-gray-400">Short URL:</span>
                  {beepInfo.short_url && (
                    <a
                      href={`https://ufobeep.com/${beepInfo.short_url}`}
                      target="_blank"
                      className="text-blue-400 hover:underline text-sm"
                    >
                      ufobeep.com/{beepInfo.short_url}
                    </a>
                  )}
                </div>
                <div className="col-span-2">
                  <span className="text-gray-400">Description:</span>
                  <div className="text-sm mt-1">{beepInfo.description}</div>
                </div>
              </div>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-3 gap-4 mb-6">
              <div className="bg-gray-800 p-4 rounded border border-gray-700 text-center">
                <div className="text-3xl font-bold text-green-400">{recipients.length}</div>
                <div className="text-sm text-gray-400">Total Recipients</div>
              </div>
              <div className="bg-gray-800 p-4 rounded border border-gray-700 text-center">
                <div className="text-3xl font-bold text-blue-400">
                  {new Set(recipients.map(r => r.username).filter(Boolean)).size}
                </div>
                <div className="text-sm text-gray-400">Unique Users</div>
              </div>
              <div className="bg-gray-800 p-4 rounded border border-gray-700 text-center">
                <div className="text-3xl font-bold text-purple-400">
                  {new Set(recipients.map(r => r.device_id)).size}
                </div>
                <div className="text-sm text-gray-400">Unique Devices</div>
              </div>
            </div>

            {/* Recipients Table */}
            <div className="bg-gray-800 rounded-lg border border-gray-700 overflow-hidden">
              <div className="p-4 border-b border-gray-700">
                <h2 className="text-xl font-semibold">👥 Recipients Who Received This Beep</h2>
              </div>
              <div className="overflow-x-auto">
                {recipients.length > 0 ? (
                  <table className="w-full">
                    <thead className="bg-gray-700">
                      <tr>
                        <th className="p-3 text-left">Username</th>
                        <th className="p-3 text-left">Email</th>
                        <th className="p-3 text-left">Device ID</th>
                        <th className="p-3 text-left">Device</th>
                        <th className="p-3 text-left">Platform</th>
                        <th className="p-3 text-left">Distance</th>
                        <th className="p-3 text-left">Received At</th>
                      </tr>
                    </thead>
                    <tbody>
                      {recipients.map((recipient, idx) => (
                        <tr key={idx} className="border-b border-gray-700 hover:bg-gray-750">
                          <td className="p-3">{recipient.username || 'Unknown'}</td>
                          <td className="p-3 text-sm">{recipient.email || 'N/A'}</td>
                          <td className="p-3 font-mono text-xs">{recipient.device_id.substring(0, 12)}...</td>
                          <td className="p-3 text-sm">{recipient.device_name || 'Unknown'}</td>
                          <td className="p-3">{recipient.platform || 'Unknown'}</td>
                          <td className="p-3">
                            {recipient.distance_km !== null
                              ? `${recipient.distance_km.toFixed(1)} km`
                              : 'N/A'}
                          </td>
                          <td className="p-3 text-sm">
                            {new Date(recipient.received_at).toLocaleString()}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                ) : (
                  <div className="p-8 text-center text-gray-400">
                    No delivery records found in database. Check Firebase Console for detailed FCM logs.
                  </div>
                )}
              </div>
            </div>
          </>
        )}

        {/* Recent Beeps */}
        {!beepInfo && recentBeeps.length > 0 && (
          <div className="bg-gray-800 rounded-lg border border-gray-700 p-6">
            <h3 className="text-xl font-semibold mb-4">📋 Recent Beeps</h3>
            <div className="space-y-2">
              {recentBeeps.map((beep) => (
                <div
                  key={beep.id}
                  className="bg-gray-700 p-4 rounded flex justify-between items-center hover:bg-gray-650"
                >
                  <div>
                    <div className="font-semibold">{beep.title || 'Untitled'}</div>
                    <div className="text-sm text-gray-400">
                      {new Date(beep.created_at).toLocaleString()}
                    </div>
                  </div>
                  <button
                    onClick={() => searchBeep(beep.id)}
                    className="bg-blue-600 hover:bg-blue-700 px-4 py-2 rounded text-sm"
                  >
                    View Distribution →
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
