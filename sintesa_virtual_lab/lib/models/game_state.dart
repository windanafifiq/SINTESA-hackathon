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
  List<Solution> _solutions = SolutionData.getAllSolutions();
  int _score = 0;
  int _tries = 0;
  int _maxTries = 10;
  
  // Gamification
  int _safetyScore = 100;
  int _precisionScore = 100;
  final Set<String> _badges = {};
  
  // Mastery levels
  String get masteryLevel {
    if (_score > 200) return 'Chief Researcher';
    if (_score > 100) return 'Senior Researcher';
    if (_score > 50) return 'Lab Assistant';
    return 'Trainee';
  }

  GamePhase get phase => _phase;
  List<Solution> get solutions => _solutions;
  int get score => _score;
  int get safetyScore => _safetyScore;
  int get precisionScore => _precisionScore;
  Set<String> get badges => _badges;
  
  bool get allGlassesDone => _solutions.every((s) => s.hasKunyit);

  void goToPhase(GamePhase phase) {
    _phase = phase;
    notifyListeners();
  }

  // Stoichiometry logic: adding kunyit impacts the visual based on pH
  bool addKunyitToSolution(String solutionId) {
    final idx = _solutions.indexWhere((s) => s.id == solutionId);
    if (idx >= 0 && !_solutions[idx].hasKunyit) {
      // Logic for color change based on pH
      final ph = _solutions[idx].ph;
      // In a real engine, we'd calculate reaction products here
      _solutions[idx] = _solutions[idx].copyWith(hasKunyit: true);
      
      _tries++;
      _score += 15;
      
      // Precision bonus for steady pouring (simulated)
      _precisionScore = (_precisionScore + 5).clamp(0, 100);
      
      if (_solutions[idx].ph > 11.0) {
        _addBadge('Strong Base Expert');
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  void updateNotebook(String solutionId, {String? color, String? type, String? note}) {
    final idx = _solutions.indexWhere((s) => s.id == solutionId);
    if (idx >= 0) {
      _solutions[idx] = _solutions[idx].copyWith(
        observationColor: color,
        observationType: type,
        observationNote: note,
      );
      _score += 10;
      notifyListeners();
    }
  }

  void _addBadge(String badge) {
    if (!_badges.contains(badge)) {
      _badges.add(badge);
    }
  }

  void penalizeSafety(int penalty) {
    _safetyScore = (_safetyScore - penalty).clamp(0, 100);
    if (_safetyScore < 70) {
      _score -= 5;
    }
    notifyListeners();
  }

  void reset() {
    _phase = GamePhase.intro;
    _solutions = SolutionData.getAllSolutions();
    _score = 0;
    _tries = 0;
    _safetyScore = 100;
    _precisionScore = 100;
    _badges.clear();
    notifyListeners();
  }
}
