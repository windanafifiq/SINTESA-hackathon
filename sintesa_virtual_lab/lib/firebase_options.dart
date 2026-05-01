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
    apiKey: 'AIzaSyDnJ81YfaDyTWTcuYk9JamAevo1hxWlpGU',
    appId: '1:981520254321:web:2b3cfbf21c8987a3c822d0',
    messagingSenderId: '981520254321',
    projectId: 'sintesa-lab',
    authDomain: 'sintesa-lab.firebaseapp.com',
    storageBucket: 'sintesa-lab.firebasestorage.app',
  );

  // Ganti nilai-nilai ini dengan konfigurasi Firebase Web App Anda

  // ── ANDROID ───────────────────────────────────────────────────────────────

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDEAN-1pPL5QaLtHiQ6SE5VcxWECTAYMi8',
    appId: '1:981520254321:android:99e62f36244ea917c822d0',
    messagingSenderId: '981520254321',
    projectId: 'sintesa-lab',
    storageBucket: 'sintesa-lab.firebasestorage.app',
  );

  // Ganti nilai-nilai ini dengan konfigurasi Firebase Android App Anda

  // ── WINDOWS ───────────────────────────────────────────────────────────────

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDnJ81YfaDyTWTcuYk9JamAevo1hxWlpGU',
    appId: '1:981520254321:web:655288c742105f4ac822d0',
    messagingSenderId: '981520254321',
    projectId: 'sintesa-lab',
    authDomain: 'sintesa-lab.firebaseapp.com',
    storageBucket: 'sintesa-lab.firebasestorage.app',
  );

  // Ganti nilai-nilai ini dengan konfigurasi Firebase Windows App Anda

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCk8OsX2ZbTq_9rx0vBT__neTtVj80vUgk',
    appId: '1:981520254321:ios:10df629c004a14e4c822d0',
    messagingSenderId: '981520254321',
    projectId: 'sintesa-lab',
    storageBucket: 'sintesa-lab.firebasestorage.app',
    iosBundleId: 'com.example.sintesaVirtualLab',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCk8OsX2ZbTq_9rx0vBT__neTtVj80vUgk',
    appId: '1:981520254321:ios:10df629c004a14e4c822d0',
    messagingSenderId: '981520254321',
    projectId: 'sintesa-lab',
    storageBucket: 'sintesa-lab.firebasestorage.app',
    iosBundleId: 'com.example.sintesaVirtualLab',
  );

}