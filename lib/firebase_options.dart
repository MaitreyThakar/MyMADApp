// File generated based on Firebase project: appointment-app-d24it166
// Project: Appointment App – Smart Slot Booking System
// Student: Maitrey Thakar | D24IT166

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCM89mehXp5FScz_BBo9-1L-l-_Odo_LdY',
    appId: '1:223283814389:android:99a443382990849ed90abc',
    messagingSenderId: '223283814389',
    projectId: 'appointment-app-d24it166',
    storageBucket: 'appointment-app-d24it166.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCM89mehXp5FScz_BBo9-1L-l-_Odo_LdY',
    appId: '1:223283814389:web:44fd0c67a724856fd90abc',
    messagingSenderId: '223283814389',
    projectId: 'appointment-app-d24it166',
    authDomain: 'appointment-app-d24it166.firebaseapp.com',
    storageBucket: 'appointment-app-d24it166.firebasestorage.app',
    measurementId: 'G-V6ZPQTFFXG',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCM89mehXp5FScz_BBo9-1L-l-_Odo_LdY',
    appId: '1:223283814389:ios:99a443382990849ed90abc',
    messagingSenderId: '223283814389',
    projectId: 'appointment-app-d24it166',
    storageBucket: 'appointment-app-d24it166.firebasestorage.app',
    iosBundleId: 'com.d24it166.appointmentapp',
  );
}
