import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'safety_procedure_screen.dart';
import 'grade_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedSidebarIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _sidebarItems = [
    {'label': 'Kimia', 'icon': Icons.science_rounded},
    {'label': 'Biologi', 'icon': Icons.eco_rounded},
    {'label': 'Fisika', 'icon': Icons.bolt_rounded},
    {'label': 'Grade', 'icon': Icons.grade_rounded},
  ];

  // Data modul per kategori — status: 'Mulai' atau 'Selesai'
  final List<List<Map<String, dynamic>>> _moduleData = [
    // Kimia
    [
      {'title': 'Reaksi Redoks', 'status': 'Selesai', 'score': 88, 'image': 'assets/images/reaksi_redoks.jpg'},
      {'title': 'Larutan Buffer', 'status': 'Mulai', 'score': null, 'image': 'assets/images/larutan_buffer.jpg'},
      {'title': 'Asam Basa Alami', 'status': 'Mulai', 'score': null, 'image': 'assets/images/asam_basa_alami.jpg'},
    ],
    // Biologi
    [
      {'title': 'Osmosis & Difusi', 'status': 'Selesai', 'score': 95, 'image': 'assets/images/osmosis.jpg'},
      {'title': 'Fotosintesis', 'status': 'Mulai', 'score': null, 'image': 'assets/images/fotosintesis.jpg'},
      {'title': 'Respirasi Sel', 'status': 'Mulai', 'score': null, 'image': 'assets/images/respirasi_sel.jpg'},
    ],
    // Fisika
    [
      {'title': 'Gerak Parabola', 'status': 'Mulai', 'score': null, 'image': 'assets/images/gerak_parabola.jpg'},
      {'title': 'Hukum Newton', 'status': 'Mulai', 'score': null, 'image': 'assets/images/newton.jpg'},
      {'title': 'Listrik Dinamis', 'status': 'Mulai', 'score': null, 'image': 'assets/images/listrik_dinamis.jpg'},
    ],
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _selectCategory(int index) {
    setState(() => _selectedSidebarIndex = index);
    _fadeController.reset();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, Color(0xFF0B357B)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Sidebar — Profil
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.secondaryDark],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: AppColors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FirebaseAuth.instance.currentUser?.displayName ??
                            FirebaseAuth.instance.currentUser?.email??
                            'Pengguna',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Siswa',
                        style: TextStyle(
                          color: AppColors.primaryLighter.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tombol Logout
                Tooltip(
                  message: 'Keluar',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      await AuthService().signOut();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, animation, __) => const LoginScreen(),
                            transitionsBuilder: (_, animation, __, child) =>
                                FadeTransition(opacity: animation, child: child),
                            transitionDuration: const Duration(milliseconds: 400),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: AppColors.primaryLighter.withOpacity(0.7),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Label navigasi
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
            child: Text(
              'MATA PELAJARAN',
              style: TextStyle(
                color: AppColors.primaryLighter.withOpacity(0.5),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),

          // Daftar menu
          ...List.generate(_sidebarItems.length, (index) {
            final item = _sidebarItems[index];
            final isSelected = _selectedSidebarIndex == index;
            return _SidebarItem(
              icon: item['icon'] as IconData,
              label: item['label'] as String,
              isSelected: isSelected,
              onTap: () => _selectCategory(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_selectedSidebarIndex == 3) {
      return const GradeScreen();
    }
    final modules = _moduleData[_selectedSidebarIndex];

    return Container(
      color: const Color(0xFFF0F4FF), // Biru sangat muda sebagai background
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner hero
            Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, Color(0xFF1A4FAD)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Dekorasi lingkaran
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withOpacity(0.04),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 60,
                    bottom: -60,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // Konten banner
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _sidebarItems[_selectedSidebarIndex]['label'] as String,
                            style: const TextStyle(
                              color: AppColors.secondaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Selamat Datang di\nVirtual Lab!',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Eksplorasi eksperimen sains secara interaktif\ndan aman di sini.',
                          style: TextStyle(
                            color: AppColors.primaryLighter.withOpacity(0.85),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Logo Sintesa di banner
                  Positioned(
                    right: 40,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo_sintesa.png',
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Judul Pilih Modul
            const Text(
              'Pilih Modul',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),

            // Grid Modul
            FadeTransition(
              opacity: _fadeAnim,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: modules.length,
                    itemBuilder: (context, index) {
                      return _ModuleCard(
                        title: modules[index]['title'] as String,
                        status: modules[index]['status'] as String,
                        score: modules[index]['score'] as int?,
                        image: modules[index]['image'] as String?,
                        onTap: () {
                          if (modules[index]['title'] == 'Asam Basa Alami') {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, animation, __) => const SafetyProcedureScreen(),
                                transitionsBuilder: (_, animation, __, child) => FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                                transitionDuration: const Duration(milliseconds: 400),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Praktikum belum tersedia.')),
                            );
                          }
                          if (modules[index]['title'] == 'Asam Basa Alami') {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, animation, __) => const SafetyProcedureScreen(),
                                transitionsBuilder: (_, animation, __, child) => FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                                transitionDuration: const Duration(milliseconds: 400),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Praktikum belum tersedia.')),
                            );
                          }
                        },
                        onRestart: () {
                          if (modules[index]['title'] == 'Asam Basa Alami') {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, animation, __) => const SafetyProcedureScreen(),
                                transitionsBuilder: (_, animation, __, child) => FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                                transitionDuration: const Duration(milliseconds: 400),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Praktikum belum tersedia.')),
                            );
                          }
                          if (modules[index]['title'] == 'Asam Basa Alami') {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, animation, __) => const SafetyProcedureScreen(),
                                transitionsBuilder: (_, animation, __, child) => FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                                transitionDuration: const Duration(milliseconds: 400),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Praktikum belum tersedia.')),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Sidebar Item terpisah agar bisa punya hover state sendiri
class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final highlight = widget.isSelected || _isHovered;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: highlight
                ? AppColors.white.withOpacity(widget.isSelected ? 0.15 : 0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: widget.isSelected
                ? Border.all(color: AppColors.secondary.withOpacity(0.5), width: 1)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected ? AppColors.secondary : AppColors.primaryLighter.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 14),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isSelected ? AppColors.white : AppColors.primaryLighter.withOpacity(0.75),
                  fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              if (widget.isSelected) ...[
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Kartu Modul terpisah
class _ModuleCard extends StatefulWidget {
  final String title;
  final String status; // 'Mulai' atau 'Selesai'
  final int? score;    // nilai jika sudah Selesai
  final String? image;
  final VoidCallback onTap;
  final VoidCallback onRestart;

  const _ModuleCard({
    required this.title,
    required this.status,
    this.score,
    this.image,
    required this.onTap,
    required this.onRestart,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _isHovered = false;

  bool get _isDone => widget.status == 'Selesai';

  Color get _scoreColor {
    final s = widget.score ?? 0;
    if (s >= 85) return AppColors.success;
    if (s >= 70) return AppColors.info;
    return AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered
            ? (Matrix4.identity()..translate(0, -6.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: _isDone
              ? Border.all(color: AppColors.success.withOpacity(0.4), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: (_isDone ? AppColors.success : AppColors.primary)
                  .withOpacity(_isHovered ? 0.18 : 0.08),
              blurRadius: _isHovered ? 28 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Area Gambar
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryLighter.withOpacity(0.4),
                            AppColors.infoLight.withOpacity(0.5),
                          ],
                        ),
                      ),
                      child: widget.image != null
                          ? Image.asset(
                              widget.image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Icon(
                                  Icons.image_not_supported_rounded,
                                  size: 40,
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.biotech_rounded,
                                size: 52,
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                    ),
                    // Badge "Selesai" di pojok kiri atas
                    if (_isDone)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Selesai',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Garis bawah: hijau kalau selesai, kosong kalau mulai
              Container(
                height: 4,
                color: _isDone ? AppColors.success.withOpacity(0.5) : AppColors.neutral100,
              ),

              // Info & Tombol
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Tampilkan nilai jika sudah selesai
                      if (_isDone && widget.score != null)
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: _scoreColor, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Nilai: ${widget.score}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _scoreColor,
                              ),
                            ),
                          ],
                        ),
                      const Spacer(),
                      // Tombol Mulai ATAU Restart
                      if (_isDone)
                        SizedBox(
                          width: double.infinity,
                          height: 34,
                          child: OutlinedButton.icon(
                            onPressed: widget.onRestart,
                            icon: const Icon(Icons.replay_rounded, size: 14),
                            label: const Text(
                              'Ulangi',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.success,
                              side: BorderSide(color: AppColors.success.withOpacity(0.6)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 34,
                          child: ElevatedButton(
                            onPressed: widget.onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Mulai',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
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
