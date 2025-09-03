#!/bin/bash
# Batch import MUFON data from August 5 to September 3, 2025

# Set MUFON credentials
export MUFON_USERNAME=varak
export MUFON_PASSWORD=ufobeep123pass

# Start and end dates
START_DATE="2025-08-05"
END_DATE="2025-09-03"

# Convert dates to seconds for comparison
start_seconds=$(date -d "$START_DATE" +%s)
end_seconds=$(date -d "$END_DATE" +%s)
current_seconds=$start_seconds

echo "🚀 Starting MUFON batch import from $START_DATE to $END_DATE"
echo "=================================================="

# Loop through each date
while [ $current_seconds -le $end_seconds ]; do
    # Format current date as YYYY-MM-DD
    current_date=$(date -d "@$current_seconds" +%Y-%m-%d)
    
    echo ""
    echo "📅 Processing date: $current_date"
    echo "----------------------------------"
    
    # Extract MUFON data for this date
    echo "🔍 Extracting MUFON data..."
    cd /home/ufobeep/ufobeep/mufon_clicker
    python3 mufon_simple_extraction.py "$current_date"
    
    # Check if extraction was successful
    json_file="mufon_simple_$(echo $current_date | tr - _).json"
    if [ -f "$json_file" ]; then
        echo "✅ Extraction successful: $json_file"
        
        # Import the data
        echo "📤 Importing to UFOBeep..."
        cd /home/ufobeep/ufobeep
        python3 api/feeds/import_mufon_fixed.py "mufon_clicker/$json_file"
        
        echo "✅ Import completed for $current_date"
    else
        echo "⚠️  No data file found for $current_date, skipping..."
    fi
    
    # Move to next day
    current_seconds=$((current_seconds + 86400))
    
    # Small delay between days to avoid overloading
    sleep 2
done

echo ""
echo "=================================================="
echo "🎉 Batch import completed!"
echo "Run 'curl -s http://localhost:8000/alerts?limit=1 | jq .data.total' to see total alerts"