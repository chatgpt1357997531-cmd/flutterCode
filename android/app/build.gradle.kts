plugins {
    id("com.android.application")

    // ✅ Firebase plugins
    id("com.google.gms.google-services")

    // ✅ Kotlin + Flutter plugin
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.adminpanelapp"
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.adminpanelapp"
        minSdk = 33 // ✅ ضروري لـ permission_handler 12+
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ⚠️ يمكنك تعديل هذا لاحقًا لتوقيع الإصدار
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        viewBinding = true
    }
}

flutter {
    source = "../.."
}
