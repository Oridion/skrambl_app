plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.oridion.skrambl"
    compileSdk = flutter.compileSdkVersion
    //ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.oridion.skrambl"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Fixed path inside the project:
            storeFile = rootProject.file("app/skrambl-release-key.jks")

            // Read secrets from ~/.gradle/gradle.properties (or env if you prefer)
            fun prop(name: String) =
                System.getenv(name) ?: project.findProperty(name) as String?

            storePassword = prop("SKRAMBL_UPLOAD_STORE_PASSWORD")
                ?: throw GradleException("Missing SKRAMBL_UPLOAD_STORE_PASSWORD")
            keyAlias = prop("SKRAMBL_UPLOAD_KEY_ALIAS")
                ?: throw GradleException("Missing SKRAMBL_UPLOAD_KEY_ALIAS")
            keyPassword = prop("SKRAMBL_UPLOAD_KEY_PASSWORD")
                ?: throw GradleException("Missing SKRAMBL_UPLOAD_KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
