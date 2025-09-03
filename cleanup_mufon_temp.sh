#!/bin/bash
# Clean up temporary MUFON media files to save disk space

echo "🧹 Starting MUFON temporary files cleanup"
echo "=========================================="

# Clean up downloaded media files in /tmp
echo "📁 Cleaning /tmp/mufon_media..."
if [ -d "/tmp/mufon_media" ]; then
    file_count=$(find /tmp/mufon_media -type f | wc -l)
    dir_size=$(du -sh /tmp/mufon_media 2>/dev/null | cut -f1)
    echo "   Found $file_count files using $dir_size"
    rm -rf /tmp/mufon_media
    echo "   ✅ Cleaned /tmp/mufon_media"
else
    echo "   ⚠️  Directory not found"
fi

# Clean up any other MUFON temp directories
echo "📁 Cleaning other MUFON temp files..."
find /tmp -name "*mufon*" -type f -mtime +1 -delete 2>/dev/null
find /tmp -name "*MUFON*" -type f -mtime +1 -delete 2>/dev/null

# Clean up old JSON files (keep last 7 days)
echo "📁 Cleaning old MUFON JSON files (keeping last 7 days)..."
cd /home/ufobeep/ufobeep/mufon_clicker
old_json_count=$(find . -name "mufon_*.json" -mtime +7 | wc -l)
if [ $old_json_count -gt 0 ]; then
    echo "   Found $old_json_count old JSON files"
    find . -name "mufon_*.json" -mtime +7 -delete
    echo "   ✅ Deleted old JSON files"
else
    echo "   No old JSON files to clean"
fi

# Show disk usage after cleanup
echo ""
echo "📊 Disk usage after cleanup:"
df -h /
echo ""
echo "📊 MUFON data directory size:"
du -sh /home/ufobeep/ufobeep/mufon_clicker

echo ""
echo "=========================================="
echo "✅ Cleanup completed!"