#!/usr/bin/env python3
"""
Send version 369 update notification to beta testers
Critical update: Infinite sessions now working
"""
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.utils import formatdate
import secrets

def send_v369_update(to_email: str):
    """Send v369 update notification via Postfix"""

    from_email = "support@ufobeep.com"
    from_name = "UFOBeep"
    subject = "🛸 UFOBeep v369 - Important Update: Sessions Fixed"

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
                background: #00ff88;
                color: #000000;
                text-decoration: none;
                border-radius: 8px;
                font-weight: bold;
                font-size: 16px;
                margin: 20px 0;
                box-shadow: 0 2px 5px rgba(0,255,136,0.3);
            }
            .button:hover {
                background: #00d973;
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
            .critical-box {
                background: #fff3cd;
                border-left: 4px solid #ffc107;
                padding: 15px;
                margin: 20px 0;
                border-radius: 4px;
            }
            .info-box {
                background: #f8f9fa;
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
                <h2>Important Update: Version 369</h2>

                <div class="critical-box">
                    <p style="margin: 0;"><strong>⚠️ Critical Fix:</strong> The Android version wasn't keeping people logged in. This has been fixed in v369. Please update to the latest version!</p>
                </div>

                <p>Thank you to everyone who has been testing UFOBeep! We've pushed an important update that fixes session handling.</p>

                <h3>📱 Get Version 369</h3>

                <p><strong>Android:</strong></p>
                <center>
                    <a href="https://play.google.com/apps/testing/com.ufobeep" class="button">
                        Update on Google Play
                    </a>
                </center>

                <p style="margin-top: 20px;"><strong>iOS:</strong></p>
                <center>
                    <a href="https://testflight.apple.com/join/YOUR_CODE" class="button">
                        Update on TestFlight
                    </a>
                </center>

                <h3>✨ What's Fixed in v369</h3>

                <ul>
                    <li><strong>Infinite Sessions</strong> - You'll stay logged in forever. No more re-logging in after a week.</li>
                    <li><strong>Background Notifications</strong> - Get alerts about nearby sightings even if you haven't opened the app in months.</li>
                    <li><strong>Automatic Token Refresh</strong> - The app handles authentication seamlessly in the background.</li>
                </ul>

                <div class="info-box">
                    <p style="margin: 0;"><strong>🧪 Test Request:</strong> Next time you're sitting in a drive-thru, send a test beep! We want to make sure the quick-capture flow works well in real situations.</p>
                </div>

                <h3>🙏 Thank You</h3>

                <p>We really appreciate everyone who's been installing and testing the app. Your feedback is helping us build something great.</p>

                <div class="info-box">
                    <p style="margin: 0;"><strong>🐛 Found a Bug?</strong> Please report all errors! Every bug report helps us make UFOBeep better. Reply to this email with any issues you encounter.</p>
                </div>

                <p style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
                    Have questions or feedback? Just reply to this email.
                </p>

                <p style="color: #888; font-size: 14px;">
                    - Mike & the UFOBeep Team
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
    UFOBeep Version 369 - Important Update

    CRITICAL FIX: The Android version wasn't keeping people logged in. This has been fixed in v369. Please update!

    Get Version 369:
    - Android: https://play.google.com/apps/testing/com.ufobeep
    - iOS: https://testflight.apple.com/join/YOUR_CODE

    What's Fixed:
    - Infinite Sessions: Stay logged in forever
    - Background Notifications: Get alerts even if app hasn't been opened in months
    - Automatic Token Refresh: Seamless authentication in background

    Test Request:
    Next time you're in a drive-thru, send a test beep! We want to make sure quick-capture works well.

    Thank you for testing! Your feedback helps us build something great.

    Questions? Reply to this email or contact support@ufobeep.com

    - Mike & the UFOBeep Team
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

        print(f"✅ Successfully sent v369 update to {to_email}")
        return True

    except Exception as e:
        print(f"❌ Failed to send email: {e}")
        return False

if __name__ == "__main__":
    import psycopg2

    # Connect to database and get all real signups
    try:
        conn = psycopg2.connect(
            host="localhost",
            database="ufobeep_db",
            user="ufobeep_user",
            password="ufopostpass"
        )
        cur = conn.cursor()

        # Get all emails from email_interests
        cur.execute("""
            SELECT DISTINCT email
            FROM email_interests
            WHERE email IS NOT NULL
            AND email NOT LIKE 'test%@%'
            ORDER BY email
        """)

        emails = [row[0] for row in cur.fetchall()]

        print(f"Found {len(emails)} beta testers")
        print("\n" + "="*50)
        print("READY TO SEND v369 UPDATE EMAILS")
        print("="*50)
        print(f"Recipients: {len(emails)}")
        print(f"\nEmails will be sent to:")
        for email in emails[:5]:
            print(f"  - {email}")
        if len(emails) > 5:
            print(f"  ... and {len(emails) - 5} more")

        print("\n" + "="*50)
        confirm = input("Type 'SEND' to send emails now: ")

        if confirm == "SEND":
            print("\nSending emails...\n")
            success_count = 0
            fail_count = 0

            for email in emails:
                print(f"Sending to {email}...", end=" ")
                if send_v369_update(email):
                    success_count += 1
                else:
                    fail_count += 1

            print(f"\n{'='*50}")
            print(f"✅ Successfully sent: {success_count}")
            print(f"❌ Failed: {fail_count}")
            print(f"{'='*50}")
        else:
            print("\n❌ Cancelled - no emails sent")

        cur.close()
        conn.close()

    except Exception as e:
        print(f"Database error: {e}")
