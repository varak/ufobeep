import Link from 'next/link'

export default function NotFound() {
  return (
    <main className="min-h-screen bg-dark-background flex items-center justify-center p-4">
      <div className="max-w-md mx-auto text-center">
        <div className="text-6xl mb-6">🛸</div>
        <h1 className="text-4xl font-bold text-text-primary mb-4">404</h1>
        <h2 className="text-xl font-semibold text-text-secondary mb-6">Page Not Found</h2>
        <p className="text-text-tertiary mb-8">
          The page you&apos;re looking for seems to have vanished into the unknown... just like a UFO sighting.
        </p>
        <div className="space-y-4">
          <Link 
            href="/"
            className="inline-block bg-brand-primary hover:bg-brand-primary-dark text-text-inverse px-6 py-3 rounded-lg font-medium transition-colors"
          >
            Return to Home
          </Link>
          <div>
            <Link 
              href="/alerts"
              className="text-brand-primary hover:text-brand-primary-light transition-colors text-sm"
            >
              View Recent Alerts
            </Link>
          </div>
        </div>
      </div>
    </main>
  )
}