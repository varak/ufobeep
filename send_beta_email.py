#!/usr/bin/env python3
"""
Send beta tester notification email
"""
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.utils import formatdate
import secrets

def send_beta_notification(to_email: str):
    """Send beta notification email via Postfix"""

    from_email = "support@ufobeep.com"
    from_name = "UFOBeep"
    subject = "🛸 UFOBeep Beta Access - Download Now!"

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
            p {
                color: #555;
                line-height: 1.6;
                font-size: 16px;
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
                <h2>Welcome to the UFOBeep Beta!</h2>
                <p>You're receiving this email because you're on our beta tester list. Your Google Play beta access is now active!</p>

                <center>
                    <a href="https://play.google.com/apps/testing/com.ufobeep" class="button">
                        📱 Download Beta from Google Play
                    </a>
                </center>

                <div class="info-box">
                    <p style="margin: 0;"><strong>Direct Link:</strong></p>
                    <p style="margin: 5px 0 0 0; font-size: 14px;">
                        <a href="https://play.google.com/apps/testing/com.ufobeep" style="color: #007bff;">
                            https://play.google.com/apps/testing/com.ufobeep
                        </a>
                    </p>
                </div>

                <h3 style="color: #333; margin-top: 30px;">📱 iOS Version</h3>
                <p>
                    The iOS version is currently under review by Apple and should be available for testing tomorrow.
                    We'll send you more information as soon as it's approved.
                </p>

                <p style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
                    Thank you for being an early tester! Your feedback will help shape the future of UFOBeep.
                </p>

                <p style="color: #888; font-size: 14px;">
                    Questions? Reply to this email or contact us at support@ufobeep.com
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
    Welcome to the UFOBeep Beta!

    You're receiving this email because you're on our beta tester list.

    Download the Android beta here:
    https://play.google.com/apps/testing/com.ufobeep

    iOS Version:
    The iOS version is currently under review by Apple and should be available for testing tomorrow.
    We'll send you more information as soon as it's approved.

    Thank you for being an early tester!

    Questions? Contact us at support@ufobeep.com

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

        print(f"✅ Successfully sent beta notification to {to_email}")
        return True

    except Exception as e:
        print(f"❌ Failed to send email: {e}")
        return False

if __name__ == "__main__":
    # Send test email to mike@emke.com
    send_beta_notification("mike@emke.com")
