# UFOBeep API Endpoints Documentation
## 🚀 **Service Layer Architecture** - Post-Refactoring

> **⚡ ARCHITECTURE REVOLUTION COMPLETE**: 3,039 lines demolished, service layers deployed!
>
> - **main.py**: 2,564 → 974 lines (62% reduction) 
> - **admin.py**: 3,141 → 1,692 lines (46% reduction)
> - **Clean Architecture**: Business logic separated into service layers
> - **Military-Grade Code**: HTTP handlers are now thin and focused

---

## 🏗️ **New Service Layer Architecture**

```
UFOBeep API (FastAPI + Service Layer)
├── 🎯 Thin HTTP Endpoints (20-50 lines each)
├── 🧠 Service Layer (Business Logic)
│   ├── AlertsService      → Alert creation, witness management  
│   ├── AdminService       → Dashboard stats, sighting management
│   ├── MediaService       → File upload, storage management
│   ├── EnrichmentService  → Weather, celestial, satellite data
│   └── ProximityService   → Alert fanout, device discovery
└── 🗄️ Data Layer (Database, Storage)
```

---

## 🚀 **Core Mobile App Endpoints** 
*CLEAN UNIFIED `/alerts` ARCHITECTURE*

### **Unified Alert Creation** 
```http
POST /alerts
```
**🆕 CLEAN**: Single endpoint for all beep creation  
**Purpose**: Submit UFO sighting with automatic proximity alerts  
**Auth**: None required  
**Body**: 
```json
{
  "device_id": "unique_device_identifier",
  "location": {
    "latitude": 47.6062,
    "longitude": -122.3321
  },
  "description": "Bright light moving erratically",
  "has_media": true
}
```
**Returns**: 
```json
{
  "sighting_id": "uuid",
  "message": "Anonymous beep sent successfully", 
  "alert_message": "Your beep alerted 3 people nearby!",
  "alert_stats": {"total_alerted": 3, "radius_km": 25},
  "location_jittered": true
}
```

### **Alert System**
```http
GET  /alerts                    # List recent alerts (mobile feed)
GET  /alerts/{alert_id}         # Single alert details
POST /alerts/{alert_id}/media   # Upload media to alert
```

**🆕 Refactored**: All endpoints use `AlertsService` with clean data models
- **62-line handlers** (was 160+ line bloated endpoints)
- **Proper error handling** with consistent response format
- **Service layer separation** - HTTP concerns vs business logic

---

## 📱 **Witness System** 
*Military-grade witness confirmation and aggregation*

### **Witness Confirmations** 
```http
POST /sightings/{id}/witness-confirm      # "I see it too" button
GET  /sightings/{id}/witness-status/{device} # Check witness status  
GET  /sightings/{id}/witness-aggregation  # Triangulation data
```

**🆕 Service Layer Methods**:
- `AlertsService.confirm_witness()` - Records witness confirmation
- `AlertsService.get_witness_status()` - Checks confirmation state
- `AlertsService.get_witness_aggregation()` - Triangulation analysis

**Example Witness Confirmation**:
```json
{
  "device_id": "device_123",
  "location": {"latitude": 47.6062, "longitude": -122.3321},
  "description": "Confirmed - saw bright object",
  "confidence": "high",
  "duration_seconds": 45
}
```

---

## 🎛️ **Admin Dashboard** 
*Clean Admin Service Architecture*

### **Core Admin Endpoints**
```http
GET /admin/                     # Dashboard with service layer stats
GET /admin/sightings           # Sighting management (refactored)
GET /admin/system              # System status with service metrics
GET /admin/media               # Media management (streamlined)
```

**🆕 Refactored Admin Features**:
- **AdminService integration** - All admin functions use service layer
- **30-line handlers** (was 352-line dashboard function)
- **Clean HTML generation** - No more embedded business logic
- **Consistent error handling** across all admin routes

### **Advanced Admin Tools**
```http
GET /admin/witnesses           # Witness management dashboard
GET /admin/alerts             # Proximity alert testing interface  
GET /admin/aggregation        # Witness triangulation analysis
GET /admin/engagement/metrics # User engagement analytics
```

### **Rate Limiting & Control**
```http
GET /admin/ratelimit/status    # Check rate limit status
GET /admin/ratelimit/on        # Enable rate limiting
GET /admin/ratelimit/off       # Disable rate limiting
GET /admin/ratelimit/set?threshold=N # Set rate limit threshold
```

### **Testing & Diagnostics**
```http
POST /admin/test/alert         # Send test proximity alert
POST /admin/test/single        # Send test push to specific device
GET  /admin/location-search    # Geocoding helper for testing
```

---

## 📊 **Data Management**
*Service-Powered CRUD Operations*

### **Sightings** 
```http
POST   /sightings             # Create full sighting (with enrichment)
GET    /alerts                # List recent sightings as alerts
GET    /alerts/{id}           # Get single sighting/alert details
```

**🆕 Enhanced Features**:
- **Automatic enrichment** - Weather, celestial data, satellite checks
- **Location privacy** - GPS jittering for anonymous reports
- **Media integration** - Seamless file upload workflow

---

## 🔍 **Analysis & Enrichment Pipeline**

### **Photo Analysis**
```http
GET  /analysis/status/{sighting_id}  # Check analysis status
```

**🆕 Integration Points**:
- **Automatic analysis** triggered on media upload
- **Service layer coordination** between media and analysis services
- **Enrichment data** integrated into sighting responses

