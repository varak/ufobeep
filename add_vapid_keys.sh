#!/bin/bash

# Add VAPID keys to production environment
echo "Adding VAPID keys to production .env file..."

ssh -p 322 ufobeep@ufobeep.com << 'EOF'
cd /home/ufobeep/ufobeep

# Backup current .env file
cp .env .env.backup.$(date +%Y%m%d_%H%M%S)

# Add VAPID keys to .env file
echo "" >> .env
echo "# === Web Push (VAPID) Keys ===" >> .env
echo "VAPID_PUBLIC_KEY=BCcwtMP4fCjeVzDhxDSKGLJsJDoj0ZX_X19syG2xkF2wmYBoj47sEVwa9hub0tdMOyIoELZb-Us6famjoF9M4HQ" >> .env
echo "VAPID_PRIVATE_KEY=j5d91is4fDgmJWJSl_6uCp339oDjilsFD81UJ5MP55k" >> .env

echo "VAPID keys added to .env file"
cat .env | grep VAPID
EOF

echo "Restarting UFOBeep API service..."
ssh -p 322 ufobeep@ufobeep.com "sudo systemctl restart ufobeep-api"

echo "Done! VAPID keys deployed to production."