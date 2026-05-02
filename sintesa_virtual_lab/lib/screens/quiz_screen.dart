import 'package:flutter/material.dart';
import '../models/app_colors.dart';
import '../services/score_service.dart';
import 'dashboard_screen.dart';

class QuizScreen extends StatefulWidget {
  final int labScore;
  const QuizScreen({super.key, this.labScore = 0});

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
      'question': 'Ekstrak kunyit akan berubah menjadi warna merah bata jika diteteskan pada larutan asam.',
      'answer': false,
    },
    {
      'question': 'Air sabun merupakan contoh larutan yang bersifat basa.',
      'answer': true,
    },
    {
      'question': 'Garam dapur adalah larutan netral yang memiliki pH sekitar 7.',
      'answer': true,
    },
    {
      'question': 'Kertas lakmus merah akan berubah menjadi biru saat dicelupkan ke dalam larutan asam.',
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
    try {
      await ScoreService().saveAttempt(
        moduleId: 'asam_basa_alami',
        moduleName: 'Asam Basa Alami',
        labScore: widget.labScore,
        quizScore: _score,
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

    return Container(
      width: 500,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
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
          const SizedBox(height: 32),
          Text(
            question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary900,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _answerQuestion(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success700,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'BENAR',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
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
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'SALAH',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultPage() {
    return Container(
      width: 500,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(40),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.warning500.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              size: 80,
              color: AppColors.warning500, 
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Kuis Selesai!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.primary900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text(
                    'Nilai Praktikum:',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.labScore}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary700,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 60,
                color: AppColors.neutral100,
              ),
              Column(
                children: [
                  const Text(
                    'Nilai Kuis:',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_score',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.success700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _backToHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary800,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
