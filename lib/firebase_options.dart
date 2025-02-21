// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBMzL-G40revnpwNprgRImEodGWHf-Pe8E',
    appId: '1:383422081574:android:361e007caa06966db014e7',
    messagingSenderId: '383422081574',
    projectId: 'cipher-89c0d',
    storageBucket: 'cipher-89c0d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD4YEy2K9pMpncKne_Pd_zPYXOVYbsvHqM',
    appId: '1:383422081574:ios:9ca4cca0c609ef77b014e7',
    messagingSenderId: '383422081574',
    projectId: 'cipher-89c0d',
    storageBucket: 'cipher-89c0d.firebasestorage.app',
    androidClientId: '383422081574-rqa6i5mhg0ue2k0ivjmc5l4ttdgfpm8f.apps.googleusercontent.com',
    iosClientId: '383422081574-nd25744cfo5vtfl9rglv0emd4osk8fu0.apps.googleusercontent.com',
    iosBundleId: 'com.example.cipher',
  );

}