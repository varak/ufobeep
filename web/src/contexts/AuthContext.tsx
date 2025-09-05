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
  renderGoogleButton: (containerId: string) => boolean
  renderAppleButton: (containerId: string) => boolean
  googleInitialized: boolean
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
            auto_select: false,
            cancel_on_tap_outside: false,
          })
          setGoogleInitialized(true)
        }
      }
      document.head.appendChild(script)
    } else if (window.google) {
      window.google.accounts.id.initialize({
        client_id: GOOGLE_CLIENT_ID,
        callback: handleGoogleCallback,
        auto_select: false,
        cancel_on_tap_outside: false,
      })
      setGoogleInitialized(true)
    }
  }
  
  const handleGoogleCallback = async (response: any) => {
    console.log('Google callback triggered:', response)
    
    // Store the current URL as the return URL for after login (if not already stored)
    if (typeof window !== 'undefined' && !localStorage.getItem('auth_return_url')) {
      localStorage.setItem('auth_return_url', window.location.href)
    }
    
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
      console.log('API response:', data)

      if (result.ok) {
        // Store auth data
        localStorage.setItem('auth_token', data.access)
        localStorage.setItem('user_data', JSON.stringify(data.user))
        setUser(data.user)
        console.log('User logged in successfully:', data.user)
        
        // Get the return URL and redirect there, or reload if no return URL
        const returnUrl = localStorage.getItem('auth_return_url')
        localStorage.removeItem('auth_return_url')
        
        if (returnUrl) {
          // Redirect back to where the user was trying to go
          window.location.href = returnUrl
        } else {
          // Force a page refresh or state update to show logged-in state
          window.location.reload()
        }
      } else {
        console.error('Google login failed:', data.detail)
        alert('Login failed: ' + (data.detail || 'Please try again'))
      }
    } catch (error) {
      console.error('Google login error:', error)
      alert('Network error during login. Please try again.')
    }
  }

  const login = async (email: string): Promise<{ success: boolean; message: string }> => {
    // Store the current URL as the return URL for after login
    if (typeof window !== 'undefined') {
      localStorage.setItem('auth_return_url', window.location.href)
    }
    
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
  const renderGoogleButton = (containerId: string) => {
    if (!googleInitialized || !window.google) {
      return false
    }
    
    try {
      // Clear any existing content
      const container = document.getElementById(containerId)
      if (!container) return false
      
      container.innerHTML = ''
      
      // Render Google Sign-In button with proper callback handling
      window.google.accounts.id.renderButton(
        container,
        {
          theme: 'outline',
          size: 'large',
          width: '100%',
          text: 'continue_with',
          shape: 'rectangular',
          type: 'standard',
          callback: handleGoogleCallback
        }
      )
      
      // Also show One Tap if user hasn't dismissed it recently
      window.google.accounts.id.prompt((notification: any) => {
        if (notification.isNotDisplayed()) {
          console.log('One Tap was not displayed:', notification.getNotDisplayedReason())
        } else if (notification.isSkippedMoment()) {
          console.log('One Tap was skipped:', notification.getSkippedReason())
        }
      })
      
      return true
    } catch (error) {
      console.error('Failed to render Google button:', error)
      return false
    }
  }
  
  const loginWithGoogle = async (): Promise<{ success: boolean; message: string }> => {
    // This method is now just for compatibility - actual login happens via rendered button
    if (!googleInitialized || !window.google) {
      return {
        success: false,
        message: 'Google OAuth not initialized. Please refresh and try again.'
      }
    }
    
    return {
      success: true,
      message: 'Please use the Google sign-in button above.'
    }
  }
  
  const handleAppleLogin = async (response: any) => {
    console.log('Apple callback triggered:', response)
    
    // Store the current URL as the return URL for after login (if not already stored)
    if (typeof window !== 'undefined' && !localStorage.getItem('auth_return_url')) {
      localStorage.setItem('auth_return_url', window.location.href)
    }
    
    try {
      // Send the authorization response to our API
      const result = await fetch('https://api.ufobeep.com/users/auth/apple', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          token: response.authorization.id_token,
          device_id: 'web_' + Date.now(),
          platform: 'web'
        }),
      })

      const data = await result.json()
      console.log('Apple API response:', data)

      if (result.ok) {
        // Store auth data
        localStorage.setItem('auth_token', data.access)
        localStorage.setItem('user_data', JSON.stringify(data.user))
        setUser(data.user)
        console.log('Apple user logged in successfully:', data.user)
        
        // Get the return URL and redirect there, or reload if no return URL
        const returnUrl = localStorage.getItem('auth_return_url')
        localStorage.removeItem('auth_return_url')
        
        if (returnUrl) {
          // Redirect back to where the user was trying to go
          window.location.href = returnUrl
        } else {
          // Force a page refresh or state update to show logged-in state
          window.location.reload()
        }
      } else {
        console.error('Apple login failed:', data.detail)
        alert('Apple login failed: ' + (data.detail || 'Please try again'))
      }
    } catch (error) {
      console.error('Apple login error:', error)
      alert('Network error during Apple login. Please try again.')
    }
  }
  
  const renderAppleButton = (containerId: string) => {
    // Load Apple Sign-In JS SDK if not already loaded
    if (!window.AppleID && !document.getElementById('apple-signin-script')) {
      const script = document.createElement('script')
      script.id = 'apple-signin-script'
      script.src = 'https://appleid.cdn-apple.com/appleauth/static/jsapi/appleid/1/en_US/appleid.auth.js'
      script.async = true
      script.onload = () => {
        if (window.AppleID) {
          console.log('Apple ID SDK loaded successfully')
          
          window.AppleID.auth.init({
            clientId: 'com.ufobeep',
            scope: 'name email',
            redirectURI: 'https://ufobeep.com',
            state: 'web_login',
            usePopup: true  // Use popup instead of redirect
          })
          
          // Set up event listeners first
          document.addEventListener('AppleIDSignInOnSuccess', (event: any) => {
            console.log('Apple Sign-In Success Event:', event)
            handleAppleLogin(event.detail)
          })
          
          document.addEventListener('AppleIDSignInOnFailure', (event: any) => {
            console.error('Apple Sign-In failed:', event.detail)
            alert('Apple Sign-In failed: ' + (event.detail.error || 'Please try again'))
          })
          
          // Render the Apple Sign-In button
          const container = document.getElementById(containerId)
          if (container) {
            container.innerHTML = `
              <div id="appleid-signin" 
                   data-color="black" 
                   data-border="true" 
                   data-type="continue" 
                   data-width="100%" 
                   data-height="44"
                   style="width: 100%; height: 44px; cursor: pointer;">
              </div>
            `
            console.log('Apple Sign-In button HTML rendered in container:', containerId)
            
            // Actually render the Apple button after DOM update
            setTimeout(() => {
              if (window.AppleID && window.AppleID.auth) {
                try {
                  window.AppleID.auth.renderButton()
                  console.log('Apple Sign-In button activated successfully')
                } catch (error) {
                  console.error('Error activating Apple Sign-In button:', error)
                }
              }
            }, 100)
          }
        }
      }
      script.onerror = () => {
        console.error('Failed to load Apple ID SDK')
      }
      document.head.appendChild(script)
      return true
    } else if (window.AppleID) {
      // Apple SDK already loaded, just render button
      const container = document.getElementById(containerId)
      if (container) {
        container.innerHTML = `
          <div id="appleid-signin" 
               data-color="black" 
               data-border="true" 
               data-type="continue" 
               data-width="100%" 
               data-height="44"
               style="width: 100%; height: 44px; cursor: pointer;">
          </div>
        `
        console.log('Apple Sign-In button HTML re-rendered in container:', containerId)
        
        // Actually render the Apple button after DOM update
        setTimeout(() => {
          if (window.AppleID && window.AppleID.auth) {
            try {
              window.AppleID.auth.renderButton()
              console.log('Apple Sign-In button re-activated successfully')
            } catch (error) {
              console.error('Error re-activating Apple Sign-In button:', error)
            }
          }
        }, 100)
      }
      return true
    }
    return false
  }
  
  const loginWithApple = async (): Promise<{ success: boolean; message: string }> => {
    // This method is now just for compatibility - actual login happens via rendered button
    return {
      success: true,
      message: 'Please use the Apple sign-in button above.'
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
        localStorage.setItem('auth_token', data.access)
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
    renderGoogleButton,
    renderAppleButton,
    googleInitialized,
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