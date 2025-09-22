import type { Metadata } from 'next'
import { redirect } from 'next/navigation'

export const metadata: Metadata = {
  title: 'UFO App - Best UFO Sighting Alert App',
  description: 'The best UFO app for real-time sighting alerts. Get notified instantly when UFOs appear near you. Download the #1 UFO alert app.',
  keywords: ['UFO app', 'best UFO app', 'UFO sighting app', 'UFO alert app', 'UFO notification app', 'real time UFO app'],
  openGraph: {
    title: 'UFO App - Best UFO Sighting Alert App',
    description: 'The best UFO app for real-time sighting alerts. Download the #1 UFO alert app.',
  },
  twitter: {
    title: 'UFO App - Best UFO Sighting Alert App',
    description: 'The best UFO app for real-time sighting alerts. Download the #1 UFO alert app.',
  },
}

export default function UFOAppPage() {
  // Redirect to main page with app keyword tracking
  redirect('/?ref=ufo-app')
}