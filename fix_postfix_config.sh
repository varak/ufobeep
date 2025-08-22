#!/bin/bash
# Fix UFOBeep Postfix Configuration
# Remove duplicate milter entries and use correct DKIM settings

set -e

echo "🔧 Fixing Postfix Configuration"
echo "==============================="

# Create clean main.cf with correct DKIM settings
sudo tee /etc/postfix/main.cf > /dev/null <<'EOF'
# --- Core identity ---
myhostname = mail.ufobeep.com
mydomain = ufobeep.com
myorigin = $mydomain
smtpd_banner = $myhostname ESMTP

# Receive locally for your domain(s)
mydestination = localhost

# (leave) networks etc.
inet_interfaces = all
inet_protocols = ipv4

# --- TLS (temp; see step 3 to replace snakeoil) ---
smtpd_tls_security_level = may
smtp_tls_security_level = may
smtp_tls_CApath = /etc/ssl/certs
smtpd_tls_cert_file = /etc/letsencrypt/live/ufobeep.com/fullchain.pem
smtpd_tls_key_file = /etc/letsencrypt/live/ufobeep.com/privkey.pem

# Virtual domains
virtual_alias_domains = ufobeep.com wipo.com
virtual_alias_maps = hash:/etc/postfix/virtual

# Security restrictions
smtpd_relay_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination
smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination
smtpd_sender_restrictions = reject_non_fqdn_sender, reject_unknown_sender_domain
mynetworks = 127.0.0.0/8, [::1]/128

# Performance
bounce_queue_lifetime = 1m

# DKIM Configuration (OpenDKIM on port 8891)
milter_default_action = accept
milter_protocol = 2
smtpd_milters = inet:localhost:8891
non_smtpd_milters = $smtpd_milters
EOF

echo "✅ Postfix configuration cleaned"

# Restart services
echo "🔄 Restarting Postfix and OpenDKIM..."
sudo systemctl restart opendkim
sudo systemctl restart postfix

echo "🧪 Testing services..."
if sudo systemctl is-active --quiet opendkim; then
    echo "✅ OpenDKIM is running"
else
    echo "❌ OpenDKIM failed to start"
    sudo systemctl status opendkim --no-pager
fi

if sudo systemctl is-active --quiet postfix; then
    echo "✅ Postfix is running"
else
    echo "❌ Postfix failed to start"
    sudo systemctl status postfix --no-pager
fi

echo ""
echo "🎉 Postfix configuration fixed!"
echo ""
echo "Test with:"
echo "  sudo tail -f /var/log/mail.log"