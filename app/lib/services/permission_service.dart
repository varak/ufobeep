import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:camera/camera.dart';

class PermissionService {
  static const String _locationGrantedKey = 'location_permission_granted';
  static const String _cameraGrantedKey = 'camera_permission_granted';
  static const String _photosGrantedKey = 'photos_permission_granted';
  static const String _notificationGrantedKey = 'notification_permission_granted';
  static const String _permissionsCheckedKey = 'permissions_checked_at_startup';

  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  bool _locationGranted = false;
  bool _cameraGranted = false;
  bool _photosGranted = false;
  bool _notificationGranted = false;
  bool _permissionsInitialized = false;
  Position? _cachedLocation;
  DateTime? _locationCacheTime;

  // Getters for current permission status
  bool get locationGranted => _locationGranted;
  bool get cameraGranted => _cameraGranted;
  bool get photosGranted => _photosGranted;
  bool get notificationGranted => _notificationGranted;
  bool get permissionsInitialized => _permissionsInitialized;
  Position? get cachedLocation => _cachedLocation;
  
  /// Check if location is ready for beep submission (permission + cached location)
  bool get locationReady => _locationGranted && _cachedLocation != null;

  /// Initialize all permissions at app startup
  Future<void> initializePermissions() async {
    if (_permissionsInitialized) return;

    print('Initializing permissions...');
    
    // Always request permissions fresh (don't rely on cache for critical permissions)
    await _requestAllPermissions();
    
    // Get initial location if permission was granted (for instant beeps)
    if (_locationGranted) {
      print('Getting initial location for instant beep readiness...');
      await getCurrentLocation(); // This caches location for immediate use
    }
    
    // Cache the results
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionsCheckedKey, true);
    await _cachePermissions();
    
