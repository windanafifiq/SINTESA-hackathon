import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream untuk memantau perubahan state auth
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // User saat ini
  User? get currentUser => _auth.currentUser;

  // Register dengan email & password
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name
    await credential.user?.updateDisplayName(name);

    // Simpan data tambahan ke Firestore
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'name': name,
      'email': email,
      'role': 'siswa',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  // Login dengan email & password
  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Kirim email reset password
  Future<void> resetPassword({required String email}) async {
    final cleanEmail = email.trim();

    // Cek apakah email terdaftar di Firebase Auth
    final methods = await _auth.fetchSignInMethodsForEmail(cleanEmail);
    if (methods.isEmpty) {
      throw Exception('email-not-found');
    }

    await _auth.sendPasswordResetEmail(email: cleanEmail);
  }

  // Ambil data user dari Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }
}
