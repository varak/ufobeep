import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'UFOBeep Screenshots - Play Store Assets Review',
  description: 'Review all UFOBeep app screenshots for Google Play Store submission',
  robots: {
    index: false,
    follow: false,
  },
}

export default function ScreenshotsPage() {
  const phoneScreenshots = [
    { file: 'phone-01-alerts-list-fixed.png', title: 'Phone: Alerts List (Fixed)', description: 'Main UFO alerts with proximity distances' },
    { file: 'phone-02-current-screen.png', title: 'Phone: Current Screen', description: 'App state capture' },
    { file: 'phone-03-beep-screen.png', title: 'Phone: Beep Creation', description: 'UFO reporting interface' },
    { file: 'phone-04-profile-screen.png', title: 'Phone: Profile Settings', description: 'User settings and features' },
    { file: 'phone-05-notification-settings.png', title: 'Phone: Notification Settings', description: 'Alert customization options' },
    { file: 'phone-06-compass-navigation.png', title: 'Phone: Compass Navigation ⭐', description: 'UNIQUE: Points to UFO location' },
  ]

  const tabletScreenshots = [
    { file: 'tablet-01-login.png', title: 'Tablet: Login Screen', description: 'Clean authentication interface' },
    { file: 'tablet-11-map-page.png', title: 'Tablet: UFO Map ⭐', description: 'Geographic UFO locations' },
    { file: 'tablet-13-compass-navigation.png', title: 'Tablet: Compass Navigation ⭐', description: 'Navigation to UFO location' },
    { file: 'tablet-10-privacy-policy.png', title: 'Tablet: Privacy Controls', description: 'App store compliance' },
    { file: 'tablet-05-alerts-screen.png', title: 'Tablet: Alerts Screen', description: 'UFO alerts list' },
    { file: 'tablet-07-alert-detail.png', title: 'Tablet: Alert Details', description: 'Individual sighting info' },
    { file: 'tablet-03-beep-screen.png', title: 'Tablet: Beep Creation', description: 'Report UFO interface' },
    { file: 'tablet-09-profile-screen.png', title: 'Tablet: Profile Screen', description: 'User profile and settings' },
  ]

  return (
    <div className="min-h-screen bg-gray-900 text-white p-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-12 text-center">
          <h1 className="text-4xl font-bold mb-4 text-green-400">
            🛸 UFOBeep Screenshots Review
          </h1>
          <p className="text-xl text-gray-300">
            Google Play Store Assets - Build 206
          </p>
          <p className="text-sm text-gray-400 mt-2">
            Phone: 1080x1920 | Tablet: 1200x1920
          </p>
        </div>

        {/* Phone Screenshots */}
        <section className="mb-12">
          <h2 className="text-3xl font-bold mb-6 text-blue-400">
            📱 Phone Screenshots (1080x1920)
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {phoneScreenshots.map((screenshot, index) => (
              <div key={index} className="bg-gray-800 rounded-lg p-4 border border-gray-700">
                <div className="mb-4">
                  <h3 className="text-lg font-semibold text-white mb-2">
                    {screenshot.title}
                  </h3>
                  <p className="text-sm text-gray-400">
                    {screenshot.description}
                  </p>
                </div>
                <div className="border border-gray-600 rounded-lg overflow-hidden">
                  <img
                    src={`/screenshots/${screenshot.file}`}
                    alt={screenshot.title}
                    className="w-full h-auto max-w-sm mx-auto"
                    style={{ aspectRatio: '9/16' }}
                  />
                </div>
                <div className="mt-3 text-center">
                  <a
                    href={`/screenshots/${screenshot.file}`}
                    target="_blank"
                    className="text-blue-400 hover:text-blue-300 text-sm"
                  >
                    View Full Size →
                  </a>
                </div>
              </div>
            ))}
          </div>
        </section>

        {/* Tablet Screenshots */}
        <section className="mb-12">
          <h2 className="text-3xl font-bold mb-6 text-purple-400">
            📊 Tablet Screenshots (1200x1920)
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {tabletScreenshots.map((screenshot, index) => (
              <div key={index} className="bg-gray-800 rounded-lg p-4 border border-gray-700">
                <div className="mb-4">
                  <h3 className="text-lg font-semibold text-white mb-2">
                    {screenshot.title}
                  </h3>
                  <p className="text-sm text-gray-400">
                    {screenshot.description}
                  </p>
                </div>
                <div className="border border-gray-600 rounded-lg overflow-hidden">
                  <img
                    src={`/screenshots/${screenshot.file}`}
                    alt={screenshot.title}
                    className="w-full h-auto max-w-sm mx-auto"
                    style={{ aspectRatio: '10/16' }}
                  />
                </div>
                <div className="mt-3 text-center">
                  <a
                    href={`/screenshots/${screenshot.file}`}
                    target="_blank"
                    className="text-purple-400 hover:text-purple-300 text-sm"
                  >
                    View Full Size →
                  </a>
                </div>
              </div>
            ))}
          </div>
        </section>

        {/* Download Links */}
        <section className="bg-gray-800 rounded-lg p-6 text-center">
          <h2 className="text-2xl font-bold mb-4 text-green-400">
            📥 Ready for Google Play Store
          </h2>
          <p className="text-gray-300 mb-4">
            Complete screenshot collection ready for submission
          </p>
          <div className="flex justify-center gap-4">
            <a
              href="/download"
              className="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-semibold"
            >
              📱 Current APK
            </a>
            <a
              href="/privacy"
              className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg font-semibold"
            >
              🛡️ Privacy Policy
            </a>
          </div>
        </section>
      </div>
    </div>
  )
}