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
