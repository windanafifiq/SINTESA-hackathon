import 'package:flutter/foundation.dart';
import 'solution.dart';

enum GamePhase {
  intro,
  step1_description,
  step2_inventory_tutorial,
  step3_experiment,
  step4_observe,
  result,
  completed,
}

class GameState extends ChangeNotifier {
  GamePhase _phase = GamePhase.intro;
  List<Solution> _solutions = SolutionData.getAllSolutions().toList();
  int _score = 0;
  int _safetyScore = 100;
  int _precisionScore = 100;
  final Set<String> _badges = {};

  // ── Getters ────────────────────────────────────────────────────────────────

  GamePhase get phase => _phase;
  List<Solution> get solutions => _solutions;
  int get score => _score;
  int get safetyScore => _safetyScore;
  int get precisionScore => _precisionScore;
  Set<String> get badges => _badges;

  /// Semua gelas sudah dituangi kunyit (belum tentu diaduk)
  bool get allKunyitAdded =>
      _solutions.every((s) => s.state != SolutionState.empty);

  /// Semua gelas sudah diaduk dan warna terungkap
  bool get allGlassesDone =>
      _solutions.every((s) => s.state == SolutionState.revealed);

  /// Berapa gelas yang masih perlu diaduk
  int get pendingStirCount =>
      _solutions.where((s) => s.state == SolutionState.kunyitAdded).length;

  String get masteryLevel {
    if (_score > 200) return 'Chief Researcher';
    if (_score > 100) return 'Senior Researcher';
    if (_score > 50) return 'Lab Assistant';
    return 'Trainee';
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void goToPhase(GamePhase phase) {
    _phase = phase;
    notifyListeners();
  }

  // ── Step 1: Tuang kunyit ke gelas ─────────────────────────────────────────
  //
  // Returns true  → kunyit berhasil dituang (gelas beralih ke kunyitAdded)
  // Returns false → gelas sudah diisi / tidak valid

  bool addKunyitToSolution(String solutionId) {
    
    final idx = _solutions.indexWhere((s) => s.id == solutionId);

    print("💡 [DEBUG GameState] Ketemu di index: $idx");
    if (idx < 0) return false;
    if (_solutions[idx].state != SolutionState.empty) return false;

    _solutions[idx] = _solutions[idx].copyWith(state: SolutionState.kunyitAdded);

    _score += 5; // poin kecil untuk setiap tuangan
    notifyListeners();
    print("💡 [DEBUG GameState] State sebelum: ${_solutions[idx].state}");
    

    return true;
  }

  // ── Step 2: Aduk gelas → warna berubah ────────────────────────────────────
  //
  // Returns true  → pengadukan berhasil, warna terungkap
  // Returns false → gelas belum diisi kunyit / sudah diaduk

  bool stirSolution(String solutionId) {
    final idx = _solutions.indexWhere((s) => s.id == solutionId);
    if (idx < 0) return false;
    if (_solutions[idx].state != SolutionState.kunyitAdded) return false;

    // Fase stirring (animasi dihandle di UI, state langsung ke revealed)
    _solutions[idx] = _solutions[idx].copyWith(state: SolutionState.revealed);

    _score += 15;
    _precisionScore = (_precisionScore + 3).clamp(0, 100);

    // Badge: strong base expert
    if (_solutions[idx].ph > 11.0) {
      _addBadge('Strong Base Expert');
    }

    // Badge: semua selesai diaduk
    if (allGlassesDone) {
      _addBadge('Diligent Chemist');
    }

    notifyListeners();
    return true;
  }

  // ── Notebook ───────────────────────────────────────────────────────────────

  void updateNotebook(
    String solutionId, {
    String? color,
    String? type,
    String? note,
  }) {
    final idx = _solutions.indexWhere((s) => s.id == solutionId);
    if (idx < 0) return;
    _solutions[idx] = _solutions[idx].copyWith(
      observationColor: color,
      observationType: type,
      observationNote: note,
    );
    _score += 10;
    notifyListeners();
  }

  // ── Safety ─────────────────────────────────────────────────────────────────

  void penalizeSafety(int penalty) {
    _safetyScore = (_safetyScore - penalty).clamp(0, 100);
    if (_safetyScore < 70) _score = (_score - 5).clamp(0, 9999);
    notifyListeners();
  }

  // ── Reset ──────────────────────────────────────────────────────────────────

  void reset() {
    _phase = GamePhase.intro;
    _solutions = SolutionData.getAllSolutions().toList();
    _score = 0;
    _safetyScore = 100;
    _precisionScore = 100;
    _badges.clear();
    notifyListeners();
  }

  // ── Private ────────────────────────────────────────────────────────────────

  void _addBadge(String badge) {
    if (_badges.add(badge)) notifyListeners();
  }
}