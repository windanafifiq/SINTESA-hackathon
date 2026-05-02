import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveAttempt({
    required String moduleId,
    required String moduleName,
    required int labScore,
    required int quizScore,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('attempts')
        .add({
      'moduleId': moduleId,
      'moduleName': moduleName,
      'labScore': labScore,
      'quizScore': quizScore,
      'totalScore': (labScore + quizScore) ~/ 2,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAttempts() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('attempts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
