# UFOBeep Enrichment Processes Documentation

## Overview
UFOBeep uses a comprehensive enrichment pipeline that automatically analyzes sighting data across multiple dimensions to provide context and validation. This modular system runs for every beep/sighting submission.

## Core Enrichment Architecture

### EnrichmentOrchestrator
- **Location**: `api/app/services/enrichment_service.py`
- **Purpose**: Coordinates all enrichment processors
- **Features**: Async processing, error handling, priority-based execution
- **Concurrency**: Up to 3 processors run simultaneously

---

## 1. Weather Data Enrichment

### WeatherEnrichmentProcessor
- **API**: OpenWeatherMap API
- **Configuration**: Requires `openweather_api_key`
- **Data Collected**:
  - Current conditions (temperature, humidity, pressure)
  - Cloud coverage percentage
  - Visibility conditions
  - Wind speed and direction
  - Weather description
- **International Support**: Metric/Imperial unit conversion
- **Caching**: In-memory cache to reduce API calls

### Weather Data Structure:
```json
{
  "condition": "Clear", 
  "description": "Clear sky",
  "temperature": {"value": 22, "unit": "°C"},
  "humidity": {"value": 65, "unit": "%"},
  "cloud_coverage": {"value": 20, "unit": "%"},
  "visibility": {"value": 10, "unit": "km"},
  "wind": {"speed": 12, "direction": 180, "unit": "km/h"}
}
```

---

## 2. Aircraft Tracking Enrichment

### PlaneMatchService & AircraftTrackingProcessor
- **API**: OpenSky Network API
- **Configuration**: Optional `opensky_client_id`, `opensky_client_secret`
- **Process**:
  1. Query aircraft within radius (up to 80km on free tier)
  2. Calculate line-of-sight to each aircraft
  3. Compare with device pointing direction (azimuth/pitch)
  4. Generate confidence scores for matches

### Aircraft Analysis Features:
- **Angular Error Calculation**: Compares device orientation with aircraft bearing
- **Line-of-Sight Geometry**: 3D calculations including altitude
- **Confidence Scoring**: Based on angular alignment and distance
- **Aircraft Details**: Flight number, altitude, speed, heading

### Aircraft Data Structure:
```json
{
  "aircraft": [
    {
      "icao24": "a12345",
      "callsign": "UAL123",
      "altitude_m": 10668,
      "distance_km": 15.2,
      "bearing_deg": 245,
      "confidence": 0.87
    }
  ],
  "total": 1,
  "match_found": true,
  "highest_confidence": 0.87
}
```

---

## 3. Satellite Tracking Enrichment 

### SatelliteEnrichmentProcessor
- **Data Source**: TLE (Two-Line Element) data from CelesTrak
- **Process**:
  1. Download current TLE data for active satellites
  2. Calculate satellite passes for sighting location/time
  3. Identify visible satellites (Starlink, ISS, etc.)
  4. Determine brightness and trajectory

### Satellite Categories Tracked:
- **ISS (International Space Station)**
- **Starlink constellation**
- **Other bright satellites**
- **Iridium flares**

### Satellite Data Structure:
```json
{
  "visible_satellites": 3,
  "starlink_present": true,
  "brightest_magnitude": -2.1,
  "satellites": [
    {
      "name": "STARLINK-1234",
      "altitude_km": 550,
      "magnitude": -1.8,
      "azimuth": 120,
      "elevation": 45
    }
  ]
}
```

---

## 4. Celestial Data Enrichment

### CelestialEnrichmentProcessor
- **Library**: Uses Skyfield for astronomical calculations
- **Data Calculated**:
  - Moon phase and illumination
  - Sun position (day/night determination)
  - Planetary positions (Venus, Jupiter, Mars visible?)
  - Bright stars and constellations

### Celestial Data Structure:
```json
{
  "moon_phase": 0.75,
  "moon_phase_name": "Waning Gibbous",
  "moon_illumination": 75,
  "sun_elevation": -15.2,
  "is_twilight": true,
  "visible_planets": ["Venus", "Jupiter"],
  "brightest_stars": ["Sirius", "Vega"]
}
```

---

## 5. Location Enrichment

### GeocodeEnrichmentProcessor
- **API**: OpenWeatherMap Geocoding API
- **Process**: Reverse geocoding of coordinates to human-readable location
- **International Support**: Returns localized place names

