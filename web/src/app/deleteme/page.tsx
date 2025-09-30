import Link from 'next/link'
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Delete Account | UFOBeep',
  description: 'Request deletion of your UFOBeep account and associated data.',
  robots: 'noindex',
}

export default function DeleteAccountPage() {
  return (
    <main className="min-h-screen py-8 px-4 md:px-8">
      <div className="max-w-3xl mx-auto">
        {/* Header */}
        <div className="mb-12">
          <Link
            href="/"
            className="text-brand-primary hover:text-brand-primary-light transition-colors mb-4 inline-block"
          >
            ← Back to Home
          </Link>

          <h1 className="text-4xl md:text-5xl font-bold text-text-primary mb-4">
            Delete Your Account
          </h1>
          <p className="text-lg text-text-secondary">
            Request permanent deletion of your UFOBeep account and all associated data
          </p>
        </div>

        {/* Option 1: In-App */}
        <div className="bg-surface-light border border-surface-border rounded-lg p-6 mb-6">
          <div className="flex items-start gap-3 mb-4">
            <div className="text-2xl">📱</div>
            <div>
              <h2 className="text-xl font-semibold text-brand-primary mb-2">Option 1: Delete from the App</h2>
              <p className="text-text-secondary mb-4">
                The fastest way to delete your account is directly from the UFOBeep mobile app.
              </p>
            </div>
          </div>

          <ol className="space-y-2 text-text-secondary ml-11">
            <li>1. Open the UFOBeep app</li>
            <li>2. Go to <strong className="text-text-primary">Settings</strong> (bottom right tab)</li>
            <li>3. Scroll down to <strong className="text-text-primary">Data Management</strong></li>
            <li>4. Tap <strong className="text-text-primary">Delete Account</strong></li>
            <li>5. Confirm deletion</li>
          </ol>

          <div className="mt-4 p-4 bg-semantic-warning bg-opacity-10 border border-semantic-warning border-opacity-20 rounded">
            <p className="text-sm text-semantic-warning">
              <strong>⚠️ Warning:</strong> This action is permanent and cannot be undone. All your beeps, comments, and account data will be deleted immediately.
            </p>
          </div>
        </div>

        {/* Option 2: Email */}
        <div className="bg-surface-light border border-surface-border rounded-lg p-6 mb-6">
          <div className="flex items-start gap-3 mb-4">
            <div className="text-2xl">✉️</div>
            <div>
              <h2 className="text-xl font-semibold text-brand-primary mb-2">Option 2: Email Request</h2>
              <p className="text-text-secondary mb-4">
                If you no longer have access to the app, email us to request account deletion.
              </p>
            </div>
          </div>

          <div className="ml-11">
            <p className="text-text-secondary mb-4">
              Send an email to:
            </p>
            <a
              href="mailto:support@ufobeep.com?subject=Delete%20My%20Account"
              className="inline-block bg-brand-primary hover:bg-brand-primary-light text-background-dark font-semibold px-6 py-3 rounded-lg transition-colors"
            >
              support@ufobeep.com
            </a>

            <p className="text-sm text-text-tertiary mt-4">
              <strong>Include in your email:</strong>
            </p>
            <ul className="text-sm text-text-tertiary space-y-1 mt-2">
              <li>• The email address associated with your account</li>
              <li>• Confirmation that you want to permanently delete your account</li>
              <li>• (Optional) Reason for leaving</li>
            </ul>

            <p className="text-sm text-text-tertiary mt-4">
              We will process your deletion request within <strong>30 days</strong> and send you a confirmation email when complete.
            </p>
          </div>
        </div>

        {/* What Gets Deleted */}
        <div className="bg-surface-light border border-surface-border rounded-lg p-6">
          <h2 className="text-xl font-semibold text-text-primary mb-4">What Data Gets Deleted</h2>

          <p className="text-text-secondary mb-4">
            When you delete your account, the following data is permanently removed:
          </p>

          <ul className="space-y-2 text-text-secondary">
            <li className="flex items-start gap-2">
              <span className="text-brand-primary">•</span>
              <span>Your profile and username</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-brand-primary">•</span>
              <span>All your beeps and sighting reports</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-brand-primary">•</span>
              <span>All your comments</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-brand-primary">•</span>
              <span>Device registration and push notification tokens</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-brand-primary">•</span>
              <span>Location and preference data</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-brand-primary">•</span>
              <span>All uploaded photos and videos</span>
            </li>
          </ul>

          <p className="text-sm text-text-tertiary mt-6">
            <strong>Note:</strong> MUFON reports sourced from the public MUFON database are not deleted, as they are not your personal data.
          </p>
        </div>

        {/* Footer */}
        <div className="mt-12 text-center text-text-tertiary text-sm">
          <p>
            Questions? Email us at{' '}
            <a href="mailto:support@ufobeep.com" className="text-brand-primary hover:underline">
              support@ufobeep.com
            </a>
          </p>
          <p className="mt-2">
            <Link href="/privacy" className="text-brand-primary hover:underline">Privacy Policy</Link>
            {' • '}
            <Link href="/terms" className="text-brand-primary hover:underline">Terms of Service</Link>
          </p>
        </div>
      </div>
    </main>
  )
}