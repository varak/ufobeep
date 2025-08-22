'use client';

import { useEffect, useState, Suspense } from 'react';
import { useSearchParams } from 'next/navigation';

function VerifyEmailContent() {
  const [status, setStatus] = useState<'loading' | 'success' | 'error' | 'expired'>('loading');
  const [message, setMessage] = useState('');
  const [username, setUsername] = useState('');
  
  const searchParams = useSearchParams();
  const token = searchParams.get('token');

  useEffect(() => {
    if (!token) {
      setStatus('error');
      setMessage('No verification token provided');
      return;
    }

    // Call the API to verify the email
    fetch('https://api.ufobeep.com/users/verify-email', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ token }),
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        setStatus('success');
        setMessage(data.message);
        setUsername(data.username);
      } else {
        if (data.detail && data.detail.includes('expired')) {
          setStatus('expired');
          setMessage('Verification link has expired');
        } else {
          setStatus('error');
          setMessage(data.detail || 'Verification failed');
        }
      }
    })
    .catch(error => {
      console.error('Verification error:', error);
      setStatus('error');
      setMessage('Failed to verify email. Please try again.');
    });
  }, [token]);

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-purple-900 flex items-center justify-center px-4">
      <div className="max-w-md w-full bg-black/20 backdrop-blur-lg border border-white/10 rounded-2xl p-8 text-center">
        {/* UFO Icon */}
        <div className="text-6xl mb-6">🛸</div>
        
        <h1 className="text-2xl font-bold text-white mb-6">
          Email Verification
        </h1>

        {status === 'loading' && (
          <div className="space-y-4">
            <div className="animate-spin h-8 w-8 border-2 border-white/20 border-t-white rounded-full mx-auto"></div>
            <p className="text-white/80">Verifying your email...</p>
          </div>
        )}

        {status === 'success' && (
          <div className="space-y-4">
            <div className="text-4xl mb-4">✅</div>
            <div className="space-y-2">
              <p className="text-green-400 font-semibold">Email verified successfully!</p>
              {username && (
                <p className="text-white/80">
                  Welcome to UFOBeep, <span className="text-green-400 font-mono">{username}</span>
                </p>
              )}
              <p className="text-white/60 text-sm">
                You can now recover your account and use UFOBeep on multiple devices.
              </p>
            </div>
            
            {/* Download app button */}
            <div className="mt-6 pt-4 border-t border-white/10">
              <p className="text-white/60 text-sm mb-3">
                Ready to start sky watching?
              </p>
              <a 
                href="/download"
                className="inline-block bg-gradient-to-r from-green-500 to-blue-600 text-white px-6 py-3 rounded-lg font-semibold hover:from-green-600 hover:to-blue-700 transition-all transform hover:scale-105"
              >
                Download UFOBeep App
              </a>
            </div>
          </div>
        )}

        {status === 'expired' && (
          <div className="space-y-4">
            <div className="text-4xl mb-4">⏰</div>
            <div className="space-y-2">
              <p className="text-yellow-400 font-semibold">Verification Link Expired</p>
              <p className="text-white/60 text-sm">
                Your verification link has expired. Please request a new one from the UFOBeep app.
              </p>
            </div>
            
            <div className="mt-6 pt-4 border-t border-white/10">
              <a 
                href="/download"
                className="inline-block bg-gradient-to-r from-yellow-500 to-orange-600 text-white px-6 py-3 rounded-lg font-semibold hover:from-yellow-600 hover:to-orange-700 transition-all"
              >
                Get UFOBeep App
              </a>
            </div>
          </div>
        )}

        {status === 'error' && (
          <div className="space-y-4">
            <div className="text-4xl mb-4">❌</div>
            <div className="space-y-2">
              <p className="text-red-400 font-semibold">Verification Failed</p>
              <p className="text-white/60 text-sm">
                {message || 'Unable to verify your email. Please try again or contact support.'}
              </p>
            </div>
            
            <div className="mt-6 pt-4 border-t border-white/10 space-y-2">
              <a 
                href="/download"
                className="inline-block bg-gradient-to-r from-red-500 to-pink-600 text-white px-6 py-3 rounded-lg font-semibold hover:from-red-600 hover:to-pink-700 transition-all mb-2"
              >
                Download UFOBeep App
              </a>
              <p className="text-white/40 text-xs">
                Try requesting a new verification email from the app
              </p>
            </div>
          </div>
        )}

        {/* Footer */}
        <div className="mt-8 pt-6 border-t border-white/10 text-center">
          <p className="text-white/40 text-xs">
            UFOBeep - Real-time UFO Alert Network
          </p>
        </div>
      </div>
    </div>
  );
}

export default function VerifyEmailPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-purple-900 flex items-center justify-center px-4">
        <div className="max-w-md w-full bg-black/20 backdrop-blur-lg border border-white/10 rounded-2xl p-8 text-center">
          <div className="text-6xl mb-6">🛸</div>
          <h1 className="text-2xl font-bold text-white mb-6">Email Verification</h1>
          <div className="animate-spin h-8 w-8 border-2 border-white/20 border-t-white rounded-full mx-auto"></div>
          <p className="text-white/80 mt-4">Loading...</p>
        </div>
      </div>
    }>
      <VerifyEmailContent />
    </Suspense>
  );
}