    _permissionsInitialized = true;
    print('Permissions initialized: Location=$_locationGranted, Camera=$_cameraGranted, Photos=$_photosGranted, Notifications=$_notificationGranted');
  }

  /// Request all permissions needed by the app
  Future<void> _requestAllPermissions() async {
    print('Requesting critical permissions for first time setup...');
    
    try {
      // BATCH REQUEST: Location + Notifications together (both critical for UFO alerts)
      // This avoids Android rate limiting by requesting multiple permissions at once
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.notification,
      ].request().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Permission request timed out after 10s - checking individual statuses');
          return <Permission, PermissionStatus>{};
        },
      );
      
      // Process location permission result
      if (statuses.containsKey(Permission.location)) {
        _locationGranted = statuses[Permission.location] == PermissionStatus.granted ||
                          statuses[Permission.location] == PermissionStatus.limited;
      } else {
        // Fallback: check current status if batch request failed
        final currentStatus = await Permission.location.status;
        _locationGranted = currentStatus == PermissionStatus.granted ||
                          currentStatus == PermissionStatus.limited;
      }
      print('Location permission: $_locationGranted');
      
      // Process notification permission result  
      if (statuses.containsKey(Permission.notification)) {
        _notificationGranted = statuses[Permission.notification] == PermissionStatus.granted;
      } else {
        // Fallback: check current status if batch request failed
        final currentStatus = await Permission.notification.status;
        _notificationGranted = currentStatus == PermissionStatus.granted;
      }
      print('Notification permission: $_notificationGranted');
    } catch (e) {
      print('Error during permission request: $e');
      // Fallback: check current statuses individually
      try {
        _locationGranted = (await Permission.location.status).isGranted;
        _notificationGranted = (await Permission.notification.status).isGranted;
        print('Fallback permission check - Location: $_locationGranted, Notification: $_notificationGranted');
      } catch (fallbackError) {
        print('Fallback permission check failed: $fallbackError');
        _locationGranted = false;
        _notificationGranted = false;
      }
    }
    
    // Camera and Photos are now OPTIONAL - request them on-demand when needed
    // This prevents permission prompt fatigue and lets users start using the app immediately
    
    // Cache the results
    await _cachePermissions();
  }

  /// Load cached permission status from storage
  Future<void> _loadCachedPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    
    _locationGranted = prefs.getBool(_locationGrantedKey) ?? false;
    _cameraGranted = prefs.getBool(_cameraGrantedKey) ?? false;
    _photosGranted = prefs.getBool(_photosGrantedKey) ?? false;
    _notificationGranted = prefs.getBool(_notificationGrantedKey) ?? false;
    
    // Double-check current system status for location (most critical)
    if (_locationGranted) {
      final currentStatus = await Geolocator.checkPermission();
      _locationGranted = currentStatus == LocationPermission.always || 
                        currentStatus == LocationPermission.whileInUse;
    }
  }

  /// Cache permission status to storage
  Future<void> _cachePermissions() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_locationGrantedKey, _locationGranted);
    await prefs.setBool(_cameraGrantedKey, _cameraGranted);
    await prefs.setBool(_photosGrantedKey, _photosGranted);
    await prefs.setBool(_notificationGrantedKey, _notificationGranted);
  }

  /// Request location permission (critical for UFO alerts)
  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      _locationGranted = permission == LocationPermission.always || 
                        permission == LocationPermission.whileInUse;
                        
      print('Location permission: $_locationGranted (status: $permission)');
    } catch (e) {
      print('Error requesting location permission: $e');
      _locationGranted = false;
    }
  }

  /// Request camera permission
  Future<void> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      _cameraGranted = status == PermissionStatus.granted;
      print('Camera permission: $_cameraGranted');
    } catch (e) {
      print('Error requesting camera permission: $e');
      _cameraGranted = false;
    }
  }

  /// Request photo library permission
  Future<void> _requestPhotosPermission() async {
    try {
      final result = await PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(
          iosAccessLevel: IosAccessLevel.readWrite,
          androidPermission: AndroidPermission(
            type: RequestType.image,
            mediaLocation: true,
          ),
        ),
      );
      _photosGranted = result.isAuth;
      print('Photos permission: $_photosGranted');
    } catch (e) {
      print('Error requesting photos permission: $e');
      _photosGranted = false;
    }
  }

  /// Request notification permission
  Future<void> _requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      _notificationGranted = status == PermissionStatus.granted;
      print('Notification permission: $_notificationGranted');
    } catch (e) {
      print('Error requesting notification permission: $e');
      _notificationGranted = false;
    }
  }

  /// Get current location (only if permission granted)
  Future<Position?> getCurrentLocation() async {
    if (!_locationGranted) {
      print('Location permission not granted');
      return null;
    }

    // Return cached location if it's fresh (less than 5 minutes old)
    if (_cachedLocation != null && _locationCacheTime != null) {
      final age = DateTime.now().difference(_locationCacheTime!);
      if (age.inMinutes < 5) {
        print('Using cached location (${age.inSeconds}s old)');
        return _cachedLocation;
      }
    }

    try {
      print('Getting fresh location...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      
      // Cache the fresh location
      _cachedLocation = position;
      _locationCacheTime = DateTime.now();
      print('Location cached: ${position.latitude}, ${position.longitude}');
      
      return position;
    } catch (e) {
      print('Error getting current location: $e');
      // Return cached location as fallback if available
      return _cachedLocation;
    }
  }

  /// Check if critical permissions are available for beeping
  bool canSendBeep() {
    return _locationGranted; // Location is required for beeping
  }

  /// Check if camera features are available
  bool canUseCamera() {
    return _cameraGranted;
  }

  /// Check if photo gallery is available
  bool canAccessPhotos() {
    return _photosGranted;
  }

  /// Show permission settings if critical permissions missing
  Future<void> openPermissionSettings() async {
    await openAppSettings();
  }

  /// Refresh permission status (call after returning from settings)
  Future<void> refreshPermissions() async {
    await _requestAllPermissions();
    await _cachePermissions();
  }
  
  /// Request camera permission on-demand (when user wants to take photo)
  Future<bool> requestCameraForCapture() async {
    if (_cameraGranted) return true;
    
    print('Requesting camera permission for photo capture...');
    final status = await Permission.camera.request();
    _cameraGranted = status == PermissionStatus.granted;
    
    if (_cameraGranted) {
      await _cachePermissions();
      print('Camera permission granted');
    } else {
      print('Camera permission denied');
    }
    
    return _cameraGranted;
  }
  
  /// Request photo library permission on-demand (when user wants to select from gallery)
  Future<bool> requestPhotosForGallery() async {
    if (_photosGranted) return true;
    
    print('Requesting photos permission for gallery access...');
    try {
      final result = await PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(
          iosAccessLevel: IosAccessLevel.readWrite,
          androidPermission: AndroidPermission(
            type: RequestType.image,
            mediaLocation: true,
          ),
        ),
      );
      _photosGranted = result.isAuth;
      
      if (_photosGranted) {
        await _cachePermissions();
        print('Photos permission granted');
      } else {
        print('Photos permission denied');
      }
    } catch (e) {
      print('Error requesting photos permission: $e');
      _photosGranted = false;
    }
    
    return _photosGranted;
  }
  
  /// Request individual permission if missing
  Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    final granted = status == PermissionStatus.granted;
    
    // Update internal state based on permission type
    switch (permission.value) {
      case 0: // Location
        _locationGranted = granted;
        break;
      case 1: // Camera  
        _cameraGranted = granted;
        break;
      case 13: // Notification
        _notificationGranted = granted;
        break;
    }
    
    await _cachePermissions();
    return granted;
  }
  
  /// Ensure location is ready for beep submission - insistent permission flow
  /// Returns true if location is ready, false if user permanently denied
  Future<bool> ensureLocationReadyForBeep() async {
    // If already ready, return immediately
    if (locationReady) {
      return true;
    }
    
    print('Location not ready for beep - checking permissions...');
    
    // Check current permission status
    final currentStatus = await Permission.location.status;
    
    if (currentStatus.isPermanentlyDenied) {
      // User permanently denied - can't request again
      print('Location permanently denied - must go to Settings');
      return false;
    }
    
    if (!currentStatus.isGranted) {
      // Request permission
      print('Requesting location permission for beep submission...');
      final newStatus = await Permission.location.request();
      _locationGranted = newStatus.isGranted;
      await _cachePermissions();
      
      if (!_locationGranted) {
        print('Location permission denied for beep');
        return false;
      }
    }
    
    // Permission granted, but might not have cached location
    if (_cachedLocation == null) {
      print('Getting location for beep submission...');
      await getCurrentLocation();
    }
    
    // Final check
    return locationReady;
  }
}

// Global instance
final permissionService = PermissionService();