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
    subject = "🛸 UFOBeep Beta - Smart Analysis That Pulls Real-Time Data"

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
            ul {
                color: #555;
                line-height: 1.8;
            }
            li {
                margin-bottom: 8px;
            }
            .info-box {
                background: #f8f9fa;
                border-left: 4px solid #00ff88;
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
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🛸 UFOBeep</h1>
            </div>
            <div class="content">
                <h2>Welcome to the UFOBeep Beta!</h2>
                <p>You're on the list! Your Google Play beta access is now active.</p>

                <center>
                    <a href="https://play.google.com/apps/testing/com.ufobeep" class="button">
                        📱 Download Beta from Google Play
                    </a>
                </center>

                <h3>🔬 What Makes UFOBeep Different</h3>

                <p>Every single sighting you report automatically captures <strong>real-time environmental data</strong> at that exact moment:</p>

                <div class="feature-box">
                    <p style="margin: 5px 0;"><strong>☁️ Weather Conditions</strong> - Temperature, visibility, cloud cover, and wind speed</p>
                </div>

                <div class="feature-box">
                    <p style="margin: 5px 0;"><strong>🌙 Celestial Positions</strong> - Sun, moon, planets, and bright stars visible at that moment</p>
                </div>

                <div class="feature-box">
                    <p style="margin: 5px 0;"><strong>✈️ Aircraft Tracking</strong> - All planes within 50km with real-time positions, altitude, and flight numbers</p>
                </div>

                <div class="feature-box">
                    <p style="margin: 5px 0;"><strong>🛰️ Satellite Data</strong> - Every satellite visible overhead at that precise moment, including brightness and trajectory</p>
                </div>

                <h3>🧪 Help Us Test!</h3>

                <p>We need your help testing these features:</p>

                <ul>
                    <li><strong>Create a test "beep"</strong> - Take a photo of the sky and submit a sighting to see the automatic analysis in action</li>
                    <li><strong>Browse other sightings</strong> - Tap on alerts to see the environmental data we capture</li>
                    <li><strong>Leave comments</strong> - Try commenting on sightings to test real-time chat</li>
                    <li><strong>Check the enrichment data</strong> - See how we identify planes, satellites, and celestial objects automatically</li>
                </ul>

                <div class="highlight-box">
                    <p style="margin: 0;"><strong>🎯 Beta Focus:</strong> We especially want feedback on the automatic enrichment data - does it help you understand what you're seeing? Is anything confusing?</p>
                </div>

                <h3>📱 iOS Version</h3>
                <p>
                    The iOS/macOS version is currently under review by Apple and should be available for testing tomorrow.
                    We'll send more information as soon as it's approved.
                </p>

                <p style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
                    Thank you for being an early tester! Your feedback will help us build the best UFO tracking platform.
                </p>

                <p style="color: #888; font-size: 14px;">
                    Questions? Reply to this email or contact support@ufobeep.com
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

    You're on the list! Your Google Play beta access is now active.

    Download: https://play.google.com/apps/testing/com.ufobeep

    What Makes UFOBeep Different:

    Every sighting you report automatically captures real-time environmental data:
    - Weather Conditions: Temperature, visibility, cloud cover, wind speed
    - Celestial Positions: Sun, moon, planets, and bright stars at that moment
    - Aircraft Tracking: All planes within 50km with positions, altitude, flight numbers
    - Satellite Data: Every satellite overhead at that moment with brightness and trajectory

    Help Us Test:
    - Create a test beep and see automatic analysis
    - Browse sightings and check the environmental data
    - Leave comments to test real-time chat
    - Review the enrichment data (planes, satellites, celestial objects)

    Beta Focus: We especially want feedback on the automatic enrichment data!

    iOS Version:
    The iOS/macOS version is under review by Apple and should be available tomorrow.
    We'll send more info as soon as it's approved.

    Thank you for being an early tester!

    Questions? Contact support@ufobeep.com

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
