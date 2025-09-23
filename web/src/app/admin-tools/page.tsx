'use client'

import { useState } from 'react'

export default function AdminToolsPage() {
  const [adminKey, setAdminKey] = useState('')
  const [authenticated, setAuthenticated] = useState(false)
  const [userTarget, setUserTarget] = useState('')
  const [deleteTarget, setDeleteTarget] = useState('')
  const [results, setResults] = useState('')
  const [loading, setLoading] = useState(false)

  const authenticate = () => {
    if (adminKey === 'ufobeep_admin_2025') {
      setAuthenticated(true)
      setResults('✅ Authenticated - Admin tools ready')
    } else {
      setResults('❌ Invalid admin key')
    }
  }

  const exportUserData = async (format: string) => {
    if (!userTarget) {
      setResults('❌ Please enter a username or user ID')
      return
    }

    setLoading(true)
    setResults('📊 Exporting user data...')

    try {
      // Call the working backend API directly
      const response = await fetch(`https://ufobeep.com/api/admin/users/${encodeURIComponent(userTarget)}/export?format=${format}`, {
        headers: {
          'X-Admin-Key': adminKey
        }
      })

      if (response.ok) {
        if (format === 'csv') {
          const csvData = await response.text()
          downloadFile(csvData, `user_export_${userTarget}_${new Date().toISOString().split('T')[0]}.csv`, 'text/csv')
          setResults(`✅ CSV export downloaded for user: ${userTarget}`)
        } else {
          const jsonData = await response.json()
          downloadFile(JSON.stringify(jsonData, null, 2), `user_export_${userTarget}_${new Date().toISOString().split('T')[0]}.json`, 'application/json')
          setResults(`✅ JSON export downloaded for user: ${userTarget}

Summary:
• ${jsonData.export_metadata.total_beeps} sightings
• ${jsonData.export_metadata.total_comments} comments
• ${jsonData.export_metadata.total_devices} devices
• ${jsonData.export_metadata.total_follows} follows`)
        }
      } else {
        const errorData = await response.json()
        setResults(`❌ Export failed: ${errorData.error}`)
      }
    } catch (error) {
      setResults(`❌ Export failed: ${error instanceof Error ? error.message : 'Unknown error'}`)
    } finally {
      setLoading(false)
    }
  }

  const deleteUser = async () => {
    if (!deleteTarget) {
      setResults('❌ Please enter a username to delete')
      return
    }

    if (!confirm(`⚠️ PERMANENT DELETION WARNING ⚠️

This will permanently delete user "${deleteTarget}" and ALL associated data:

✅ User profile and account
✅ All uploaded beeps/sightings
✅ All media files and photos
✅ All comments made by user
✅ All follows and notifications

This action CANNOT be undone.

Click OK to proceed with deletion.`)) {
      return
    }

    const confirmation = prompt(`Type "${deleteTarget}" to confirm permanent deletion:`)
    if (confirmation !== deleteTarget) {
      setResults('❌ Deletion cancelled - username did not match')
      return
    }

    setLoading(true)
    setResults('🗑️ Deleting user account comprehensively...')

    try {
      // Call the working backend API directly
      const response = await fetch(`https://ufobeep.com/api/admin/users/${encodeURIComponent(deleteTarget)}`, {
        method: 'DELETE',
        headers: {
          'X-Admin-Key': adminKey
        }
      })

      if (response.ok) {
        const result = await response.json()
        setResults(`✅ User ${deleteTarget} comprehensively deleted!

Cleaned up:
• ${result.details.sightings_deleted} sightings
• ${result.details.comments_deleted} comments
• ${result.details.files_deleted} files

All data permanently removed for GDPR compliance.`)
      } else {
        const errorData = await response.json()
        setResults(`❌ Deletion failed: ${errorData.error}`)
      }
    } catch (error) {
      setResults(`❌ Deletion failed: ${error instanceof Error ? error.message : 'Unknown error'}`)
    } finally {
      setLoading(false)
    }
  }

  const downloadFile = (content: string, filename: string, contentType: string) => {
    const blob = new Blob([content], { type: contentType })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = filename
    a.click()
    window.URL.revokeObjectURL(url)
  }

  return (
    <div className="min-h-screen bg-gray-900 text-white p-6">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold mb-8 text-center text-blue-400">
          🛸 UFOBeep Admin Tools - GDPR Compliance
        </h1>

        {!authenticated ? (
          <div className="bg-gray-800 p-8 rounded-lg border border-gray-700 max-w-md mx-auto">
            <h2 className="text-xl font-semibold mb-6">Authentication Required</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-gray-300 mb-2">Admin Key:</label>
                <input
                  type="password"
                  value={adminKey}
                  onChange={(e) => setAdminKey(e.target.value)}
                  onKeyPress={(e) => e.key === 'Enter' && authenticate()}
                  className="w-full p-3 bg-gray-700 text-white rounded border border-gray-600 focus:border-blue-500"
                  placeholder="Enter admin key"
                />
              </div>
              <button
                onClick={authenticate}
                className="w-full bg-blue-600 hover:bg-blue-700 text-white p-3 rounded font-semibold"
              >
                Authenticate
              </button>
            </div>
          </div>
        ) : (
          <div className="space-y-8">
            {/* Export Section */}
            <div className="bg-gray-800 p-6 rounded-lg border border-gray-700">
              <h2 className="text-2xl font-semibold mb-4 text-green-400">📊 User Data Export (GDPR Compliance)</h2>
              <div className="space-y-4">
                <div>
                  <label className="block text-gray-300 mb-2">Username or User ID:</label>
                  <input
                    type="text"
                    value={userTarget}
                    onChange={(e) => setUserTarget(e.target.value)}
                    className="w-full p-3 bg-gray-700 text-white rounded border border-gray-600 focus:border-green-500"
                    placeholder="e.g. vibrant.passage.2705 or UUID"
                  />
                </div>
                <div className="flex gap-3">
                  <button
                    onClick={() => exportUserData('json')}
                    disabled={loading}
                    className="bg-green-600 hover:bg-green-700 disabled:bg-gray-600 text-white px-6 py-3 rounded font-semibold"
                  >
                    📄 Export JSON
                  </button>
                  <button
                    onClick={() => exportUserData('csv')}
                    disabled={loading}
                    className="bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 text-white px-6 py-3 rounded font-semibold"
                  >
                    📊 Export CSV
                  </button>
                </div>
              </div>
            </div>

            {/* Delete Section */}
            <div className="bg-gray-800 p-6 rounded-lg border border-red-700">
              <h2 className="text-2xl font-semibold mb-4 text-red-400">🗑️ User Account Deletion (GDPR Compliance)</h2>
              <div className="space-y-4">
                <div>
                  <label className="block text-gray-300 mb-2">Username to Delete:</label>
                  <input
                    type="text"
                    value={deleteTarget}
                    onChange={(e) => setDeleteTarget(e.target.value)}
                    className="w-full p-3 bg-gray-700 text-white rounded border border-gray-600 focus:border-red-500"
                    placeholder="e.g. vibrant.passage.2705"
                  />
                </div>
                <button
                  onClick={deleteUser}
                  disabled={loading}
                  className="bg-red-600 hover:bg-red-700 disabled:bg-gray-600 text-white px-6 py-3 rounded font-semibold"
                >
                  🗑️ Delete Account & All Data
                </button>
              </div>
            </div>

            {/* Results */}
            {results && (
              <div className={`p-4 rounded-lg border ${results.includes('❌') ? 'bg-red-900 border-red-700' : 'bg-green-900 border-green-700'}`}>
                <pre className="whitespace-pre-wrap text-sm">{results}</pre>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  )
}