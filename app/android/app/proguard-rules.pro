# UFOBeep Android Proguard Rules

# Keep Flutter engine classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep JSON serialization classes
-keepclassmembers class * {
    @com.fasterxml.jackson.annotation.JsonProperty <fields>;
}

# Keep Dio networking classes
-keep class com.example.dio.** { *; }

# Keep location services
-keep class com.geolocator.** { *; }
-keep class location.** { *; }

# Keep camera classes
-keep class io.flutter.plugins.camera.** { *; }

# Keep sensor classes
-keep class sensors_plus.** { *; }

# Keep Matrix SDK classes
-keep class org.matrix.** { *; }

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}