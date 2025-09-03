#!/bin/bash
# Comprehensive MUFON artifact cleanup for production
echo "🧹 Starting comprehensive MUFON cleanup on production..."
echo "=================================================="

# Get initial disk usage
echo "📊 Initial disk usage:"
df -h | grep '/dev/vda2'
echo

# Remove all MUFON JSON files (except the .env.mufon which we might want to keep)
echo "🗑️  Removing MUFON JSON files..."
find /home/ufobeep/ufobeep -name "mufon_simple_*.json" -type f -delete
find /home/ufobeep/ufobeep -name "mufon_working_*.json" -type f -delete

# Remove any trace files
echo "🗑️  Removing debug/trace files..."
find /home/ufobeep/ufobeep -name "debug_trace.zip" -type f -delete
find /home/ufobeep/ufobeep -name "trace.zip" -type f -delete

# Remove temporary MUFON files from /tmp
echo "🗑️  Cleaning /tmp directory..."
find /tmp -name "*mufon*" -type f -delete 2>/dev/null || true

# Remove batch import script (it's completed)
echo "🗑️  Removing batch import script..."
rm -f /home/ufobeep/ufobeep/import_mufon_batch.sh

# Remove any potential media temp directories
echo "🗑️  Checking for temporary media directories..."
find /tmp -name "*mufon_media*" -type d -exec rm -rf {} \; 2>/dev/null || true

# Remove any old log files if they exist
echo "🗑️  Cleaning up any MUFON-related logs..."
find /home/ufobeep/ufobeep -name "*mufon*.log" -type f -delete 2>/dev/null || true

# Clean up any cache files
echo "🗑️  Cleaning cache files..."
find /home/ufobeep/ufobeep -name "__pycache__" -type d -exec rm -rf {} \; 2>/dev/null || true

echo
echo "✅ Cleanup completed!"
echo "📊 Final disk usage:"
df -h | grep '/dev/vda2'
echo
echo "🔍 Remaining MUFON files (should be minimal):"
find /home/ufobeep/ufobeep -name "*mufon*" -type f | head -10
echo
echo "📈 Disk space freed up:"
echo "Run 'du -sh /home/ufobeep/ufobeep/mufon_clicker' to see remaining space usage"