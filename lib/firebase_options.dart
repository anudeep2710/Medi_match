import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
    apiKey: 'AIzaSyCLEMsUT7EqMOzaY0IMfhUevhvDEFF2K7Q',
    appId: '1:811543386253:web:3dbae7c2a9913d44f7aac4',
    messagingSenderId: '811543386253',
    projectId: 'medimatch-f446c',
    authDomain: 'medimatch-f446c.firebaseapp.com',
    databaseURL: 'https://medimatch-f446c-default-rtdb.firebaseio.com',
    storageBucket: 'medimatch-f446c.firebasestorage.app',
    measurementId: 'G-Q7ZBPMC4HC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAXZQkIuqKHrCLrsQ0Yoakv49mIEEBkhG0',
    appId: '1:811543386253:android:00c1ca82a9aab100f7aac4',
    messagingSenderId: '811543386253',
    projectId: 'medimatch-f446c',
    databaseURL: 'https://medimatch-f446c-default-rtdb.firebaseio.com',
    storageBucket: 'medimatch-f446c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCLEMsUT7EqMOzaY0IMfhUevhvDEFF2K7Q',
    appId: '1:811543386253:ios:3dbae7c2a9913d44f7aac4',
    messagingSenderId: '811543386253',
    projectId: 'medimatch-f446c',
    databaseURL: 'https://medimatch-f446c-default-rtdb.firebaseio.com',
    storageBucket: 'medimatch-f446c.firebasestorage.app',
    iosClientId:
        '811543386253-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com',
    iosBundleId: 'com.health.medimatch',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCLEMsUT7EqMOzaY0IMfhUevhvDEFF2K7Q',
    appId: '1:811543386253:ios:3dbae7c2a9913d44f7aac4',
    messagingSenderId: '811543386253',
    projectId: 'medimatch-f446c',
    databaseURL: 'https://medimatch-f446c-default-rtdb.firebaseio.com',
    storageBucket: 'medimatch-f446c.firebasestorage.app',
    iosClientId:
        '811543386253-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com',
    iosBundleId: 'com.health.medimatch',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCLEMsUT7EqMOzaY0IMfhUevhvDEFF2K7Q',
    appId: '1:811543386253:web:3dbae7c2a9913d44f7aac4',
    messagingSenderId: '811543386253',
    projectId: 'medimatch-f446c',
    authDomain: 'medimatch-f446c.firebaseapp.com',
    databaseURL: 'https://medimatch-f446c-default-rtdb.firebaseio.com',
    storageBucket: 'medimatch-f446c.firebasestorage.app',
    measurementId: 'G-Q7ZBPMC4HC',
  );
}
