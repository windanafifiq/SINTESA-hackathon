import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'theory_and_tools_screen.dart';

class SafetyProcedureScreen extends StatefulWidget {
  const SafetyProcedureScreen({super.key});

  @override
  State<SafetyProcedureScreen> createState() => _SafetyProcedureScreenState();
}

class _SafetyProcedureScreenState extends State<SafetyProcedureScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _procedures = [
    {'icon': Icons.medical_services_rounded, 'title': 'Pertolongan Pertama', 'color': AppColors.danger, 'desc': 'Pelajari prosedur memberikan P3K pada kecelakaan ringan di lab.'},
    {'icon': Icons.fire_extinguisher_rounded, 'title': 'Penanganan Kebakaran', 'color': AppColors.secondary, 'desc': 'Pahami langkah awal saat terjadi kebakaran kecil dengan APAR.'},
    {'icon': Icons.masks_rounded, 'title': 'Alat Pelindung Diri', 'color': AppColors.info, 'desc': 'Gunakan jas lab, sarung tangan, dan kacamata pengaman sebelum bekerja.'},
    {'icon': Icons.warning_rounded, 'title': 'Simbol Bahaya Kimia', 'color': AppColors.warning, 'desc': 'Kenali label bahan kimia untuk menghindari potensi bahaya tak terduga.'},
    {'icon': Icons.local_laundry_service_rounded, 'title': 'Penanganan Tumpahan', 'color': AppColors.successDark, 'desc': 'Ketahui cara mengisolasi dan membersihkan tumpahan zat asam/basa.'},
    {'icon': Icons.exit_to_app_rounded, 'title': 'Jalur Evakuasi', 'color': AppColors.primaryLight, 'desc': 'Ketahui arah keluar terdekat untuk menyelamatkan diri saat darurat.'},
    {'icon': Icons.no_food_rounded, 'title': 'Larangan di Lab', 'color': AppColors.dangerDark, 'desc': 'Tidak boleh makan, minum, atau bercanda di dalam area laboratorium.'},
    {'icon': Icons.recycling_rounded, 'title': 'Pembuangan Limbah', 'color': AppColors.success, 'desc': 'Buang limbah pada wadah yang telah ditentukan sesuai jenisnya.'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    final isShort = screenH < 500;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          // Header Bar
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + (isShort ? 8 : 14),
              left: isShort ? 14 : 24,
              right: isShort ? 14 : 24,
              bottom: isShort ? 10 : 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, Color(0xFF0B357B)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x3300246B),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Tombol Kembali
                _NavButton(
                  label: '← Kembali',
                  onTap: () => Navigator.pop(context),
                  isShort: isShort,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'PROSEDUR',
                        style: TextStyle(
                          fontSize: isShort ? 12 : 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.white,
                          letterSpacing: isShort ? 2 : 4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'KESELAMATAN LAB',
                        style: TextStyle(
                          fontSize: isShort ? 12 : 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.secondary,
                          letterSpacing: isShort ? 2 : 4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Spacer penyeimbang tombol kiri (supaya teks beneran di tengah)
                SizedBox(width: isShort ? 70 : 100), 
              ],
            ),
          ),

          // Grid Konten
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isShort ? 12 : 24,
                  isShort ? 10 : 20,
                  isShort ? 12 : 24,
                  0,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Portrait: 2 cols; landscape wide: 4 cols; landscape narrow: 2-3 cols
                    int cols;
                    if (isPortrait) {
                      cols = 2;
                    } else {
                      cols = constraints.maxWidth > 1000 ? 4 : (constraints.maxWidth > 700 ? 3 : 2);
                    }
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: isShort ? 10 : 16,
                        mainAxisSpacing: isShort ? 10 : 16,
                        childAspectRatio: isPortrait ? 1.0 : (isShort ? 1.1 : 0.88),
                      ),
                      itemCount: _procedures.length,
                      itemBuilder: (context, index) {
                        return _ProcedureCard(
                          icon: _procedures[index]['icon'] as IconData,
                          title: _procedures[index]['title'] as String,
                          accentColor: _procedures[index]['color'] as Color,
                          description: _procedures[index]['desc'] as String,
                          isShort: isShort,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // Footer Tombol Selanjutnya
          Padding(
            padding: EdgeInsets.fromLTRB(
              isShort ? 14 : 24,
              isShort ? 8 : 14,
              isShort ? 14 : 24,
              isShort ? MediaQuery.of(context).padding.bottom + 8 : 20,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: _PrimaryButton(
                label: 'Selanjutnya →',
                isShort: isShort,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, animation, __) => const TheoryAndToolsScreen(),
                      transitionsBuilder: (_, animation, __, child) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Kartu Prosedur dengan hover effect
class _ProcedureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color accentColor;
  final String description;
  final bool isShort;

  const _ProcedureCard({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.description,
    this.isShort = false,
  });

  @override
  State<_ProcedureCard> createState() => _ProcedureCardState();
}

class _ProcedureCardState extends State<_ProcedureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered
            ? (Matrix4.identity()..translate(0, -5.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withOpacity(_isHovered ? 0.22 : 0.07),
              blurRadius: _isHovered ? 24 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Area Gambar dengan aksen warna
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.accentColor.withOpacity(0.12),
                        widget.accentColor.withOpacity(0.06),
                      ],
                    ),
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _isHovered ? (widget.isShort ? 52 : 72) : (widget.isShort ? 44 : 64),
                      height: _isHovered ? (widget.isShort ? 52 : 72) : (widget.isShort ? 44 : 64),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.accentColor.withOpacity(0.15),
                      ),
                      child: Center(
                        child: Icon(
                          widget.icon,
                          size: widget.isShort ? 26 : 38,
                          color: widget.accentColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Garis aksen bawah gambar
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.accentColor.withOpacity(0.6),
                      widget.accentColor.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
              // Area Teks
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isShort ? 8 : 14,
                    vertical: widget.isShort ? 6 : 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: widget.isShort ? 10 : 12,
                          color: AppColors.neutral900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!widget.isShort) const SizedBox(height: 4),
                      if (!widget.isShort)
                        Expanded(
                          child: Text(
                            widget.description,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.neutral700,
                              height: 1.4,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tombol Navigasi (Kembali) — untuk background gelap
class _NavButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isShort;

  const _NavButton({required this.label, required this.onTap, this.isShort = false});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isShort ? 12 : 20,
            vertical: widget.isShort ? 7 : 11,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.white.withOpacity(0.25)
                : AppColors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontSize: widget.isShort ? 11 : 13,
            ),
          ),
        ),
      ),
    );
  }
}

// Tombol Primer — untuk footer dengan background terang
class _PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isShort;

  const _PrimaryButton({required this.label, required this.onTap, this.isShort = false});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isShort ? 20 : 32,
            vertical: widget.isShort ? 9 : 13,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondary,
                _isHovered ? AppColors.secondaryDark : AppColors.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(_isHovered ? 0.4 : 0.2),
                blurRadius: _isHovered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: widget.isShort ? 12 : 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
