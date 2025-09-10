'use client'

import React, { useState, useRef, useEffect } from 'react'
import { usePathname, useRouter, useSearchParams } from 'next/navigation'
import { useTranslation } from 'next-i18next';
import { supportedLocales, getLocaleDisplayName } from '../config/locales';

interface LanguageSwitcherProps {
  className?: string;
  showLabel?: boolean;
  variant?: 'dropdown' | 'buttons' | 'minimal';
}

export function LanguageSwitcher({
  className = '',
  showLabel = false,
  variant = 'dropdown',
}: LanguageSwitcherProps) {
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()
  const { t, i18n } = useTranslation('navigation');
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);
  
  // Determine current locale from pathname 
  const path = pathname || '/'
  const segs = path.split('/').filter(Boolean)
  let currentLocale = 'en'
  
  if (path.startsWith('/beep/') && segs.length >= 2) {
    // New beep URL structure: /beep/[locale]/...
    if (Object.keys(supportedLocales).includes(segs[1])) {
      currentLocale = segs[1]
    }
  } else {
    // Traditional locale prefix: /es/... or /...
    if (segs.length && Object.keys(supportedLocales).includes(segs[0])) {
      currentLocale = segs[0]
    }
  }
  const supportedLocaleCodes = Object.keys(supportedLocales);
  
  // Close dropdown when clicking outside
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    }
    
    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
      return () => document.removeEventListener('mousedown', handleClickOutside);
    }
  }, [isOpen]);
  
  // Handle keyboard navigation
  useEffect(() => {
    function handleKeyDown(event: KeyboardEvent) {
      if (event.key === 'Escape') {
        setIsOpen(false);
      }
    }
    
    if (isOpen) {
      document.addEventListener('keydown', handleKeyDown);
      return () => document.removeEventListener('keydown', handleKeyDown);
    }
  }, [isOpen]);
  
  const handleLanguageChange = async (locale: string) => {
    setIsOpen(false)
    // Persist preference
    if (typeof window !== 'undefined') {
      localStorage.setItem('preferred-language', locale)
      document.cookie = `NEXT_LOCALE=${locale}; path=/; max-age=31536000; SameSite=Lax`
    }
    
    const qs = searchParams?.toString()
    let targetPath = pathname || '/'
    
    // Handle the new beep URL structure: /beep/[locale]/... 
    if (targetPath.startsWith('/beep/')) {
      const parts = targetPath.split('/').filter(Boolean) // ['beep', 'locale', ...]
      if (parts.length >= 2 && supportedLocaleCodes.includes(parts[1])) {
        // Replace existing locale: /beep/en/... -> /beep/es/...
        parts[1] = locale
        targetPath = '/' + parts.join('/')
      } else if (parts.length === 1) {
        // Add locale to bare /beep -> /beep/es
        targetPath = `/beep/${locale}`
      } else {
        // Fallback: add locale after /beep/
        targetPath = `/beep/${locale}`
      }
    } else {
      // Handle other paths with traditional locale prefix
      const parts = targetPath.split('/').filter(Boolean)
      // Strip any existing locale prefix
      if (parts.length && supportedLocaleCodes.includes(parts[0])) {
        parts.shift()
        targetPath = '/' + parts.join('/')
      }
      // Apply locale prefix for non-English
      targetPath = locale === 'en' ? targetPath : `/${locale}${targetPath}`
    }
    
    router.push(qs ? `${targetPath}?${qs}` : targetPath)
  }
  
  if (variant === 'buttons') {
    return (
      <div className={`flex gap-1 ${className}`} role="group" aria-label={t('language')}>
        {showLabel && (
          <span className="text-sm text-gray-600 dark:text-gray-400 mr-2">
            {t('language')}:
          </span>
        )}
        {supportedLocaleCodes.map((locale) => (
          <button
            key={locale}
            onClick={() => handleLanguageChange(locale)}
            className={`
              px-2 py-1 text-sm rounded transition-colors
              ${currentLocale === locale
                ? 'bg-blue-600 text-white'
                : 'bg-gray-200 text-gray-700 hover:bg-gray-300 dark:bg-gray-700 dark:text-gray-300 dark:hover:bg-gray-600'
              }
            `}
            aria-pressed={currentLocale === locale}
            aria-label={`${t('language')}: ${getLocaleDisplayName(locale)}`}
          >
            {supportedLocales[locale].flag}
          </button>
        ))}
      </div>
    );
  }
  
  if (variant === 'minimal') {
    return (
      <div className={`flex items-center gap-2 ${className}`}>
        {showLabel && (
          <span className="text-sm text-gray-600 dark:text-gray-400">
            {t('language')}:
          </span>
        )}
        <select
          value={currentLocale}
          onChange={(e) => handleLanguageChange(e.target.value)}
          className="
            text-sm bg-transparent border-none outline-none cursor-pointer
            text-gray-700 dark:text-gray-300
            focus:ring-2 focus:ring-blue-500 rounded
          "
          aria-label={t('language')}
        >
          {supportedLocaleCodes.map((locale) => (
            <option key={locale} value={locale}>
              {supportedLocales[locale].flag} {supportedLocales[locale].nativeName}
            </option>
          ))}
        </select>
      </div>
    );
  }
  
  // Default dropdown variant
  return (
    <div className={`relative ${className}`} ref={dropdownRef}>
      {showLabel && (
        <span className="text-sm text-gray-600 dark:text-gray-400 mr-2">
          {t('language')}:
        </span>
      )}
      
      <button
        onClick={() => setIsOpen(!isOpen)}
        onKeyDown={(e) => {
          if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            setIsOpen(!isOpen);
          }
        }}
        className="
          flex items-center gap-2 px-3 py-2 text-sm
          bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600
          rounded-md shadow-sm cursor-pointer transition-colors
          hover:bg-gray-50 dark:hover:bg-gray-700
          focus:ring-2 focus:ring-blue-500 focus:border-blue-500
          text-gray-700 dark:text-gray-300
        "
        aria-expanded={isOpen}
        aria-haspopup="listbox"
        aria-label={`${t('language')}: ${getLocaleDisplayName(currentLocale)}`}
      >
        <span className="flex items-center gap-2">
          <span>{supportedLocales[currentLocale].flag}</span>
          <span className="hidden sm:inline">
            {supportedLocales[currentLocale].nativeName}
          </span>
        </span>
        
        <svg
          className={`w-4 h-4 transition-transform ${isOpen ? 'rotate-180' : ''}`}
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          aria-hidden="true"
        >
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
        </svg>
      </button>
      
      {isOpen && (
        <div
          className="
            absolute right-0 z-50 mt-1 w-48
            bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600
            rounded-md shadow-lg overflow-hidden
            ring-1 ring-black ring-opacity-5
          "
          role="listbox"
          aria-label={t('language')}
        >
          {supportedLocaleCodes.map((locale) => (
            <button
              key={locale}
              onClick={() => handleLanguageChange(locale)}
              className={`
                w-full text-left px-4 py-3 text-sm transition-colors
                flex items-center gap-3
                ${currentLocale === locale
                  ? 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300'
                  : 'text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700'
                }
              `}
              role="option"
              aria-selected={currentLocale === locale}
            >
              <span>{supportedLocales[locale].flag}</span>
              <div className="flex flex-col">
                <span className="font-medium">
                  {supportedLocales[locale].nativeName}
                </span>
                <span className="text-xs text-gray-500 dark:text-gray-400">
                  {supportedLocales[locale].name}
                </span>
              </div>
              {currentLocale === locale && (
                <svg
                  className="ml-auto w-4 h-4 text-blue-600 dark:text-blue-400"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                  aria-hidden="true"
                >
                  <path
                    fillRule="evenodd"
                    d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                    clipRule="evenodd"
                  />
                </svg>
              )}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

// Locale detection hook
export function useLocaleDetection() {
  const router = useRouter()

  useEffect(() => {
    if (typeof window === 'undefined') return
    const storedLocale = localStorage.getItem('preferred-language')
    const cookieLocale = document.cookie
      .split('; ')
      .find(row => row.startsWith('NEXT_LOCALE='))
      ?.split('=')[1]
    const preferred = storedLocale || cookieLocale
    const codes = Object.keys(supportedLocales)
    if (!preferred || !codes.includes(preferred)) return

    const path = window.location.pathname
    const parts = path.split('/').filter(Boolean)
    const current = parts.length && codes.includes(parts[0]) ? parts[0] : 'en'
    if (preferred === current) return

    // Strip existing prefix
    if (parts.length && codes.includes(parts[0])) parts.shift()
    const bare = '/' + parts.join('/')
    const target = preferred === 'en' ? bare : `/${preferred}${bare}`
    router.push(target + window.location.search)
  }, [])
}

// Component to handle locale detection on app initialization
export function LocaleDetector() {
  useLocaleDetection();
  return null;
}

export default LanguageSwitcher;
