import 'dart:async';
import 'package:flutter/material.dart';
import '../models/app_colors.dart';
import '../models/game_state.dart';
import '../models/solution.dart';
import '../widgets/lab_widgets.dart' hide SolutionState, Solution;
import 'lab_report_flow_screen.dart';

class GameScreen extends StatefulWidget {
  final GameState gameState;

  const GameScreen({super.key, required this.gameState});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // ── Feedback toast ─────────────────────────────────────────────────────────
  late AnimationController _popupCtrl;
  late Animation<double> _popupScale;
  String? _feedbackMessage;
  bool _showFeedback = false;
  bool _feedbackSuccess = true;

  // ── Panels ─────────────────────────────────────────────────────────────────
  bool _isInventoryOpen = false;
  bool _isNotebookOpen = false;

  // ── Timer State ────────────────────────────────────────────────────────────
  Timer? _timer;
  int _secondsRemaining = 120;

  // ── Per-flask stir animation controllers ───────────────────────────────────
  // Key = solution id
  final Map<String, AnimationController> _stirControllers = {};
  final Map<String, Animation<double>> _stirAnims = {};

  // ── Instruction state ──────────────────────────────────────────────────────
  // Tracks which instruction to show based on game progress
  _InstructionPhase get _instructionPhase {
    final gs = widget.gameState;
    if (gs.allGlassesDone) return _InstructionPhase.done;
    if (gs.pendingStirCount > 0) return _InstructionPhase.stir;
    return _InstructionPhase.pour;
  }

