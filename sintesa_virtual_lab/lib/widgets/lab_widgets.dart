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
  final Solution solution;
  final bool isDropTarget;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const FlaskWidget({
    super.key,
    required this.solution,
    this.isDropTarget = false,
    this.onTap,
    this.width = 90,
    this.height = 120,
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
                    widget.solution.hasKunyit
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
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutBack,
      bottom: isOpen ? 0 : -220,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Toggle button
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary900,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border.all(color: AppColors.primary700),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isOpen ? Icons.keyboard_arrow_down : Icons.backpack,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isOpen ? 'Tutup Inventory' : 'Buka Inventory',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          Container(
            height: 220,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/Inventory.png'),
                fit: BoxFit.cover,
              ),
              color: AppColors.primary900,
              border: Border(top: BorderSide(color: AppColors.primary700)),
            ),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _buildInventoryItem(
                      'Larutan Kunyit',
                      'assets/images/Larutan Kunyit.png',
                      'kunyit',
                    ),
                    const SizedBox(width: 20),
                    _buildInventoryItem(
                      'Sendok Preparat',
                      'assets/images/sendok preparat.png',
                      'sendok',
                    ),
                  ],
                ),
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
    return Column(
      children: [
        Container(
          width: 100,
          height: 120,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Image.asset(asset, fit: BoxFit.contain),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Smart Lab-Notebook Widget
class LabNotebook extends StatelessWidget {
  final List<Solution> solutions;
  final Function(String, {String? color, String? type, String? note}) onSave;

  const LabNotebook({
    super.key,
    required this.solutions,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: AppColors.primary900.withOpacity(0.95),
        border: Border(left: BorderSide(color: AppColors.primary700, width: 2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary800,
            child: const Row(
              children: [
                Icon(Icons.edit_note, color: AppColors.info500),
                SizedBox(width: 8),
                Text(
                  'Smart Lab-Notebook',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: solutions.length,
              itemBuilder: (context, index) {
                final s = solutions[index];
                return _buildNotebookEntry(context, s);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotebookEntry(BuildContext context, Solution s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
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
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          if (!s.hasKunyit)
            const Text(
              'Lakukan pengamatan dulu...',
              style: TextStyle(color: Colors.white54, fontSize: 10),
            )
          else ...[
            _notebookRow('Warna:', s.observationColor ?? '-', () => _editField(context, s, 'warna')),
            _notebookRow('Sifat:', s.observationType ?? '-', () => _editField(context, s, 'sifat')),
          ],
        ],
      ),
    );
  }

  Widget _notebookRow(String label, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.info900.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.info500.withOpacity(0.3)),
              ),
              child: Text(
                value,
                style: const TextStyle(color: AppColors.info500, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editField(BuildContext context, Solution s, String field) {
    final controller = TextEditingController(
      text: field == 'warna' ? s.observationColor : s.observationType,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primary900,
        title: Text('Input Data ${s.name}', style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Data Pengamatan ($field)',
            labelStyle: const TextStyle(color: Colors.white54),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (field == 'warna') {
                onSave(s.id, color: controller.text);
              } else {
                onSave(s.id, type: controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
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
  final Solution solution;
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
