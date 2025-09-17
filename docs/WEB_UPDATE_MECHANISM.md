# UFOBeep Real-Time Update System

**Last Updated**: September 17, 2025
**Current Status**: ✅ **FULLY FUNCTIONAL** - Both Mobile and Web Real-Time Updates Working

## Overview

UFOBeep now has a complete real-time comment and update system working across both mobile apps and web browsers, with different optimized mechanisms for each platform.

## Real-Time Comment System Architecture

### Mobile App (Flutter)
```
Comment Posted → API Push Notification → Firebase FCM → Mobile Device
├── Single notification per comment (no duplicates)
├── Auto-scroll to new comments when on beep page
├── Deep-link navigation to specific beep + comment
└── CommentsRefreshNotifier triggers UI updates
```

**Key Components:**
- **Push Notifications**: Firebase FCM with device exclusion
- **Auto-scroll**: Automatic scroll to bottom for notification-triggered refreshes
- **Deep-linking**: `ufobeep://beep/{id}?focusComment=true&commentId={id}`
- **Single Source**: One notification per comment via device exclusion logic

### Web Browser (Next.js)
```
Comment Posted → API WebSocket Broadcast → All Connected Browsers
├── WebSocket connections to wss://ufobeep.com/ws/beep/{beepId}
├── Real-time comment updates without page refresh
├── Auto-scroll and new comment notifications
└── Cross-tab synchronization
```

**Key Components:**
- **WebSocket Endpoints**: `/ws/beep/{beepId}` for real-time updates
- **Nginx Proxy**: Routes WebSocket connections to API server
- **Real-time UI**: Surgical comment updates without full page refresh
- **Auto-scroll**: Smart scrolling based on user position and activity

## Infrastructure

### API Server (FastAPI)
```python
# WebSocket Manager
@router.websocket("/ws/beep/{beep_id}")
async def websocket_beep_comments(websocket: WebSocket, beep_id: str):
    await websocket_manager.connect_to_beep(websocket, beep_id)
    # Handles real-time comment broadcasts

# Comment Creation
@router.post("/{sighting_id}/comments")
async def create_comment():
    # 1. Save comment to database
    # 2. Send push notifications to mobile devices
    # 3. Broadcast WebSocket message to web browsers
```

### Nginx Configuration
```nginx
# WebSocket proxy for real-time updates (FastAPI on :8000)
location ^~ /ws/ {
    proxy_pass         http://127.0.0.1:8000;
    proxy_http_version 1.1;

    # Required for WS handshake
    proxy_set_header   Upgrade $http_upgrade;
    proxy_set_header   Connection $connection_upgrade;

    # Forward client/host info
    proxy_set_header   Host $host;
    proxy_set_header   X-Real-IP $remote_addr;
    proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Proto $scheme;

    # Keep the pipe open, avoid buffering
    proxy_read_timeout  3600s;
    proxy_send_timeout  3600s;
    proxy_buffering     off;
    proxy_cache_bypass  $http_upgrade;
}

# Required WebSocket upgrade map in nginx.conf
map $http_upgrade $connection_upgrade {
    default upgrade;
    ""      close;
}
```

## Current Implementation Details

### Web Real-Time Updates (WORKING ✅)

