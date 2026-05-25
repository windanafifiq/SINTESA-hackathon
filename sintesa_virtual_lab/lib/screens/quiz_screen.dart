import 'package:flutter/material.dart';
import '../models/app_colors.dart';
import '../models/module_state.dart';
import '../services/score_service.dart';
import 'dashboard_screen.dart';

class QuizScreen extends StatefulWidget {
  final int labScore;
  final int completionScore;
  final int notebookScore;
  final int reportScore;

  const QuizScreen({
    super.key,
    this.labScore = 0,
    this.completionScore = 0,
    this.notebookScore = 0,
    this.reportScore = 0,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isFinished = false;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Air jeruk bersifat asam karena memiliki pH kurang dari 7.',
      'answer': true,
    },
    {
      'question':
          'Ekstrak kunyit akan berubah menjadi warna merah bata jika diteteskan pada larutan asam.',
      'answer': false,
    },
    {
      'question': 'Air sabun merupakan contoh larutan yang bersifat basa.',
      'answer': true,
    },
    {
      'question':
          'Garam dapur adalah larutan netral yang memiliki pH sekitar 7.',
      'answer': true,
    },
    {
      'question':
          'Kertas lakmus merah akan berubah menjadi biru saat dicelupkan ke dalam larutan asam.',
      'answer': false,
    },
  ];

  void _answerQuestion(bool value) {
    if (_questions[_currentQuestionIndex]['answer'] == value) {
      _score += 20; // 5 pertanyaan, 20 poin masing-masing = max 100
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      setState(() {
        _isFinished = true;
      });
    }
  }

  Future<void> _backToHome() async {
    setState(() => _isSaving = true);

    // Weighted scoring calculation (Last Request):
    // 50% Completion (max 140)
    // 30% Notebook (max 140) + Report (max 100)
    // 20% Quiz (max 100)

    final completionPct = (widget.completionScore / 140) * 50;

    // Combine Notebook (15%) and Report (15%) for total 30%
    final notebookPct = (widget.notebookScore / 140) * 15;
    final reportPct = (widget.reportScore / 100) * 15;

    final quizPct = (_score / 100) * 20;

    final finalScore = (completionPct + notebookPct + reportPct + quizPct)
        .round();

    try {
      // Update Local State
      ModuleProgress.complete(ModuleTitles.asamBasa, finalScore);

      // Calculate display percentages for historical view
      final pScore = (widget.completionScore / 140 * 100).round();
      // Combined Laporan score (Notebook + Form)
      final rScore =
          ((widget.notebookScore / 140 * 50) + (widget.reportScore / 100 * 50))
              .round();
      final qScore = _score;

      await ScoreService().saveAttempt(
        moduleId: 'asam_basa_alami',
        moduleName: ModuleTitles.asamBasa,
        practicumScore: pScore,
        reportScore: rScore,
        quizScore: qScore,
        totalScore: finalScore,
      );
    } catch (e) {
      debugPrint('Error saving score: $e');
    }

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF), // Vibe dashboard screen
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Kuis Praktikum Asam Basa',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primary900,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: _isFinished ? _buildResultPage() : _buildQuizPage(),
        ),
      ),
    );
  }

  Widget _buildQuizPage() {
    final question = _questions[_currentQuestionIndex]['question'] as String;
    final isShort = MediaQuery.of(context).size.height < 500;

    return Container(
      width: 500,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isShort ? 16 : 32,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary900.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary200.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Pertanyaan ${_currentQuestionIndex + 1} dari ${_questions.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary800,
                ),
              ),
            ),
            SizedBox(height: isShort ? 16 : 32),
            Text(
              question,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isShort ? 16 : 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary900,
                height: 1.4,
              ),
            ),
            SizedBox(height: isShort ? 24 : 48),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _answerQuestion(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success700,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isShort ? 12 : 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'BENAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _answerQuestion(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger500,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isShort ? 12 : 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'SALAH',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultPage() {
    final isShort = MediaQuery.of(context).size.height < 500;

    return Container(
      width: 500,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: EdgeInsets.symmetric(
        horizontal: 32,
        vertical: isShort ? 16 : 40,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary900.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isShort ? 10 : 20),
              decoration: BoxDecoration(
                color: AppColors.warning500.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                size: isShort ? 48 : 80,
                color: AppColors.warning500,
              ),
            ),
            SizedBox(height: isShort ? 12 : 24),
            Text(
              'Kuis Selesai!',
              style: TextStyle(
                fontSize: isShort ? 20 : 26,
                fontWeight: FontWeight.w900,
                color: AppColors.primary900,
              ),
            ),
            SizedBox(height: isShort ? 8 : 12),
            // Final Score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary800,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'SKOR AKHIR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '${((widget.completionScore / 140 * 50) + (widget.notebookScore / 140 * 15) + (widget.reportScore / 100 * 15) + (_score / 100 * 20)).round()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isShort ? 32 : 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isShort ? 12 : 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _scoreItem(
                  'Praktikum',
                  '${(widget.completionScore / 140 * 100).round()}%',
                  AppColors.primary700,
                ),
                _scoreItem(
                  'Laporan',
                  '${((widget.notebookScore / 140 * 50) + (widget.reportScore / 100 * 50)).round()}%',
                  AppColors.info700,
                ),
                _scoreItem('Kuis', '$_score%', AppColors.success700),
              ],
            ),
            SizedBox(height: isShort ? 24 : 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _backToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary800,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: isShort ? 12 : 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Kembali ke Beranda',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
