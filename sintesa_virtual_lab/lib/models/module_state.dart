import '../services/score_service.dart';

class ModuleTitles {
  static const String asamBasa = 'Asam Basa Alami';
  static const String reaksiRedoks = 'Reaksi Redoks';
  static const String larutanBuffer = 'Larutan Buffer';
}

class ModuleProgress {
  static Map<String, Map<String, dynamic>> status = {
    ModuleTitles.asamBasa: {'status': 'Mulai', 'score': null},
    ModuleTitles.reaksiRedoks: {'status': 'Mulai', 'score': null},
    ModuleTitles.larutanBuffer: {'status': 'Mulai', 'score': null},
    'Osmosis & Difusi': {'status': 'Mulai', 'score': null},
  };

  static void complete(String title, int score) {
    print("✅ [DEBUG] Completing module: $title with score: $score");
    status[title] = {'status': 'Selesai', 'score': score};
    print("✅ [DEBUG] New status for $title: ${status[title]}");
  }

  static void reset() {
    status.forEach((key, value) {
      status[key] = {'status': 'Mulai', 'score': null};
    });
  }

  static Future<void> syncWithFirestore() async {
    try {
      reset(); // Start with clean state
      final snapshot = await ScoreService().getAttempts().first;
      // Dokumen sudah diurutkan descending (terbaru duluan).
      // Tandai modul yang sudah di-set agar tidak ditimpa oleh attempt lama.
      final Set<String> alreadySet = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final title = data['moduleName'] as String?;
        final totalScore = data['totalScore'] as int?;
        if (title != null && status.containsKey(title) && !alreadySet.contains(title)) {
          // Ambil hanya attempt pertama (terbaru) per modul
          status[title] = {'status': 'Selesai', 'score': totalScore};
          alreadySet.add(title);
        }
      }
    } catch (e) {
      print("❌ [DEBUG] Error syncing progress: $e");
    }
  }
}