---

## 🌐 **Additional Services**

### **Device Management** 
```http  
POST /devices/register          # Register device for push notifications
GET  /devices                  # List user devices
PUT  /devices/{id}             # Update device settings
```

### **Media Upload**
```http
POST /alerts/{alert_id}/media   # Upload media files to alert
GET  /media/{alert_id}/{file}   # Serve media files
```

### **Health & Monitoring**
```http
GET /healthz                   # Kubernetes health check
GET /ping                      # Simple connectivity test
```

---

## 🔄 **Service Layer Data Flow**

```
📱 Anonymous Beep Submission (New Architecture):
┌─────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   📱 App    │───→│ Thin HTTP Handler│───→│  AlertsService  │
│ Submit Beep │    │  (30 lines)     │    │ Business Logic  │
└─────────────┘    └──────────────────┘    └─────────────────┘
                            │                        │
                            ▼                        ▼
                   ┌──────────────────┐    ┌─────────────────┐
                   │  Error Handling  │    │ ProximityService│
                   │  & Validation    │    │ Alert Fanout    │
                   └──────────────────┘    └─────────────────┘

🎛️ Admin Dashboard (Post-Demolition):
┌─────────────┐    ┌──────────────────┐    ┌─────────────────┐
│🎛️ Dashboard │───→│ Clean Handler    │───→│  AdminService   │
│    UI       │    │  (30 lines)     │    │ Dashboard Stats │
└─────────────┘    └──────────────────┘    └─────────────────┘
                            │                        │
                            ▼                        ▼
                   ┌──────────────────┐    ┌─────────────────┐
                   │  HTML Templates  │    │    Database     │
                   │  (No Logic)      │    │   Queries       │
                   └──────────────────┘    └─────────────────┘
```

---

## 📈 **Performance Improvements**

### **Before Refactoring**:
- 📊 main.py: 2,564 lines with bloated 200+ line endpoints
- 📊 admin.py: 3,141 lines with mixed HTTP/business logic  
- ❌ **Maintenance nightmare** - business logic scattered everywhere
- ❌ **Testing difficulty** - HTTP concerns mixed with business rules

### **After Service Layer Revolution + Spaghetti Elimination**:
- ✅ **Clean architecture** - HTTP handlers 20-50 lines each
- ✅ **Service separation** - Business logic in dedicated services
- ✅ **Easy testing** - Services can be unit tested independently  
- ✅ **Maintainable code** - Clear separation of concerns
- ✅ **4,157 lines obliterated** (3,039 refactor + 1,118 redundant endpoints)
- ✅ **Single media endpoint** - No more confusing duplicate upload routes
- ✅ **Firebase FCM working** - Push notifications functional

---

## 🔧 **Service Architecture Benefits**

1. **🎯 Thin HTTP Handlers**: Focus only on request/response concerns
2. **🧠 Service Layer**: Contains all business logic and complex operations
3. **🔄 Reusable Services**: Business logic can be reused across different endpoints
4. **🧪 Testable Code**: Services can be unit tested without HTTP mocking
5. **📈 Performance**: Cleaner code with better maintainability and performance
6. **🔒 Error Handling**: Consistent error patterns across all endpoints

**The UFOBeep API has been transformed from bloated spaghetti code into a military-grade, service-oriented architecture! 🚀**

---

## 📱 **Universal Widget System Architecture** 
*Cross-Platform Component Reusability (COMPLETED - 2025-08-19)*

### **Mobile App Modular Widgets**
```
/app/lib/widgets/alert_sections/
├── AlertHeroSection        → Media display with web-optimized images
├── AlertDetailsSection     → Location, description, metadata
├── AlertDirectionSection   → Compass, bearing, distance calculation  
├── AlertWitnessSection     → "I SEE IT TOO!" with confirmation counts
└── AlertActionsSection     → Join Chat, Add Photos, Report to MUFON
```

**🆕 ARCHITECTURE BENEFITS**:
- **Universal Reusability** - Same widgets work across mobile app, website, and different pages
- **Clean Separation** - Each section handles its own logic and styling
- **Consistent Styling** - 12px border radius, unified padding, cohesive design
- **Performance Optimized** - No actual image loading in list views (just indicators)

### **Alert List Refactoring** 
```http
AlertCard Component (Completely Rewritten):
```
**🆕 CLEAN LIST DISPLAY**:
- **UFO Emoji Icons** - Clean visual identifier (no image loading)
- **Media Indicators** - Photo/video icons with counts (🎥 3, 📷 5)
- **Witness Confirmations** - Only shown when > 1 confirmations
- **Distance Badges** - Color coded: Red < 1km, Orange < 5km, Green < 15km, Gray > 15km
- **Location Fallback** - Shows coordinates when location name unavailable
- **Backward Compatible** - Existing navigation continues working

### **Styling Consistency**
```css
Universal Design Tokens:
- Border Radius: 12px (all cards and buttons)
- Padding: 16px standard, 20px for sections
- Colors: Unified AppColors theme
- Typography: Consistent font weights and sizes
```

**🆕 CODE REUSE STRATEGY**:
- **Mobile First** - Universal sections designed for Flutter
- **Web Integration** - Same component patterns adaptable to Next.js
- **Cross-Platform** - Single source of truth for UI components
- **Maintainable** - Changes in one place update entire system