  @override
  void initState() {
    super.initState();

    _popupCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _popupScale =
        CurvedAnimation(parent: _popupCtrl, curve: Curves.elasticOut);

    // Create a stir controller for each solution
    for (final s in widget.gameState.solutions) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      _stirControllers[s.id] = ctrl;
      _stirAnims[s.id] =
          Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: ctrl,
        curve: Curves.easeInOut,
      ));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.gameState.goToPhase(GamePhase.step1_description);
      _startTimer();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        _onTimeUp();
      }
    });
  }

  void _onTimeUp() {
    // Force navigate to report with 0 score
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LabReportFlowScreen(labScore: 0),
      ),
    );
  }

  @override
  void dispose() {
    _popupCtrl.dispose();
    _timer?.cancel();
    for (final c in _stirControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Feedback ───────────────────────────────────────────────────────────────

  void _showFeedbackMessage(String msg, bool success) {
    setState(() {
      _feedbackMessage = msg;
      _feedbackSuccess = success;
      _showFeedback = true;
    });
    _popupCtrl.forward(from: 0);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showFeedback = false);
    });
  }

  // ── Stir action ────────────────────────────────────────────────────────────

  Future<void> _onStirFlask(String solutionId) async {
    final solution =
        widget.gameState.solutions.firstWhere((s) => s.id == solutionId);

    if (solution.state != SolutionState.kunyitAdded) {
      if (solution.state == SolutionState.empty) {
        _showFeedbackMessage('Tuangkan kunyit dulu!', false);
      }
      return;
    }

    // Play stir spin animation
    final ctrl = _stirControllers[solutionId]!;
    await ctrl.forward(from: 0);

    // Update state → revealed
    final success = widget.gameState.stirSolution(solutionId);
    if (success) {
      final s =
          widget.gameState.solutions.firstWhere((s) => s.id == solutionId);
      _showFeedbackMessage(
        'Selesai diaduk! Amati perubahan warnanya.',
        true,
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.gameState,
      builder: (context, _) {
        return Scaffold(
          body: LabBackground(
            child: Stack(
              children: [
                _buildMainContent(),

                // HUD
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildHUD(),
                ),

                // Feedback Toast
                if (_showFeedback) _buildFeedbackToast(),

                // Inventory
                InventoryWidget(
                  isOpen: _isInventoryOpen,
                  onToggle: () =>
                      setState(() => _isInventoryOpen = !_isInventoryOpen),
                ),

                // Notebook Sidebar
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  top: 0,
                  bottom: 0,
                  right: _isNotebookOpen ? 0 : -300,
                  child: LabNotebook(
                    solutions: widget.gameState.solutions
                        .map((s) => WidgetSolution.fromModel(s))
                        .toList(),
                    onSave: (id, {color, type, note}) {
                      widget.gameState.updateNotebook(id,
                          color: color, type: type, note: note);
                    },
                  ),
                ),

                // Notebook Toggle
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  right: _isNotebookOpen ? 300 : 0,
                  top: 100,
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _isNotebookOpen = !_isNotebookOpen),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary800,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ],
                      ),
                      child: Icon(
                        _isNotebookOpen
                            ? Icons.chevron_right
                            : Icons.edit_note,
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

  // ── HUD ────────────────────────────────────────────────────────────────────

  Widget _buildHUD() {
    return Container(
      padding:
          const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          // Timer in Top Left
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _secondsRemaining < 30 ? Colors.red.withOpacity(0.8) : Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _secondsRemaining < 30 ? Colors.red : Colors.white24),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: _secondsRemaining < 30 ? Colors.white : AppColors.warning400, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          _hudStat(Icons.workspace_premium, AppColors.warning400,
              widget.gameState.masteryLevel),
          const Spacer(),
          _hudStat(Icons.security, AppColors.success400,
              'Safety: ${widget.gameState.safetyScore}%'),
          const SizedBox(width: 20),
          _hudStat(Icons.precision_manufacturing, AppColors.info400,
              'Prec: ${widget.gameState.precisionScore}%'),
          const SizedBox(width: 20),
          _hudStat(Icons.star, AppColors.warning400,
              '${widget.gameState.score} pts'),
        ],
      ),
    );
  }

  Widget _hudStat(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── Main content router ────────────────────────────────────────────────────

  Widget _buildMainContent() {
    return switch (widget.gameState.phase) {
      GamePhase.step1_description => _buildDescriptionStep(),
      GamePhase.step3_experiment  => _buildExperimentStep(),
      _                           => _buildDescriptionStep(),
    };
  }

  // ── Description step ───────────────────────────────────────────────────────

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
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              'Gunakan ekstrak kunyit untuk menguji sifat larutan.\n'
              '1. Tuangkan larutan kunyit ke setiap beker glass.\n'
              '2. Aduk setiap gelas untuk melihat perubahan warna.\n'
              '3. Catat hasil di Smart Lab-Notebook!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () =>
                  widget.gameState.goToPhase(GamePhase.step3_experiment),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Mulai Simulasi'),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _showDemoVideo,
              icon: const Icon(Icons.play_circle_outline, size: 18),
              label: const Text('Lihat Video Prosedur'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Experiment step ────────────────────────────────────────────────────────

  Widget _buildExperimentStep() {
    return Column(
      children: [
        const SizedBox(height: 120),

        // Dynamic instruction bubble
        _buildInstructionBubble(),

        // Flask row
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.gameState.solutions
                    .map((s) => WidgetSolution.fromModel(s)) // Ubah ke WidgetSolution
                    .map<Widget>((ws) => _buildFlaskSlot(ws)) // Ubah jadi Widget secara eksplisit
                    .toList(), // Jadikan list di akhir saja
              ),
            ),
          ),
        ),

        // Space reserved for inventory panel
        const SizedBox(height: 150),

        // Generate report button — only visible when all flasks are done
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: widget.gameState.allGlassesDone
              ? Padding(
                  key: const ValueKey('reportBtn'),
                  padding: const EdgeInsets.only(bottom: 170),
                  child: ElevatedButton.icon(
                    onPressed: _generateReport,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Generate Lab Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success700,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                    ),
                  ),
                )
              : const SizedBox(key: ValueKey('empty'), height: 0),
        ),
      ],
    );
  }

  // ── Instruction bubble (dynamic) ───────────────────────────────────────────

  Widget _buildInstructionBubble() {
    final (text, icon) = switch (_instructionPhase) {
      _InstructionPhase.pour => (
          'Buka inventory dan drag "Larutan Kunyit" ke setiap beker glass.',
          Icons.info_outline,
        ),
      _InstructionPhase.stir => (
          'Bagus! Sekarang drag "Sendok Preparat" dari inventory ke setiap gelas untuk mengaduk.',
          Icons.touch_app_outlined,
        ),
      _InstructionPhase.done => (
          'Semua larutan sudah teramati! Tekan "Generate Lab Report" untuk melanjutkan.',
          Icons.check_circle_outline,
        ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: InstructionBubble(
        key: ValueKey(_instructionPhase),
        text: text,
        icon: icon,
      ),
    );
  }

  // ── Single flask slot: DragTarget + stir button ────────────────────────────

  Widget _buildFlaskSlot(WidgetSolution s) {
    final stirAnim = _stirAnims[s.id]!;

    print("🔍 CEK GELAS [${s.id}] -> State-nya saat ini adalah: ${s.state}");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── DragTarget (tuang kunyit) ──────────────────────────────────
          DragTarget<String>(
            onWillAcceptWithDetails: (details) =>
                (details.data == 'kunyit' && s.state == SolutionState.empty) ||
                (details.data == 'sendok' && s.state == SolutionState.kunyitAdded),
            onAcceptWithDetails: (details) {
              print("💡 [DEBUG] Item '${details.data}' mendarat di atas gelas ${s.id}");
              if (details.data == 'kunyit') {
                final ok = widget.gameState.addKunyitToSolution(s.id);
                if (ok) {
                  _showFeedbackMessage(
                      'Kunyit dituang ke ${s.name}! Sekarang aduk dengan sendok.', true);
                }
              } else if (details.data == 'sendok') {
                _onStirFlask(s.id);
              } else {
                _showFeedbackMessage('Gunakan larutan kunyit!', false);
                widget.gameState.penalizeSafety(5);
              }
            },
            builder: (context, candidates, _) {
              final isTarget =
                  candidates.isNotEmpty && s.state == SolutionState.empty;

              return AnimatedBuilder(
                animation: stirAnim,
                builder: (context, child) {
                  // Shake/rotate effect while stirring
                  final angle = s.state == SolutionState.kunyitAdded
                      ? 0.0
                      : stirAnim.value * 0.08 *
                          (stirAnim.value < 0.5 ? 1 : -1);
                  return Transform.rotate(
                    angle: angle,
                    child: child,
                  );
                },
                child: FlaskWidget(
                  solution: s,
                  isDropTarget: isTarget,
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // ── Stir button (hanya muncul jika kunyit sudah dituang) ───────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: s.state == SolutionState.revealed
                    ? _RevealedBadge(
                        key: ValueKey('done_${s.id}'),
                        label: s.reactionColorName,
                      )
                    : const SizedBox(
                        key: ValueKey('none'),
                        height: 36,
                      ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _showDemoVideo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(
                child: Text(
                  'Video Dokumentasi Prosedur\n[Placeholder]',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup')),
          ],
        ),
      ),
    );
  }

  void _generateReport() {
    _timer?.cancel();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LabReportFlowScreen(
        labScore: 100,
      )),
    );
  }

  // ── Feedback toast ─────────────────────────────────────────────────────────

  Widget _buildFeedbackToast() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: ScaleTransition(
          scale: _popupScale,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: _feedbackSuccess
                  ? AppColors.success700
                  : AppColors.danger900,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 10)
              ],
            ),
            child: Text(
              _feedbackMessage ?? '',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PRIVATE HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════

enum _InstructionPhase { pour, stir, done }

// ── Stir button ────────────────────────────────────────────────────────────

class _StirButton extends StatefulWidget {
  final VoidCallback onTap;

  const _StirButton({super.key, required this.onTap});

  @override
  State<_StirButton> createState() => _StirButtonState();
}

class _StirButtonState extends State<_StirButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotCtrl;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _rotCtrl.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _rotCtrl, curve: Curves.easeInOut),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.warning500.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🥄', style: TextStyle(fontSize: 16)),
              SizedBox(width: 4),
              Text(
                'Aduk',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Revealed badge ─────────────────────────────────────────────────────────

class _RevealedBadge extends StatelessWidget {
  final String label;

  const _RevealedBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
    );
  }
}