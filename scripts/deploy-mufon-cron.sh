#!/bin/bash

# Deploy MUFON cron job to production server

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Deploying MUFON cron job to production server...${NC}"

# First, ensure latest code is pushed
echo -e "${YELLOW}Pushing latest code to GitHub...${NC}"
git add .
git commit -m "Add MUFON integration and cron job setup" || true
git push

# Deploy to production
echo -e "${YELLOW}Setting up MUFON cron on production server...${NC}"

ssh -p 322 ufobeep@ufobeep.com << 'ENDSSH'
# Colors for remote output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Setting up MUFON integration on production...${NC}"

# Navigate to project
cd /home/ufobeep/ufobeep

# Pull latest code
echo -e "${YELLOW}Pulling latest code...${NC}"
git pull origin main

# Install Python dependencies in API virtual environment
echo -e "${YELLOW}Installing Python dependencies...${NC}"
cd api
source venv/bin/activate
pip install selenium webdriver-manager

# Install Chrome for headless scraping
echo -e "${YELLOW}Installing Chrome browser for headless scraping...${NC}"
if ! command -v google-chrome &> /dev/null; then
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    sudo apt-get update
    sudo apt-get install -y google-chrome-stable
    echo -e "${GREEN}✓ Chrome installed${NC}"
else
    echo -e "${GREEN}✓ Chrome already installed${NC}"
fi

# Create MUFON nightly import script
echo -e "${YELLOW}Creating MUFON import script...${NC}"
cat > /home/ufobeep/ufobeep/scripts/mufon-nightly-import.sh << 'EOF'
#!/bin/bash

# MUFON Nightly Import Script
# Runs at 2 AM daily to import new MUFON sightings

export PATH=/usr/local/bin:/usr/bin:/bin
export PYTHONPATH=/home/ufobeep/ufobeep/api

# Log file
LOG_FILE="/home/ufobeep/ufobeep/logs/mufon-import-$(date +%Y%m%d).log"
mkdir -p /home/ufobeep/ufobeep/logs

echo "========================================" >> $LOG_FILE
echo "MUFON Import Started: $(date)" >> $LOG_FILE
echo "========================================" >> $LOG_FILE

# Activate virtual environment
source /home/ufobeep/ufobeep/api/venv/bin/activate

# Load credentials
source /home/ufobeep/ufobeep/.env.mufon

# Run the import script
cd /home/ufobeep/ufobeep/api
python -m app.services.mufon_scraper >> $LOG_FILE 2>&1

# Check if successful
if [ $? -eq 0 ]; then
    echo "Import completed successfully at $(date)" >> $LOG_FILE
else
    echo "Import failed at $(date)" >> $LOG_FILE
fi

echo "========================================" >> $LOG_FILE
EOF

# Make script executable
chmod +x /home/ufobeep/ufobeep/scripts/mufon-nightly-import.sh

# Create credentials file (secure)
if [ ! -f /home/ufobeep/ufobeep/.env.mufon ]; then
    echo -e "${YELLOW}Creating MUFON credentials file...${NC}"
    cat > /home/ufobeep/ufobeep/.env.mufon << 'EOF'
# MUFON Credentials (keep secure!)
export MUFON_USERNAME="varak"
export MUFON_PASSWORD="ufo4me123"
EOF
    chmod 600 /home/ufobeep/ufobeep/.env.mufon
    echo -e "${GREEN}✓ Credentials file created${NC}"
fi

# Add to crontab (runs at 2 AM daily)
CRON_JOB="0 2 * * * /home/ufobeep/ufobeep/scripts/mufon-nightly-import.sh"

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -q "mufon-nightly-import.sh"; then
    echo -e "${YELLOW}MUFON cron job already exists, updating...${NC}"
    # Remove old entry
    crontab -l | grep -v "mufon-nightly-import.sh" | crontab -
fi

# Add new cron job
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo -e "${GREEN}✓ MUFON nightly import cron job installed!${NC}"
echo -e "${GREEN}✓ Will run daily at 2:00 AM${NC}"
echo -e "${GREEN}✓ Logs: /home/ufobeep/ufobeep/logs/mufon-import-*.log${NC}"

# Restart API service to load new routes
echo -e "${YELLOW}Restarting API service...${NC}"
sudo systemctl restart ufobeep-api

echo -e "${GREEN}✓ MUFON integration deployed successfully!${NC}"

# Show status
echo ""
echo -e "${YELLOW}Status:${NC}"
crontab -l | grep mufon || echo "No MUFON cron jobs found"
echo ""
echo -e "${YELLOW}Test commands:${NC}"
echo "  Test import: /home/ufobeep/ufobeep/scripts/mufon-nightly-import.sh"
echo "  View logs: tail -f /home/ufobeep/ufobeep/logs/mufon-import-*.log"
echo "  Check API: curl https://api.ufobeep.com/mufon/recent"

ENDSSH

echo ""
echo -e "${GREEN}✅ MUFON cron job deployed to production!${NC}"
echo ""
echo -e "${YELLOW}Production commands:${NC}"
echo "  SSH to server: ssh -p 322 ufobeep@ufobeep.com"
echo "  Test import: ssh -p 322 ufobeep@ufobeep.com '/home/ufobeep/ufobeep/scripts/mufon-nightly-import.sh'"
echo "  View logs: ssh -p 322 ufobeep@ufobeep.com 'tail -f /home/ufobeep/ufobeep/logs/mufon-import-*.log'"
echo "  Check cron: ssh -p 322 ufobeep@ufobeep.com 'crontab -l'"