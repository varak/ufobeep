import { redirect } from 'next/navigation'

export default function BeepPage() {
  // Default locale redirect
  redirect('/beep/en')
}