#!/bin/bash
# Daily MUFON import cron job script
# Runs at 3:00 AM daily to import yesterday's MUFON data

# Set up logging
LOG_FILE="/home/ufobeep/logs/mufon_daily.log"
LOCK_FILE="/tmp/mufon_daily.lock"

# Function to log with timestamp
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

# Check if another instance is running
if [ -f "$LOCK_FILE" ]; then
    log "⚠️  Another MUFON import is already running. Exiting."
    exit 1
fi

# Create lock file
echo $$ > "$LOCK_FILE"

# Cleanup lock file on exit
trap 'rm -f "$LOCK_FILE"' EXIT

log "🌅 Starting daily MUFON import process"

# Get yesterday's date in YYYY-MM-DD format
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)
log "📅 Importing MUFON data for date: $YESTERDAY"

# Set MUFON credentials
export MUFON_USERNAME=varak
export MUFON_PASSWORD=ufobeep123pass

# Change to project directory
cd /home/ufobeep/ufobeep

# Extract MUFON data for yesterday
log "🔍 Extracting MUFON data..."
cd /home/ufobeep/ufobeep/mufon_clicker
timeout 300 python3 mufon_simple_extraction.py "$YESTERDAY"

# Check if extraction was successful
json_file="mufon_simple_$(echo $YESTERDAY | tr - _).json"
if [ -f "$json_file" ]; then
    log "✅ Extraction successful: $json_file"
    
    # Import the data
    log "📤 Importing to UFOBeep database..."
    cd /home/ufobeep/ufobeep
    timeout 600 python3 api/feeds/import_mufon_fixed.py "mufon_clicker/$json_file"
    
    if [ $? -eq 0 ]; then
        log "✅ Import completed successfully for $YESTERDAY"
        
        # Clean up the JSON file to save space
        rm -f "mufon_clicker/$json_file"
        log "🗑️  Cleaned up temporary file: $json_file"
    else
        log "❌ Import failed for $YESTERDAY"
    fi
else
    log "⚠️  No data file found for $YESTERDAY, skipping..."
fi

# Clean up any temporary files
find /tmp -name "*mufon*" -type f -mtime +1 -delete 2>/dev/null || true

log "🏁 Daily MUFON import process completed"
log "=============================================="