# UFOBeep API Endpoints Documentation

## 🌐 API Architecture Overview

```
UFOBeep API (FastAPI)
├── Core Endpoints (main.py)
├── Router Modules
│   ├── 📁 /admin          → Admin interface & management
│   ├── 📁 /alerts         → Alert management & triggers  
│   ├── 📁 /beep           → User engagement & responses
│   ├── 📁 /devices        → Device registration & FCM
│   ├── 📁 /emails         → Email collection system
│   ├── 📁 /media          → File upload & serving
│   ├── 📁 /mufon          → MUFON integration
│   └── 📁 /photo-analysis → Image analysis pipeline
```

---

## 🚀 Core Mobile App Endpoints

### **Anonymous Beeping** 
```http
POST /beep/anonymous
```
**Purpose**: Submit UFO sighting with automatic proximity alerts  
**Auth**: None required  
**Body**: `{device_id, location: {lat, lng}, description?, heading?}`  
**Returns**: `{sighting_id, alert_stats, witness_count}`  
**Flow**: Creates sighting → Sends proximity alerts → Returns stats

### **Alert System**
```http
GET  /alerts                    # List recent alerts (mobile feed)
GET  /alerts/{alert_id}         # Single alert details
POST /alerts/send/{sighting_id} # Manual alert sending
```

### **Media Upload Flow**
```http
POST /media/presign             # Get upload URL + metadata
POST /media/upload              # Upload file (multipart)  
POST /media/complete            # Finalize upload
GET  /media/{sighting_id}/{file} # Serve media files
```

### **Device Management**
```http
POST /devices/register          # Register device for push notifications
PATCH /devices/{id}/location    # Update device location for proximity
```

---

## 🔧 Admin & Management

### **Admin Dashboard**
```http
GET /admin/                     # Main admin interface
GET /admin/stats               # System statistics
GET /admin/recent-activity     # Recent sightings/activity
GET /admin/sightings          # Sighting management UI
GET /admin/media              # Media management UI
```

### **Rate Limiting Controls**
```http
GET /admin/ratelimit/status    # Check rate limit status
GET /admin/ratelimit/on        # Enable rate limiting
GET /admin/ratelimit/off       # Disable rate limiting
GET /admin/ratelimit/set?N     # Set rate limit threshold
```

### **Testing Endpoints**
```http
POST /admin/test/alert         # Send test proximity alert
POST /admin/test/single        # Send test push to specific device
```

---

## 📱 Engagement & Social Features

### **Witness Confirmations** 
```http
POST /sightings/{id}/witness-confirm      # "I see it too" button
GET  /sightings/{id}/witness-status/{device} # Check witness status
GET  /sightings/{id}/witness-aggregation  # Triangulation data
```

### **Beep Engagement**
```http
POST /beep/{sighting_id}/witness          # Quick action responses
GET  /beep/{sighting_id}/engagement-stats # Engagement metrics
```

---

## 🗄️ Data Management

### **Sightings CRUD**
```http
POST   /sightings             # Create full sighting
GET    /sightings/{id}        # Get sighting details
PUT    /sightings/{id}        # Update sighting
DELETE /sightings/{id}        # Delete sighting
GET    /sightings             # List sightings (paginated)
```

### **Media Management**
```http
GET    /media-management/sighting/{id}/media    # List sighting media
PUT    /media-management/{id}/set-primary       # Set primary media
PUT    /media-management/{id}/priority          # Change display order
```

---

## 🔍 Analysis & Enrichment

### **Photo Analysis**
```http
POST /photo-analysis/photo     # Analyze uploaded image
POST /photo-metadata/{id}      # Submit EXIF metadata
GET  /analysis/status/{id}     # Check analysis status
```

### **External Integrations**
```http
POST /plane-match              # Check against flight data
GET  /plane-match/health       # Service health check
POST /mufon/import            # Import MUFON reports
GET  /mufon/recent            # Recent MUFON data
```

---

## 🌐 Web & Email Integration

### **Email Collection**
```http
POST /api/v1/emails/interest   # Collect email signups
GET  /api/v1/emails/count      # Get signup count
```

### **Health & Monitoring**
```http
GET /healthz                   # Kubernetes health check
GET /ping                      # Simple connectivity test
```

---

## 🔄 Data Flow Diagram

```
Mobile App Beep Submission:
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   📱 App    │───→│  /beep/anon  │───→│ 🚨 Alerts  │
│ Submit Beep │    │ Create Sight │    │Send Nearby  │
└─────────────┘    └──────────────┘    └─────────────┘
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│Upload Media │    │  💾 Database │    │📱 Push FCM │
│/media/upload│    │Store Sighting│    │ Notifications│
└─────────────┘    └──────────────┘    └─────────────┘

Admin Management:
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│🎛️ Dashboard │───→│  Rate Limits │───→│📊 Analytics │
│/admin/      │    │ /admin/rl/*  │    │ /admin/stats│
└─────────────┘    └──────────────┘    └─────────────┘
```

---

## 🏗️ Architecture Notes

- **Main App**: Single FastAPI instance with router modules
- **Storage**: Filesystem storage at `/media/{sighting_id}/`
- **Database**: PostgreSQL with asyncpg connection pool
- **Push**: Firebase Cloud Messaging (FCM) integration
- **Proximity**: Haversine distance calculation (no PostGIS required)
- **Auth**: Device ID based (anonymous), HTTP Basic for admin