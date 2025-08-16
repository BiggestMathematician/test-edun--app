# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Stripe SDK v11.5.0 - Keep all classes to prevent R8 missing class errors
-keep class com.stripe.android.** { *; }
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.reactnativestripesdk.** { *; }
-keep class com.stripe.android.paymentsheet.** { *; }
-keep class com.stripe.android.paymentlauncher.** { *; }
-keep class com.stripe.android.model.** { *; }
-keep class com.stripe.android.view.** { *; }

# Google Play Core v1.x - Keep all classes to prevent R8 missing class errors
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.common.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.appupdate.** { *; }
-keep class com.google.android.play.core.review.** { *; }
-keep class com.google.android.play.core.install.** { *; }
-keep class com.google.android.play.core.listener.** { *; }

# Specific missing classes from R8 error (using v1.x versions)
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallException { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallManager { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallManagerFactory { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallRequest { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallRequest$Builder { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallSessionState { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener { *; }
-keep class com.google.android.play.core.tasks.OnFailureListener { *; }
-keep class com.google.android.play.core.tasks.OnSuccessListener { *; }
-keep class com.google.android.play.core.tasks.Task { *; }
-keep class com.google.android.play.core.listener.StateUpdatedListener { *; }

# Google Crypto Tink - Keep all classes to prevent R8 missing class errors
-keep class com.google.crypto.tink.** { *; }
-keep class com.google.crypto.tink.subtle.** { *; }
-keep class com.google.crypto.tink.subtle.Ed25519Sign { *; }
-keep class com.google.crypto.tink.subtle.Ed25519Sign$KeyPair { *; }
-keep class com.google.crypto.tink.subtle.Ed25519Verify { *; }
-keep class com.google.crypto.tink.subtle.X25519 { *; }

# Specific Stripe missing classes
-keep class com.stripe.android.pushProvisioning.EphemeralKeyUpdateListener { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivity$g { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider { *; }

# Apache Tika and XML classes
-keep class org.apache.tika.** { *; }
-keep class javax.xml.stream.** { *; }
-keep class javax.xml.stream.XMLStreamException { *; }

# Nimbus JOSE classes (for crypto operations)
-keep class com.nimbusds.jose.** { *; }
-keep class com.nimbusds.jose.jwk.** { *; }
-keep class com.nimbusds.jose.crypto.** { *; }
-keep class com.nimbusds.jose.jwk.gen.** { *; }

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep R8 from removing classes that might be used by reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep WebView related classes
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep Hive database classes
-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }
-keep class * implements androidx.sqlite.db.SupportSQLiteOpenHelper { *; }

# Keep permission handler classes
-keep class com.baseflow.permissionhandler.** { *; }

# Keep device info classes
-keep class dev.fluttercommunity.plus.device_info.** { *; }

# Keep package info classes
-keep class dev.fluttercommunity.plus.package_info.** { *; }

# Keep webview classes
-keep class io.flutter.plugins.webviewflutter.** { *; }

# Keep all classes in packages that might be used by reflection
-keep class com.google.** { *; }
-keep class androidx.** { *; }
-keep class android.** { *; }

# Keep all classes with @Keep annotation
-keep class * {
    @androidx.annotation.Keep *;
}

# Keep all classes in the app package
-keep class com.example.edunote_student_parent_2.** { *; }

# Keep all classes that might be used by the Flutter engine
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }

# Keep all classes that might be used by deferred components
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Keep all classes that might be used by the Flutter JNI
-keep class io.flutter.embedding.engine.FlutterJNI { *; }

# Keep all classes that might be used by the Flutter engine loader
-keep class io.flutter.embedding.engine.loader.** { *; }

# Keep all classes that might be used by the Flutter plugin registry
-keep class io.flutter.plugin.common.** { *; }

# Keep all classes that might be used by the Flutter method channel
-keep class io.flutter.plugin.common.MethodChannel { *; }
-keep class io.flutter.plugin.common.MethodCall { *; }
-keep class io.flutter.plugin.common.MethodResult { *; }

# Keep all classes that might be used by the Flutter event channel
-keep class io.flutter.plugin.common.EventChannel { *; }

# Keep all classes that might be used by the Flutter basic message channel
-keep class io.flutter.plugin.common.BasicMessageChannel { *; }

# Keep all classes that might be used by the Flutter binary messenger
-keep class io.flutter.plugin.common.BinaryMessenger { *; }

# Keep all classes that might be used by the Flutter codec
-keep class io.flutter.plugin.common.StandardMessageCodec { *; }
-keep class io.flutter.plugin.common.StandardMethodCodec { *; }

# Keep all classes that might be used by the Flutter view
-keep class io.flutter.view.FlutterView { *; }
-keep class io.flutter.view.FlutterNativeView { *; }

# Keep all classes that might be used by the Flutter activity
-keep class io.flutter.embedding.android.FlutterActivity { *; }
-keep class io.flutter.embedding.android.FlutterFragmentActivity { *; }

# Keep all classes that might be used by the Flutter application
-keep class io.flutter.embedding.android.FlutterApplication { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

# Keep all classes that might be used by the Flutter engine
-keep class io.flutter.embedding.engine.FlutterEngine { *; }
-keep class io.flutter.embedding.engine.FlutterEngineCache { *; }

# Keep all classes that might be used by the Flutter renderer
-keep class io.flutter.embedding.engine.renderer.** { *; }

# Keep all classes that might be used by the Flutter surface
-keep class io.flutter.embedding.engine.renderer.SurfaceTexture { *; }

# Keep all classes that might be used by the Flutter texture
-keep class io.flutter.embedding.engine.renderer.TextureRegistry { *; }

# Keep all classes that might be used by the Flutter platform view
-keep class io.flutter.embedding.engine.platformviews.** { *; }

# Keep all classes that might be used by the Flutter accessibility
-keep class io.flutter.embedding.engine.accessibility.** { *; }

# Keep all classes that might be used by the Flutter lifecycle
-keep class io.flutter.embedding.engine.lifecycle.** { *; }

# Keep all classes that might be used by the Flutter navigation
-keep class io.flutter.embedding.engine.navigation.** { *; }

# Keep all classes that might be used by the Flutter platform
-keep class io.flutter.embedding.engine.platform.** { *; }

# Keep all classes that might be used by the Flutter system
-keep class io.flutter.embedding.engine.system.** { *; }

# Keep all classes that might be used by the Flutter thread
-keep class io.flutter.embedding.engine.thread.** { *; }

# Keep all classes that might be used by the Flutter timing
-keep class io.flutter.embedding.engine.timing.** { *; }

# Keep all classes that might be used by the Flutter tracing
-keep class io.flutter.embedding.engine.tracing.** { *; }

# Keep all classes that might be used by the Flutter utils
-keep class io.flutter.embedding.engine.utils.** { *; }

# Keep all classes that might be used by the Flutter version
-keep class io.flutter.embedding.engine.version.** { *; }

# Keep all classes that might be used by the Flutter warmup
-keep class io.flutter.embedding.engine.warmup.** { *; }

# Keep all classes that might be used by the Flutter window
-keep class io.flutter.embedding.engine.window.** { *; }