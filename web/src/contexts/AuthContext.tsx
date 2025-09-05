'use client'

import { createContext, useContext, useState, useEffect, ReactNode } from 'react'

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
  logout: () => void
  getAuthToken: () => string | null
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(true)

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
    
    setIsLoading(false)
  }, [])

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