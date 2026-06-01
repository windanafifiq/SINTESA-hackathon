import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isGameStarted = false;

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

    // Force landscape for game
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _popupCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _popupScale = CurvedAnimation(parent: _popupCtrl, curve: Curves.elasticOut);

    // Create a stir controller for each solution
    for (final s in widget.gameState.solutions) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      _stirControllers[s.id] = ctrl;
      _stirAnims[s.id] = Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.gameState.goToPhase(GamePhase.step1_description);
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
    // Force navigate to report with 0 score because time out
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LabReportFlowScreen(
          labScore: 0,
          completionScore: 0,
          notebookScore: 0,
          notebookData: [],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Return to portrait + landscape when leaving game
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

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
    final solution = widget.gameState.solutions.firstWhere(
      (s) => s.id == solutionId,
    );

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
      final s = widget.gameState.solutions.firstWhere(
        (s) => s.id == solutionId,
      );
      _showFeedbackMessage('Selesai diaduk! Amati perubahan warnanya.', true);
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
                Positioned(top: 0, left: 0, right: 0, child: _buildHUD()),

                // Feedback Toast
                if (_showFeedback) _buildFeedbackToast(),

                // Inventory
                InventoryWidget(
                  isOpen: _isInventoryOpen,
                  onToggle: () =>
                      setState(() => _isInventoryOpen = !_isInventoryOpen),
                ),

                // Notebook Sidebar
                LabNotebook(
                  isOpen: _isNotebookOpen,
                  onToggle: () =>
                      setState(() => _isNotebookOpen = !_isNotebookOpen),
                  solutions: widget.gameState.solutions
                      .map((s) => WidgetSolution.fromModel(s))
                      .toList(),
                  onSave: (id, {color, type, note}) {
                    widget.gameState.updateNotebook(
                      id,
                      color: color,
                      type: type,
                      note: note,
                    );
                  },
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
    final safeTop = MediaQuery.of(context).padding.top;
    final screenW = MediaQuery.of(context).size.width;
    final isCompact = screenW < 700;

    return Container(
      padding: EdgeInsets.only(
        top: safeTop + 6,
        left: 12,
        right: 12,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.85), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          // Timer
          _buildTimerChip(),
          const SizedBox(width: 8),
          if (!isCompact) ..._buildHudStats(),
          const Spacer(),
          if (isCompact) _buildCompactStats(),
          if (!isCompact) const SizedBox(width: 8),
          if (widget.gameState.allGlassesDone) ..._buildFinishButton(),
        ],
      ),
    );
  }

  Widget _buildTimerChip() {
    final isLow = _secondsRemaining < 30;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isLow ? Colors.red.withOpacity(0.85) : Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isLow ? Colors.red : Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: isLow ? Colors.white : AppColors.warning400, size: 14),
          const SizedBox(width: 5),
          Text(
            '${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHudStats() {
    return [
      _hudStat(Icons.workspace_premium, AppColors.warning400, widget.gameState.masteryLevel),
      const SizedBox(width: 12),
      _hudStat(Icons.security, AppColors.success400, '${widget.gameState.safetyScore}%'),
      const SizedBox(width: 12),
      _hudStat(Icons.star, AppColors.warning400, '${widget.gameState.score}pts'),
    ];
  }

  Widget _buildCompactStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: AppColors.warning400, size: 13),
          const SizedBox(width: 3),
          Text(
            '${widget.gameState.score}',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Icon(Icons.security, color: AppColors.success400, size: 13),
          const SizedBox(width: 3),
          Text(
            '${widget.gameState.safetyScore}%',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFinishButton() {
    return [
      const SizedBox(width: 8),
      GestureDetector(
        onTap: () {
          _timer?.cancel();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => LabReportFlowScreen(
                labScore: widget.gameState.score,
                completionScore: widget.gameState.completionScore,
                notebookScore: widget.gameState.notebookScore,
                notebookData: widget.gameState.solutions
                    .map((s) => WidgetSolution.fromModel(s))
                    .toList(),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
              SizedBox(width: 5),
              Text('SELESAI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _hudStat(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ── Main content router ────────────────────────────────────────────────────

  Widget _buildMainContent() {
    return switch (widget.gameState.phase) {
      GamePhase.step1_description => _buildDescriptionStep(),
      GamePhase.step3_experiment => _buildExperimentStep(),
      _ => _buildDescriptionStep(),
    };
  }

  // ── Description step ───────────────────────────────────────────────────────
  Widget _buildDescriptionStep() {
    return Center(
      child: Container(
        width: 500,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary900.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary700),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.science, color: AppColors.info500, size: 40),
              const SizedBox(height: 12),
              const Text(
                'Praktikum Indikator Asam-Basa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Gunakan ekstrak kunyit untuk menguji sifat larutan.\n'
                '1. Tuangkan larutan kunyit ke setiap beker glass.\n'
                '2. Aduk setiap gelas untuk melihat perubahan warna.\n'
                '3. Catat hasil di Smart Lab-Notebook!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'PERINGATAN: Praktikum tidak dapat dijeda selama 2 menit. Pastikan Anda siap.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => _isGameStarted = true);
                  _startTimer();
                  widget.gameState.goToPhase(GamePhase.step3_experiment);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Mulai Simulasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Experiment step ────────────────────────────────────────────────────────

  Widget _buildExperimentStep() {
    final isShort = MediaQuery.of(context).size.height < 500;
    // Panel sizes: match lab_widgets.dart (panelW: isShort ? 160 : 200) + toggle 36px + buffer 4px
    final panelPad = isShort ? 200.0 : 240.0;
    return Column(
      children: [
        SizedBox(height: isShort ? 44 : 56),

        // Dynamic instruction bubble
        _buildInstructionBubble(),

        // Flask row - Two Rows for better spacing
        Expanded(
          child: Center(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(
                left: _isInventoryOpen ? panelPad : 8,
                right: _isNotebookOpen ? panelPad : 8,
              ),
              child: SingleChildScrollView(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Row 1: First 4 flasks
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.gameState.solutions
                            .take(4)
                            .map((s) => WidgetSolution.fromModel(s))
                            .map<Widget>((ws) => _buildFlaskSlot(ws))
                            .toList(),
                      ),
                      SizedBox(height: isShort ? 8 : 24),
                      // Row 2: Remaining 3 flasks
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.gameState.solutions
                            .skip(4)
                            .map((s) => WidgetSolution.fromModel(s))
                            .map<Widget>((ws) => _buildFlaskSlot(ws))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: isShort ? 8 : 20),
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
    final isShort = MediaQuery.of(context).size.height < 500;
    final fWidth = isShort ? 75.0 : 120.0;
    final fHeight = isShort ? 100.0 : 160.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isShort ? 6 : 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── DragTarget (tuang kunyit) ──────────────────────────────────
          DragTarget<String>(
            onWillAcceptWithDetails: (details) =>
                (details.data == 'kunyit' && s.state == SolutionState.empty) ||
                (details.data == 'sendok' &&
                    s.state == SolutionState.kunyitAdded),
            onAcceptWithDetails: (details) {
              print(
                "💡 [DEBUG] Item '${details.data}' mendarat di atas gelas ${s.id}",
              );
              if (details.data == 'kunyit') {
                final ok = widget.gameState.addKunyitToSolution(s.id);
                if (ok) {
                  _showFeedbackMessage(
                    'Kunyit dituang ke ${s.name}! Sekarang aduk dengan sendok.',
                    true,
                  );
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
                      : stirAnim.value * 0.08 * (stirAnim.value < 0.5 ? 1 : -1);
                  return Transform.rotate(angle: angle, child: child);
                },
                child: FlaskWidget(
                  solution: s,
                  isDropTarget: isTarget,
                  width: fWidth,
                  height: fHeight,
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
                : SizedBox(
                    key: const ValueKey('none'),
                    height: isShort ? 24 : 36,
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
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  void _generateReport() {
    _timer?.cancel();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LabReportFlowScreen(labScore: 100),
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: _feedbackSuccess
                  ? AppColors.success700
                  : AppColors.danger900,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 10),
              ],
            ),
            child: Text(
              _feedbackMessage ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
        turns: Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: _rotCtrl, curve: Curves.easeInOut)),
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
                  fontWeight: FontWeight.bold,
                ),
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
      child: const Icon(
        Icons.check_circle,
        color: Colors.greenAccent,
        size: 16,
      ),
    );
  }
}
