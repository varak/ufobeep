'use client';

import EmailNotifySignup from '@/components/EmailNotifySignup';

export default function DownloadPage() {
  const latestVersion = "v1.9.3+388";
  const releaseDate = "October 26, 2025";
  const apkSize = "73 MB";
  
  return (
    <div className="min-h-screen bg-gray-900 text-white">
      <div className="max-w-4xl mx-auto px-4 py-12">
        {/* Header */}
        <div className="text-center mb-12">
          <h1 className="text-5xl font-bold mb-4 text-green-400">
            🛸 Download UFOBeep
          </h1>
          <p className="text-xl text-gray-300">
            Real-time UFO sighting alerts for Android & iOS
          </p>
        </div>

        {/* Version Info Card */}
        <div className="bg-gray-800 rounded-lg p-6 mb-8 border border-green-500/30">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-2xl font-semibold">Latest Release</h2>
            <span className="px-3 py-1 bg-green-600 rounded-full text-sm">
              {latestVersion}
            </span>
          </div>

          <div className="grid md:grid-cols-2 gap-4 text-gray-300 mb-6">
            <div>
              <p>📅 Release Date: {releaseDate}</p>
              <p>📦 File Size: {apkSize}</p>
            </div>
            <div>
              <p>📱 Requires: Android 5.0+ / iOS 13.0+</p>
              <p>🔧 Type: Beta Release</p>
            </div>
          </div>

          {/* Download Buttons */}
          <div className="grid md:grid-cols-2 gap-4">
            <a
              href="https://play.google.com/store/apps/details?id=com.ufobeep"
              target="_blank"
              rel="noopener noreferrer"
              className="block text-center bg-green-600 hover:bg-green-700 text-white font-bold py-3 px-6 rounded-lg transition-all transform hover:scale-105"
            >
              🤖 Get on Google Play
            </a>
            <a
              href="https://testflight.apple.com/join/jJvBaWSa"
              target="_blank"
              rel="noopener noreferrer"
              className="block text-center bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg transition-all transform hover:scale-105"
            >
              🍎 iOS Beta (TestFlight)
            </a>
          </div>
        </div>

        {/* Open Beta Announcement */}
        <div className="bg-green-900/30 border border-green-600/50 rounded-lg p-6 mb-8">
          <h2 className="text-2xl font-semibold mb-4 text-green-400 text-center">
            🎉 Open Beta Now Available!
          </h2>
          <div className="text-gray-300 space-y-4">
            <p className="text-center text-lg">
              UFOBeep is now in <strong>open beta</strong> on both Android and iOS! Anyone can download and start using the app right away.
            </p>

            <div className="bg-gray-800 rounded-lg p-6">
              <h3 className="text-xl font-semibold mb-4 text-center text-green-400">Ready to Get Started?</h3>
              <p className="text-center mb-6">
                Choose your platform below to get started. No approval needed!
              </p>
              <div className="grid md:grid-cols-2 gap-4">
                <a
                  href="https://play.google.com/store/apps/details?id=com.ufobeep"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="block text-center bg-green-600 hover:bg-green-700 text-white font-bold py-3 px-6 rounded-lg transition-all transform hover:scale-105"
                >
                  🤖 Get on Google Play
                </a>
                <a
                  href="https://testflight.apple.com/join/jJvBaWSa"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="block text-center bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg transition-all transform hover:scale-105"
                >
                  🍎 Join iOS Beta (TestFlight)
                </a>
              </div>
            </div>

            <div className="bg-blue-900/30 border border-blue-600/50 rounded-lg p-4 mt-6">
              <p className="text-center text-sm text-blue-300">
                <strong>Help us improve!</strong> As a beta tester, your feedback is invaluable. Report any bugs or suggestions to support@ufobeep.com
              </p>
            </div>
          </div>
        </div>

        {/* How to Get Started */}
        <div className="bg-gray-800 rounded-lg p-6 mb-8">
          <h2 className="text-2xl font-semibold mb-4 text-green-400">
            📱 How to Get Started
          </h2>
          <div className="space-y-4 text-gray-300">
            <div className="border-l-4 border-green-500 pl-4">
              <h3 className="font-semibold text-lg mb-2">Android Users</h3>
              <p>Click the Google Play button above to download UFOBeep directly from the Play Store. No registration required!</p>
            </div>
            <div className="border-l-4 border-blue-500 pl-4">
              <h3 className="font-semibold text-lg mb-2">iOS Users</h3>
              <p>Download the TestFlight app from the App Store, then use the iOS Beta link above to join the beta program.</p>
            </div>
            <div className="border-l-4 border-purple-500 pl-4">
              <h3 className="font-semibold text-lg mb-2">Mac Users</h3>
              <p>The macOS version is currently under review by Apple. Sign up below to get notified when it&apos;s available.</p>
            </div>
          </div>
        </div>

        {/* Permissions */}
        <div className="bg-gray-800 rounded-lg p-6 mb-8">
          <h2 className="text-2xl font-semibold mb-4 text-green-400">
            🔒 Required Permissions
          </h2>
          <div className="grid md:grid-cols-2 gap-4 text-gray-300">
            <div>
              <p className="font-semibold mb-2">Essential:</p>
              <ul className="space-y-1 text-sm">
                <li>📍 <strong>Location (Always):</strong> Background monitoring for proximity alerts</li>
                <li>📷 <strong>Camera:</strong> To capture sightings</li>
                <li>🔔 <strong>Notifications:</strong> For UFO alerts</li>
              </ul>
            </div>
            <div>
              <p className="font-semibold mb-2">Optional:</p>
              <ul className="space-y-1 text-sm">
                <li>💾 <strong>Storage:</strong> Save photos/videos</li>
                <li>🧭 <strong>Sensors:</strong> Compass navigation</li>
                <li>🌐 <strong>Internet:</strong> Real-time updates</li>
              </ul>
            </div>
          </div>
        </div>



        {/* iOS TestFlight */}
        <div className="bg-blue-900/30 border border-blue-600/50 rounded-lg p-6 mb-8">
          <h2 className="text-2xl font-semibold mb-4 text-blue-400 text-center">
            🍎 iOS Beta (TestFlight)
          </h2>
          <p className="text-center text-gray-300 mb-6">
            The iOS version is now available for testing on TestFlight! Download it on your iPhone or iPad.
          </p>
          <center>
            <a
              href="https://testflight.apple.com/join/jJvBaWSa"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-block bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg transition-all transform hover:scale-105"
            >
              📱 Join iOS Beta on TestFlight
            </a>
          </center>
          <div className="bg-gray-800 rounded-lg p-4 mt-6">
            <p className="text-center text-sm text-gray-400">
              <strong>Note:</strong> TestFlight requires iOS 13.0 or later. You&apos;ll need the TestFlight app from the App Store.
            </p>
          </div>
        </div>

        {/* Mac Version Notice */}
        <div className="bg-purple-900/30 border border-purple-600/50 rounded-lg p-6 mb-8">
          <h2 className="text-2xl font-semibold mb-4 text-purple-400 text-center">
            💻 macOS Version
          </h2>
          <p className="text-center text-gray-300 mb-6">
            The macOS version is currently under review by Apple.
            It will be available on the Mac App Store as soon as it receives approval.
          </p>
          <div className="bg-gray-800 rounded-lg p-6">
            <h3 className="text-xl font-semibold mb-4 text-center text-purple-400">Get Notified When Available</h3>
            <p className="text-center mb-6 text-gray-300">
              Add your email below and we&apos;ll notify you as soon as the Mac version is approved.
            </p>
            <EmailNotifySignup />
          </div>
        </div>

        {/* Footer */}
        <div className="text-center text-gray-400 text-sm">
          <p>UFOBeep is currently in beta. Report bugs to support@ufobeep.com</p>
          <p className="mt-2">
            Now available on Google Play and TestFlight
          </p>
        </div>
      </div>
    </div>
  );
}