#!/usr/bin/env python3
import requests
import json
from datetime import datetime, timedelta
import random
import uuid

API_BASE = "https://api.ufobeep.com"

# Real Vegas locations spread around the city
vegas_locations = [
    {
        "name": "Near Red Rock Canyon",
        "lat": 36.1354, 
        "lon": -115.4274,
        "title": "Bright light moving erratically",
        "description": "Saw a very bright white light moving back and forth about 500 feet up. Way too fast and erratic to be a plane. No sound at all.",
        "category": "light"
    },
    {
        "name": "Henderson area", 
        "lat": 36.0395,
        "lon": -114.9817,
        "title": "Multiple objects in formation",
        "description": "Four orange lights in diamond formation moving slowly across sky from east to west. They stayed in perfect formation for about 3 minutes.",
        "category": "formation"
    },
    {
        "name": "Summerlin", 
        "lat": 36.1662,
        "lon": -115.3063,
        "title": "Triangular craft with lights",
        "description": "Large triangle shape with three white lights at corners and red light in center. Silent. Moved slowly overhead then accelerated rapidly.",
        "category": "triangle"
    },
    {
        "name": "North Las Vegas",
        "lat": 36.2147, 
        "lon": -115.1372,
        "title": "Disc-shaped object hovering", 
        "description": "Metallic disc hovering motionless for several minutes near Nellis AFB area. Then shot straight up and disappeared.",
        "category": "disc"
    },
    {
        "name": "Boulder City direction",
        "lat": 36.0108,
        "lon": -114.8315, 
        "title": "Fast moving light",
        "description": "Single bright blue-white light moving incredibly fast in zigzag pattern. Faster than any aircraft I've seen.",
        "category": "light"
    }
]

def create_sensor_data(lat, lon):
    """Create realistic sensor data for the location"""
    now = datetime.utcnow()
    return {
        'timestamp': now.isoformat() + 'Z',
        'latitude': lat + random.uniform(-0.001, 0.001),  # Small jitter
        'longitude': lon + random.uniform(-0.001, 0.001),
        'altitude': random.uniform(550, 700),  # Vegas elevation ~500-600m
        'accuracy': random.uniform(3.0, 8.0),
        'heading': random.uniform(0, 360),
        'speed': random.uniform(0, 2),  # Slow walking speed
        'atmospheric_pressure': random.uniform(1010, 1020),
        'temperature': random.uniform(15, 35),  # Celsius
        'humidity': random.uniform(10, 30),  # Low humidity for Vegas
        'light_level': random.uniform(0.1, 50.0) if now.hour >= 19 or now.hour <= 6 else random.uniform(1000, 50000)
    }

def submit_sighting(location_data):
    """Submit a sighting using the same format as the app - anonymous beep style"""
    
    # Generate unique device ID for this submission
    device_id = f"test_device_{uuid.uuid4().hex[:8]}"
    
    payload = {
        'device_id': device_id,
        'location': {
            'latitude': location_data['lat'],
            'longitude': location_data['lon']
        },
        'description': location_data['description'],
        'has_media': False  # No media for these test alerts
    }
    
    try:
        response = requests.post(f"{API_BASE}/alerts", json=payload)
        if response.status_code == 200 or response.status_code == 201:
            result = response.json()
            print(f"✅ Created alert: {location_data['title']} at {location_data['name']}")
            print(f"   Response: {result.get('message', 'N/A')}")
            if 'alert_message' in result:
                print(f"   Alert stats: {result['alert_message']}")
            return result.get('sighting_id')
        else:
            print(f"❌ Failed to create {location_data['title']}: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error submitting {location_data['title']}: {e}")
        return None

def main():
    print("Creating 5 realistic Vegas area sightings...")
    print(f"API Base: {API_BASE}")
    
    created_ids = []
    
    for i, location in enumerate(vegas_locations, 1):
        print(f"\n{i}/5: Creating sighting near {location['name']}")
        sighting_id = submit_sighting(location)
        if sighting_id:
            created_ids.append(sighting_id)
        
        # Small delay between submissions
        import time
        time.sleep(0.5)
    
    print(f"\n🎉 Successfully created {len(created_ids)} sightings around Vegas!")
    if created_ids:
        print("Sighting IDs:", created_ids)

if __name__ == "__main__":
    main()