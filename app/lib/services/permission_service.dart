import 'dart:async';
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

  /// Initialize all permissions at app startup (lightweight)
  Future<void> initializePermissions() async {
    if (_permissionsInitialized) return;

    debugPrint('Initializing permissions (fast check)...');
    
    // Just check current status - don't request or do background work
    await _checkCurrentPermissions();
    
    _permissionsInitialized = true;
    debugPrint('Permissions checked: Location=$_locationGranted, Camera=$_cameraGranted, Photos=$_photosGranted, Notifications=$_notificationGranted');
  }
  
  /// Fast permission check without requests
  Future<void> _checkCurrentPermissions() async {
    try {
      // Use Geolocator for location (consistent with BeepService)
      final locationPermission = await Geolocator.checkPermission();
      _locationGranted = locationPermission == LocationPermission.always || 
                        locationPermission == LocationPermission.whileInUse;
      
      // Check other permissions without requesting
      final cameraStatus = await Permission.camera.status;
      _cameraGranted = cameraStatus == PermissionStatus.granted;
      
      final notificationStatus = await Permission.notification.status;
      _notificationGranted = notificationStatus == PermissionStatus.granted;
      
      // Photos permission is complex, skip for now
      _photosGranted = false;
      
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      // Safe defaults
      _locationGranted = false;
      _cameraGranted = false;
      _photosGranted = false;
      _notificationGranted = false;
    }
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
                        
      debugPrint('Location permission: $_locationGranted (status: $permission)');
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      _locationGranted = false;
    }
  }

  /// Request camera permission
  Future<void> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      _cameraGranted = status == PermissionStatus.granted;
      debugPrint('Camera permission: $_cameraGranted');
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
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
      debugPrint('Photos permission: $_photosGranted');
    } catch (e) {
      debugPrint('Error requesting photos permission: $e');
      _photosGranted = false;
    }
  }

  /// Request notification permission
  Future<void> _requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      _notificationGranted = status == PermissionStatus.granted;
      debugPrint('Notification permission: $_notificationGranted');
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      _notificationGranted = false;
    }
  }

  /// Get current location (simplified - let BeepService handle this)
  Future<Position?> getCurrentLocation() async {
    // BeepService now handles location directly with Geolocator
    // This method kept for compatibility but delegates to Geolocator
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
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
    await _checkCurrentPermissions();
  }
  
  /// Request camera permission on-demand (when user wants to take photo)
  Future<bool> requestCameraForCapture() async {
    if (_cameraGranted) return true;
    
    debugPrint('Requesting camera permission for photo capture...');
    final status = await Permission.camera.request();
    _cameraGranted = status == PermissionStatus.granted;
    
    if (_cameraGranted) {
      await _cachePermissions();
      debugPrint('Camera permission granted');
    } else {
      debugPrint('Camera permission denied');
    }
    
    return _cameraGranted;
  }
  
  /// Request photo library permission on-demand (when user wants to select from gallery)
  Future<bool> requestPhotosForGallery() async {
    if (_photosGranted) return true;
    
    debugPrint('Requesting photos permission for gallery access...');
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
        debugPrint('Photos permission granted');
      } else {
        debugPrint('Photos permission denied');
      }
    } catch (e) {
      debugPrint('Error requesting photos permission: $e');
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
  
  /// Request notification permission (for push notifications)
  Future<bool> requestNotificationPermissionForPush() async {
    debugPrint('Requesting notification permission for push alerts...');
    final granted = await requestPermission(Permission.notification);
    if (granted) {
      debugPrint('Notification permission granted for push alerts');
    } else {
      debugPrint('Notification permission denied for push alerts');
    }
    return granted;
  }
  
  /// Ensure location is ready for beep submission - insistent permission flow
  /// Returns true if location is ready, false if user permanently denied
  Future<bool> ensureLocationReadyForBeep() async {
    // If already ready, return immediately
    if (locationReady) {
      return true;
    }
    
    debugPrint('Location not ready for beep - checking permissions...');
    
    // Check current permission status
    final currentStatus = await Permission.location.status;
    
    if (currentStatus.isPermanentlyDenied) {
      // User permanently denied - can't request again
      debugPrint('Location permanently denied - must go to Settings');
      return false;
    }
    
    if (!currentStatus.isGranted) {
      // Request permission
      debugPrint('Requesting location permission for beep submission...');
      final newStatus = await Permission.location.request();
      _locationGranted = newStatus.isGranted;
      await _cachePermissions();
      
      if (!_locationGranted) {
        debugPrint('Location permission denied for beep');
        return false;
      }
    }
    
    // Permission granted, but might not have cached location
    if (_cachedLocation == null) {
      debugPrint('Getting location for beep submission...');
      await getCurrentLocation();
    }
    
    // Final check
    return locationReady;
  }

  /// Background location fetch to avoid blocking startup
  Future<void> _backgroundLocationFetch() async {
    try {
      debugPrint('Background: Fetching initial location...');
      await getCurrentLocation();
      debugPrint('Background: Initial location cached successfully');
    } catch (e) {
      debugPrint('Background: Failed to get initial location - $e (will retry when needed)');
    }
  }
}

// Global instance
final permissionService = PermissionService();