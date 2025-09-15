/// Type-safe JSON parsing utilities to handle API response inconsistencies
/// 
/// This utility addresses the critical issue where APIs sometimes return
/// strings instead of integers, or other unexpected type mismatches that
/// cause crashes like "type 'String' is not a subtype of type 'int' of 'index'"

import 'dart:convert';

class TypeSafeJson {
  /// Safely converts any dynamic value to Map<String, dynamic>
  /// Handles Lists, Maps, JSON strings, and other types gracefully
  static Map<String, dynamic> asMap(dynamic value, {String? context}) {
    if (value == null) {
      return {};
    }
    
    if (value is Map<String, dynamic>) {
      return value;
    }
    
    if (value is Map) {
      // Convert Map<dynamic, dynamic> to Map<String, dynamic>
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    
    if (value is List) {
      // Convert List to Map with numeric string keys
      // This prevents "String is not a subtype of int" errors when accessing arrays
      return {
        "_type": "List",
        "_length": value.length,
        "_context": context ?? "unknown",
        "_items": value,
        // Add first few items as direct keys for backward compatibility
        if (value.isNotEmpty) "0": value[0],
        if (value.length > 1) "1": value[1],
        if (value.length > 2) "2": value[2],
      };
    }
    
    if (value is String && value.trim().startsWith('{')) {
      try {
        final parsed = jsonDecode(value);
        if (parsed is Map<String, dynamic>) {
          return parsed;
        }
        if (parsed is Map) {
          return parsed.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (e) {
        // JSON parsing failed, return safe wrapper
        return {
          "_type": "InvalidJson",
          "_value": value,
          "_error": e.toString(),
          "_context": context ?? "unknown",
        };
      }
    }
    
    // Fallback: wrap primitive values
    return {
      "_type": value.runtimeType.toString(),
      "_value": value,
      "_context": context ?? "unknown",
    };
  }
  
  /// Safely extracts an integer value, converting strings if needed
  static int? safeInt(dynamic value, {int? defaultValue}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      // Try parsing as double first, then round
      final doubleValue = double.tryParse(value);
      if (doubleValue != null) return doubleValue.round();
    }
    return defaultValue;
  }
  
  /// Safely extracts a string value
  static String? safeString(dynamic value, {String? defaultValue}) {
    if (value == null) return defaultValue;
    return value.toString();
  }
  
  /// Safely extracts a boolean value
  static bool? safeBool(dynamic value, {bool? defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    if (value is int) {
      return value != 0;
    }
    return defaultValue;
  }
  
  /// Check if a value represents a converted List (to avoid treating it as Map)
  static bool isConvertedList(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value["_type"] == "List";
    }
    return false;
  }
  
  /// Get original List from converted Map
  static List<dynamic>? getOriginalList(dynamic value) {
    if (value is Map<String, dynamic> && value["_type"] == "List") {
      return value["_items"] as List<dynamic>?;
    }
    return null;
  }
  
  /// Log type mismatch warnings for debugging
  static void logTypeMismatch(String expected, dynamic actual, String context) {
    debugPrint('🔴 TYPE MISMATCH in $context: Expected $expected, got ${actual.runtimeType}: $actual');
  }
}

/// Extension methods for easier usage
extension TypeSafeMap on Map<String, dynamic> {
  /// Get integer value safely
  int? safeInt(String key, {int? defaultValue}) {
    return TypeSafeJson.safeInt(this[key], defaultValue: defaultValue);
  }
  
  /// Get string value safely  
  String? safeString(String key, {String? defaultValue}) {
    return TypeSafeJson.safeString(this[key], defaultValue: defaultValue);
  }
  
  /// Get boolean value safely
  bool? safeBool(String key, {bool? defaultValue}) {
    return TypeSafeJson.safeBool(this[key], defaultValue: defaultValue);
  }
  
  /// Get nested map safely
  Map<String, dynamic> safeMap(String key) {
    return TypeSafeJson.asMap(this[key], context: key);
  }
}