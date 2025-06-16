import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseOptionsEnv {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY_WEB']!,
        appId: dotenv.env['FIREBASE_APP_ID_WEB']!,
        messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
        projectId: dotenv.env['PROJECT_ID']!,
        storageBucket: dotenv.env['STORAGE_BUCKET']!,
        measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID_WEB'],
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY_ANDROID']!,
          appId: dotenv.env['FIREBASE_APP_ID_ANDROID']!,
          messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
          projectId: dotenv.env['PROJECT_ID']!,
          storageBucket: dotenv.env['STORAGE_BUCKET']!,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY_IOS']!,
          appId: dotenv.env['FIREBASE_APP_ID_IOS']!,
          messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
          projectId: dotenv.env['PROJECT_ID']!,
          storageBucket: dotenv.env['STORAGE_BUCKET']!,
        );
      case TargetPlatform.windows:
        return FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY_WINDOWS']!,
          appId: dotenv.env['FIREBASE_APP_ID_WINDOWS']!,
          messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
          projectId: dotenv.env['PROJECT_ID']!,
          storageBucket: dotenv.env['STORAGE_BUCKET']!,
          measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID_WINDOWS'],
        );
      default:
        throw UnsupportedError(
          'Firebase configuration is not supported for this platform.',
        );
    }
  }
}
