'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'

export default function AppPage() {
  const router = useRouter()
  
  useEffect(() => {
    // Redirect to download page
    router.push('/download')
  }, [router])

  return (
    <main className="min-h-screen flex items-center justify-center">
      <div className="text-center">
        <div className="text-4xl mb-4">📱</div>
        <p className="text-text-secondary">Redirecting to download page...</p>
      </div>
    </main>
  )
}