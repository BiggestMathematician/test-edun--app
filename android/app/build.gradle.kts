plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.edunote_student_parent_2"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.edunote_student_parent_2"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    packaging {
        pickFirsts += listOf(
            "**/libc++_shared.so",
            "**/libjsc.so"
        )
        excludes += listOf(
            "META-INF/DEPENDENCIES",
            "META-INF/LICENSE",
            "META-INF/LICENSE.txt",
            "META-INF/license.txt",
            "META-INF/NOTICE",
            "META-INF/NOTICE.txt",
            "META-INF/notice.txt",
            "META-INF/ASL2.0",
            "META-INF/*.kotlin_module"
        )
    }

    // R8 configuration to prevent missing classes
    buildFeatures {
        buildConfig = true
    }
}

dependencies {
    // Add missing Google Play Core dependencies
    implementation("com.google.android.play:core:1.10.3")
    implementation("com.google.android.play:core-ktx:1.8.1")
    
    // Add crypto dependencies
    implementation("com.google.crypto.tink:tink-android:1.7.0")
    implementation("com.google.crypto.tink:tink:1.7.0")
    
    // Add XML stream dependencies
    implementation("javax.xml.stream:javax.xml.stream-api:1.0")
    implementation("org.apache.tika:tika-core:2.7.0")
}

configurations.all {
    resolutionStrategy {
        // Force use of specific versions to avoid conflicts
        force("com.google.android.play:core:1.10.3")
        force("com.google.android.play:core-ktx:1.8.1")
        force("com.google.crypto.tink:tink-android:1.7.0")
        force("com.google.crypto.tink:tink:1.7.0")
        
        // Exclude conflicting versions
        exclude(group = "com.google.android.play", module = "core-common")
    }
}

flutter {
    source = "../.."
}
