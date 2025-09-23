'use client'

import { useState, useEffect } from 'react'

interface User {
  id: string
  username: string
  email: string | null
  device_model: string | null
  device_manufacturer: string | null
  os_version: string | null
  app_version: string | null
  acquisition_source: string | null
  marketing_consent: boolean
  created_at: string
  last_active_at: string | null
}

interface UserStats {
  total_users: number
  active_users_7d: number
  active_users_30d: number
  marketing_consent_count: number
  top_devices: Array<{model: string, manufacturer: string, count: number}>
  top_sources: Array<{source: string, count: number}>
}

export default function AdminUsersPage() {
  const [users, setUsers] = useState<User[]>([])
  const [stats, setStats] = useState<UserStats | null>(null)
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [adminKey, setAdminKey] = useState('')
  const [authenticated, setAuthenticated] = useState(false)

  const authenticate = () => {
    if (adminKey === 'ufobeep_admin_2025') {
      setAuthenticated(true)
      loadData()
    } else {
      alert('Invalid admin key')
    }
  }

  const loadData = async () => {
    try {
      setLoading(true)

      // Load user statistics
      const statsResponse = await fetch('/api/admin/users/stats', {
        headers: { 'X-Admin-Key': adminKey }
      })
      if (statsResponse.ok) {
        const statsData = await statsResponse.json()
        setStats(statsData)
      }

      // Load users list
      const usersResponse = await fetch(`/api/admin/users?search=${search}&limit=50`, {
        headers: { 'X-Admin-Key': adminKey }
      })
      if (usersResponse.ok) {
        const usersData = await usersResponse.json()
        setUsers(usersData)
      }

    } catch (error) {
      console.error('Error loading admin data:', error)
    } finally {
      setLoading(false)
    }
  }

  const exportMarketingEmails = async () => {
    try {
      const response = await fetch('/api/admin/users/export/marketing-emails?format=csv', {
        headers: { 'X-Admin-Key': adminKey }
      })

      if (response.ok) {
        const blob = await response.blob()
        const url = window.URL.createObjectURL(blob)
        const a = document.createElement('a')
        a.href = url
        a.download = `ufobeep_marketing_emails_${new Date().toISOString().split('T')[0]}.csv`
        a.click()
      }
    } catch (error) {
      console.error('Error exporting emails:', error)
    }
  }

  const deleteUser = async (userId: string, username: string) => {
    if (!confirm(`⚠️ COMPREHENSIVE DELETE WARNING ⚠️\n\nThis will permanently delete user "${username}" and ALL associated data:\n\n✅ User profile and account\n✅ All uploaded beeps/sightings\n✅ All media files and photos\n✅ All comments made by user\n✅ All follows and notifications\n\nThis action CANNOT be undone and will free up storage space.\n\nType "${username}" to confirm deletion:`)) {
      return
    }

    const confirmation = prompt(`Type "${username}" to confirm permanent deletion:`)
    if (confirmation !== username) {
      alert('Deletion cancelled - username did not match')
      return
    }

    try {
      const response = await fetch(`/api/admin/users/${userId}`, {
        method: 'DELETE',
        headers: { 'X-Admin-Key': adminKey }
      })

      if (response.ok) {
        const result = await response.json()
        if (result.details) {
          alert(`✅ User ${username} comprehensively deleted!\n\nCleaned up:\n• ${result.details.sightings_deleted} sightings\n• ${result.details.comments_deleted} comments\n• ${result.details.files_deleted} files\n• ${result.details.storage_freed_mb}MB storage freed\n\nAll data permanently removed.`)
        } else {
          alert(`User ${username} deleted successfully`)
        }
        loadData() // Reload the list
      } else {
        alert('Failed to delete user')
      }
    } catch (error) {
      console.error('Error deleting user:', error)
      alert('Error deleting user')
    }
  }

  const exportUserData = async (userId: string, username: string, format: string = 'csv') => {
    try {
      // Call via Next.js API route to avoid CORS issues
      const response = await fetch(`/api/admin/users/${userId}/export?format=${format}`, {
        headers: { 'X-Admin-Key': adminKey }
      })

      if (response.ok) {
        if (format === 'csv') {
          const csvData = await response.text()
          const blob = new Blob([csvData], { type: 'text/csv' })
          const url = window.URL.createObjectURL(blob)
          const a = document.createElement('a')
          a.href = url
          a.download = `user_data_${username}_${new Date().toISOString().split('T')[0]}.csv`
          a.click()
        } else {
          const data = await response.json()
          const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
          const url = window.URL.createObjectURL(blob)
          const a = document.createElement('a')
          a.href = url
          a.download = `user_data_${username}_${new Date().toISOString().split('T')[0]}.json`
          a.click()
        }
        alert(`User data for ${username} exported successfully`)
      } else {
        const errorText = await response.text()
        alert(`Failed to export user data: ${errorText}`)
      }
    } catch (error) {
      console.error('Error exporting user data:', error)
      alert('Error exporting user data')
    }
  }

  if (!authenticated) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="bg-gray-800 p-8 rounded-lg border border-gray-700 max-w-md w-full">
          <h1 className="text-2xl font-bold text-white mb-6 text-center">
            🛸 UFOBeep Admin
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
          <h1 className="text-3xl font-bold mb-4">🛸 UFOBeep User Management</h1>
          <div className="flex gap-4 items-center">
            <input
              type="text"
              placeholder="Search users..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="p-2 bg-gray-800 border border-gray-600 rounded text-white"
            />
            <button
              onClick={loadData}
              className="bg-blue-600 hover:bg-blue-700 px-4 py-2 rounded"
            >
              Refresh
            </button>
            <button
              onClick={exportMarketingEmails}
              className="bg-green-600 hover:bg-green-700 px-4 py-2 rounded"
            >
              📧 Export Marketing Emails
            </button>
          </div>
        </div>

        {/* Stats */}
        {stats && (
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
            <div className="bg-gray-800 p-4 rounded border border-gray-700">
              <h3 className="text-sm text-gray-400">Total Users</h3>
              <p className="text-2xl font-bold text-white">{stats.total_users}</p>
            </div>
            <div className="bg-gray-800 p-4 rounded border border-gray-700">
              <h3 className="text-sm text-gray-400">Active (7 days)</h3>
              <p className="text-2xl font-bold text-green-400">{stats.active_users_7d}</p>
            </div>
            <div className="bg-gray-800 p-4 rounded border border-gray-700">
              <h3 className="text-sm text-gray-400">Active (30 days)</h3>
              <p className="text-2xl font-bold text-blue-400">{stats.active_users_30d}</p>
            </div>
            <div className="bg-gray-800 p-4 rounded border border-gray-700">
              <h3 className="text-sm text-gray-400">Marketing Consent</h3>
              <p className="text-2xl font-bold text-purple-400">{stats.marketing_consent_count}</p>
            </div>
          </div>
        )}

        {/* Users Table */}
        <div className="bg-gray-800 rounded-lg border border-gray-700 overflow-hidden">
          <div className="p-4 border-b border-gray-700">
            <h2 className="text-xl font-semibold">User List</h2>
          </div>

          {loading ? (
            <div className="p-8 text-center text-gray-400">Loading users...</div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-700">
                  <tr>
                    <th className="p-3 text-left">Username</th>
                    <th className="p-3 text-left">Email</th>
                    <th className="p-3 text-left">Device</th>
                    <th className="p-3 text-left">OS</th>
                    <th className="p-3 text-left">Marketing</th>
                    <th className="p-3 text-left">Created</th>
                    <th className="p-3 text-left">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {users.map((user) => (
                    <tr key={user.id} className="border-b border-gray-700 hover:bg-gray-750">
                      <td className="p-3">
                        <div className="font-medium">{user.username}</div>
                        <div className="text-sm text-gray-400">ID: {user.id.substring(0, 8)}...</div>
                      </td>
                      <td className="p-3">
                        {user.email ? (
                          <div className="text-sm">{user.email}</div>
                        ) : (
                          <span className="text-gray-500">No email</span>
                        )}
                      </td>
                      <td className="p-3">
                        {user.device_model ? (
                          <div>
                            <div className="text-sm">{user.device_model}</div>
                            <div className="text-xs text-gray-400">{user.device_manufacturer}</div>
                          </div>
                        ) : (
                          <span className="text-gray-500">Unknown</span>
                        )}
                      </td>
                      <td className="p-3">
                        <div className="text-sm">{user.os_version || 'Unknown'}</div>
                        <div className="text-xs text-gray-400">App: {user.app_version || 'Unknown'}</div>
                      </td>
                      <td className="p-3">
                        <span className={`px-2 py-1 rounded text-xs ${
                          user.marketing_consent
                            ? 'bg-green-600 text-white'
                            : 'bg-gray-600 text-gray-300'
                        }`}>
                          {user.marketing_consent ? 'Yes' : 'No'}
                        </span>
                      </td>
                      <td className="p-3">
                        <div className="text-sm">{new Date(user.created_at).toLocaleDateString()}</div>
                        <div className="text-xs text-gray-400">
                          {user.acquisition_source || 'Unknown source'}
                        </div>
                      </td>
                      <td className="p-3">
                        <div className="flex gap-2">
                          <button
                            onClick={() => exportUserData(user.id, user.username, 'csv')}
                            className="bg-blue-600 hover:bg-blue-700 text-white px-3 py-1 rounded text-sm"
                            title="Export all user data (GDPR)"
                          >
                            📄 Export
                          </button>
                          <button
                            onClick={() => deleteUser(user.id, user.username)}
                            className="bg-red-600 hover:bg-red-700 text-white px-3 py-1 rounded text-sm"
                            title="Comprehensive delete - removes ALL user data"
                          >
                            🗑️ Delete
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}