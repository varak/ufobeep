'use client'

import { createContext, useContext, useState, useEffect, ReactNode } from 'react'

// Google OAuth configuration
const GOOGLE_CLIENT_ID = '346511467728-cttlsm8akgnse4npqin4gqeu6j8lh896.apps.googleusercontent.com'

// Declare Google and Apple API types
declare global {
  interface Window {
    google?: any
    gapi?: any
    AppleID?: any
    completeMagicAuth?: (code: string) => Promise<{ success: boolean; message: string }>
  }
}

interface User {
  id: string
  username: string
  email: string
}

interface AuthContextType {
  user: User | null
  isAuthenticated: boolean
  isLoading: boolean
  login: (email: string) => Promise<{ success: boolean; message: string }>
  loginWithGoogle: () => Promise<{ success: boolean; message: string }>
  loginWithApple: () => Promise<{ success: boolean; message: string }>
  logout: () => void
  getAuthToken: () => string | null
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [googleInitialized, setGoogleInitialized] = useState(false)

  useEffect(() => {
    // Check for existing session on page load
    const token = localStorage.getItem('auth_token')
    const userData = localStorage.getItem('user_data')
    
    if (token && userData) {
      try {
        setUser(JSON.parse(userData))
      } catch (e) {
        // Clear invalid data
        localStorage.removeItem('auth_token')
        localStorage.removeItem('user_data')
      }
    }
    
    // Initialize Google OAuth
    initializeGoogleOAuth()
    
    setIsLoading(false)
  }, [])
  
  const initializeGoogleOAuth = () => {
    // Load Google OAuth library
    if (!window.google && !document.getElementById('google-oauth-script')) {
      const script = document.createElement('script')
      script.id = 'google-oauth-script'
      script.src = 'https://accounts.google.com/gsi/client'
      script.onload = () => {
        if (window.google) {
          window.google.accounts.id.initialize({
            client_id: GOOGLE_CLIENT_ID,
            callback: handleGoogleCallback,
          })
          setGoogleInitialized(true)
        }
      }
      document.head.appendChild(script)
    } else if (window.google) {
      window.google.accounts.id.initialize({
        client_id: GOOGLE_CLIENT_ID,
        callback: handleGoogleCallback,
      })
      setGoogleInitialized(true)
    }
  }
  
  const handleGoogleCallback = async (response: any) => {
    try {
      // Send the ID token to our API for verification
      const result = await fetch('https://api.ufobeep.com/users/auth/google', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          token: response.credential,
          device_id: 'web_' + Date.now(),
          platform: 'web'
        }),
      })

      const data = await result.json()

      if (result.ok) {
        // Store auth data
        localStorage.setItem('auth_token', data.access_token)
        localStorage.setItem('user_data', JSON.stringify(data.user))
        setUser(data.user)
      } else {
        console.error('Google login failed:', data.detail)
      }
    } catch (error) {
      console.error('Google login error:', error)
    }
  }

  const login = async (email: string): Promise<{ success: boolean; message: string }> => {
    try {
      const response = await fetch('https://api.ufobeep.com/auth/magic/start', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email }),
      })

      const data = await response.json()

      if (response.ok) {
        return {
          success: true,
          message: 'Magic link sent! Check your email and click the link to complete login.'
        }
      } else {
        return {
          success: false,
          message: data.detail || 'Failed to send magic link'
        }
      }
    } catch (error) {
      return {
        success: false,
        message: 'Network error. Please try again.'
      }
    }
  }

  const logout = () => {
    localStorage.removeItem('auth_token')
    localStorage.removeItem('user_data')
    setUser(null)
  }

  const getAuthToken = (): string | null => {
    return localStorage.getItem('auth_token')
  }

  // Function to complete magic link authentication (called from magic link completion page)
  const loginWithGoogle = async (): Promise<{ success: boolean; message: string }> => {
    if (!googleInitialized || !window.google) {
      return {
        success: false,
        message: 'Google OAuth not initialized. Please refresh and try again.'
      }
    }
    
    try {
      // Prompt for Google login
      window.google.accounts.id.prompt()
      return {
        success: true,
        message: 'Please complete Google login in the popup.'
      }
    } catch (error) {
      return {
        success: false,
        message: 'Failed to start Google login.'
      }
    }
  }
  
  const loginWithApple = async (): Promise<{ success: boolean; message: string }> => {
    try {
      // Load Apple Sign-In JS SDK if not already loaded
      if (!window.AppleID && !document.getElementById('apple-signin-script')) {
        const script = document.createElement('script')
        script.id = 'apple-signin-script'
        script.src = 'https://appleid.cdn-apple.com/appleauth/static/jsapi/appleid/1/en_US/appleid.auth.js'
        script.async = true
        document.head.appendChild(script)
        
        // Wait for script to load
        await new Promise((resolve) => {
          script.onload = resolve
        })
      }
      
      if (window.AppleID) {
        window.AppleID.auth.init({
          clientId: 'com.ufobeep', // Your Apple service identifier
          scope: 'name email',
          redirectURI: 'https://ufobeep.com/auth/apple/callback',
          state: 'web_login',
          usePopup: true
        })
        
        const response = await window.AppleID.auth.signIn()
        
        // Send the authorization code to our API
        const result = await fetch('https://api.ufobeep.com/users/auth/apple', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            token: response.authorization.id_token,
            device_id: 'web_' + Date.now(),
            platform: 'web',
            user_id: response.user?.name ? JSON.stringify(response.user) : undefined
          }),
        })

        const data = await result.json()

        if (result.ok) {
          // Store auth data
          localStorage.setItem('auth_token', data.access_token)
          localStorage.setItem('user_data', JSON.stringify(data.user))
          setUser(data.user)
          return {
            success: true,
            message: 'Successfully logged in with Apple!'
          }
        } else {
          return {
            success: false,
            message: data.detail || 'Apple login failed'
          }
        }
      } else {
        return {
          success: false,
          message: 'Apple Sign-In not available. Please try email login or Google.'
        }
      }
    } catch (error: any) {
      console.error('Apple login error:', error)
      if (error.error === 'popup_closed_by_user') {
        return {
          success: false,
          message: 'Apple login cancelled.'
        }
      }
      return {
        success: false,
        message: 'Apple login failed. Please try again.'
      }
    }
  }
  
  const completeMagicAuth = async (code: string): Promise<{ success: boolean; message: string }> => {
    try {
      const response = await fetch('https://api.ufobeep.com/auth/magic/exchange', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ code }),
      })

      const data = await response.json()

      if (response.ok) {
        // Store auth data
        localStorage.setItem('auth_token', data.access_token)
        localStorage.setItem('user_data', JSON.stringify(data.user))
        setUser(data.user)

        return {
          success: true,
          message: 'Successfully logged in!'
        }
      } else {
        return {
          success: false,
          message: data.detail || 'Failed to complete login'
        }
      }
    } catch (error) {
      return {
        success: false,
        message: 'Network error. Please try again.'
      }
    }
  }

  // Make completeMagicAuth available globally for magic link completion
  useEffect(() => {
    (window as any).completeMagicAuth = completeMagicAuth
  }, [])

  const value: AuthContextType = {
    user,
    isAuthenticated: !!user,
    isLoading,
    login,
    loginWithGoogle,
    loginWithApple,
    logout,
    getAuthToken,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}