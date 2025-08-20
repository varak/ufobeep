# UFOBeep API Endpoints Documentation (v12)
## 🚀 **Service Layer Architecture** - Enhanced for User System & Witness Media

> **⚡ ARCHITECTURE UPDATES (v12)**: Witness media sharing, human-readable IDs, viral social integration!
>
> - **New User System**: `cosmic-whisper-7823` human-readable identifiers
> - **Multi-User Media**: Witnesses can contribute evidence to alerts
> - **Social Sharing**: Localized viral sharing (X, VK, WeChat)
> - **Simple Moderation**: 3-flag auto-hide system, no complex queues
> - **No Matrix Chat**: Replaced with evidence-only witness interaction

---

## 🏗️ **Enhanced Service Layer Architecture (v12)**

```
UFOBeep API (FastAPI + Enhanced Service Layer)
├── 🎯 Thin HTTP Endpoints (20-50 lines each)
├── 🧠 Enhanced Service Layer
│   ├── UserService          → Human ID generation, registration
│   ├── AlertsService        → Alert creation, witness management  
│   ├── MediaService         → Multi-user uploads, attribution
│   ├── ModerationService    → Auto-filtering, community flagging
│   ├── SocialService        → Viral sharing, platform configs
│   ├── EnrichmentService    → Weather, aircraft, satellite data
│   └── ProximityService     → Alert fanout, device discovery
└── 🗄️ Enhanced Data Layer (Users, Multi-media, Flags)
```

---

## 🚀 **Core Mobile App Endpoints (v12 Enhanced)**

### **User Registration System (NEW)**
```http
POST /users/generate-id
```
**Purpose**: Generate human-readable username like `cosmic-whisper-7823`
**Auth**: None required
**Returns**: 
```json
{
  "human_id": "cosmic-whisper-7823",
  "available": true
}
```

```http
GET /users/check-availability/{human_id}
POST /users/register
GET /users/{id}/profile
```

### **Enhanced Alert Creation** 
```http
POST /alerts
```
**🆕 v12 ENHANCED**: Now with user attribution
**Body**: 
```json
{
  "user_id": "cosmic-whisper-7823",
  "device_id": "unique_device_identifier", 
  "location": {"latitude": 47.6062, "longitude": -122.3321},
  "description": "Bright light moving erratically",
  "has_media": true
}
```
**Returns**: 
```json
{
  "alert_id": "uuid",
  "human_readable_id": "UFO-2025-001234",
  "message": "Beep sent successfully",
  "alert_stats": {"total_alerted": 3, "radius_km": 25},
  "share_url": "https://ufobeep.com/alerts/UFO-2025-001234"
}
```

### **Multi-User Media System (v12 CORE)**
```http
POST /alerts/{alert_id}/media
```
**🆕 v12 ENHANCED**: Multi-user uploads with attribution
**Headers**: `X-User-ID: cosmic-whisper-7823`
**Purpose**: Original sighter OR witnesses can upload media
**Body**: Form data with media files
**Returns**:
```json
{
  "media_id": "uuid",
  "filename": "evidence_photo.jpg",
  "uploaded_by": "stellar-phoenix-9876",
  "is_witness_upload": true,
  "url": "https://api.ufobeep.com/media/alert123/stellar-phoenix-9876_evidence.jpg"
}
```

### **Witness System (v12 Enhanced)**
```http
POST /alerts/{alert_id}/witness
```
**🆕 v12 ENHANCED**: Now includes optional media upload
**Body**:
```json
{
  "user_id": "cosmic-whisper-7823",
  "device_id": "device_123",
  "location": {"latitude": 47.6062, "longitude": -122.3321},
  "has_media": true,
  "description": "I can confirm this sighting"
}
```

---

## 📱 **Content Moderation System (NEW in v12)**

### **Auto-NSFW Detection**
```http
POST /alerts/{alert_id}/media (enhanced)
```
**🆕 Auto-filtering**: Images/videos scanned before storage
- HuggingFace Vision API integration
- Google Vision SafeSearch
- Auto-rejection of flagged content

### **Community Flagging**
```http
POST /alerts/{alert_id}/media/{media_id}/flag
```
**Purpose**: Community-driven content moderation
**Body**:
```json
{
  "user_id": "cosmic-whisper-7823",
  "flag_type": "NSFW", // NSFW, Spam, Unrelated
  "reason": "Inappropriate content"
}
```

**Auto-hide logic**: 3 flags → content hidden automatically

```http
GET /admin/moderation/flagged
DELETE /alerts/{alert_id}/media/{media_id}
```

---

## 🌐 **Viral Social Sharing System (NEW in v12)**

### **Social Platform Configuration**
```http
GET /social/platforms/{locale}
```
**Purpose**: Get locale-specific social platforms
**Examples**:
- `en_US`: X, Facebook, WhatsApp
- `ru_RU`: VKontakte, Telegram  
- `zh_CN`: WeChat, Weibo
**Returns**:
```json
{
  "platforms": [
    {
      "name": "X", 
      "url_template": "https://x.com/intent/tweet?text={message}",
      "message_template": "UFO sighting {alert_id} near {location}! {url}"
    }
  ]
}
```

