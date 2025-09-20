# Alert Range Configuration Bug

## Critical Issue Discovered 2025-09-20

**Bug**: Alert range settings are stored in TWO different tables with different values:
- `users.alert_range_km` = 50 (user preference)
- `devices.alert_range_km` = 10 (device setting)

**Impact**: Proximity alert service uses `devices.alert_range_km` but user profile shows `users.alert_range_km`. When users change alert range in UI, it may only update one table, causing:
- UI shows 50km range
- Device actually uses 10km range
- User doesn't get expected alerts

**Example**:
```sql
-- User thinks they have 50km range
SELECT username, alert_range_km FROM users WHERE username = 'instant.storm.2516';
-- Returns: 50

-- But device actually uses 10km range
SELECT device_id, alert_range_km FROM devices WHERE device_id = 'android_OPM1.171019.011';
-- Returns: 10
```

**Root Cause**: Dual storage of same setting without synchronization

**Fix Required**:
1. **Choose single source of truth** (recommend `users.alert_range_km`)
2. **Update proximity service** to use users table value
3. **Remove alert_range_km from devices table** OR sync values
4. **Test alert range slider** updates both tables consistently

**Files to Update**:
- `api/services/proximity_alert_service.py` - Change query to use users.alert_range_km
- Alert range UI components - Ensure updates go to correct table(s)
- Database migration - Sync existing values or remove duplicate column

**Discovered in**: Investigation of Y device not receiving proximity alerts despite being 0.75m from beep location