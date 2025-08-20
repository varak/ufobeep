'use client';

import { useState } from 'react';

export default function CopeScanPage() {
  const [showInstallSteps, setShowInstallSteps] = useState(false);

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 text-white">
      <div className="container mx-auto px-4 py-12 max-w-4xl">
        {/* Header */}
        <div className="text-center mb-12">
          <h1 className="text-5xl font-bold mb-4 bg-gradient-to-r from-green-400 to-blue-500 bg-clip-text text-transparent">
            CopeScan
          </h1>
          <p className="text-xl text-gray-300 mb-8">
            Automated Copenhagen Tobacco Code Scanner & Submitter
          </p>
          
          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <h2 className="text-2xl font-semibold mb-4 text-green-400">📱 What is CopeScan?</h2>
            <p className="text-gray-300 leading-relaxed">
              CopeScan is a mobile app that uses your phone&apos;s camera and OCR (Optical Character Recognition) 
              to automatically scan Copenhagen tobacco reward codes from wrapper images, then submits them 
              directly to the Fresh Cope rewards program. No more manual typing of codes!
            </p>
          </div>
        </div>

        {/* Features */}
        <div className="grid md:grid-cols-2 gap-6 mb-12">
          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <h3 className="text-xl font-semibold mb-3 text-blue-400">🔍 Smart Scanning</h3>
            <ul className="text-gray-300 space-y-2">
              <li>• Camera-based code detection</li>
              <li>• ML Kit text recognition</li>
              <li>• Auto-submit or queue for later</li>
              <li>• Manual code input backup</li>
            </ul>
          </div>

          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <h3 className="text-xl font-semibold mb-3 text-purple-400">⚡ Batch Processing</h3>
            <ul className="text-gray-300 space-y-2">
              <li>• Queue multiple codes</li>
              <li>• Batch submission with delays</li>
              <li>• Anti-automation protection</li>
              <li>• Submission history tracking</li>
            </ul>
          </div>

          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <h3 className="text-xl font-semibold mb-3 text-yellow-400">🎯 User Experience</h3>
            <ul className="text-gray-300 space-y-2">
              <li>• Audio & haptic feedback</li>
              <li>• Targeting overlay for accuracy</li>
              <li>• Configurable username/password</li>
              <li>• Password visibility toggle</li>
            </ul>
          </div>

          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <h3 className="text-xl font-semibold mb-3 text-green-400">💰 DevTax Model</h3>
            <ul className="text-gray-300 space-y-2">
              <li>• Every 10th submission → developer</li>
              <li>• Transparent policy display</li>
              <li>• Fair payment for app development</li>
              <li>• Submission counter visible</li>
            </ul>
          </div>
        </div>

        {/* Requirements */}
        <div className="bg-red-900 bg-opacity-50 rounded-lg p-6 border border-red-700 mb-12">
          <h2 className="text-2xl font-semibold mb-4 text-red-400">🔑 Account Required</h2>
          <p className="text-gray-200 mb-4">
            <strong>You must have a Fresh Cope account to use this app.</strong>
          </p>
          <ul className="text-gray-300 space-y-2">
            <li>• Create account at: <a href="https://www.freshcope.com/rewards/earn" target="_blank" rel="noopener noreferrer" className="text-blue-400 underline hover:text-blue-300">freshcope.com/rewards/earn</a></li>
            <li>• You&apos;ll need your username/email and password</li>
            <li>• The app submits codes directly to your account</li>
            <li>• DevTax: Every 10th code goes to app developer</li>
          </ul>
        </div>

        {/* Download Section */}
        <div className="text-center mb-8">
          <div className="bg-gray-800 rounded-lg p-8 border border-gray-700">
            <h2 className="text-2xl font-semibold mb-4 text-blue-400">📲 Download CopeScan</h2>
            <p className="text-gray-300 mb-6">
              Current Version: <span className="font-mono text-green-400">v1.0.0</span> • 
              File Size: <span className="font-mono text-yellow-400">127 MB</span> • 
              Android APK
            </p>
            
            <a 
              href="/downloads/copescan.apk" 
              className="inline-block bg-gradient-to-r from-green-500 to-blue-600 hover:from-green-600 hover:to-blue-700 text-white font-bold py-3 px-8 rounded-lg transition-all duration-200 transform hover:scale-105"
              download
            >
              📱 Download CopeScan APK
            </a>
            
            <p className="text-sm text-gray-400 mt-4">
              Android 6.0+ required • Not available on Google Play Store
            </p>
          </div>
        </div>

        {/* Installation Instructions */}
        <div className="mb-8">
          <button 
            onClick={() => setShowInstallSteps(!showInstallSteps)}
            className="w-full bg-gray-800 hover:bg-gray-700 rounded-lg p-4 border border-gray-600 transition-colors duration-200 flex items-center justify-between"
          >
            <span className="text-lg font-semibold text-orange-400">🔧 Installation Instructions</span>
            <span className="text-2xl text-gray-400">{showInstallSteps ? '−' : '+'}</span>
          </button>
          
          {showInstallSteps && (
            <div className="bg-gray-800 border-x border-b border-gray-600 rounded-b-lg p-6">
              <div className="space-y-4">
                <div className="border-l-4 border-yellow-500 pl-4">
                  <h3 className="font-semibold text-yellow-400 mb-2">Step 1: Enable Unknown Sources</h3>
                  <p className="text-gray-300 text-sm">
                    Go to Settings → Security → &quot;Install unknown apps&quot; → Chrome (or your browser) → Enable &quot;Allow from this source&quot;
                  </p>
                </div>
                
                <div className="border-l-4 border-blue-500 pl-4">
                  <h3 className="font-semibold text-blue-400 mb-2">Step 2: Download APK</h3>
                  <p className="text-gray-300 text-sm">
                    Click the download button above. The APK file (127 MB) will download to your device.
                  </p>
                </div>
                
                <div className="border-l-4 border-green-500 pl-4">
                  <h3 className="font-semibold text-green-400 mb-2">Step 3: Install App</h3>
                  <p className="text-gray-300 text-sm">
                    Open your Downloads folder, tap the copescan.apk file, and follow the installation prompts.
                  </p>
                </div>
                
                <div className="border-l-4 border-purple-500 pl-4">
                  <h3 className="font-semibold text-purple-400 mb-2">Step 4: Configure Account</h3>
                  <p className="text-gray-300 text-sm">
                    Open CopeScan → Settings (gear icon) → Enter your Fresh Cope username and password → Save Settings
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* How to Use */}
        <div className="bg-gray-800 rounded-lg p-6 border border-gray-700 mb-8">
          <h2 className="text-2xl font-semibold mb-4 text-purple-400">🎯 How to Use CopeScan</h2>
          <div className="grid md:grid-cols-2 gap-4 text-gray-300">
            <div>
              <h4 className="font-semibold text-blue-400 mb-2">Automatic Mode:</h4>
              <ol className="space-y-1 text-sm">
                <li>1. Enable &quot;Auto-Submit: ON&quot;</li>
                <li>2. Point camera at code</li>
                <li>3. Tap &quot;Capture Code&quot;</li>
                <li>4. Code submits automatically</li>
              </ol>
            </div>
            <div>
              <h4 className="font-semibold text-green-400 mb-2">Queue Mode:</h4>
              <ol className="space-y-1 text-sm">
                <li>1. Set &quot;Auto-Submit: OFF&quot;</li>
                <li>2. Scan multiple codes</li>
                <li>3. View queue (clipboard icon)</li>
                <li>4. Submit all at once</li>
              </ol>
            </div>
          </div>
        </div>

        {/* Warning */}
        <div className="bg-yellow-900 bg-opacity-50 rounded-lg p-6 border border-yellow-700">
          <h2 className="text-xl font-semibold mb-3 text-yellow-400">⚠️ Important Notes</h2>
          <ul className="text-gray-200 space-y-2 text-sm">
            <li>• <strong>DevTax Policy:</strong> Every 10th code submission goes to the app developer as payment</li>
            <li>• <strong>Account Security:</strong> Your login credentials are stored locally on your device only</li>
            <li>• <strong>Internet Required:</strong> App needs internet connection to submit codes</li>
            <li>• <strong>Camera Permissions:</strong> Required for scanning codes from images</li>
            <li>• <strong>Beta Software:</strong> This is experimental software - use at your own risk</li>
          </ul>
        </div>

        {/* Footer */}
        <div className="text-center mt-12 text-gray-400">
          <p className="text-sm">
            CopeScan v1.0.0 • Built for Copenhagen tobacco enthusiasts • Not affiliated with Copenhagen or Altria
          </p>
        </div>
      </div>
    </div>
  );
}