import { NextApiRequest, NextApiResponse } from 'next'
import { EmailSignupService, EmailSignup } from '../../lib/email-signup'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  const { email } = req.body

  if (!email || !EmailSignupService.isValidEmail(email)) {
    return res.status(400).json({ error: 'Valid email address required' })
  }

  try {
    // Check if email is already subscribed (optional)
    const isAlreadySubscribed = await EmailSignupService.isEmailSubscribed(email)
    if (isAlreadySubscribed) {
      return res.status(200).json({ 
        success: true, 
        message: "You're already signed up! We'll notify you when the app is ready." 
      })
    }

    // Create signup record
    const signup: EmailSignup = {
      email: email.toLowerCase().trim(),
      timestamp: new Date().toISOString(),
      source: 'app-page',
      userAgent: req.headers['user-agent'],
      referrer: req.headers['referer']
    }

    // Save to all configured backends
    await EmailSignupService.saveSignup(signup)

    console.log(`New email signup processed: ${email}`)

    return res.status(200).json({ 
      success: true, 
      message: "Thanks! We'll notify you when the UFOBeep app is ready for download." 
    })
    
  } catch (error) {
    console.error('Email signup error:', error)
    return res.status(500).json({ 
      error: 'Something went wrong. Please try again later.' 
    })
  }
}