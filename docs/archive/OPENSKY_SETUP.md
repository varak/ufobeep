# OpenSky Network Setup Guide

This guide explains how to set up OpenSky Network integration for UFOBeep's plane matching feature.

## Overview

UFOBeep uses the [OpenSky Network](https://opensky-network.org/) to identify commercial aircraft that might be mistaken for UFOs. When a user captures a photo of a sky object, the system:

1. Captures device sensor data (GPS, compass, pitch/roll)
2. Queries OpenSky's free API for nearby aircraft
3. Performs line-of-sight calculations to match the object
4. Displays "Likely plane: [callsign]" if a match is found

## Getting OpenSky Credentials

### 1. Create an OpenSky Account

1. Visit [https://opensky-network.org](https://opensky-network.org)
2. Click "Sign Up" and create a free account
3. Verify your email address

### 2. Get API Credentials

1. Log in to your OpenSky account
2. Go to [My OpenSky](https://opensky-network.org/my-opensky)
3. Your username and password serve as API credentials
4. Note: API access requires a verified account

### 3. Configure Environment Variables

Add these to your `.env` file:

```bash
# OpenSky Network Configuration
OPENSKY_CLIENT_ID=your_username_here
OPENSKY_CLIENT_SECRET=your_password_here

# Plane Matching Settings (optional, defaults shown)
PLANE_MATCH_ENABLED=true
PLANE_MATCH_RADIUS_KM=50.0          # Max 80km for free tier
PLANE_MATCH_TOLERANCE_DEG=2.5       # Angular tolerance for matches
PLANE_MATCH_CACHE_TTL=10            # Cache duration in seconds
PLANE_MATCH_TIME_QUANTIZATION=5     # Time buckets for caching
```

## API Quotas and Limitations

### Free Tier Limits

- **Requests per day**: 400 with credentials, 100 anonymous
- **Rate limiting**: Reasonable use expected
- **Geographic scope**: Worldwide coverage
- **Data resolution**: 5-second updates for authenticated users
- **Bounding box**: Recommended ≤80km radius to stay within quotas

### Commercial Use

⚠️ **Important**: The OpenSky Network free tier is for **non-commercial use only**. 

If UFOBeep becomes a commercial service, you must:
- Contact OpenSky for commercial licensing
- Consider alternative data sources
- Implement tiered access based on user subscription

## Technical Details

### Authentication

UFOBeep uses OAuth2 client credentials flow:

```http
POST https://opensky-network.org/api/auth/token
Authorization: Basic base64(client_id:client_secret)
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials
```

### API Endpoints Used

**States API**: `/api/states/all`
- Retrieves current aircraft positions
- Supports bounding box filtering
- Returns state vectors with position, altitude, velocity, etc.

### Line-of-Sight Calculation

The system performs geometric analysis:

1. **Device Orientation**: Uses magnetometer + accelerometer for compass heading and pitch
2. **Aircraft Position**: Gets lat/lon/altitude from OpenSky
3. **Angular Comparison**: Calculates bearing/elevation to aircraft vs device pointing direction
4. **Tolerance Matching**: Considers matches within configurable tolerance (default 2.5°)

### Caching Strategy

To minimize API usage:

- **Time Quantization**: Groups requests into 5-second buckets
- **Geographic Caching**: Cache results per bounding box
- **TTL**: 10-second cache expiration
- **Deduplication**: Avoid duplicate requests for similar locations/times

## Configuration Options

### Plane Matching Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `PLANE_MATCH_ENABLED` | `true` | Enable/disable the feature |
| `PLANE_MATCH_RADIUS_KM` | `50.0` | Search radius (max 80km for free tier) |
| `PLANE_MATCH_TOLERANCE_DEG` | `2.5` | Angular tolerance for matches |
| `PLANE_MATCH_CACHE_TTL` | `10` | Cache duration in seconds |
| `PLANE_MATCH_TIME_QUANTIZATION` | `5` | Time bucket size in seconds |

### Recommended Production Settings

```bash
# Conservative settings for production
PLANE_MATCH_RADIUS_KM=30.0          # Smaller radius for better quota usage
PLANE_MATCH_TOLERANCE_DEG=3.0       # Slightly looser for mobile device accuracy
PLANE_MATCH_CACHE_TTL=15            # Longer cache to reduce API calls
```

## Testing the Integration

### 1. Check Service Health

```bash
curl http://localhost:8000/v1/plane-match/health
```

Expected response:
```json
{
  "status": "healthy",
  "plane_match_enabled": true,
  "radius_km": 50.0,
  "tolerance_deg": 2.5,
  "opensky_configured": true
}
```

### 2. Test Plane Matching

Use the mobile app or send a direct API request:

```bash
curl -X POST http://localhost:8000/v1/plane-match \
  -H "Content-Type: application/json" \
  -d '{
    "sensor_data": {
      "utc": "2024-01-01T12:00:00Z",
      "latitude": 37.7749,
      "longitude": -122.4194,
      "azimuth_deg": 45.0,
      "pitch_deg": 30.0,
      "accuracy": 5.0
    }
  }'
```

## Troubleshooting

### Common Issues

**1. "Aircraft data service unavailable"**
- Check your credentials in `.env`
- Verify OpenSky account is verified
- Check if you've exceeded daily quota

**2. "OpenSky authentication failed"**
- Double-check username/password
- Ensure account is active and verified
- Try generating API tokens from OpenSky dashboard

**3. "No aircraft found"**
- Normal in rural areas or over oceans
- Try testing near major airports
- Check if radius is reasonable for the area

**4. Rate limiting errors**
- Reduce `PLANE_MATCH_RADIUS_KM`
- Increase `PLANE_MATCH_CACHE_TTL`
- Implement request queuing for high traffic

### Debug Logging

Enable debug logging to see API interactions:

```bash
# In your .env
LOG_LEVEL=DEBUG
```

Check logs for:
- OpenSky API request/response details
- Authentication token refresh
- Cache hit/miss statistics
- Line-of-sight calculation details

## Alternative Data Sources

If OpenSky becomes unavailable or insufficient:

1. **ADS-B Exchange**: Community-driven, requires API key
2. **FlightRadar24**: Commercial API, paid tiers
3. **AirLabs**: Flight tracking API with free tier
4. **Airplanes.live**: Real-time flight tracking

Each requires different integration work and has different terms of service.

## Compliance Notes

- Ensure proper attribution to OpenSky Network in your UI
- Respect rate limits and don't abuse the free service  
- Monitor usage to stay within commercial/non-commercial boundaries
- Consider contributing to OpenSky if you have ADS-B receivers

## Support

- OpenSky Network: [https://opensky-network.org/community](https://opensky-network.org/community)
- UFOBeep Issues: [GitHub Issues](https://github.com/ufobeep/ufobeep/issues)
- API Documentation: [https://opensky-network.org/api](https://opensky-network.org/api)