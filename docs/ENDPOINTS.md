# API Endpoints

Base URL: `https://api.ufobeep.com`

## Health Check
```
GET /healthz
Response: {"ok": true}
```

## Alerts

### List Alerts (Paginated)
```
GET /alerts

Response:
{
  "success": true,
  "data": {
    "alerts": [
      {
        "id": "17f5bc52-82e8-42af-8d8f-3ffb22996f41",
        "created_at": "2025-08-20T18:36:17.460145+00:00",
        "latitude": 36.1234,
        "longitude": -115.5678,
        "location_description": "Las Vegas, NV",
        "enrichment_data": {
          "blacksky": {
            "available": true,
            "name": "BlackSky High-Resolution Imagery",
            "status": "coming_soon"
          },
          "skyfi": {
            "available": true,
            "name": "SkyFi High-Resolution Imagery", 
            "status": "coming_soon"
          },
          "iss": {...},
          "starlink": {...},
          "weather": {...},
          "aircraft": {...}
        }
        
Note: Premium satellite imagery (BlackSky/SkyFi) only visible to:
- Alert creator
- Confirmed witnesses within 2x visibility distance
      }
    ]
  },
  "total": 5,
  "limit": 20,
  "offset": 0
}

Note: Alerts wrapped in data.alerts (nested structure)
```

### Create Alert
```
POST /alerts
Body: {
  "latitude": 36.1234,
  "longitude": -115.5678,
  "description": "Strange lights"
}
```

## Media

### Get Upload Presign URL
```
POST /upload/presign
Body: {
  "filename": "photo.jpg",
  "content_type": "image/jpeg"
}
```

### Attach Media to Alert
```
POST /media/attach
Body: {
  "alert_id": "uuid",
  "media_url": "s3://bucket/key"
}
```

## Users (MP13-1 Username System)

### Generate Username
```
POST /users/generate-username
Response: {
  "username": "cosmic.whisper.7823",
  "alternatives": ["stellar.probe.1234", "galactic.echo.5678", ...]
}
```

### Register User
```
POST /users/register
Body: {
  "device_id": "unique-device-id",
  "username": "cosmic.whisper.7823",  // optional, auto-generated if not provided
  "email": "user@example.com",        // optional
  "platform": "ios|android",
  "device_name": "iPhone 15",         // optional
  "app_version": "1.0.0",            // optional
  "alert_range_km": 50.0,            // optional, default 50
  "units_metric": true,              // optional, default true
  "preferred_language": "en"         // optional, default "en"
}

Response: {
  "user_id": "uuid",
  "username": "cosmic.whisper.7823",
  "device_id": "unique-device-id",
  "is_new_user": true,
  "message": "Welcome to UFOBeep, cosmic.whisper.7823!"
}
```

### Get User by Device ID
```
GET /users/by-device/{device_id}
Response: {
  "user_id": "uuid",
  "username": "cosmic.whisper.7823",
  "device_id": "device-id",
  "is_new_user": false,
  "message": "User found"
}
```

### Get User Profile
```
GET /users/profile/{username}
Response: {
  "user_id": "uuid",
  "username": "cosmic.whisper.7823",
  "email": "user@example.com",      // only if public_profile=true
  "display_name": "Cosmic Whisper",
  "alert_range_km": 50.0,
  "units_metric": true,
  "preferred_language": "en",
  "is_verified": false,
  "created_at": "2025-08-22T10:30:00Z",
  "stats": {
    "sightings_reported": 5,
    "sightings_witnessed": 12,
    "total_engagement": 17,
    "member_since": "2025-08"
  }
}
```

### Validate Username
```
POST /users/validate-username?username=cosmic.whisper.7823
Response: {
  "valid": true,
  "available": true,
  "error": null
}
```

### Migrate Device to User
```
POST /users/migrate-device-to-user?device_id=device-id
Response: {
  "success": true,
  "message": "Device migrated to user system",
  "username": "legacy.device.1234",
  "user_id": "uuid"
}
```

## Devices

### Register Device
```
POST /devices
Body: {
  "device_id": "unique-device-id",
  "platform": "ios|android"
}
```