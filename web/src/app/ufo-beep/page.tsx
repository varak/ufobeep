import type { Metadata } from 'next'
import { redirect } from 'next/navigation'

export const metadata: Metadata = {
  title: 'UFO Beep - Real-time UFO Alerts App',
  description: 'Get instant alerts when UFOs are spotted near you. UFO Beep shows you exactly where to look and when. Download now and never miss a UFO sighting.',
  keywords: ['UFO beep', 'UFO app', 'UFO alerts', 'UFO sightings', 'real time UFO', 'UFO notification app'],
  openGraph: {
    title: 'UFO Beep - Real-time UFO Alerts App',
    description: 'Get instant alerts when UFOs are spotted near you. Download UFO Beep and never miss a sighting.',
  },
  twitter: {
    title: 'UFO Beep - Real-time UFO Alerts App',
    description: 'Get instant alerts when UFOs are spotted near you. Download UFO Beep and never miss a sighting.',
  },
}

export default function UFOBeepPage() {
  // Redirect to main page with tracking
  redirect('/?ref=ufo-beep')
}