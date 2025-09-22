import type { Metadata } from 'next'
import './globals.css'
import { env } from '@/config/environment'
import GoogleAnalytics from '@/components/GoogleAnalytics'
import { AuthProvider } from '@/contexts/AuthContext'
import Header from '@/components/Header'

// Removed Inter from next/font/google to avoid build-time network fetch

export const metadata: Metadata = {
  title: {
    default: 'UFOBeep - Real-time UFO Sighting Alerts',
    template: '%s | UFOBeep'
  },
  description: 'Get instant alerts when UFOs are spotted near you. See exactly where to look and when. Download the app and never miss a UFO sighting again.',
  keywords: ['UFO', 'UFO beep', 'UFO app', 'sightings', 'alerts', 'anomaly', 'UAP', 'MUFON', 'location tracking', 'proximity alerts', 'community', 'reports', 'OVNI', 'UFO Warnung', 'UFO alerte', 'avistamiento', 'alertas', 'multilingual'],
  authors: [{ name: 'UFOBeep Team' }],
  creator: 'UFOBeep',
  publisher: 'UFOBeep',
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  metadataBase: new URL(env.siteUrl),
  alternates: {
    canonical: '/',
  },
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: env.siteUrl,
    title: 'UFOBeep - Real-time UFO Sighting Alerts',
    description: 'Get instant alerts when UFOs are spotted near you. See exactly where to look and when.',
    siteName: 'UFOBeep',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'UFOBeep - Real-time UFO Sighting Network',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'UFOBeep - Real-time UFO Sighting Alerts',
    description: 'Get instant alerts when UFOs are spotted near you. Download the app and never miss a UFO sighting again.',
    images: ['/twitter-image.png'],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  verification: {
    google: env.isDevelopment ? undefined : 'your-google-verification-code',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className="dark">
      <head>
        {/* Structured Data */}
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify({
              '@context': 'https://schema.org',
              '@type': 'WebSite',
              name: 'UFOBeep',
              description: 'Real-time UFO and anomaly sighting alerts with community verification',
              url: env.siteUrl,
              potentialAction: {
                '@type': 'SearchAction',
                target: {
                  '@type': 'EntryPoint',
                  urlTemplate: `${env.siteUrl}/search?q={search_term_string}`,
                },
                'query-input': 'required name=search_term_string',
              },
            }),
          }}
        />
        {/* Removed Google Fonts preconnects to avoid external dependency during build */}
      </head>
      <body className={`bg-dark-background text-text-primary min-h-screen`}>
        <GoogleAnalytics />
        <AuthProvider>
          <Header />
          {children}
        </AuthProvider>
      </body>
    </html>
  )
}
