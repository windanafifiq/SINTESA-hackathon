import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'safety_procedure_screen.dart';
import 'grade_screen.dart';
import '../models/module_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _navItems = [
    {'label': 'Kimia', 'icon': Icons.science_rounded},
    {'label': 'Biologi', 'icon': Icons.eco_rounded},
    {'label': 'Fisika', 'icon': Icons.bolt_rounded},
    {'label': 'Nilai', 'icon': Icons.grade_rounded},
  ];

  // Data modul per kategori — status diambil dari ModuleProgress
  List<Map<String, dynamic>> get _currentModules {
    final List<List<Map<String, dynamic>>> categories = [
      // Kimia
      [
        {
          'title': ModuleTitles.asamBasa,
          'image': 'assets/images/asam_basa_alami.jpg',
        },
        {
          'title': ModuleTitles.reaksiRedoks,
          'image': 'assets/images/reaksi_redoks.jpg',
        },
        {
          'title': ModuleTitles.larutanBuffer,
          'image': 'assets/images/larutan_buffer.jpg',
        },
      ],
      // Biologi
      [
        {'title': 'Osmosis & Difusi', 'image': 'assets/images/osmosis.jpg'},
        {'title': 'Fotosintesis', 'image': 'assets/images/fotosintesis.jpg'},
        {'title': 'Respirasi Sel', 'image': 'assets/images/respirasi_sel.jpg'},
      ],
      // Fisika
      [
        {
          'title': 'Gerak Parabola',
          'image': 'assets/images/gerak_parabola.jpg',
        },
        {'title': 'Hukum Newton', 'image': 'assets/images/newton.jpg'},
        {
          'title': 'Listrik Dinamis',
          'image': 'assets/images/listrik_dinamis.jpg',
        },
      ],
    ];

    if (_selectedIndex >= categories.length) return [];

    return categories[_selectedIndex].map((m) {
      final progress =
          ModuleProgress.status[m['title']] ??
          {'status': 'Mulai', 'score': null};
      return {...m, 'status': progress['status'], 'score': progress['score']};
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

    // Sinkronisasi dengan database
    ModuleProgress.syncWithFirestore().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _selectCategory(int index) {
    setState(() => _selectedIndex = index);
    _fadeController.reset();
    _fadeController.forward();
  }

  Future<void> _handleLogout() async {
    await AuthService().signOut();
    if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenW = MediaQuery.of(context).size.width;
    // Wide landscape = tablet-like, show full sidebar
    final isWideLandscape = isLandscape && screenW >= 700;

    if (isWideLandscape) {
      return _buildSidebarLayout();
    } else {
      return _buildBottomNavLayout();
    }
  }

  // ── Portrait / Narrow: Bottom Navigation ────────────────────────────────────

  Widget _buildBottomNavLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: _selectedIndex == 3
            ? const GradeScreen()
            : _buildMainContent(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? user?.email ?? 'Pengguna';

    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      toolbarHeight: 60,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.secondaryDark],
              ),
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Siswa',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
          tooltip: 'Keluar',
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    // Show only first 3 nav items + grade as "Nilai"
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = _selectedIndex == index;
              return _BottomNavItem(
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                isSelected: isSelected,
                onTap: () => _selectCategory(index),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── Wide Landscape: Sidebar Layout ───────────────────────────────────────────

  Widget _buildSidebarLayout() {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: _selectedIndex == 3
                ? const GradeScreen()
                : _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 220,
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
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Sidebar — Profil
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
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
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.secondaryDark],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: AppColors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FirebaseAuth.instance.currentUser?.displayName ??
                              FirebaseAuth.instance.currentUser?.email ??
                              'Pengguna',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Siswa',
                          style: TextStyle(
                            color: AppColors.primaryLighter.withOpacity(0.7),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tombol Logout
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _handleLogout,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: AppColors.primaryLighter.withOpacity(0.7),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Label navigasi
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'MATA PELAJARAN',
                style: TextStyle(
                  color: AppColors.primaryLighter.withOpacity(0.5),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            // Daftar menu
            ...List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = _selectedIndex == index;
              return _SidebarItem(
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                isSelected: isSelected,
                onTap: () => _selectCategory(index),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Main Content ─────────────────────────────────────────────────────────────

  Widget _buildMainContent() {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final isShort = screenH < 500;
    final modules = _currentModules;

    return Container(
      color: const Color(0xFFF0F4FF),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isShort ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner hero
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: isPortrait ? 120 : (isShort ? 100 : 160),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, Color(0xFF1A4FAD)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Dekorasi lingkaran
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withOpacity(0.04),
                      ),
                    ),
                  ),
                  // Konten banner
                  Padding(
                    padding: EdgeInsets.only(
                      left: isShort ? 12 : 18,
                      top: isShort ? 12 : 18,
                      bottom: isShort ? 12 : 18,
                      right: isShort ? 90 : 130, // Ruang kosong untuk logo
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _navItems[_selectedIndex < 3 ? _selectedIndex : 0]['label'] as String,
                            style: const TextStyle(
                              color: AppColors.secondaryLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Selamat Datang di Virtual Lab!',
                          style: TextStyle(
                            fontSize: isShort ? 15 : 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                            height: 1.2,
                          ),
                        ),
                        if (!isShort) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Eksplorasi eksperimen sains secara interaktif.',
                            style: TextStyle(
                              color: AppColors.primaryLighter.withOpacity(0.8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Logo Sintesa di banner
                  Positioned(
                    right: isShort ? 12 : 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo_sintesa.png',
                        height: isShort ? 60 : 90,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isShort ? 12 : 20),

            // Judul Pilih Modul
            Text(
              'Pilih Modul',
              style: TextStyle(
                fontSize: isShort ? 15 : 18,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: isShort ? 10 : 14),

            // Grid Modul
            FadeTransition(
              opacity: _fadeAnim,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Portrait mobile: 1 col if very narrow, else 2
                  int crossAxisCount;
                  if (isPortrait) {
                    crossAxisCount = constraints.maxWidth > 500 ? 3 : 2;
                  } else {
                    crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: isShort ? 10 : 14,
                      mainAxisSpacing: isShort ? 10 : 14,
                      childAspectRatio: isPortrait ? 0.75 : (isShort ? 0.95 : 0.82),
                    ),
                    itemCount: modules.length,
                    itemBuilder: (context, index) {
                      return _ModuleCard(
                        title: modules[index]['title'] as String,
                        status: modules[index]['status'] as String,
                        score: modules[index]['score'] as int?,
                        image: modules[index]['image'] as String?,
                        onTap: () {
                          if (modules[index]['title'] ==
                              ModuleTitles.asamBasa) {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, animation, __) =>
                                    const SafetyProcedureScreen(),
                                transitionsBuilder:
                                    (_, animation, __, child) =>
                                        FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                transitionDuration: const Duration(
                                  milliseconds: 400,
                                ),
                              ),
                            ).then((_) {
                              setState(() {});
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Modul ${modules[index]['title']} belum tersedia.',
                                ),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          }
                        },
                        onRestart: () {
                          if (modules[index]['title'] ==
                              ModuleTitles.asamBasa) {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, animation, __) =>
                                    const SafetyProcedureScreen(),
                                transitionsBuilder:
                                    (_, animation, __, child) =>
                                        FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                transitionDuration: const Duration(
                                  milliseconds: 400,
                                ),
                              ),
                            ).then((_) => setState(() {}));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Praktikum belum tersedia.'),
                              ),
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

// ── Bottom Nav Item ──────────────────────────────────────────────────────────
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? AppColors.secondary : Colors.white54,
                size: isSelected ? 24 : 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.secondary : Colors.white54,
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
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
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: highlight
                ? AppColors.white.withOpacity(widget.isSelected ? 0.15 : 0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: widget.isSelected
                ? Border.all(
                    color: AppColors.secondary.withOpacity(0.5),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected
                    ? AppColors.secondary
                    : AppColors.primaryLighter.withOpacity(0.7),
                size: 18,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isSelected
                      ? AppColors.white
                      : AppColors.primaryLighter.withOpacity(0.75),
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              if (widget.isSelected) ...[
                const Spacer(),
                Container(
                  width: 5,
                  height: 5,
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
  final int? score; // nilai jika sudah Selesai
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
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: _isDone
                ? Border.all(
                    color: AppColors.success.withOpacity(0.4),
                    width: 1.5,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: (_isDone ? AppColors.success : AppColors.primary)
                    .withOpacity(_isHovered ? 0.18 : 0.08),
                blurRadius: _isHovered ? 24 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
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
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                      child: Icon(
                                        Icons.image_not_supported_rounded,
                                        size: 32,
                                        color: AppColors.primary.withOpacity(0.3),
                                      ),
                                    ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.biotech_rounded,
                                  size: 40,
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                      ),
                      // Badge "Selesai" di pojok kiri atas
                      if (_isDone)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 10,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Selesai',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
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

                // Garis bawah
                Container(
                  height: 3,
                  color: _isDone
                      ? AppColors.success.withOpacity(0.5)
                      : AppColors.neutral100,
                ),

                // Info & Tombol
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      // Tampilkan nilai jika sudah selesai
                      if (_isDone && widget.score != null) ...[
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: _scoreColor, size: 12),
                            const SizedBox(width: 3),
                            Text(
                              'Nilai: ${widget.score}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _scoreColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                      ] else ...[
                        const SizedBox(height: 5),
                      ],
                      // Tombol Mulai ATAU Restart
                      if (_isDone)
                        SizedBox(
                          width: double.infinity,
                          height: 30,
                          child: OutlinedButton.icon(
                            onPressed: widget.onRestart,
                            icon: const Icon(Icons.replay_rounded, size: 12),
                            label: const Text(
                              'Ulangi',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.success,
                              padding: EdgeInsets.zero,
                              side: BorderSide(
                                color: AppColors.success.withOpacity(0.6),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 30,
                          child: ElevatedButton(
                            onPressed: widget.onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: EdgeInsets.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Mulai',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
