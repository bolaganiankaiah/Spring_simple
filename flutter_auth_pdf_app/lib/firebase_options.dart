// Placeholder Firebase options. Replace with values from Firebase Console or FlutterFire CLI.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'web-api-key',
        appId: '1:000000000000:web:example',
        messagingSenderId: '000000000000',
        projectId: 'your-project-id',
        storageBucket: 'your-project-id.appspot.com',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'android-api-key',
          appId: '1:000000000000:android:example',
          messagingSenderId: '000000000000',
          projectId: 'your-project-id',
          storageBucket: 'your-project-id.appspot.com',
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: 'ios-api-key',
          appId: '1:000000000000:ios:example',
          messagingSenderId: '000000000000',
          projectId: 'your-project-id',
          storageBucket: 'your-project-id.appspot.com',
          iosBundleId: 'com.example.flutterAuthPdfApp',
        );
      case TargetPlatform.macOS:
        return const FirebaseOptions(
          apiKey: 'macos-api-key',
          appId: '1:000000000000:ios:example',
          messagingSenderId: '000000000000',
          projectId: 'your-project-id',
          storageBucket: 'your-project-id.appspot.com',
          iosBundleId: 'com.example.flutterAuthPdfApp',
        );
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return const FirebaseOptions(
          apiKey: 'desktop-api-key',
          appId: '1:000000000000:desktop:example',
          messagingSenderId: '000000000000',
          projectId: 'your-project-id',
          storageBucket: 'your-project-id.appspot.com',
        );
    }
  }
}