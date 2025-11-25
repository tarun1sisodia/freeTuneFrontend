# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Isar
-keep class isar.** { *; }
-keep class com.isar.** { *; }

# Audio Service
-keep class com.ryanheise.audioservice.** { *; }

# Just Audio
-keep class com.ryanheise.just_audio.** { *; }

# Flutter Cache Manager
-keep class com.baseflow.flutter_cache_manager.** { *; }

# Retrofit/Dio (if used with reflection, though Dio usually doesn't need much)
-keep class dio.** { *; }
-dontwarn dio.**
