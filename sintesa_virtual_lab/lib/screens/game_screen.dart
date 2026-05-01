import 'package:flutter/material.dart';
import '../models/app_colors.dart';
import '../models/game_state.dart';
import '../models/solution.dart';
import '../widgets/lab_widgets.dart';
import 'lab_report_flow_screen.dart';

class GameScreen extends StatefulWidget {
  final GameState gameState;

  const GameScreen({super.key, required this.gameState});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _popupCtrl;
  late Animation<double> _popupScale;

  String? _feedbackMessage;
  bool _showFeedback = false;
  bool _feedbackSuccess = true;
  
  bool _isInventoryOpen = false;
  bool _isNotebookOpen = false;

  @override
  void initState() {
    super.initState();
    _popupCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _popupScale = CurvedAnimation(parent: _popupCtrl, curve: Curves.elasticOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.gameState.goToPhase(GamePhase.step1_description);
    });
  }

  @override
  void dispose() {
    _popupCtrl.dispose();
    super.dispose();
  }

  void _showFeedbackMessage(String msg, bool success) {
    setState(() {
      _feedbackMessage = msg;
      _feedbackSuccess = success;
      _showFeedback = true;
    });
    _popupCtrl.forward(from: 0);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showFeedback = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.gameState,
      builder: (context, child) {
        return Scaffold(
          body: LabBackground(
            child: Stack(
              children: [
                _buildMainContent(),
                
                // HUD
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: _buildHUD(),
                ),

                // Feedback Toast
                if (_showFeedback) _buildFeedbackToast(),

                // Inventory
                InventoryWidget(
                  isOpen: _isInventoryOpen,
                  onToggle: () => setState(() => _isInventoryOpen = !_isInventoryOpen),
                ),

                // Notebook Sidebar
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  top: 0,
                  bottom: 0,
                  right: _isNotebookOpen ? 0 : -300,
                  child: LabNotebook(
                    solutions: widget.gameState.solutions,
                    onSave: (id, {color, type, note}) {
                      widget.gameState.updateNotebook(id, color: color, type: type, note: note);
                    },
                  ),
                ),

                // Sidebar Toggle
                Positioned(
                  right: _isNotebookOpen ? 300 : 0,
                  top: 100,
                  child: GestureDetector(
                    onTap: () => setState(() => _isNotebookOpen = !_isNotebookOpen),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary800,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Icon(
                        _isNotebookOpen ? Icons.chevron_right : Icons.edit_note,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHUD() {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          // Mastery Badge
          _hudStat(Icons.workspace_premium, AppColors.warning400, widget.gameState.masteryLevel),
          const Spacer(),
          // Scores
          _hudStat(Icons.security, AppColors.success400, 'Safety: ${widget.gameState.safetyScore}%'),
          const SizedBox(width: 20),
          _hudStat(Icons.precision_manufacturing, AppColors.info400, 'Prec: ${widget.gameState.precisionScore}%'),
          const SizedBox(width: 20),
          _hudStat(Icons.star, AppColors.warning400, '${widget.gameState.score} pts'),
        ],
      ),
    );
  }

  Widget _hudStat(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    switch (widget.gameState.phase) {
      case GamePhase.step1_description:
        return _buildDescriptionStep();
      case GamePhase.step3_experiment:
        return _buildExperimentStep();
      default:
        return _buildDescriptionStep();
    }
  }

  Widget _buildDescriptionStep() {
    return Center(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: AppColors.primary900.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary700),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.science, color: AppColors.info500, size: 50),
            const SizedBox(height: 20),
            const Text(
              'Praktikum Indikator Asam-Basa',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              'Gunakan ekstrak kunyit untuk menguji sifat larutan. Amati perubahan warna dan catat di Smart Lab-Notebook!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => widget.gameState.goToPhase(GamePhase.step3_experiment),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info700,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Mulai Simulasi'),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => _showDemoVideo(),
              icon: const Icon(Icons.play_circle_outline, size: 18),
              label: const Text('Lihat Video Prosedur'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperimentStep() {
    return Column(
      children: [
        const SizedBox(height: 120),
        const InstructionBubble(
          text: 'Buka inventory dan drag "Larutan Kunyit" ke gelas untuk memulai pengujian.',
          icon: Icons.info_outline,
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                children: widget.gameState.solutions.map((s) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: DragTarget<String>(
                      onAcceptWithDetails: (details) {
                        if (details.data == 'kunyit') {
                          final success = widget.gameState.addKunyitToSolution(s.id);
                          if (success) {
                            _showFeedbackMessage('Reaksi Kimia Berhasil!', true);
                          }
                        } else {
                          _showFeedbackMessage('Gunakan larutan kunyit!', false);
                          widget.gameState.penalizeSafety(5);
                        }
                      },
                      builder: (context, candidate, rejected) {
                        return FlaskWidget(
                          solution: s,
                          isDropTarget: candidate.isNotEmpty,
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 150), // Space for inventory
        if (widget.gameState.allGlassesDone)
          Padding(
            padding: const EdgeInsets.only(bottom: 250),
            child: ElevatedButton.icon(
              onPressed: () => _generateReport(),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generate Lab Report'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success700),
            ),
          ),
      ],
    );
  }

  void _showDemoVideo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AspectRatio(
              aspectRatio: 16/9,
              child: Center(child: Text('Video Dokumentasi Prosedur\n[Placeholder]', textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))
          ],
        ),
      ),
    );
  }

  void _generateReport() {
    // Navigate to results but with a "Report" styling
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LabReportFlowScreen()),
    );
  }

  Widget _buildFeedbackToast() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: ScaleTransition(
          scale: _popupScale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: _feedbackSuccess ? AppColors.success700 : AppColors.danger900,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10)],
            ),
            child: Text(
              _feedbackMessage ?? '',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
