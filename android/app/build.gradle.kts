import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing (D-144). The upload keystore and its passwords live
// outside Git: android/key.properties (gitignored), or the file named by
// the MOKSHARAN_KEY_PROPERTIES environment variable. See docs/RELEASE.md.
val keyPropertiesFile: File =
    System.getenv("MOKSHARAN_KEY_PROPERTIES")?.let { file(it) }
        ?: rootProject.file("key.properties")
val keyProperties = Properties().apply {
    if (keyPropertiesFile.exists()) {
        keyPropertiesFile.inputStream().use { load(it) }
    }
}
val hasUploadKey = keyPropertiesFile.exists()

android {
    namespace = "io.github.karan_ksrk.moksharan"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Permanent package ID; never change (CLAUDE.md).
        applicationId = "io.github.karan_ksrk.moksharan"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // On-demand chapter media packs (D-139). Only app bundles carry them;
    // plain APKs (flutter run) report them unavailable.
    assetPacks += listOf(":chapter_02")

    signingConfigs {
        if (hasUploadKey) {
            create("upload") {
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Never signed with the debug key. Without key.properties the
            // release output is unsigned and cannot be installed or
            // uploaded (docs/RELEASE.md).
            signingConfig =
                if (hasUploadKey) signingConfigs.getByName("upload") else null
            // Keeps classes R8 would wrongly strip (D-145).
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Play Asset Delivery client for chapter packs (D-139).
    implementation("com.google.android.play:asset-delivery:2.3.0")
}
