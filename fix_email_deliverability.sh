#!/bin/bash
# Fix UFOBeep Email Deliverability
# Complete DKIM setup and DNS configuration

set -e

echo "🚀 Fixing UFOBeep Email Deliverability"
echo "======================================"

# Step 1: Install OpenDKIM
echo "📦 Installing OpenDKIM..."
sudo apt update
sudo apt install -y opendkim opendkim-tools

# Step 2: Create DKIM keys
echo "🔐 Generating DKIM keys..."
sudo mkdir -p /etc/opendkim/keys/ufobeep.com
cd /etc/opendkim/keys/ufobeep.com

# Generate DKIM key pair
sudo opendkim-genkey -b 2048 -d ufobeep.com -D /etc/opendkim/keys/ufobeep.com -s default

# Set permissions
sudo chown -R opendkim:opendkim /etc/opendkim
sudo chmod 600 /etc/opendkim/keys/ufobeep.com/default.private
sudo chmod 644 /etc/opendkim/keys/ufobeep.com/default.txt

echo "✅ DKIM keys generated"

# Step 3: Configure OpenDKIM
echo "🔧 Configuring OpenDKIM..."
sudo tee /etc/opendkim.conf > /dev/null <<'EOF'
# OpenDKIM Configuration for UFOBeep
Syslog yes
UMask 002
Domain ufobeep.com
KeyFile /etc/opendkim/keys/ufobeep.com/default.private
Selector default
SOCKET inet:8891@localhost
PidFile /var/run/opendkim/opendkim.pid
SignatureAlgorithm rsa-sha256
Mode sv
SubDomains no
AutoRestart yes
AutoRestartRate 10/1h
Background yes
DNSTimeout 5
SignatureExpireTime 1209600
EOF

# Step 4: Configure Postfix for DKIM
echo "📮 Configuring Postfix for DKIM..."

# Backup original main.cf
sudo cp /etc/postfix/main.cf /etc/postfix/main.cf.backup

# Add DKIM configuration to Postfix
sudo tee -a /etc/postfix/main.cf > /dev/null <<'EOF'

# DKIM Configuration
milter_default_action = accept
milter_protocol = 2
smtpd_milters = inet:localhost:8891
non_smtpd_milters = $smtpd_milters
EOF

# Step 5: Start services
echo "🔄 Starting services..."
sudo systemctl enable opendkim
sudo systemctl start opendkim
sudo systemctl restart postfix

# Step 6: Display DNS records needed
echo ""
echo "============================================"
echo "📋 DNS RECORDS TO ADD TO ufobeep.com:"
echo "============================================"
echo ""
echo "1. DKIM Record (TXT):"
echo "   Name: default._domainkey.ufobeep.com"
echo "   Value:"
sudo cat /etc/opendkim/keys/ufobeep.com/default.txt

echo ""
echo "2. Update DMARC Record (TXT):"
echo "   Name: _dmarc.ufobeep.com"
echo "   Value: v=DMARC1; p=none; adkim=r; aspf=r; rua=mailto:admin@ufobeep.com;"
echo ""

# Step 7: Test DKIM setup
echo "🧪 Testing DKIM setup..."
if sudo systemctl is-active --quiet opendkim; then
    echo "✅ OpenDKIM is running"
else
    echo "❌ OpenDKIM failed to start"
    sudo systemctl status opendkim
fi

if sudo systemctl is-active --quiet postfix; then
    echo "✅ Postfix is running"
else
    echo "❌ Postfix failed to start"
    sudo systemctl status postfix
fi

# Test DKIM signing
echo "📧 Testing DKIM signing capability..."
echo "Subject: DKIM Test" | sudo sendmail -v admin@ufobeep.com || echo "⚠️  Test email failed (expected if no admin@ufobeep.com)"

echo ""
echo "🎉 Email deliverability setup complete!"
echo ""
echo "Next steps:"
echo "1. Add the DKIM DNS record shown above"
echo "2. Update the DMARC DNS record shown above"
echo "3. Wait 5-10 minutes for services to stabilize"
echo "4. Test sending an email"
echo ""
echo "Check logs with:"
echo "  sudo tail -f /var/log/mail.log"
echo "  sudo tail -f /var/log/opendkim.log"