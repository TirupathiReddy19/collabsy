# Flutter engine / embedding / generated plugin registrant
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Play Core split-install APIs are referenced by Flutter's deferred-components
# support even though this app doesn't use deferred components.
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
