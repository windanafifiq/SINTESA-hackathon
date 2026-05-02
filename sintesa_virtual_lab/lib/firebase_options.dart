// File: lib/firebase_options.dart
// 
// ⚠️  PENTING: File ini perlu dikonfigurasi dengan data Firebase project Anda.
//
// Cara setup Firebase:
// 1. Buka https://console.firebase.google.com/
// 2. Buat project baru atau gunakan yang sudah ada
// 3. Aktifkan "Authentication" → Sign-in method → Email/Password
// 4. Aktifkan "Firestore Database" dan buat database
// 5. Di Project Settings → Your apps → tambahkan Web App
// 6. Copy konfigurasi (apiKey, authDomain, dll.) ke bawah ini
//
// ATAU gunakan FlutterFire CLI:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
// Perintah di atas akan auto-generate file ini dengan data yang benar.
//
// ──────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] untuk digunakan dengan aplikasi Firebase Anda.
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
          'DefaultFirebaseOptions tidak dikonfigurasi untuk Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions tidak mendukung platform ini.',
        );
    }
  }

  // ── WEB ──────────────────────────────────────────────────────────────────

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBG-7ThTVRuaYjUc8eCa_SVkMhJSi5xD6k',
    appId: '1:417544840886:web:c3e5705a2b936623d1a817',
    messagingSenderId: '417544840886',
    projectId: 'sintesa-lab-virtual',
    authDomain: 'sintesa-lab-virtual.firebaseapp.com',
    storageBucket: 'sintesa-lab-virtual.firebasestorage.app',
  );

  // Ganti nilai-nilai ini dengan konfigurasi Firebase Web App Anda

  // ── ANDROID ───────────────────────────────────────────────────────────────

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-SVy25YG0rC1MLFumBmPd6SWluU6__2M',
    appId: '1:417544840886:android:4fdfc622dfad7bbad1a817',
    messagingSenderId: '417544840886',
    projectId: 'sintesa-lab-virtual',
    storageBucket: 'sintesa-lab-virtual.firebasestorage.app',
  );

  // Ganti nilai-nilai ini dengan konfigurasi Firebase Android App Anda

  // ── WINDOWS ───────────────────────────────────────────────────────────────

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBG-7ThTVRuaYjUc8eCa_SVkMhJSi5xD6k',
    appId: '1:417544840886:web:995fdad1a6c52de8d1a817',
    messagingSenderId: '417544840886',
    projectId: 'sintesa-lab-virtual',
    authDomain: 'sintesa-lab-virtual.firebaseapp.com',
    storageBucket: 'sintesa-lab-virtual.firebasestorage.app',
  );

  // Ganti nilai-nilai ini dengan konfigurasi Firebase Windows App Anda

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAh6NmiB5ac0_M1rragdDLxIcUTpoJzvMo',
    appId: '1:417544840886:ios:cbf46fc0c3218779d1a817',
    messagingSenderId: '417544840886',
    projectId: 'sintesa-lab-virtual',
    storageBucket: 'sintesa-lab-virtual.firebasestorage.app',
    iosBundleId: 'com.example.sintesaVirtualLab',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAh6NmiB5ac0_M1rragdDLxIcUTpoJzvMo',
    appId: '1:417544840886:ios:cbf46fc0c3218779d1a817',
    messagingSenderId: '417544840886',
    projectId: 'sintesa-lab-virtual',
    storageBucket: 'sintesa-lab-virtual.firebasestorage.app',
    iosBundleId: 'com.example.sintesaVirtualLab',
  );

}