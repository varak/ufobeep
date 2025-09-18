# MASTER_PLAN_v16 — Community & Media (Implementation Status)

**Current Status: Sprint B Completed + URL Architecture Overhaul**

Goals: Multi-media per alert, Comments, Auto-follow + pushes, Share cards, Share→Compose reliability, Sleep/DND.

Guardrails: keep `/alerts`, `/media/uploads`; proximity & device location must stay green.

## 🎯 **Current Sprint Progress**
- ✅ **Sprint A**: Multi-Media Alerts - COMPLETED
- ✅ **Sprint B**: Comments + Follows + Push - COMPLETED  
- ✅ **URL Architecture**: Smart Short URLs + Multilingual Support - COMPLETED
- 🔄 **Sprint C**: Share Cards + Share→Compose + Sleep/DND - IN PROGRESS
- ⏳ **Sprint D**: Map & Ops - PENDING

## 🚨 **Critical Fixes Completed (August-September 2025)**
- ✅ **URL Architecture Overhaul**: New short URL system with automatic language detection
- ✅ **Dual Endpoint Support**: Both `/beep` and `/alerts` APIs for client compatibility
- ✅ **Multilingual Routing**: 22 language support with smart browser detection
- ✅ **SEO Optimization**: Canonical URLs with descriptive slugs
- ✅ **Witness Confirmation Bug**: Fixed "string is not subtype of int at index" crash
- ✅ **Type Safety**: Added comprehensive defensive JSON parsing
- ✅ **UI Consistency**: Updated button styling across all screens
- ✅ **Push Notifications**: End-to-end witness confirmation flow working
- ✅ **Username Regeneration**: Fixed API call with proper parameters

## 🌍 **Translation System Overhaul (September 17, 2025)**
- ✅ **Universal Translation Coverage**: All 22 languages now work consistently without English fallbacks
- ✅ **T+ Time Format**: Aerospace/military time notation (T+1h30m) implemented across mobile and web
- ✅ **Reporter Display Fix**: "Reported by" field shows correctly in Details section using alert.username
- ✅ **I See It Too Logic**: Button properly hidden for user's own beeps using username comparison
- ✅ **Detail Page Layout**: Share link and reporter info integrated into Details section for consistency
- ✅ **Translation Key Expansion**: 28+ new keys added for weather, location, satellite, aircraft sections
- ✅ **AlertTitleUtils Fixed**: Eliminated English fallbacks, requires translation function for all languages
- ✅ **Web Component Unification**: Removed duplicate inline sections, uses only proper card components

## Sprint A — Multi-Media Alerts
[api] Keep MP14 endpoints. Add Idempotency on POST `/media/uploads`, `/alerts`.
[app] Composer multi-select; post with first media; attach rest via `/alerts/{id}/media`.

**Upload queue sketch**
```dart
import 'package:dio/dio.dart';
class UploadItem { UploadItem(this.path); final String path; String? url; }
class UploadQueue {
  final Dio dio; final _items = <UploadItem>[];
  UploadQueue(this.dio);
  void add(String path)=>_items.add(UploadItem(path));
  Future<List<Map<String,dynamic>>> flush() async {
    final out=<Map<String,dynamic>>[];
    for (final it in _items) {
      final form=FormData.fromMap({"file":await MultipartFile.fromFile(it.path)});
      final res=await dio.post("/media/uploads",data=form);
      final media=(res.data["media"] as List).first; it.url=media["url"]; out.add(media);
    } _items.clear(); return out;
  }
}
```

**Alerts service excerpts**
```dart
Future<int> createAlert({required String message, required double lat, required double lon,
  required List<Map<String,dynamic>> firstMedia,}) async {
  final body={"message":message,"lat":lat,"lon":lon,if(firstMedia.isNotEmpty)"media":firstMedia};
  final res=await dio.post("/alerts",data:body); return res.data["id"] as int;
}
Future<void> appendMedia(int alertId, List<Map<String,dynamic>> media) async {
  await dio.post("/alerts/$alertId/media",data:{"media":media});
}
```

✅ **Acceptance**: create 3‑image alert; first as preview; no dupes on retry. **STATUS: WORKING**

## Sprint B — Comments + Follows + Push ✅ COMPLETED
[api] Tables `comments`, `follows`. Endpoints: GET/POST `/alerts/{id}/comments`; POST `/alerts/{id}/follow`.
[app] Thread UI; bell to mute.

✅ **Implementation Status**:
- Comments system fully functional with thread UI
- Auto-follow on witness confirmation working
- Push notifications for witness confirmations and comments active
- FCM integration delivering real-time alerts
- "I see it too" button working reliably with type-safe API responses

## URL Architecture Overhaul ✅ COMPLETED

**New Smart URL System**:
- **Short URLs**: `/ehf3` auto-detects user language
- **Language-specific**: `/ehf3/es` for explicit Spanish
- **Canonical URLs**: `/beep/es/enhanced-sighting-description-ehf3`
- **22 Languages**: es, de, fr, pt, ru, ja, zh, it, ar, ko, tr, hi, pl, cs, nl, sv, da, no, fi, el, he

**Dual API Support**:
- **Primary**: `/beep` endpoints for new web frontend
- **Legacy**: `/alerts` endpoints for mobile app compatibility
- **Frontend transformation**: `data.alerts` → `data.beeps` for web consistency

**SEO & Performance**:
- Automatic language detection from browser headers
- Descriptive slugs for better search ranking
- Canonical URL redirects prevent duplicate content
- Middleware-based routing for optimal performance

## Sprint C — Share Cards + Share→Compose + Sleep/DND
[web] OG tags; `/og/beep/{id}.png` image (updated for new URL structure).
[app] singleTask + onNewIntent + persisted pending share.

**Updated Implementation Notes**:
- Share URLs now use short format: `ufobeep.com/ehf3`
- Language-aware sharing: shared URL detects recipient's language
- OG image generation supports new `/beep/{locale}/{slug}` structure
- Mobile deep links handle both short and canonical URL formats

## Sprint D — Map & Ops
Map clustering; Sentry; CI; Field Diagnostic screen.