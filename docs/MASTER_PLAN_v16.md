# MASTER_PLAN_v16 — Community & Media (Implementation Status)

**Current Status: Sprint B Completed + Critical Bug Fixes**

Goals: Multi-media per alert, Comments, Auto-follow + pushes, Share cards, Share→Compose reliability, Sleep/DND.

Guardrails: keep `/alerts`, `/media/uploads`; proximity & device location must stay green.

## 🎯 **Current Sprint Progress**
- ✅ **Sprint A**: Multi-Media Alerts - COMPLETED
- ✅ **Sprint B**: Comments + Follows + Push - COMPLETED  
- 🔄 **Sprint C**: Share Cards + Share→Compose + Sleep/DND - IN PROGRESS
- ⏳ **Sprint D**: Map & Ops - PENDING

## 🚨 **Critical Fixes Completed (August 2025)**
- ✅ **Witness Confirmation Bug**: Fixed "string is not subtype of int at index" crash
- ✅ **Type Safety**: Added comprehensive defensive JSON parsing
- ✅ **UI Consistency**: Updated button styling across all screens
- ✅ **Push Notifications**: End-to-end witness confirmation flow working
- ✅ **Username Regeneration**: Fixed API call with proper parameters

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
  final res=await dio.post("/alerts",data=body); return res.data["id"] as int;
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

## Sprint C — Share Cards + Share→Compose + Sleep/DND
[web] OG tags; `/og/alerts/{id}.png` image (starter provided).
[app] singleTask + onNewIntent + persisted pending share.

## Sprint D — Map & Ops
Map clustering; Sentry; CI; Field Diagnostic screen.
