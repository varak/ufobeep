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

  // Getters for current permission status
  bool get locationGranted => _locationGranted;
  bool get cameraGranted => _cameraGranted;
  bool get photosGranted => _photosGranted;
  bool get notificationGranted => _notificationGranted;
  bool get permissionsInitialized => _permissionsInitialized;

  /// Initialize all permissions at app startup
  Future<void> initializePermissions() async {
    if (_permissionsInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    
    // Check if we've already done initial permission setup
    final alreadyChecked = prefs.getBool(_permissionsCheckedKey) ?? false;
    
    if (alreadyChecked) {
      // Load cached permission status
      await _loadCachedPermissions();
    } else {
      // First time - request all needed permissions
      await _requestAllPermissions();
      await prefs.setBool(_permissionsCheckedKey, true);
    }
    
    _permissionsInitialized = true;
    print('Permissions initialized: Location=$_locationGranted, Camera=$_cameraGranted, Photos=$_photosGranted, Notifications=$_notificationGranted');
  }

  /// Request all permissions needed by the app
  Future<void> _requestAllPermissions() async {
    print('Requesting all permissions for first time setup...');
    
    // Request location permission (critical for UFO beeping)
    await _requestLocationPermission();
    
    // Request camera permission (for photo capture)
    await _requestCameraPermission();
    
    // Request photo library permission (for gallery selection)
    await _requestPhotosPermission();
    
    // Request notification permission (for alerts)
    await _requestNotificationPermission();
    
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

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting current location: $e');
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
    await _requestAllPermissions();
    await _cachePermissions();
  }
}

// Global instance
final permissionService = PermissionService();