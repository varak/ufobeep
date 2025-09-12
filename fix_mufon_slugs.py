#!/usr/bin/env python3
"""
Fix existing MUFON records to use proper classification titles and SEO-friendly URLs
Usage: python3 fix_mufon_slugs.py [--dry-run]
"""

import subprocess
import sys
import json
import re
from datetime import datetime

CLASSIFICATION_THRESHOLD = 0.3  # Only include classification if confidence >= 30%

def log(message):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {message}")

def get_mufon_records():
    """Get all MUFON records from database"""
    cmd = """sudo -u postgres psql -d ufobeep_db -t -c "SELECT id, title, enrichment_data, short_url FROM sightings WHERE source = 'mufon';" """
    
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        records = []
        
        for line in result.stdout.strip().split('\n'):
            if line.strip():
                parts = line.split('|')
                if len(parts) >= 4:
                    sighting_id = parts[0].strip()
                    title = parts[1].strip()
                    enrichment_json = parts[2].strip()
                    short_url = parts[3].strip()
                    
                    try:
                        enrichment = json.loads(enrichment_json) if enrichment_json else {}
                    except:
                        enrichment = {}
                    
                    records.append({
                        'id': sighting_id,
                        'title': title,
                        'enrichment': enrichment,
                        'short_url': short_url
                    })
        
        return records
    except Exception as e:
        log(f"❌ Error getting MUFON records: {e}")
        return []

def generate_proper_title(enrichment):
    """Generate proper title with classification if confidence is high enough"""
    classification = enrichment.get('classification', {})
    shape = classification.get('type', 'unknown')
    confidence = classification.get('confidence', 0.0)
    
    if confidence >= CLASSIFICATION_THRESHOLD and shape != 'unknown':
        return f"MUFON {shape.title()} Report"
    else:
        return "MUFON Report"

def generate_proper_slug(enrichment, short_url):
    """Generate proper long slug with classification and location"""
    # Get classification
    classification = enrichment.get('classification', {})
    shape = classification.get('type', 'unknown')
    confidence = classification.get('confidence', 0.0)
    
    # Get location from geocoding
    geocoding = enrichment.get('geocoding', {})
    location = geocoding.get('location', 'unknown-location')
    
    # Clean location for URL (remove state/country suffixes)
    if ',' in location:
        city = location.split(',')[0].strip()
    else:
        city = location
    
    # Clean city name for URL
    city_slug = re.sub(r'[^a-zA-Z0-9\s-]', '', city.lower())
    city_slug = re.sub(r'\s+', '-', city_slug.strip())
    
    # Get date (try multiple sources)
    occurred_at = enrichment.get('occurred_at', '')
    if occurred_at:
        try:
            from datetime import datetime
            date_obj = datetime.fromisoformat(occurred_at.replace('Z', '+00:00'))
            date_slug = date_obj.strftime('%Y-%m-%d')
        except:
            date_slug = '2025-01-01'  # fallback
    else:
        date_slug = '2025-01-01'  # fallback
    
    # Build slug with conditional classification
    if confidence >= CLASSIFICATION_THRESHOLD and shape != 'unknown':
        return f"mufon-{shape}-ufo-sighting-{city_slug}-{date_slug}-{short_url}"
    else:
        return f"mufon-ufo-sighting-{city_slug}-{date_slug}-{short_url}"

def update_record(record, new_title, new_slug, dry_run=False):
    """Update a single record with new title and slug"""
    if dry_run:
        log(f"DRY RUN: Would update {record['short_url']}")
        log(f"  Title: '{record['title']}' → '{new_title}'")
        log(f"  Slug: → '{new_slug}'")
        return True
    
    try:
        # Update title
        update_title_cmd = f"""sudo -u postgres psql -d ufobeep_db -c "UPDATE sightings SET title = '{new_title}' WHERE id = '{record['id']}';" """
        subprocess.run(update_title_cmd, shell=True, capture_output=True)
        
        # Note: Long slug storage would need to be implemented based on your slug system
        # This might involve updating a separate slugs table or enrichment_data
        
        log(f"✅ Updated {record['short_url']}: '{new_title}'")
        return True
        
    except Exception as e:
        log(f"❌ Failed to update {record['short_url']}: {e}")
        return False

def main():
    import datetime
    
    dry_run = "--dry-run" in sys.argv
    
    if dry_run:
        log("🧪 DRY RUN MODE - No database changes will be made")
    else:
        log("🔧 LIVE MODE - Database will be updated")
    
    log("📊 Fetching MUFON records...")
    records = get_mufon_records()
    
    if not records:
        log("❌ No MUFON records found")
        return
    
    log(f"📋 Found {len(records)} MUFON records to process")
    
    updated_count = 0
    high_confidence_count = 0
    
    for record in records:
        # Generate proper title and slug
        new_title = generate_proper_title(record['enrichment'])
        new_slug = generate_proper_slug(record['enrichment'], record['short_url'])
        
        # Check if classification was used
        if 'sphere' in new_title.lower() or 'light' in new_title.lower() or 'triangle' in new_title.lower():
            high_confidence_count += 1
        
        # Update if different
        if new_title != record['title']:
            if update_record(record, new_title, new_slug, dry_run):
                updated_count += 1
    
    log("")
    log("🎉 MUFON Record Correction Complete:")
    log(f"  📊 Total records: {len(records)}")
    log(f"  ✅ Updated: {updated_count}")
    log(f"  🎯 High confidence classification: {high_confidence_count}")
    log(f"  📈 Classification rate: {high_confidence_count/len(records)*100:.1f}%")

if __name__ == '__main__':
    main()