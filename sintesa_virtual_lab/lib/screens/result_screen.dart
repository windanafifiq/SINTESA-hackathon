import 'package:flutter/material.dart';
import '../models/app_colors.dart';
import '../models/game_state.dart';
import '../models/solution.dart';
import '../widgets/lab_widgets.dart';
import '../painters/lab_painters.dart';
import 'dashboard_screen.dart';
import 'game_screen.dart';
import '../models/module_state.dart';
import '../services/score_service.dart';


class ResultScreen extends StatefulWidget {
  final GameState gameState;

  const ResultScreen({super.key, required this.gameState});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late Animation<double> _headerScale;

  // Quiz state: user identifying acid/base
  final Map<String, SolutionType?> _userAnswers = {};
  bool _quizCompleted = false;
  int _quizScore = 0;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _headerScale =
        CurvedAnimation(parent: _headerCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  void _submitQuiz() {
    int score = 0;
    for (final solution in widget.gameState.solutions) {
      if (_userAnswers[solution.id] == solution.type) {
        score++;
      }
    }
    setState(() {
      _quizScore = score;
      _quizCompleted = true;
    });
    // Simpan progres ke Dashboard agar status berubah jadi Selesai
    ModuleProgress.complete(ModuleTitles.asamBasa, (score / widget.gameState.solutions.length * 100).round());
    
    // Simpan ke Firestore untuk riwayat nilai
    ScoreService().saveAttempt(
      moduleId: 'asam_basa_alami',
      moduleName: ModuleTitles.asamBasa,
      labScore: widget.gameState.score.clamp(0, 100), // Asumsi skor max lab
      quizScore: (score / widget.gameState.solutions.length * 100).round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B35),
              Color(0xFF1A2744),
              Color(0xFF0D1B35),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _quizCompleted
                    ? _buildFinalResult()
                    : _buildQuizSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ScaleTransition(
      scale: _headerScale,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.science, color: AppColors.primary200, size: 32),
            const SizedBox(height: 8),
            const Text(
              'Hasil Pengamatan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Praktikum Indikator Asam-Basa Alami',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizSection() {
    final solutions = widget.gameState.solutions;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info900.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.info500.withOpacity(0.4)),
          ),
          child: const Row(
            children: [
              Icon(Icons.quiz, color: AppColors.info500, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Berdasarkan perubahan warna, identifikasi sifat setiap larutan!',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
        ),

        // Flask display row
        SizedBox(
          height: 140,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: solutions
                  .map((s) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: FlaskWidget(
                          solution: s,
                          width: 65,
                          height: 95,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),

        // Quiz list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: solutions.length,
            itemBuilder: (context, index) {
              final solution = solutions[index];
              return _buildQuizItem(solution, index);
            },
          ),
        ),

        // Submit button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _userAnswers.length == solutions.length
                ? _submitQuiz
                : null,
            icon: const Icon(Icons.check_circle),
            label: Text(
              _userAnswers.length == solutions.length
                  ? 'Cek Jawaban!'
                  : 'Jawab semua dulu (${_userAnswers.length}/${solutions.length})',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _userAnswers.length == solutions.length
                  ? AppColors.success700
                  : Colors.grey[800],
              foregroundColor: _userAnswers.length == solutions.length
                  ? AppColors.success400
                  : Colors.white54,
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizItem(Solution solution, int index) {
    final selected = _userAnswers[solution.id];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 200 + index * 80),
      builder: (context, value, child) =>
          Opacity(opacity: value, child: child),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary900.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected != null
                ? _getTypeColor(selected).withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            // Color swatch
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: solution.afterColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: solution.afterColor.withOpacity(0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                solution.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Answer buttons
            ...[SolutionType.asam, SolutionType.basa, SolutionType.netral]
                .map((type) {
              final isSelected = selected == type;
              return GestureDetector(
                onTap: () =>
                    setState(() => _userAnswers[solution.id] = type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getTypeColor(type).withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? _getTypeColor(type)
                          : Colors.white.withOpacity(0.15),
                    ),
                  ),
                  child: Text(
                    _getTypeLabel(type),
                    style: TextStyle(
                      color: isSelected
                          ? _getTypeColor(type)
                          : Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalResult() {
    final total = widget.gameState.solutions.length;
    final pct = (_quizScore / total * 100).round();
    final passed = pct >= 70;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Final Report Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary900.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.info500.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'LABORATORY RESEARCH REPORT',
                  style: TextStyle(color: AppColors.info500, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const Divider(color: Colors.white10, height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _reportStat('Mastery', widget.gameState.masteryLevel, AppColors.warning400),
                    _reportStat('Safety', '${widget.gameState.safetyScore}%', AppColors.success400),
                    _reportStat('Precision', '${widget.gameState.precisionScore}%', AppColors.info400),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Badge Collection
          if (widget.gameState.badges.isNotEmpty) ...[
            const Text(
              'LENCANA PENCAPAIAN',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: widget.gameState.badges.map((b) => _buildBadgeItem(b)).toList(),
            ),
            const SizedBox(height: 25),
          ],

          const Text(
            'HASIL ANALISIS LARUTAN',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Answer review
          ...widget.gameState.solutions.asMap().entries.map((entry) {
            final i = entry.key;
            final solution = entry.value;
            final userAnswer = _userAnswers[solution.id];
            final isCorrect = userAnswer == solution.type;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + i * 80),
              builder: (context, value, child) =>
                  Opacity(opacity: value, child: child),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCorrect
                        ? AppColors.success400.withOpacity(0.3)
                        : AppColors.danger300.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.verified : Icons.error_outline,
                      color: isCorrect ? AppColors.success400 : AppColors.danger300,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            solution.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            solution.explanation,
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    (route) => false,
                  ),
                  icon: const Icon(Icons.home),
                  label: const Text('Ke Menu Utama'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary800),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final newState = GameState();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => GameScreen(gameState: newState)),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.info700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reportStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBadgeItem(String badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warning900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning400.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium, color: AppColors.warning400, size: 14),
          const SizedBox(width: 6),
          Text(badge, style: const TextStyle(color: AppColors.warning400, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getTypeColor(SolutionType type) {
    switch (type) {
      case SolutionType.asam:
        return AppColors.danger300;
      case SolutionType.basa:
        return AppColors.info500;
      case SolutionType.netral:
        return AppColors.success400;
    }
  }

  String _getTypeLabel(SolutionType type) {
    switch (type) {
      case SolutionType.asam:
        return 'ASAM';
      case SolutionType.basa:
        return 'BASA';
      case SolutionType.netral:
        return 'NETRAL';
    }
  }
}

