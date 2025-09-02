#!/bin/bash
# Auto daily MUFON import for cron
# Usage: Add to crontab: 0 6 * * * /home/mike/D/ufobeep/mufon_clicker/auto_daily_import.sh

cd /home/mike/D/ufobeep/mufon_clicker

# Get yesterday's date (when new cases are typically available)
DATE=$(date -d "yesterday" +%Y-%m-%d)

echo "$(date): Starting daily MUFON import for $DATE" >> daily_import.log

# Run the unified pipeline
python mufon_pipeline.py $DATE >> daily_import.log 2>&1

echo "$(date): Daily import completed" >> daily_import.log