#!/bin/bash
# Setup MUFON nightly cron job

echo "🕐 Setting up MUFON nightly pipeline cron job..."

# Create log directory
mkdir -p /home/ufobeep/ufobeep/logs

# Add cron job to run every night at 2 AM (when MUFON activity is low)
CRON_JOB="0 2 * * * cd /home/ufobeep/ufobeep && python3 api/feeds/mufon_nightly_pipeline.py >> logs/mufon-nightly.log 2>&1"

# Check if cron job already exists
if ! crontab -l 2>/dev/null | grep -q "mufon_nightly_pipeline.py"; then
    # Add the cron job
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "✅ MUFON nightly pipeline scheduled for 2:00 AM daily"
    echo "📋 View logs: tail -f /home/ufobeep/ufobeep/logs/mufon-nightly.log"
else
    echo "⚠️  MUFON cron job already exists"
fi

# Show current crontab
echo ""
echo "📅 Current cron jobs:"
crontab -l