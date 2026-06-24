# Flutter Wrapper and Engine rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Keep all platform channel MethodCallHandlers and StreamHandlers
-keep class * implements io.flutter.plugin.common.MethodChannel$MethodCallHandler { *; }
-keep class * implements io.flutter.plugin.common.EventChannel$StreamHandler { *; }
-keep class * implements io.flutter.plugin.common.PluginRegistry$PluginRegistrantCallback { *; }
-keep class * implements io.flutter.plugin.common.PluginRegistry { *; }
-keep class * implements io.flutter.plugin.common.PluginRegistry$Registrar { *; }

# print_bluetooth_thermal plugin rules
-keep class com.jhon_azulay.print_bluetooth_thermal.** { *; }

# permission_handler plugin rules
-keep class com.baseflow.permissionhandler.** { *; }

# shared_preferences plugin rules
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Keep generic library signatures and annotations
-keepattributes Signature,InnerClasses,EnclosingMethod,AnnotationDefault,*Annotation*

# Suppress OkHttp/Okio warnings if present in dependency tree
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**

# Ignore warnings for missing Play Core classes (used by Flutter embedding but not needed here)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
