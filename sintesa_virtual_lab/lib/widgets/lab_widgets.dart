import 'package:flutter/material.dart';
import '../models/app_colors.dart';
import '../models/solution.dart';
import '../painters/lab_painters.dart';

/// Lab background with bench
/// Lab background with bench and background image
class LabBackground extends StatelessWidget {
  final Widget child;

  const LabBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A2744),
      ),
      child: Stack(
        children: [
          // Background asset
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF1A2744),
              ),
            ),
          ),
          // Gradient overlay for depth
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// A single flask widget using assets
class FlaskWidget extends StatefulWidget {
  final WidgetSolution solution;
  final bool isDropTarget;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const FlaskWidget({
    super.key,
    required this.solution,
    this.isDropTarget = false,
    this.onTap,
    this.width = 95,
    this.height = 125,
  });

  @override
  State<FlaskWidget> createState() => _FlaskWidgetState();
}

class _FlaskWidgetState extends State<FlaskWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(FlaskWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDropTarget) {
      _animCtrl.repeat(reverse: true);
    } else {
      _animCtrl.stop();
      _animCtrl.value = 0;
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animCtrl,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isDropTarget ? _scaleAnim.value : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: widget.isDropTarget
                        ? Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Image.asset(
                    widget.solution.isRevealed
                        ? widget.solution.assetAfter
                        : widget.solution.assetBefore,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => CustomPaint(
                      painter: FlaskPainter(
                        liquidColor: widget.solution.currentLiquidColor,
                        hasKunyit: widget.solution.hasKunyit,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary900.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    widget.solution.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Inventory Widget
class InventoryWidget extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;

  const InventoryWidget({
    super.key,
    required this.isOpen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      left: isOpen ? 0 : -240, // -240 agar tombol tab (40px) tetap kelihatan
      top: 100,
      bottom: 100,
      child: Row(
        children: [
          // Content
          Container(
            width: 240,
            decoration: BoxDecoration(
              color: AppColors.primary900.withOpacity(0.95),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border.all(color: AppColors.primary700, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(5, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary800,
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(22)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.backpack, color: AppColors.warning400, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'INVENTORY',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(15),
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    children: [
                      _buildInventoryItem(
                        'Kunyit',
                        'assets/images/Larutan Kunyit.png',
                        'kunyit',
                      ),
                      _buildInventoryItem(
                        'Sendok',
                        'assets/images/sendok preparat.png',
                        'sendok',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Toggle button (Vertical)
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 40,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary800,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border(
                  top: BorderSide(color: AppColors.primary700, width: 2),
                  right: BorderSide(color: AppColors.primary700, width: 2),
                  bottom: BorderSide(color: AppColors.primary700, width: 2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOpen ? Icons.chevron_left : Icons.backpack,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  const RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      'INVENTORY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItem(String label, String asset, String data) {
    return Draggable<String>(
      data: data,
      feedback: Opacity(
        opacity: 0.8,
        child: SizedBox(
          width: 100,
          height: 140,
          child: Image.asset(asset),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _itemBox(label, asset),
      ),
      child: _itemBox(label, asset),
    );
  }

  Widget _itemBox(String label, String asset) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.02),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(asset, fit: BoxFit.contain),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Smart Lab-Notebook Widget
class LabNotebook extends StatelessWidget {
  final List<WidgetSolution> solutions;
  final Function(String, {String? color, String? type, String? note}) onSave;
  final bool isOpen;
  final VoidCallback onToggle;

  const LabNotebook({
    super.key,
    required this.solutions,
    required this.onSave,
    required this.isOpen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      right: isOpen ? 0 : -240, // Match inventory logic but from right
      top: 100,
      bottom: 100,
      child: Row(
        children: [
          // Toggle button (Vertical)
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 40,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary800,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                border: Border(
                  top: BorderSide(color: AppColors.primary700, width: 2),
                  left: BorderSide(color: AppColors.primary700, width: 2),
                  bottom: BorderSide(color: AppColors.primary700, width: 2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOpen ? Icons.chevron_right : Icons.edit_note,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  const RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      'NOTEBOOK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          Container(
            width: 240,
            decoration: BoxDecoration(
              color: AppColors.primary900.withOpacity(0.95),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
              border: Border.all(color: AppColors.primary700, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(-5, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.primary800,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_stories, color: AppColors.info400, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'OBSERVASI',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: solutions.length,
                    itemBuilder: (context, index) {
                      final s = solutions[index];
                      return _buildNotebookEntry(context, s);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotebookEntry(BuildContext context, WidgetSolution s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: s.hasKunyit ? AppColors.info500.withOpacity(0.3) : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.name,
            style: const TextStyle(
              color: AppColors.info400,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          if (!s.hasKunyit)
            const Text(
              'Lakukan pengamatan dulu...',
              style: TextStyle(color: Colors.white54, fontSize: 10),
            )
          else ...[
            _notebookRow('Sifat:', s.observationType ?? 'Pilih...', 
                () => _showPicker(context, s, 'sifat', ['Asam', 'Basa', 'Netral'])),
            const SizedBox(height: 8),
            _notebookRow('Reaksi:', s.observationNote ?? 'Pilih...', 
                () => _showPicker(context, s, 'reaksi', ['Tidak Bereaksi', 'Merah Kecokelatan'])),
          ],
        ],
      ),
    );
  }

  Widget _notebookRow(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context, WidgetSolution s, String field, List<String> options) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primary900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Data ${s.name}',
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (field == 'sifat') {
                    onSave(s.id, type: opt);
                  } else {
                    onSave(s.id, note: opt);
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary800,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(opt, style: const TextStyle(fontSize: 12)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


/// The draggable sendok preparat widget
class DraggableSendok extends StatefulWidget {
  final Color kunyitColor;
  final Function(Offset) onDragEnd;
  final bool enabled;

  const DraggableSendok({
    super.key,
    this.kunyitColor = const Color(0xFFFFD700),
    required this.onDragEnd,
    this.enabled = true,
  });

  @override
  State<DraggableSendok> createState() => _DraggableSendokState();
}

class _DraggableSendokState extends State<DraggableSendok>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: Draggable<String>(
            data: 'sendok_kunyit',
            feedback: SizedBox(
              width: 60,
              height: 90,
              child: CustomPaint(
                painter: SendokPainter(
                  hasLiquid: true,
                  liquidColor: widget.kunyitColor,
                ),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: SizedBox(
                width: 60,
                height: 90,
                child: CustomPaint(
                  painter: SendokPainter(
                    hasLiquid: true,
                    liquidColor: widget.kunyitColor,
                  ),
                ),
              ),
            ),
            onDragEnd: (details) => widget.onDragEnd(details.offset),
            child: Column(
              children: [
                SizedBox(
                  width: 60,
                  height: 90,
                  child: CustomPaint(
                    painter: SendokPainter(
                      hasLiquid: true,
                      liquidColor: widget.kunyitColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.5)),
                  ),
                  child: const Text(
                    'Sendok\nPreparat',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 2),
                const Icon(
                  Icons.touch_app,
                  color: Colors.white54,
                  size: 14,
                ),
                const Text(
                  'Drag ke gelas!',
                  style: TextStyle(color: Colors.white54, fontSize: 8),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Instruction bubble / tooltip
class InstructionBubble extends StatelessWidget {
  final String text;
  final IconData? icon;

  const InstructionBubble({super.key, required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.info900.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info500.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.info500.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.info500, size: 18),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated result card for a solution
class SolutionResultCard extends StatelessWidget {
  final WidgetSolution solution;
  final int index;

  const SolutionResultCard({
    super.key,
    required this.solution,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + index * 100),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary900.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: solution.typeColor.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            // Mini flask
            SizedBox(
              width: 36,
              height: 52,
              child: CustomPaint(
                painter: FlaskPainter(
                  liquidColor: solution.afterColor,
                  hasKunyit: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        solution.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: solution.typeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: solution.typeColor.withOpacity(0.6)),
                        ),
                        child: Text(
                          solution.typeLabel,
                          style: TextStyle(
                            color: solution.typeColor,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    solution.explanation,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 9,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            // Color swatch
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: solution.afterColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: solution.afterColor.withOpacity(0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// WidgetSolution mapping is now directly linked to the model's SolutionState

// ── Solution model ───────────────────────────────────────────────────────────

class WidgetSolution {
  final String id;
  final String name;
  final double ph;
  final SolutionState state;

  // Observation notebook fields
  final String? observationColor;
  final String? observationType;
  final String? observationNote;

  const WidgetSolution({
    required this.id,
    required this.name,
    required this.ph,
    this.state = SolutionState.empty,
    this.observationColor,
    this.observationType,
    this.observationNote,
  });

  factory WidgetSolution.fromModel(Solution model) {
    return WidgetSolution(
      id: model.id,
      name: model.name,
      ph: model.ph,
      state: model.state,
      observationColor: model.observationColor,
      observationType: model.observationType,
      observationNote: model.observationNote,
    );
  }

  // ── State helpers ────────────────────────────────────────────────────────

  /// True jika kunyit sudah dituang (belum tentu diaduk)
  bool get hasKunyit =>
      state == SolutionState.kunyitAdded ||
      state == SolutionState.stirring ||
      state == SolutionState.revealed;

  bool get isRevealed => state == SolutionState.revealed;
  bool get needsStirring => state == SolutionState.kunyitAdded;

  // ── Asset paths ──────────────────────────────────────────────────────────
  /// Asset sebelum kunyit dituang (larutan bening)
  String get assetBefore => 'assets/images/${id}_before.png';

  /// Asset setelah kunyit dituang dan diaduk (warna reaksi)
  String get assetAfter => 'assets/images/${id}_after.png';

  // ── Color getters ────────────────────────────────────────────────────────

  /// Warna liquid saat ini untuk fallback CustomPaint (FlaskPainter)
  Color get currentLiquidColor {
    if (!hasKunyit) return const Color(0xFFB3D9FF); // bening sebelum kunyit
    if (!isRevealed) return const Color(0xFFE8C94B).withOpacity(0.6); // kunyit belum bereaksi
    return afterColor; // warna reaksi
  }

  /// Warna hasil reaksi setelah diaduk (berdasarkan pH)
  /// - Asam kuat  (pH < 4)  : kuning cerah (warna asli kurkumin)
  /// - Asam       (pH < 7)  : kuning
  /// - Netral     (pH ≈ 7)  : kuning kecokelatan
  /// - Basa       (pH < 11) : merah kecokelatan
  /// - Basa kuat  (pH ≥ 11) : merah tua / cokelat gelap
  Color get afterColor {
    if (ph < 4)  return const Color(0xFFFFF176); // kuning cerah
    if (ph < 7)  return const Color(0xFFFFD54F); // kuning
    if (ph < 8)  return const Color(0xFFFFB300); // kuning kecokelatan
    if (ph < 11) return const Color(0xFFBF360C); // merah kecokelatan
    return const Color(0xFF7B1111);               // merah tua
  }

  /// Warna label asam/basa/netral untuk UI card
  Color get typeColor {
    if (ph < 7) return const Color(0xFF4E91FF);  // biru untuk asam
    if (ph == 7) return const Color(0xFF4CAF50); // hijau untuk netral
    return const Color(0xFFFF7043);              // oranye untuk basa
  }

  // ── Text getters ─────────────────────────────────────────────────────────

  String get acidBaseLabel {
    if (ph < 7) return 'Asam';
    if (ph == 7) return 'Netral';
    return 'Basa';
  }

  /// Label singkat untuk badge di result card
  String get typeLabel => acidBaseLabel;

  /// Nama warna reaksi dalam bahasa Indonesia
  String get reactionColorName {
    if (ph < 4)  return 'Kuning Cerah';
    if (ph < 7)  return 'Kuning';
    if (ph < 8)  return 'Kuning Kecokelatan';
    if (ph < 11) return 'Merah Kecokelatan';
    return 'Merah Tua';
  }

  /// Penjelasan singkat untuk result card
  String get explanation {
    if (ph < 4) {
      return 'Larutan bersifat asam kuat (pH ${ph.toStringAsFixed(1)}). '
          'Kurkumin dalam kunyit tetap berwarna kuning cerah pada suasana asam.';
    }
    if (ph < 7) {
      return 'Larutan bersifat asam (pH ${ph.toStringAsFixed(1)}). '
          'Indikator kunyit menunjukkan warna kuning khas.';
    }
    if (ph < 8) {
      return 'Larutan bersifat netral (pH ${ph.toStringAsFixed(1)}). '
          'Warna kunyit mulai bergeser ke kuning kecokelatan.';
    }
    if (ph < 11) {
      return 'Larutan bersifat basa (pH ${ph.toStringAsFixed(1)}). '
          'Kurkumin terdeprotonasi sehingga berubah menjadi merah kecokelatan.';
    }
    return 'Larutan bersifat basa kuat (pH ${ph.toStringAsFixed(1)}). '
        'Reaksi kurkumin dengan basa kuat menghasilkan warna merah tua.';
  }

  // ── copyWith ─────────────────────────────────────────────────────────────

  WidgetSolution copyWith({
    SolutionState? state,
    String? observationColor,
    String? observationType,
    String? observationNote,
  }) {
    return WidgetSolution(
      id: id,
      name: name,
      ph: ph,
      state: state ?? this.state,
      observationColor: observationColor ?? this.observationColor,
      observationType: observationType ?? this.observationType,
      observationNote: observationNote ?? this.observationNote,
    );
  }
}

