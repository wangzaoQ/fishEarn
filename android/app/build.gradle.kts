plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id ("com.google.gms.google-services")
}

android {
    namespace = "com.example.fish.fish_earn"
    compileSdk = 36
    ndkVersion = "28.1.13356709"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true   // ← 注意这里的“is”前缀
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.fishearn"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    sourceSets {
        getByName("main") {
            jniLibs.srcDirs("libs")
        }
    }

}

dependencies{
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.aar"))))
//    implementation(files("libs/du.jar"))
    coreLibraryDesugaring ("com.android.tools:desugar_jdk_libs:2.1.4")
//    //max
    implementation ("com.applovin:applovin-sdk:13.3.1")
    implementation("com.applovin.mediation:bidmachine-adapter:3.4.0.0")
    implementation("com.applovin.mediation:bigoads-adapter:5.5.1.1")
    //chartboost
    implementation("com.applovin.mediation:chartboost-adapter:9.9.2.1")
    implementation("com.google.android.gms:play-services-base:16.1.0")
    //dt
    implementation("com.applovin.mediation:fyber-adapter:8.3.8.0")
    implementation("com.applovin.mediation:inmobi-adapter:10.8.7.0")
    implementation("com.squareup.picasso:picasso:2.8")
    implementation("androidx.recyclerview:recyclerview:1.1.0")
    implementation("com.applovin.mediation:ironsource-adapter:8.10.0.0.0")
    //Liftoff Monetize
    implementation("com.applovin.mediation:vungle-adapter:7.5.1.0")
    implementation("com.applovin.mediation:facebook-adapter:6.20.0.0")
    implementation("com.applovin.mediation:mintegral-adapter:16.9.91.0")
    implementation("com.applovin.mediation:moloco-adapter:3.12.1.0")
    //pangle
    implementation("com.applovin.mediation:bytedance-adapter:7.5.0.2.0")
    implementation("com.applovin.mediation:unityads-adapter:4.16.1.0")
//    implementation ("com.applovin.mediation:google-ad-manager-adapter:24.5.0.0")
//    implementation ("com.applovin.mediation:google-adapter:24.5.0.0")
}

flutter {
    source = "../.."
}
