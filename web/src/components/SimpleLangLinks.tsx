'use client'

/**
 * Simple Language Links Component
 * 
 * Safe, lightweight language switching without complex state management.
 * Shows popular languages as direct links to avoid crashes.
 */

import { usePathname } from 'next/navigation'

const POPULAR_LANGUAGES = [
  { code: 'en', name: 'English', flag: '🇺🇸' },
  { code: 'es', name: 'Español', flag: '🇪🇸' },
  { code: 'de', name: 'Deutsch', flag: '🇩🇪' },
  { code: 'fr', name: 'Français', flag: '🇫🇷' },
  { code: 'ru', name: 'Русский', flag: '🇷🇺' },
  { code: 'ja', name: '日本語', flag: '🇯🇵' },
  { code: 'zh', name: '中文', flag: '🇨🇳' },
  { code: 'pt', name: 'Português', flag: '🇵🇹' },
]

interface SimpleLangLinksProps {
  className?: string
  showAllLink?: boolean
}

export default function SimpleLangLinks({ className = '', showAllLink = true }: SimpleLangLinksProps) {
  const pathname = usePathname() || ''
  
  // Extract current path without language prefix
  const getCurrentPath = () => {
    const segments = pathname.split('/').filter(Boolean)
    const langCodes = POPULAR_LANGUAGES.map(l => l.code)
    
    if (segments.length > 0 && langCodes.includes(segments[0])) {
      return '/' + segments.slice(1).join('/')
    }
    return pathname || '/'
  }
  
  // Determine current language
  const getCurrentLang = () => {
    const segments = pathname.split('/').filter(Boolean)
    const langCodes = POPULAR_LANGUAGES.map(l => l.code)
    
    if (segments.length > 0 && langCodes.includes(segments[0])) {
      return segments[0]
    }
    return 'en'
  }
  
  const currentPath = getCurrentPath()
  const currentLang = getCurrentLang()
  
  const buildLangUrl = (langCode: string) => {
    if (langCode === 'en') {
      return currentPath
    }
    return `/${langCode}${currentPath}`
  }
  
  return (
    <div className={`flex flex-wrap items-center gap-2 text-xs ${className}`}>
      <span className="text-text-tertiary">🌐</span>
      {POPULAR_LANGUAGES.map((lang) => {
        const isActive = currentLang === lang.code
        const url = buildLangUrl(lang.code)
        
        return (
          <a
            key={lang.code}
            href={url}
            className={`
              px-2 py-1 rounded text-xs transition-colors
              ${isActive 
                ? 'bg-brand-primary text-white font-medium' 
                : 'text-text-secondary hover:text-text-primary hover:bg-dark-surface-elevated'
              }
            `}
            title={`Switch to ${lang.name}`}
          >
            {lang.flag} {lang.code.toUpperCase()}
          </a>
        )
      })}
      
      {showAllLink && (
        <div className="text-text-tertiary text-xs ml-2">
          + 14 more languages
        </div>
      )}
    </div>
  )
}

// Safe usage guide for footer or anywhere that needs language switching
export function LanguageFooter() {
  return (
    <div className="border-t border-dark-border pt-4 mt-8">
      <div className="text-center">
        <div className="text-sm text-text-secondary mb-2">
          UFOBeep supports 22 languages worldwide
        </div>
        <SimpleLangLinks className="justify-center" />
        <div className="text-xs text-text-tertiary mt-2">
          Also available: Arabic, Italian, Korean, Turkish, Hindi, Polish, Czech, 
          Dutch, Swedish, Danish, Norwegian, Finnish, Greek, Hebrew
        </div>
      </div>
    </div>
  )
}