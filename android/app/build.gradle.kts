// plugins {
//     id("com.android.application")
//     // START: FlutterFire Configuration
//     id("com.google.gms.google-services")
//     // END: FlutterFire Configuration
//     id("kotlin-android")
//     // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
//     id("dev.flutter.flutter-gradle-plugin")
// }

// android {
//     namespace = "com.example.echoo"
//     compileSdk = flutter.compileSdkVersion
//     ndkVersion = flutter.ndkVersion

//     compileOptions {
//         sourceCompatibility = JavaVersion.VERSION_17
//         targetCompatibility = JavaVersion.VERSION_17
//     }

//     kotlinOptions {
//         jvmTarget = JavaVersion.VERSION_17.toString()
//     }

//     // defaultConfig {
//     //     // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
//     //     applicationId = "com.example.echoo"
//     //     // You can update the following values to match your application needs.
//     //     // For more information, see: https://flutter.dev/to/review-gradle-config.
//     //     minSdk = flutter.minSdkVersion
//     //     targetSdk = flutter.targetSdkVersion
//     //     versionCode = flutter.versionCode
//     //     versionName = flutter.versionName
//     // }
//     android {
//     namespace = "com.example.echoo" // aapka package name
//     compileSdk = 34 // ya jo bhi version aap use kar rahe hain

//     defaultConfig {
//         applicationId = "com.example.echoo"
//         minSdk = 21  // <--- Sahi jagah ye hai
//         targetSdk = 34
//         versionCode = 1
//         versionName = "1.0"
//     }
// }

//     buildTypes {
//         release {
//             // TODO: Add your own signing config for the release build.
//             // Signing with the debug keys for now, so `flutter run --release` works.
//             signingConfig = signingConfigs.getByName("debug")
//         }
//     }
// }

// flutter {
//     source = "../.."
// }

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Sirf yeh ek line aayegi, bina kisi version ke
}
dependencies {
  // Import the Firebase BoM
  implementation(platform("com.google.firebase:firebase-bom:34.12.0"))


  // TODO: Add the dependencies for Firebase products you want to use
  // When using the BoM, don't specify versions in Firebase dependencies
  implementation("com.google.firebase:firebase-analytics")


  // Add the dependencies for any other desired Firebase products
  // https://firebase.google.com/docs/android/setup#available-libraries
}
android {
    // 1. Namespace aur SDK versions
    namespace = "com.example.echoo"
    compileSdk = 34 
    ndkVersion = flutter.ndkVersion

    // 2. Default Configuration
    defaultConfig {
        applicationId = "com.example.echoo"
        minSdk = 21 // Firebase ke liye 21 bilkul sahi hai
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
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

// (Optional) Agar aapko aage chal kar dependencies ki error aaye, toh niche wala block add kar sakte hain:
/*
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics")
}
*/