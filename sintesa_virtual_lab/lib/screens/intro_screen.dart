import 'package:flutter/material.dart';
import '../models/app_colors.dart';
import '../models/game_state.dart';
import 'game_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _floatCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _startGame() {
    final gameState = GameState();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GameScreen(gameState: gameState),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.5, -0.3),
            radius: 1.5,
            colors: [
              Color(0xFF1A3060),
              Color(0xFF0D1B35),
              Color(0xFF060D1A),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Stack(
            children: [
              // Decorative circles
              ..._buildDecorativeElements(size),

              // Main content
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon / logo area
                          AnimatedBuilder(
                            animation: _floatCtrl,
                            builder: (context, child) => Transform.translate(
                              offset: Offset(0, _floatAnim.value),
                              child: child,
                            ),
                            child: _buildLabIcon(),
                          ),
                          const SizedBox(height: 24),

                          // Title
                          const Text(
                            'VIRTUAL LAB KIMIA',
                            style: TextStyle(
                              color: AppColors.primary200,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary500.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color:
                                      AppColors.secondary500.withOpacity(0.4)),
                            ),
                            child: const Text(
                              'Praktikum Asam-Basa',
                              style: TextStyle(
                                color: AppColors.secondary500,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Info cards
                          _buildInfoSection(),

                          const SizedBox(height: 32),

                          // Start button
                          GestureDetector(
                            onTap: _startGame,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF002259),
                                    Color(0xFF5779AF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary700.withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.science,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'Mulai Praktikum',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primary700.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: AppColors.primary700.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.science,
        color: AppColors.primary200,
        size: 50,
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: Icons.flag,
                title: 'Tujuan',
                content:
                    'Mengenal larutan asam & basa menggunakan indikator alami Ekstrak Kunyit',
                color: AppColors.info500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                icon: Icons.inventory_2,
                title: 'Bahan',
                content:
                    'Ekstrak Kunyit + 7 Larutan:\nAir, Air Selokan, Air Garam, Obat Maag, Air Sabun, Cuka, Air Kapur',
                color: AppColors.secondary500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.videogame_asset,
          title: 'Cara Bermain',
          content:
              'Drag & drop sendok preparat berisi ekstrak kunyit ke setiap gelas larutan. Amati perubahan warna dan identifikasi sifat larutan!',
          color: AppColors.success400,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDecorativeElements(Size size) {
    return [
      Positioned(
        top: -50,
        right: -50,
        child: _decorativeCircle(200, AppColors.primary700.withOpacity(0.08)),
      ),
      Positioned(
        bottom: -80,
        left: -60,
        child: _decorativeCircle(250, AppColors.secondary500.withOpacity(0.06)),
      ),
      Positioned(
        top: size.height * 0.3,
        left: -30,
        child: _decorativeCircle(100, AppColors.info500.withOpacity(0.05)),
      ),
    ];
  }

  Widget _decorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
