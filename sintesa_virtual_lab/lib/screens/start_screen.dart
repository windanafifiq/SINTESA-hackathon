import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,          // #002259 deep navy
              Color(0xFF0B357B),          // info dark
              Color(0xFF1A1A3E),          // very dark navy
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Dekorasi lingkaran blur background
            Positioned(
              top: -100,
              right: -100,
              child: _buildCircleDecor(300, AppColors.primaryLight.withOpacity(0.08)),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: _buildCircleDecor(250, AppColors.secondary.withOpacity(0.06)),
            ),
            Positioned(
              top: 200,
              left: -80,
              child: _buildCircleDecor(200, AppColors.info.withOpacity(0.05)),
            ),

            // Konten Utama
            Center(
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnim.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnim.value),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo / Banner Image
                    ScaleTransition(
                      scale: _pulseAnim,
                      child: Container(
                        width: 380,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.primaryLighter.withOpacity(0.3),
                            width: 1.5,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryLight.withOpacity(0.15),
                              AppColors.primary.withOpacity(0.25),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.info.withOpacity(0.2),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/logo_sintesa.png',
                                height: 80,
                                // color: AppColors.primaryLighter.withOpacity(0.85),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'SINTESA',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.white.withOpacity(0.9),
                                  letterSpacing: 6,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Virtual Laboratory',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primaryLighter.withOpacity(0.7),
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 56),

                    // Tombol MULAI dengan glow effect
                    _MulaiButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleDecor(double size, Color color) {
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

class _MulaiButton extends StatefulWidget {
  @override
  State<_MulaiButton> createState() => _MulaiButtonState();
}

class _MulaiButtonState extends State<_MulaiButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: 220,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: _isHovered
                ? [AppColors.secondary, AppColors.secondaryDark]
                : [AppColors.secondary.withOpacity(0.9), AppColors.secondaryDark],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(_isHovered ? 0.55 : 0.3),
              blurRadius: _isHovered ? 28 : 16,
              spreadRadius: _isHovered ? 2 : 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, animation, __) => const LoginScreen(),
                  transitionsBuilder: (_, animation, __, child) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  transitionDuration: const Duration(milliseconds: 500),
                ),
              );
            },
            child: const Center(
              child: Text(
                'MULAI',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
