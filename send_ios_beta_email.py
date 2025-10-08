#!/usr/bin/env python3
"""
Send iOS beta availability email to testers
"""
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.utils import formatdate
import secrets

def send_ios_notification(to_email: str):
    """Send iOS beta notification email via Postfix"""

    from_email = "support@ufobeep.com"
    from_name = "UFOBeep"
    subject = "🍎 UFOBeep iOS Beta Now Available on TestFlight!"

    html_body = """
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            body {
                font-family: Arial, sans-serif;
                background: #f5f5f5;
                color: #333333;
                margin: 0;
                padding: 0;
            }
            .container {
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
                background: #f5f5f5;
            }
            .header {
                text-align: center;
                padding: 20px 0;
            }
            .content {
                background: #ffffff;
                padding: 40px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                border: 1px solid #e0e0e0;
            }
            .button {
                display: inline-block;
                padding: 15px 30px;
                background: #007AFF;
                color: #ffffff;
                text-decoration: none;
                border-radius: 8px;
                font-weight: bold;
                font-size: 16px;
                margin: 20px 0;
                box-shadow: 0 2px 5px rgba(0,122,255,0.3);
            }
            .button:hover {
                background: #0051D5;
            }
            .android-button {
                display: inline-block;
                padding: 12px 24px;
                background: #4CAF50;
                color: white;
                text-decoration: none;
                border-radius: 8px;
                font-weight: bold;
                margin: 10px 0;
            }
            .android-button:hover {
                background: #45a049;
            }
            .footer {
                text-align: center;
                margin-top: 30px;
                color: #666;
                font-size: 14px;
            }
            h1 {
                color: #333;
                margin: 0;
                font-size: 32px;
            }
            h2 {
                color: #333;
                margin-bottom: 20px;
                font-size: 24px;
            }
            h3 {
                color: #333;
                margin-top: 30px;
                font-size: 20px;
            }
            p {
                color: #555;
                line-height: 1.6;
                font-size: 16px;
            }
            ul {
                color: #555;
                line-height: 1.8;
            }
            li {
                margin-bottom: 8px;
            }
            .info-box {
                background: #f8f9fa;
                border-left: 4px solid #007AFF;
                padding: 15px;
                margin: 20px 0;
                border-radius: 4px;
            }
            .feature-box {
                background: #f8f9fa;
                border-left: 4px solid #007bff;
                padding: 12px 15px;
                margin: 10px 0;
                border-radius: 4px;
            }
            .highlight-box {
                background: #fff3cd;
                border-left: 4px solid #ffc107;
                padding: 15px;
                margin: 20px 0;
                border-radius: 4px;
            }
            .update-box {
                background: #e7f3ff;
                border-left: 4px solid #00ff88;
                padding: 15px;
                margin: 20px 0;
                border-radius: 4px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🛸 UFOBeep</h1>
            </div>
            <div class="content">
                <h2>iOS Beta is Live!</h2>

                <p>Great news - the iOS version of UFOBeep is now available for testing on TestFlight!</p>

                <center>
                    <a href="https://testflight.apple.com/join/jJvBaWSa" class="button">
                        🍎 Download iOS Beta (TestFlight)
                    </a>
                </center>

                <div class="info-box">
                    <p style="margin: 0;"><strong>TestFlight Link:</strong></p>
                    <p style="margin: 5px 0 0 0; font-size: 14px;">
                        <a href="https://testflight.apple.com/join/jJvBaWSa" style="color: #007bff;">
                            https://testflight.apple.com/join/jJvBaWSa
                        </a>
                    </p>
                    <p style="font-size: 14px; color: #666; margin: 10px 0 0 0;">
                        <strong>Note:</strong> You'll need the TestFlight app from the App Store. Requires iOS 13.0 or later.
                    </p>
                </div>

                <div class="update-box">
                    <p style="margin: 0; color: #333;"><strong>🔄 Android Beta Users:</strong> If you haven't tried the Android beta yet, we've made some significant improvements! Check out the new blue gradient bottom sheets and improved translations.</p>
                </div>

                <h3 style="color: #333; margin-top: 30px;">📱 Android Beta</h3>
                <p>Already on Android or want to test on both platforms?</p>

                <center>
                    <a href="https://play.google.com/apps/testing/com.ufobeep" class="android-button">
                        🤖 Android Beta (Google Play)
                    </a>
                </center>

                <h3 style="color: #333; margin-top: 30px;">🔬 What Makes UFOBeep Different</h3>

                <p>Every sighting automatically captures <strong>real-time environmental data</strong> at that exact moment:</p>

                <div class="feature-box">
                    <p style="margin: 5px 0;"><strong>☁️ Weather Conditions</strong> - Temperature, visibility, cloud cover, wind speed</p>
                </div>

                <div class="feature-box">
                    <p style="margin: 5px 0;"><strong>🌙 Celestial Positions</strong> - Sun, moon, planets, and bright stars</p>
                </div>

                <div class="feature-box">
                    <p style="margin: 5px 0;"><strong>✈️ Aircraft Tracking</strong> - All planes within 50km with positions and flight numbers</p>
                </div>

                <div class="feature-box">
                    <p style="margin: 5px 0;"><strong>🛰️ Satellite Data</strong> - Every satellite overhead with brightness and trajectory</p>
                </div>

                <h3 style="color: #333; margin-top: 30px;">🧪 Please Test!</h3>

                <ul>
                    <li><strong>Create a test beep</strong> - Take a photo of the sky and see the automatic analysis</li>
                    <li><strong>Browse sightings</strong> - Tap alerts to see the environmental data we capture</li>
                    <li><strong>Leave comments</strong> - Test the real-time chat feature</li>
                    <li><strong>Check enrichment data</strong> - See how we identify planes, satellites, and celestial objects</li>
                </ul>

                <div class="highlight-box">
                    <p style="margin: 0;"><strong>🎯 We need your feedback:</strong> Does the automatic enrichment data help you understand what you're seeing? Is anything confusing or missing?</p>
                </div>

                <p style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
                    Thank you for being an early tester! Your feedback is invaluable.
                </p>

                <p style="color: #888; font-size: 14px;">
                    Questions or feedback? Reply to this email or contact support@ufobeep.com
                </p>
            </div>
            <div class="footer">
                <p>UFOBeep - Real-time UFO Alert Network</p>
                <p>This email was sent from support@ufobeep.com</p>
            </div>
        </div>
    </body>
    </html>
    """

    text_body = """
    iOS Beta is Live!

    Great news - the iOS version of UFOBeep is now available for testing on TestFlight!

    Download iOS Beta: https://testflight.apple.com/join/jJvBaWSa

    Note: You'll need the TestFlight app from the App Store. Requires iOS 13.0+.

    Android Beta Users: If you haven't tried the Android beta yet, we've made some significant
    improvements! Check out the new blue gradient bottom sheets and improved translations.

    Android Beta: https://play.google.com/apps/testing/com.ufobeep

    What Makes UFOBeep Different:

    Every sighting captures real-time environmental data at that exact moment:
    - Weather: Temperature, visibility, cloud cover, wind speed
    - Celestial: Sun, moon, planets, and bright stars
    - Aircraft: All planes within 50km with positions and flight numbers
    - Satellites: Every satellite overhead with brightness and trajectory

    Please Test:
    - Create a test beep and see automatic analysis
    - Browse sightings and check environmental data
    - Leave comments to test real-time chat
    - Review enrichment data (planes, satellites, celestial objects)

    We need your feedback: Does the enrichment data help? Is anything confusing?

    Thank you for being an early tester!

    Questions? support@ufobeep.com

    - The UFOBeep Team
    """

    try:
        # Create message
        msg = MIMEMultipart('alternative')
        msg['From'] = f"{from_name} <{from_email}>"
        msg['To'] = to_email
        msg['Subject'] = subject
        msg['Date'] = formatdate(localtime=True)

        # Add headers for better deliverability
        msg['Message-ID'] = f"<{secrets.token_hex(16)}@ufobeep.com>"
        msg['Reply-To'] = "support@ufobeep.com"

        # Attach text and HTML parts
        text_part = MIMEText(text_body, 'plain')
        html_part = MIMEText(html_body, 'html')
        msg.attach(text_part)
        msg.attach(html_part)

        # Send via Postfix on production server
        with smtplib.SMTP('localhost', 587) as server:
            server.send_message(msg)

        print(f"✅ Successfully sent iOS notification to {to_email}")
        return True

    except Exception as e:
        print(f"❌ Failed to send email: {e}")
        return False

if __name__ == "__main__":
    import psycopg2

    # Connect to database and get all real signups (exclude test emails)
    try:
        conn = psycopg2.connect(
            host="localhost",
            database="ufobeep_db",
            user="ufobeep_user",
            password="ufopostpass"
        )
        cur = conn.cursor()

        # Get all emails, excluding obvious test entries
        cur.execute("""
            SELECT DISTINCT email
            FROM email_interests
            WHERE email IS NOT NULL
            AND email NOT LIKE 'test%@%'
            AND email != 'stephania.predovic@theaccessuk.org'
            ORDER BY email
        """)

        emails = [row[0] for row in cur.fetchall()]

        print(f"Found {len(emails)} real beta signups")
        print("Sending iOS beta emails...\n")

        success_count = 0
        fail_count = 0

        for email in emails:
            print(f"Sending to {email}...", end=" ")
            if send_ios_notification(email):
                success_count += 1
            else:
                fail_count += 1

        print(f"\n{'='*50}")
        print(f"✅ Successfully sent: {success_count}")
        print(f"❌ Failed: {fail_count}")
        print(f"{'='*50}")

        cur.close()
        conn.close()

    except Exception as e:
        print(f"Database error: {e}")