'use client';

import { useState } from 'react';

export default function DownloadPage() {
  const [showInstructions, setShowInstructions] = useState(false);
  
  const latestVersion = "v0.8.1 Beta";
  const releaseDate = new Date().toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  });
  const apkSize = "63 MB";
  
  return (
    <div className="min-h-screen bg-gray-900 text-white">
      <div className="max-w-4xl mx-auto px-4 py-12">
        {/* Header */}
        <div className="text-center mb-12">
          <h1 className="text-5xl font-bold mb-4 text-green-400">
            🛸 Download UFOBeep
          </h1>
          <p className="text-xl text-gray-300">
            Real-time UFO sighting alerts for Android
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
          
          <div className="grid md:grid-cols-2 gap-4 text-gray-300">
            <div>
              <p>📅 Release Date: {releaseDate}</p>
              <p>📦 File Size: {apkSize}</p>
            </div>
            <div>
              <p>📱 Requires: Android 5.0+</p>
              <p>🔧 Type: APK (Direct Install)</p>
            </div>
          </div>
        </div>

        {/* What's New */}
        <div className="bg-gray-800 rounded-lg p-6 mb-8">
          <h2 className="text-2xl font-semibold mb-4 text-green-400">
            🚀 What&apos;s New
          </h2>
          <ul className="space-y-2 text-gray-300">
            <li>✅ <strong>CRITICAL FIX:</strong> Anonymous beep with media now works correctly</li>
            <li>✅ <strong>Service Layer Architecture:</strong> 3,000+ lines of code optimized for blazing performance</li>
            <li>✅ <strong>Smart Unit Conversion:</strong> Automatic metric/imperial conversion based on your location</li>
            <li>✅ <strong>Enhanced Weather Data:</strong> Precision-controlled measurements with clean display</li>
            <li>✅ <strong>Alert Level Support:</strong> Proper alert prioritization system</li>
            <li>✅ <strong>Database Caching:</strong> Enrichment data computed once, displayed instantly</li>
          </ul>
        </div>

        {/* Download Button */}
        <div className="text-center mb-8">
          <a
            href="/downloads/ufobeep-latest.apk"
            className="inline-block bg-green-600 hover:bg-green-700 text-white font-bold py-4 px-8 rounded-lg text-xl transition-all transform hover:scale-105"
            download
          >
            📥 Download UFOBeep APK
          </a>
          <p className="text-sm text-gray-400 mt-2">
            Direct download • No app store required
          </p>
        </div>

        {/* Installation Instructions */}
        <div className="bg-gray-800 rounded-lg p-6 mb-8">
          <div 
            className="flex items-center justify-between cursor-pointer"
            onClick={() => setShowInstructions(!showInstructions)}
          >
            <h2 className="text-2xl font-semibold text-green-400">
              📱 Installation Instructions
            </h2>
            <span className="text-2xl">
              {showInstructions ? '−' : '+'}
            </span>
          </div>
          
          {showInstructions && (
            <div className="mt-6 space-y-6">
              {/* Step 1 */}
              <div className="border-l-4 border-green-500 pl-4">
                <h3 className="font-semibold text-lg mb-2">
                  Step 1: Enable Installation from Unknown Sources
                </h3>
                <p className="text-gray-300 mb-2">
                  Android blocks APK installations by default for security. You need to enable it:
                </p>
                <ol className="list-decimal list-inside space-y-1 text-gray-400">
                  <li>Open <strong>Settings</strong> on your Android device</li>
                  <li>Go to <strong>Security</strong> or <strong>Privacy</strong></li>
                  <li>Find <strong>&quot;Install unknown apps&quot;</strong> or <strong>&quot;Unknown sources&quot;</strong></li>
                  <li>Enable for your browser (Chrome, Firefox, etc.)</li>
                </ol>
              </div>

              {/* Step 2 */}
              <div className="border-l-4 border-green-500 pl-4">
                <h3 className="font-semibold text-lg mb-2">
                  Step 2: Download the APK
                </h3>
                <p className="text-gray-300 mb-2">
                  Click the download button above. The APK will download to your Downloads folder.
                </p>
                <p className="text-yellow-400 text-sm">
                  ⚠️ If Chrome warns about the file, tap &quot;Download anyway&quot;
                </p>
              </div>

              {/* Step 3 */}
              <div className="border-l-4 border-green-500 pl-4">
                <h3 className="font-semibold text-lg mb-2">
                  Step 3: Install the APK
                </h3>
                <ol className="list-decimal list-inside space-y-1 text-gray-400">
                  <li>Open your <strong>Downloads</strong> folder</li>
                  <li>Tap on <strong>ufobeep-latest.apk</strong></li>
                  <li>Tap <strong>&quot;Install&quot;</strong> when prompted</li>
                  <li>Wait for installation to complete</li>
                  <li>Tap <strong>&quot;Open&quot;</strong> to launch UFOBeep!</li>
                </ol>
              </div>

              {/* Troubleshooting */}
              <div className="bg-yellow-900/20 border border-yellow-600/50 rounded-lg p-4">
                <h3 className="font-semibold text-yellow-400 mb-2">
                  🔧 Troubleshooting
                </h3>
                <ul className="space-y-1 text-gray-300 text-sm">
                  <li>• <strong>&quot;App not installed&quot;:</strong> Uninstall old version first</li>
                  <li>• <strong>&quot;Parse error&quot;:</strong> Your Android version might be too old (need 5.0+)</li>
                  <li>• <strong>Can&apos;t find file:</strong> Check your Downloads folder or notification panel</li>
                  <li>• <strong>Security warning:</strong> This is normal for APKs - we&apos;re not on Play Store yet</li>
                </ul>
              </div>
            </div>
          )}
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
                <li>📍 <strong>Location:</strong> For proximity alerts</li>
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


        {/* Footer */}
        <div className="text-center text-gray-400 text-sm">
          <p>UFOBeep is currently in beta. Report bugs to support@ufobeep.com</p>
          <p className="mt-2">
            Coming soon to Google Play Store and Apple App Store
          </p>
        </div>
      </div>
    </div>
  );
}