'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { useState } from 'react'
import { useAuth } from '@/contexts/AuthContext'
import LanguageSwitcher from '@/components/LanguageSwitcher'
import { useClientTranslations } from '@/hooks/useClientTranslations'

function NavLink({ href, label }: { href: string; label: string }) {
  const pathname = usePathname()
  const active = pathname === href
  return (
    <Link
      href={href}
      className={`px-3 py-2 rounded-md text-sm font-medium transition-colors ${
        active
          ? 'text-white bg-brand-primary'
          : 'text-text-secondary hover:text-text-primary hover:bg-dark-surface-elevated'
      }`}
    >
      {label}
    </Link>
  )
}

export default function Header() {
  const { isAuthenticated, user, logout } = useAuth()
  const [open, setOpen] = useState(false)
  const { t } = useClientTranslations('common')

  return (
    <header className="sticky top-0 z-40 border-b border-dark-border bg-dark-background/85 backdrop-blur supports-[backdrop-filter]:bg-dark-background/60">
      <div className="max-w-6xl mx-auto px-4 md:px-6">
        <div className="flex h-14 items-center justify-between">
          {/* Left: Logo */}
          <div className="flex items-center gap-2">
            <Link href="/" className="flex items-center gap-2">
              <span className="text-xl">🛸</span>
              <span className="font-semibold text-text-primary">UFOBeep</span>
            </Link>
          </div>

          {/* Center: Nav (desktop) */}
          <nav className="hidden md:flex items-center gap-1">
            <NavLink href="/beep" label={t('navRecentBeeps') || 'Recent Beeps'} />
            <NavLink href="/map" label={t('navMap') || 'Map'} />
            <NavLink href="/download" label={t('navDownloadApp') || 'Download App'} />
          </nav>

          {/* Right: Language + Account */}
          <div className="hidden md:flex items-center gap-3">
            <LanguageSwitcher variant="minimal" />
            {isAuthenticated ? (
              <div className="flex items-center gap-2">
                <span className="text-sm text-text-secondary">{user?.username}</span>
                <button
                  className="text-xs text-text-tertiary hover:text-text-secondary"
                  onClick={logout}
                >
                  {t('logout', 'Logout')}
                </button>
              </div>
            ) : (
              <Link
                href="/auth"
                className="px-3 py-2 rounded-md text-sm font-medium text-text-secondary hover:text-text-primary hover:bg-dark-surface-elevated"
              >
                {t('signIn', 'Sign in')}
              </Link>
            )}
          </div>

          {/* Mobile menu button */}
          <button
            className="md:hidden px-2 py-1 text-text-secondary hover:text-text-primary"
            onClick={() => setOpen(!open)}
            aria-label="Toggle navigation"
          >
            ☰
          </button>
        </div>

        {/* Mobile menu */}
        {open && (
          <div className="md:hidden pb-3">
            <div className="flex flex-col gap-1">
              <NavLink href="/beep" label={t('navRecentBeeps', 'Recent Beeps')} />
              <NavLink href="/map" label={t('navMap', 'Map')} />
              <NavLink href="/download" label={t('navDownloadApp', 'Download App')} />
              <div className="px-1 py-2">
                <LanguageSwitcher variant="buttons" />
              </div>
              <div className="flex items-center justify-between px-1 py-2">
                {isAuthenticated ? (
                  <button
                    className="text-xs text-text-tertiary hover:text-text-secondary"
                    onClick={logout}
                  >
                    {t('logout', 'Logout')}
                  </button>
                ) : (
                  <Link
                    href="/auth"
                    className="text-sm text-text-secondary hover:text-text-primary"
                  >
                    {t('signIn', 'Sign in')}
                  </Link>
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    </header>
  )
}
