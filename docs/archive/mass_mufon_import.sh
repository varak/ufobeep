#!/bin/bash

# [ARCHIVED] Mass MUFON import script - superseded by range support in mufon.sh
# Usage: ./mufon.sh YYYY-MM-DD:YYYY-MM-DD

echo "🚀 Starting Mass MUFON Import from August 1st, 2025"
echo "=================================================="
echo "⚠️  Deprecated: Use './mufon.sh YYYY-MM-DD:YYYY-MM-DD' instead."

# Start date: August 1st, 2025
start_date="2025-08-01"
current_date=$(date -d "$start_date" +%Y-%m-%d)
today=$(date +%Y-%m-%d)

# Counter for tracking
day_count=0
success_count=0
error_count=0

echo "📅 Import range: $start_date to $today"
echo "⏱️  2-second delay between each day"
echo ""

# Loop through each day from start_date to today
while [[ "$current_date" <= "$today" ]]; do
    day_count=$((day_count + 1))
    echo "📅 Day $day_count: Processing $current_date"
    
    # Run MUFON import for this date
    if ./mufon.sh "$current_date"; then
        echo "✅ Successfully imported data for $current_date"
        success_count=$((success_count + 1))
    else
        echo "❌ Failed to import data for $current_date"
        error_count=$((error_count + 1))
    fi
    
    # Move to next day
    current_date=$(date -d "$current_date + 1 day" +%Y-%m-%d)
    
    # Sleep for 2 seconds if not the last day
    if [[ "$current_date" <= "$today" ]]; then
        echo "⏳ Waiting 2 seconds..."
        sleep 2
        echo ""
    fi
done

echo ""
echo "🎉 Mass MUFON Import Complete!"
echo "================================"
echo "📊 Total days processed: $day_count"
echo "✅ Successful imports: $success_count"
echo "❌ Failed imports: $error_count"
echo "📅 Date range: $start_date to $today"

if [ $error_count -eq 0 ]; then
    echo "🎯 All imports completed successfully!"
else
    echo "⚠️  Some imports failed. Check logs above for details."
fi
