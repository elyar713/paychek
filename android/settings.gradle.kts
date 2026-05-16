pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Versions réelles sur Maven Google (8.10.2 n’existe pas → résolution impossible).
    // 8.11.x + Gradle 8.14 : exiger Gradle ≥ 8.13 pour AGP 8.11 (cf. Android / Flutter).
    id("com.android.application") version "8.11.2" apply false
    id("com.android.library") version "8.11.2" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false
    // END: FlutterFire Configuration
    // Aligné sur les deps Google (play-services-measurement * Kotlin metadata 2.2) et Flutter ≥ 2.1.
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
