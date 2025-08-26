#!/bin/bash

# Script to safely add dmarc@ufobeep.com alias on production server
# This APPENDS to the virtual aliases file without overwriting existing entries

set -e

# Production connection
PROD_HOST="ufobeep@ufobeep.com"
PROD_PORT="322"

echo "🔧 Adding DMARC email alias on production server"
echo "================================================"
echo
echo "This will add: dmarc@ufobeep.com → mike@ufobeep.com"
echo

# Command to run on production server
REMOTE_CMD='
# Check if virtual aliases file exists
if [ ! -f /etc/postfix/virtual ]; then
    echo "ERROR: /etc/postfix/virtual does not exist"
    exit 1
fi

# Check if dmarc alias already exists
if grep -q "^dmarc@ufobeep.com" /etc/postfix/virtual 2>/dev/null; then
    echo "✅ DMARC alias already exists:"
    grep "^dmarc@ufobeep.com" /etc/postfix/virtual
else
    # Add the new alias
    echo "Adding dmarc@ufobeep.com alias..."
    echo "dmarc@ufobeep.com mike@ufobeep.com" | sudo tee -a /etc/postfix/virtual > /dev/null
    
    # Rebuild the virtual database
    echo "Rebuilding postfix virtual database..."
    sudo postmap /etc/postfix/virtual
    
    # Reload postfix to apply changes
    echo "Reloading postfix..."
    sudo systemctl reload postfix
    
    echo "✅ DMARC alias added successfully!"
fi

# Show all current aliases for verification
echo ""
echo "Current email aliases:"
echo "====================="
sudo cat /etc/postfix/virtual | grep "@"
'

# Execute on production server
ssh -p $PROD_PORT $PROD_HOST "$REMOTE_CMD"

echo
echo "✅ DMARC alias configuration complete!"
echo "   DMARC reports will now be sent to mike@ufobeep.com"
echo
echo "Next steps:"
echo "1. Wait 24-48 hours for first DMARC reports to arrive"
echo "2. Check reports to see why emails are going to spam"
echo "3. Adjust email headers based on report findings"