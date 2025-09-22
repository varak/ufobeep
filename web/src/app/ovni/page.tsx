import type { Metadata } from 'next'
import { redirect } from 'next/navigation'

export const metadata: Metadata = {
  title: 'OVNI Alertas - Aplicación de Alertas OVNI en Tiempo Real',
  description: 'Recibe alertas instantáneas cuando se avistan OVNIs cerca de ti. Ve exactamente dónde mirar y cuándo. Descarga la aplicación.',
  keywords: ['OVNI', 'alertas OVNI', 'avistamientos OVNI', 'aplicación OVNI', 'UFO España', 'alertas tiempo real'],
  openGraph: {
    title: 'OVNI Alertas - Aplicación de Alertas OVNI en Tiempo Real',
    description: 'Recibe alertas instantáneas cuando se avistan OVNIs cerca de ti. Descarga OVNI Alertas ahora.',
  },
  twitter: {
    title: 'OVNI Alertas - Aplicación de Alertas OVNI en Tiempo Real',
    description: 'Recibe alertas instantáneas cuando se avistan OVNIs cerca de ti. Descarga OVNI Alertas ahora.',
  },
}

export default function OVNIPage() {
  // Redirect to main page with Spanish tracking
  redirect('/?ref=ovni')
}