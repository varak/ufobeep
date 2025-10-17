import 'dart:io';
import 'package:flutter/services.dart';

class IosPermissionsService {
  static const _channel = MethodChannel('ios_permissions');

  /// Check iOS permission status via native code
  /// Returns true if granted, false otherwise
  static Future<bool> checkPermissionStatus(String permissionType) async {
    if (!Platform.isIOS) {
      throw UnsupportedError('iOS permissions only supported on iOS');
    }

    try {
      final result = await _channel.invokeMethod<bool>(
        'checkPermission',
        {'type': permissionType},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error checking iOS permission $permissionType: ${e.message}');
      return false;
    }
  }

  /// Check multiple permissions at once
  static Future<Map<String, bool>> checkMultiplePermissions(
    List<String> permissionTypes,
  ) async {
    final results = <String, bool>{};
    for (final type in permissionTypes) {
      results[type] = await checkPermissionStatus(type);
    }
    return results;
  }
}
