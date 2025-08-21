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
            "pricing": {"estimated_cost_usd": "$50-100"},
            "status": "coming_soon"
          },
          "iss": {...},
          "starlink": {...},
          "weather": {...},
          "aircraft": {...}
        }
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

## Devices

### Register Device
```
POST /devices
Body: {
  "device_id": "unique-device-id",
  "platform": "ios|android"
}
```