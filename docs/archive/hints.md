# UFOBeep Unified Alerts Architecture

## Clean Mobile App Workflow (New)
The mobile app uses the unified `/alerts` pattern for everything:

```
1. POST /devices/register               ← Register device  
2. PATCH /devices/{device_id}/location  ← Update location
3. POST /alerts                         ← Create alert, get ID
4. POST /alerts/{alert_id}/media        ← Upload image/video
5. GET /alerts/{alert_id}              ← Display result
```

## Unified `/alerts` Endpoints
All sighting operations use `/alerts` - no more confusion:

```
POST   /alerts                         → Create new alert
GET    /alerts                         → List all alerts
GET    /alerts/{id}                    → Get specific alert  
POST   /alerts/{id}/media              → Upload media to alert
DELETE /alerts/{id}/media/{file}       → Remove media
PATCH  /alerts/{id}                    → Update alert details
POST   /alerts/{id}/witness            → Confirm witness
GET    /alerts/{id}/witness-aggregation → Witness data
```

## Future Features Ready
- **User Accounts**: Clean alert ownership model
- **2x Visibility Media**: Proximity-based media sharing permissions
- **Cross-Device Sync**: User's alerts synced across devices
- **Alert Management**: Edit/delete own alerts
- **Proximity Sharing**: Users within 2x visibility distance can add media

## Database Notes
- Database table stays as `sightings` (implementation detail)
- API presents everything as `alerts` (clean public interface)
- No backward compatibility - clean break architecture

## Current Status
- ✅ Database layer working (sightings table)
- ⚠️ API layer needs unification to /alerts pattern
- ⚠️ Mobile app needs update to use /alerts endpoints
- ⚠️ Remove all /sightings endpoint references