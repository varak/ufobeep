#!/bin/bash
# Daily NUFORC collection script
# Add to cron: 0 6 * * * cd /home/ufobeep/ufobeep && ./daily_nuforc.sh

echo "🌅 Daily NUFORC collection starting..."
echo "Date: $(date)"
echo "=" | tr '=' '=' | head -c 50; echo

cd "$(dirname "$0")"

# Create logs directory if it doesn't exist
mkdir -p logs

# Log file with timestamp
LOG_FILE="logs/nuforc_daily_$(date +%Y%m%d_%H%M%S).log"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "🥷 Starting stealth collection for yesterday's reports..."

# Run stealth scraper for yesterday
python3 nuforc_stealth.py yesterday >> "$LOG_FILE" 2>&1

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    log "✅ Daily collection completed successfully"

    # Optional: Clean up old logs (keep last 30 days)
    find logs/ -name "nuforc_daily_*.log" -mtime +30 -delete 2>/dev/null

    echo "📊 Collection summary:"
    tail -10 "$LOG_FILE" | grep -E "(✅|❌|📊)"

else
    log "❌ Daily collection failed with exit code: $EXIT_CODE"

    # Optional: Send alert/notification about failure
    echo "Collection failed - check log: $LOG_FILE"
fi

log "🏁 Daily NUFORC collection finished"