**AlertComments.tsx**:
```javascript
// WebSocket connection for real-time comment updates
useEffect(() => {
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
  const host = window.location.host
  websocket = new WebSocket(`${protocol}//${host}/ws/beep/${alertId}`)

  websocket.onopen = () => {
    console.log('[WebSocket] Connected to comment updates')
  }

  websocket.onmessage = (event) => {
    const data = JSON.parse(event.data)
    if (data.type === 'comment_added' && data.comment) {
      // Add comment to UI without page refresh
      // Auto-scroll if user is near bottom or actively participating
    }
  }
}, [alertId])
```

### Mobile Real-Time Updates (WORKING ✅)

**Push Notification Flow**:
```dart
// Comment notification handling
void _handleCommentNotification(RemoteMessage message) async {
  final sightingId = message.data['sighting_id'];
  final commentId = message.data['comment_id'];

  // Show notification and trigger refresh
  await _showCommentNotification(message);
  CommentsRefreshNotifier.instance.notifyRefresh(sightingId);

  // Navigate with auto-scroll
  navigateToAlertWithComment(sightingId, commentId);
}
```

**Auto-scroll System**:
```dart
// AlertDetailScreen auto-scroll for notifications
Future<void> _loadComments({bool fromNotification = false}) async {
  if (fromNotification && _comments?.isNotEmpty == true) {
    // Auto-scroll to bottom for notification-triggered refreshes
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
```

## System Status & Fixes Applied (Sept 17, 2025)

### Issues Resolved ✅

1. **Double Mobile Notifications**
   - **Problem**: Both push notifications and WebSocket broadcasts triggered for same comment
   - **Solution**: Separated notification channels - mobile gets push only, web gets WebSocket only
   - **Result**: Single notification per comment on mobile devices

2. **Mobile Auto-Scroll Breaking After 3rd Comment**
   - **Problem**: Auto-scroll logic used `_hasScrolledToComment` flag that blocked future scrolls
   - **Solution**: Added `fromNotification` parameter to force auto-scroll for push notification refreshes
   - **Result**: Consistent auto-scroll for all comments when already on beep page

3. **Web Real-Time Updates Not Working**
   - **Problem**: Malformed nginx WebSocket location block (all on one line)
   - **Solution**: Fixed nginx syntax with proper formatting and `^~` prefix
   - **Result**: WebSocket connections now establish successfully, real-time updates working

4. **Comment Notification Deep-Link Broken**
   - **Problem**: Missing `case 'comment':` in deep link handler
   - **Solution**: Added comment case to route to specific beep with comment focus
   - **Result**: Tapping comment notifications navigates to correct beep instead of alerts tab

### Current Performance

#### Mobile Apps
- ✅ **Single notifications** (no duplicates)
- ✅ **Auto-scroll** working past 3rd comment
- ✅ **Deep-linking** to specific comments
- ✅ **Real-time refresh** via CommentsRefreshNotifier

#### Web Browsers
- ✅ **WebSocket connections** establishing successfully
- ✅ **Real-time comment updates** across all tabs
- ✅ **Auto-scroll** and smart notifications
- ✅ **Cross-tab synchronization** working

## Monitoring & Debugging

### WebSocket Connection Logs
```bash
# Check WebSocket connections
sudo journalctl -u ufobeep-api | grep -i websocket

# Monitor comment activity
sudo journalctl -u ufobeep-api | grep -E 'comment.*POST|WebSocket.*broadcast'
```

### Mobile App Debug Logs
```bash
# Monitor mobile comment notifications and auto-scroll
adb logcat -s flutter:I | grep -E "(💬|🔄|CommentsRefresh)"
```

### Browser DevTools
```javascript
// Check WebSocket connection status
console.log('WebSocket readyState:', websocket.readyState)
// 0: CONNECTING, 1: OPEN, 2: CLOSING, 3: CLOSED

// Monitor WebSocket messages
websocket.addEventListener('message', (event) => {
  console.log('WebSocket message:', JSON.parse(event.data))
})
```

## Future Enhancements

### Phase 1: Enhanced Real-Time Features
- [ ] **Typing indicators**: Show when users are composing comments
- [ ] **Read receipts**: Show which comments have been seen
- [ ] **Online presence**: Show which users are currently viewing beep
- [ ] **Comment reactions**: Real-time emoji reactions to comments

### Phase 2: Advanced WebSocket Features
- [ ] **WebSocket heartbeat**: Keep connections alive with ping/pong
- [ ] **Automatic reconnection**: Smart retry logic for dropped connections
- [ ] **Connection pooling**: Efficient WebSocket connection management
- [ ] **Message queuing**: Handle offline/reconnection scenarios

### Phase 3: Progressive Web App (PWA)
- [ ] **Service Worker**: Background sync and offline capability
- [ ] **Web Push Notifications**: Browser notifications for web users
- [ ] **App-like Experience**: Install prompts and app shell
- [ ] **Background Sync**: Queue actions when offline

## Deployment Notes

### Critical Infrastructure
- **API Server**: Port 8000 with WebSocket support
- **Web Server**: Port 3000 (Next.js)
- **Nginx Proxy**: Routes `/ws/` to API, everything else to web
- **WebSocket Map**: Required in nginx.conf for proper connection handling

### Deployment Commands
```bash
# Deploy API changes (affects WebSocket broadcasts)
./deploy.sh api

# Deploy web changes (affects WebSocket client connections)
./deploy.sh web

# Deploy mobile changes (affects push notifications)
./deploy.sh moto  # or specific device
```

### Testing Real-Time Updates
```bash
# 1. Test WebSocket proxy
curl -i -H "Connection: Upgrade" -H "Upgrade: websocket" \
  https://ufobeep.com/ws/beep/test-id
# Should return JSON 404 from API (not HTML from Next.js)

# 2. Test mobile notifications
# Post comment from web → mobile should get single notification

# 3. Test web updates
# Post comment from mobile → web tabs should auto-update
```

## Success Metrics

### Real-Time Performance
- **WebSocket Connection Success**: 100% of web browsers establish connections
- **Mobile Notification Delivery**: Single notification per comment, <2s latency
- **Auto-Scroll Accuracy**: Comments auto-scroll consistently when user on page
- **Cross-Platform Sync**: Comments appear in real-time across all platforms

### User Experience
- **No Manual Refreshes**: Users never need to refresh to see new comments
- **Seamless Navigation**: Notification taps go directly to relevant content
- **Consistent Behavior**: Auto-scroll works reliably regardless of comment count
- **Zero Duplicates**: No duplicate notifications or UI updates

---

**BREAKTHROUGH ACHIEVED**: September 17, 2025 - Complete real-time comment system working across all platforms with optimized notification delivery and auto-scroll functionality.