### **Share URL Generation**
```http
POST /social/share/{alert_id}
```
**Purpose**: Generate platform-specific share URLs
**Body**:
```json
{
  "platform": "X",
  "locale": "en_US",
  "user_id": "cosmic-whisper-7823"
}
```

---

## 🎛️ **Admin Dashboard (Enhanced for v12)**

### **User Management (NEW)**
```http
GET /admin/users              # User statistics
GET /admin/users/{id}         # Individual user details
POST /admin/users/{id}/suspend # Moderation actions
```

### **Enhanced Media Management**
```http
GET /admin/media              # All media with attribution
GET /admin/media/flagged      # Flagged content queue
POST /admin/media/{id}/restore # Restore flagged content
```

### **Social Sharing Analytics (NEW)**
```http
GET /admin/social/stats       # Share conversion rates
GET /admin/social/platforms   # Platform performance
```

---

## 🔍 **Enhanced Enrichment Pipeline (v11 + v12)**

### **Aircraft Tracking (v11)**
```http
GET /enrichment/aircraft/{alert_id}
```
**🆕 OpenSky Integration**: Real-time aircraft data
**Purpose**: Identify possible aircraft matches

### **Advanced Weather + Light Pollution (v11)**
```http
GET /enrichment/weather/{alert_id}
```
**🆕 Enhanced**: Bortle scale, sky quality data

### **Precise Satellite Tracking (v11)**
```http
GET /enrichment/satellites/{alert_id}
```
**🆕 NASA TLE Data**: Exact ISS position, BlackSky integration

---

## 🔄 **v12 Data Flow Architecture**

```
📱 Enhanced Beep Submission (v12):
┌─────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   📱 App    │───→│ User Attribution │───→│  AlertsService  │
│ User: cosmic│    │ Human ID Lookup  │    │ + MediaService  │
│ -whisper-7823│   │                  │    │                 │
└─────────────┘    └──────────────────┘    └─────────────────┘
                            │                        │
                            ▼                        ▼
                   ┌──────────────────┐    ┌─────────────────┐
                   │ Social Share     │    │ ProximityService│
                   │ Modal (NEW)      │    │ Alert Fanout    │
                   └──────────────────┘    └─────────────────┘

🎭 Witness Media Flow (v12):
┌─────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ Witness App │───→│ "I SEE IT TOO"   │───→│ MediaService    │
│ stellar-    │    │ + Media Upload   │    │ Multi-user      │
│ phoenix-9876│    │                  │    │ Attribution     │
└─────────────┘    └──────────────────┘    └─────────────────┘
                            │                        │
                            ▼                        ▼
                   ┌──────────────────┐    ┌─────────────────┐
                   │ Auto-NSFW Filter │    │ Community       │
                   │ + Virus Scan     │    │ Flagging System │
                   └──────────────────┘    └─────────────────┘
```

---

## 📈 **v12 Performance Improvements**

### **Before v12**:
- ❌ Anonymous-only system
- ❌ Single-user media uploads  
- ❌ No viral sharing mechanism
- ❌ Complex Matrix chat system

### **After v12 Revolution**:
- ✅ **Human-readable attribution** - `cosmic-whisper-7823` format
- ✅ **Multi-witness evidence** - Multiple users can contribute media
- ✅ **Viral growth engine** - Localized social sharing
- ✅ **Simple moderation** - 3-flag auto-hide, no admin burden
- ✅ **Evidence-focused interaction** - No chat, just media sharing
- ✅ **Progressive registration** - Collect data when needed

---

## 🔧 **v12 Service Architecture Benefits**

1. **👤 User Attribution**: Every action tied to human-readable ID
2. **📸 Evidence Collection**: Multi-angle witness media
3. **🚀 Viral Mechanics**: Share buttons drive user acquisition
4. **🛡️ Smart Moderation**: Community self-policing with auto-restoration
5. **🌍 Global Ready**: Localized social platforms per region
6. **⚡ Speed Preserved**: Registration optional, beeping still ≤3 seconds

**The UFOBeep API has evolved from anonymous alerts to a full witness evidence platform with viral growth mechanics! 🛸**

---

## 📊 **v12 Success Metrics**

### **User System**
- Human ID generation rate
- Registration completion rate
- User retention after registration

### **Evidence Collection**
- Multi-witness upload rate
- Media quality scores
- Content flagging accuracy

### **Viral Growth**
- Social share button clicks
- Share-to-install conversion rate
- Platform performance by locale

### **Content Quality** 
- Auto-NSFW filter accuracy
- Community flagging precision
- False positive rates

**The witness media system transforms UFOBeep from simple alerts to collaborative evidence collection with viral growth potential! 🌟**