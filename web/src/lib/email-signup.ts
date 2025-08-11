// Email signup utilities for production integration

export interface EmailSignup {
  email: string
  timestamp: string
  source: 'app-page' | 'homepage' | 'other'
  userAgent?: string
  referrer?: string
}

export class EmailSignupService {
  /**
   * Save email signup to various backends
   */
  static async saveSignup(signup: EmailSignup): Promise<void> {
    const promises = []

    // 1. Save to file system (development/fallback)
    promises.push(this.saveToFile(signup))

    // 2. Save to database (production)
    if (process.env.DATABASE_URL) {
      promises.push(this.saveToDatabase(signup))
    }

    // 3. Send to email service (production)
    if (process.env.SENDGRID_API_KEY || process.env.MAILCHIMP_API_KEY) {
      promises.push(this.sendToEmailService(signup))
    }

    // 4. Send to webhook (if configured)
    if (process.env.EMAIL_SIGNUP_WEBHOOK_URL) {
      promises.push(this.sendToWebhook(signup))
    }

    await Promise.allSettled(promises)
  }

  /**
   * Save to file system (fallback method)
   */
  private static async saveToFile(signup: EmailSignup): Promise<void> {
    try {
      const fs = require('fs').promises
      const path = require('path')
      
      const dataDir = path.join(process.cwd(), 'data')
      await fs.mkdir(dataDir, { recursive: true })
      
      const signupsFile = path.join(dataDir, 'email-signups.jsonl')
      const entry = JSON.stringify(signup) + '\n'
      
      await fs.appendFile(signupsFile, entry)
      console.log(`Email signup saved to file: ${signup.email}`)
    } catch (error) {
      console.error('Error saving email signup to file:', error)
    }
  }

  /**
   * Save to database (production method)
   */
  private static async saveToDatabase(signup: EmailSignup): Promise<void> {
    try {
      // This would integrate with your actual database
      // For now, just log that it would be saved
      console.log(`Would save to database: ${signup.email}`)
      
      // Example implementation:
      // const { Pool } = require('pg')
      // const pool = new Pool({ connectionString: process.env.DATABASE_URL })
      // 
      // await pool.query(
      //   'INSERT INTO email_signups (email, timestamp, source, user_agent, referrer) VALUES ($1, $2, $3, $4, $5)',
      //   [signup.email, signup.timestamp, signup.source, signup.userAgent, signup.referrer]
      // )
    } catch (error) {
      console.error('Error saving email signup to database:', error)
    }
  }

  /**
   * Send to email service (SendGrid, Mailchimp, etc.)
   */
  private static async sendToEmailService(signup: EmailSignup): Promise<void> {
    try {
      if (process.env.SENDGRID_API_KEY) {
        await this.sendToSendGrid(signup)
      } else if (process.env.MAILCHIMP_API_KEY) {
        await this.sendToMailchimp(signup)
      }
    } catch (error) {
      console.error('Error sending to email service:', error)
    }
  }

  /**
   * SendGrid integration
   */
  private static async sendToSendGrid(signup: EmailSignup): Promise<void> {
    try {
      const sgMail = require('@sendgrid/mail')
      sgMail.setApiKey(process.env.SENDGRID_API_KEY)

      // Add to SendGrid contacts list
      const request = {
        method: 'POST',
        url: '/v3/marketing/contacts',
        body: {
          contacts: [
            {
              email: signup.email,
              custom_fields: {
                signup_source: signup.source,
                signup_timestamp: signup.timestamp
              }
            }
          ],
          list_ids: [process.env.SENDGRID_LIST_ID || ''] // Configure your list ID
        }
      }

      await sgMail.request(request)
      console.log(`Email added to SendGrid: ${signup.email}`)

      // Optionally send welcome email
      if (process.env.SEND_WELCOME_EMAIL === 'true') {
        await this.sendWelcomeEmail(signup.email)
      }
    } catch (error) {
      console.error('SendGrid error:', error)
    }
  }

  /**
   * Mailchimp integration
   */
  private static async sendToMailchimp(signup: EmailSignup): Promise<void> {
    try {
      // Mailchimp integration would go here
      console.log(`Would add to Mailchimp: ${signup.email}`)
    } catch (error) {
      console.error('Mailchimp error:', error)
    }
  }

  /**
   * Send to custom webhook
   */
  private static async sendToWebhook(signup: EmailSignup): Promise<void> {
    try {
      const response = await fetch(process.env.EMAIL_SIGNUP_WEBHOOK_URL!, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${process.env.EMAIL_SIGNUP_WEBHOOK_TOKEN || ''}`
        },
        body: JSON.stringify(signup)
      })

      if (response.ok) {
        console.log(`Email signup sent to webhook: ${signup.email}`)
      } else {
        console.error('Webhook failed:', response.status, response.statusText)
      }
    } catch (error) {
      console.error('Webhook error:', error)
    }
  }

  /**
   * Send welcome email
   */
  private static async sendWelcomeEmail(email: string): Promise<void> {
    try {
      const sgMail = require('@sendgrid/mail')
      
      const msg = {
        to: email,
        from: process.env.FROM_EMAIL || 'noreply@ufobeep.com',
        subject: '🛸 Thanks for signing up for UFOBeep!',
        html: `
          <div style="max-width: 600px; margin: 0 auto; font-family: Arial, sans-serif;">
            <div style="text-align: center; padding: 40px 20px;">
              <div style="font-size: 60px; margin-bottom: 20px;">🛸</div>
              <h1 style="color: #2563eb; margin-bottom: 20px;">Welcome to UFOBeep!</h1>
              
              <p style="font-size: 18px; color: #374151; margin-bottom: 30px;">
                Thanks for signing up to be notified when the UFOBeep mobile app launches!
              </p>
              
              <div style="background: #f3f4f6; padding: 20px; border-radius: 8px; margin-bottom: 30px;">
                <h3 style="color: #1f2937; margin-bottom: 15px;">What to expect:</h3>
                <ul style="text-align: left; color: #4b5563;">
                  <li>📱 Instant UFO sighting alerts in your area</li>
                  <li>📸 Quick photo/video reporting with GPS</li>
                  <li>🧭 AR compass navigation to incident locations</li>
                  <li>💬 Secure community chat for each sighting</li>
                  <li>🔒 Privacy-first with location jittering</li>
                </ul>
              </div>
              
              <p style="color: #6b7280; font-size: 14px;">
                We'll only email you when the app is ready to download.<br>
                No spam, ever. You can unsubscribe at any time.
              </p>
              
              <div style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #e5e7eb;">
                <p style="color: #9ca3af; font-size: 12px;">
                  UFOBeep - Citizen Science for Anomaly Investigation<br>
                  <a href="https://ufobeep.com" style="color: #2563eb;">ufobeep.com</a>
                </p>
              </div>
            </div>
          </div>
        `
      }

      await sgMail.send(msg)
      console.log(`Welcome email sent to: ${email}`)
    } catch (error) {
      console.error('Error sending welcome email:', error)
    }
  }

  /**
   * Validate email address
   */
  static isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email)
  }

  /**
   * Check if email is already subscribed (to prevent duplicates)
   */
  static async isEmailSubscribed(email: string): Promise<boolean> {
    try {
      // This would check your database or email service
      // For now, just return false (allow all signups)
      return false
    } catch (error) {
      console.error('Error checking email subscription:', error)
      return false
    }
  }
}