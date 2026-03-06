# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# MediaKit (Ihre Regeln + Ergänzungen)
-keep class com.alexmercerind.mediakit.** { *; }
-keep class com.alexmercerind.media_kit_video.** { *; }
-keep class com.alexmercerind.media_kit_libs_android_video.** { *; }
-keep class com.alexmercerind.media_kit_libs_video.** { *; }

# Native Methoden
-keepclasseswithmembernames class * {
    native <methods>;
}

# Isar
-keep class io.isar.** { *; }
-keep class io.realm.transformer.** { *; }

# Don't warn Regeln
-dontwarn com.alexmercerind.**
-dontwarn io.isar.**
-dontwarn sun.misc.**

# Allgemeine Regeln
-keepattributes Signature
-keepattributes *Annotation*
-keep class androidx.** { *; }
-keep public class * extends androidx.** { *; }
-keep class com.google.** { *; }