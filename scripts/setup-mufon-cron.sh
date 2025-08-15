#!/bin/bash

# Setup MUFON nightly import cron job

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Setting up MUFON nightly import cron job...${NC}"

# Create the cron script
cat > /home/mike/D/ufobeep/scripts/mufon-nightly-import.sh << 'EOF'
#!/bin/bash

# MUFON Nightly Import Script
# Runs at 2 AM daily to import new MUFON sightings

export PATH=/usr/local/bin:/usr/bin:/bin
export PYTHONPATH=/home/mike/D/ufobeep/api

# Log file
LOG_FILE="/home/mike/D/ufobeep/logs/mufon-import-$(date +%Y%m%d).log"
mkdir -p /home/mike/D/ufobeep/logs

echo "========================================" >> $LOG_FILE
echo "MUFON Import Started: $(date)" >> $LOG_FILE
echo "========================================" >> $LOG_FILE

# Activate virtual environment
source /home/mike/D/ufobeep/api/venv/bin/activate

# Run the import script
cd /home/mike/D/ufobeep/api
python -m app.services.mufon_scraper >> $LOG_FILE 2>&1

# Check if successful
if [ $? -eq 0 ]; then
    echo "Import completed successfully at $(date)" >> $LOG_FILE
else
    echo "Import failed at $(date)" >> $LOG_FILE
    # Optional: Send notification on failure
    # mail -s "MUFON Import Failed" admin@ufobeep.com < $LOG_FILE
fi

echo "========================================" >> $LOG_FILE
EOF

# Make script executable
chmod +x /home/mike/D/ufobeep/scripts/mufon-nightly-import.sh

# Add to crontab (runs at 2 AM daily)
CRON_JOB="0 2 * * * /home/mike/D/ufobeep/scripts/mufon-nightly-import.sh"

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
echo -e "${GREEN}✓ Logs will be saved to: /home/mike/D/ufobeep/logs/${NC}"

# Create environment file for credentials (secure storage)
if [ ! -f /home/mike/D/ufobeep/.env.mufon ]; then
    echo -e "${YELLOW}Creating MUFON credentials file...${NC}"
    cat > /home/mike/D/ufobeep/.env.mufon << 'EOF'
# MUFON Credentials (keep secure!)
MUFON_USERNAME=varak
MUFON_PASSWORD=ufo4me123
EOF
    chmod 600 /home/mike/D/ufobeep/.env.mufon
    echo -e "${GREEN}✓ Credentials file created (restricted access)${NC}"
fi

echo ""
echo -e "${YELLOW}Manual commands:${NC}"
echo "  View cron jobs: crontab -l"
echo "  Test import now: /home/mike/D/ufobeep/scripts/mufon-nightly-import.sh"
echo "  View logs: tail -f /home/mike/D/ufobeep/logs/mufon-import-*.log"
echo "  Edit credentials: nano /home/mike/D/ufobeep/.env.mufon"