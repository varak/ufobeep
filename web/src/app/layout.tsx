import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { env } from '@/config/environment'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: {
    default: 'UFOBeep - Real-time UFO Sighting Alerts',
    template: '%s | UFOBeep'
  },
  description: 'Real-time UFO and anomaly sighting alerts with AR compass navigation, encrypted chat, and community verification. Report sightings, get instant notifications, and join the global network.',
  keywords: ['UFO', 'sightings', 'alerts', 'anomaly', 'UAP', 'compass', 'navigation', 'community', 'reports'],
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
    languages: {
      'en-US': '/en',
      'es-ES': '/es', 
      'de-DE': '/de',
    },
  },
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: env.siteUrl,
    title: 'UFOBeep - Real-time UFO Sighting Alerts',
    description: 'Real-time UFO and anomaly sighting alerts with AR compass navigation, encrypted chat, and community verification.',
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
    description: 'Report sightings, get instant alerts, navigate with AR compass. Join the global UFO sighting network.',
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
        {/* Preconnect to external domains */}
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
      </head>
      <body className={`${inter.className} bg-dark-background text-text-primary min-h-screen`}>
        {children}
      </body>
    </html>
  )
}