### Location Data Structure:
```json
{
  "latitude": 40.7128,
  "longitude": -74.0060,
  "address": "New York, NY, US",
  "city": "New York",
  "state": "New York",
  "country": "United States",
  "timezone": "America/New_York"
}
```

---

## 6. Satellite Imagery Services

### BlackSkyService (Premium)
- **Purpose**: High-resolution commercial satellite imagery
- **Status**: "Coming Soon" feature
- **Capabilities**: 35cm resolution, 90-minute delivery
- **Cost**: $50-100 per image

### SkyFi Integration 
- **Purpose**: On-demand satellite imagery
- **Processors**: 
  - `api/app/enrichment/skyfi_processor.py`
  - `api/app/enrichment/blacksky_processor.py`

---

## 7. Photo Analysis Enrichment

### PhotoAnalysisService
- **Purpose**: Astronomical object identification in photos
- **Process**:
  1. Extract EXIF metadata (timestamp, GPS, camera settings)
  2. Query NASA JPL Horizons for celestial object positions
  3. Match bright objects in photo with known celestial bodies
  4. Generate sky map for comparison

### Photo Analysis Features:
- **EXIF Data Extraction**: Camera settings, GPS, timestamp
- **Astrometry**: Match photo coordinates with sky catalog
- **Object Identification**: Stars, planets, satellites
- **Light Pollution Analysis**: Sky brightness assessment

---

## 8. Content Filtering

### ContentFilterProcessor
- **API**: HuggingFace Transformers API
- **Models**: `martin-ha/toxic-comment-model`
- **Purpose**: NSFW detection, content classification
- **Status**: Modular component, can be enabled/disabled

---

## 9. Processing Summary

### EnrichmentDataGenerator
- **Purpose**: Coordinates all enrichment data into unified structure
- **Features**:
  - Intelligent unit conversion (metric/imperial)
  - Error handling for failed processors
  - International compatibility
  - Modular architecture for adding new processors

### Complete Enrichment Data Structure:
```json
{
  "location": {...},
  "weather": {...},
  "aircraft_tracking": {...},
  "satellites": {...},
  "celestial": {...},
  "blacksky_imagery": {...},
  "skyfi_imagery": {...},
  "processing_summary": {
    "total_processors": 7,
    "successful_processors": 6,
    "failed_processors": 1,
    "processing_time_ms": 2341
  }
}
```

---

## International Compatibility Standards

### Coordinate Systems
- **Standard**: WGS84 decimal degrees
- **Precision**: 6 decimal places (~0.1m accuracy)

### Time Formats  
- **Standard**: ISO 8601 with timezone
- **Example**: `2025-01-15T20:30:00-05:00`

### Unit Systems
- **Automatic Detection**: Based on user location
- **Support**: Both metric and imperial
- **Conversion**: Real-time based on user preferences

### Language Support
- **Geocoding**: Returns localized place names
- **Weather**: Supports multiple languages via API
- **Classifications**: Shape-based (language-agnostic)

---

## Configuration & API Keys

### Required Environment Variables:
```bash
# Weather data
OPENWEATHER_API_KEY=your_key_here

# Aircraft tracking (optional for premium features)
OPENSKY_CLIENT_ID=your_id
OPENSKY_CLIENT_SECRET=your_secret

# AI content filtering (optional)
HUGGINGFACE_API_TOKEN=your_token
```

### Feature Flags:
- `plane_match_enabled`: Enable/disable aircraft tracking
- `plane_match_radius_km`: Search radius (max 80km free tier)
- `plane_match_tolerance_deg`: Angular tolerance for matches

---

## Performance & Reliability

### Caching Strategy
- **Weather**: 5-minute cache per location
- **TLE Data**: 24-hour cache for satellite data
- **Geocoding**: Persistent cache for coordinate lookups

### Error Handling
- **Graceful Degradation**: Failed processors don't stop others
- **Timeout Management**: 30-second timeout per processor
- **Retry Logic**: Automatic retry for transient failures

### Monitoring
- **Success Rates**: Track per-processor success rates
- **Performance**: Monitor processing times
- **API Usage**: Track API call quotas and limits

This enrichment pipeline provides comprehensive context for every UFO sighting, helping users and researchers understand environmental conditions, potential conventional explanations, and astronomical context at the time of each reported event.