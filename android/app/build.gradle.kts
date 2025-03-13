plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter Plugin (should come last)
}

android {
    namespace = "com.example.rentloapp_admin"
    compileSdk = 35 // ✅ Update to latest version

    defaultConfig {
        applicationId = "com.example.rentloapp_admin"
        minSdk = 23
        targetSdk = 35 // ✅ Match compileSdk
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // ✅ Set to Java 17
        targetCompatibility = JavaVersion.VERSION_17 // ✅ Set to Java 17
    }

    kotlinOptions {
        jvmTarget = "17" // ✅ Use Java 17 for Kotlin
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
