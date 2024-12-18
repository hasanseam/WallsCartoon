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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBkBbDiM87hyJj5bqBOgdUPc8MLOtpHQkU',
    appId: '1:832257314194:web:aed070115a9a8bc90d454b',
    messagingSenderId: '832257314194',
    projectId: 'walls-cartoon',
    authDomain: 'walls-cartoon.firebaseapp.com',
    storageBucket: 'walls-cartoon.appspot.com',
    measurementId: 'G-8JDEKVMXKP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDqyVHQhpzMcPFFONjUwF74EPS-xiXfrDU',
    appId: '1:832257314194:android:ffaf8b7cd4e5fb2c0d454b',
    messagingSenderId: '832257314194',
    projectId: 'walls-cartoon',
    storageBucket: 'walls-cartoon.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCndiQUsgN--4mInjbU_49nm4ERXiAmrSc',
    appId: '1:832257314194:ios:b80e99b2b87686d40d454b',
    messagingSenderId: '832257314194',
    projectId: 'walls-cartoon',
    storageBucket: 'walls-cartoon.appspot.com',
    iosBundleId: 'com.hasanur.downloadWallpaper',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCndiQUsgN--4mInjbU_49nm4ERXiAmrSc',
    appId: '1:832257314194:ios:b80e99b2b87686d40d454b',
    messagingSenderId: '832257314194',
    projectId: 'walls-cartoon',
    storageBucket: 'walls-cartoon.appspot.com',
    iosBundleId: 'com.hasanur.downloadWallpaper',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBkBbDiM87hyJj5bqBOgdUPc8MLOtpHQkU',
    appId: '1:832257314194:web:332c94fdea67fa970d454b',
    messagingSenderId: '832257314194',
    projectId: 'walls-cartoon',
    authDomain: 'walls-cartoon.firebaseapp.com',
    storageBucket: 'walls-cartoon.appspot.com',
    measurementId: 'G-8HL83328R5',
  );

}