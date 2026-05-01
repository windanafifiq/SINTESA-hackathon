import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

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
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      if (mounted) {
        // Tampilkan sukses lalu ke dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Akun berhasil dibuat! Selamat datang.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, animation, __) => const DashboardScreen(),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } on Exception catch (e) {
      setState(() {
        _errorMessage = _parseFirebaseError(e.toString());
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Regex & validators ────────────────────────────────────────────────────
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );
  // Nama: hanya huruf, spasi, titik, dan tanda hubung
  static final _nameRegex = RegExp(r"^[a-zA-Z .'-]+$");
  // Password harus mengandung huruf
  static final _hasLetter = RegExp(r'[a-zA-Z]');
  // Password harus mengandung angka
  static final _hasDigit = RegExp(r'[0-9]');

  String _parseFirebaseError(String error) {
    if (error.contains('email-already-in-use')) {
      return 'Email ini sudah terdaftar. Coba masuk atau gunakan email lain.';
    } else if (error.contains('invalid-email')) {
      return 'Format email tidak valid.';
    } else if (error.contains('weak-password')) {
      return 'Password terlalu lemah. Gunakan kombinasi huruf dan angka.';
    } else if (error.contains('operation-not-allowed')) {
      return 'Pendaftaran dengan email belum diaktifkan.';
    } else if (error.contains('network-request-failed')) {
      return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
    } else if (error.contains('too-many-requests')) {
      return 'Terlalu banyak permintaan. Coba lagi nanti.';
    }
    return 'Terjadi kesalahan tak terduga. Silakan coba lagi.';
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
              AppColors.primary,
              Color(0xFF0B357B),
              Color(0xFF1A1A3E),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Dekorasi lingkaran blur background
            Positioned(
              top: -120,
              right: -120,
              child: _buildCircleDecor(350, AppColors.primaryLight.withOpacity(0.08)),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: _buildCircleDecor(300, AppColors.secondary.withOpacity(0.06)),
            ),
            Positioned(
              top: 200,
              left: -100,
              child: _buildCircleDecor(220, AppColors.info.withOpacity(0.05)),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo Card
                          ScaleTransition(
                            scale: _pulseAnim,
                            child: _buildLogoCard(),
                          ),

                          const SizedBox(height: 36),

                          // Form Card
                          _buildFormCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryLighter.withOpacity(0.25),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight.withOpacity(0.12),
            AppColors.primary.withOpacity(0.2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo_sintesa.png',
            height: 56,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SINTESA',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white.withOpacity(0.95),
                  letterSpacing: 5,
                ),
              ),
              Text(
                'Virtual Laboratory',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryLighter.withOpacity(0.7),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: AppColors.white.withOpacity(0.07),
        border: Border.all(
          color: AppColors.white.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            Text(
              'Buat Akun Baru',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.white.withOpacity(0.95),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Daftarkan diri Anda untuk mulai belajar.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primaryLighter.withOpacity(0.65),
              ),
            ),

            const SizedBox(height: 32),

            // Error message
            if (_errorMessage != null) _buildErrorBanner(),

            // Nama Lengkap
            _buildLabel('Nama Lengkap'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'Nama Anda',
              icon: Icons.person_outline_rounded,
              validator: (v) {
                final val = v?.trim() ?? '';
                if (val.isEmpty) return 'Nama tidak boleh kosong';
                if (val.length < 2) return 'Nama minimal 2 karakter';
                if (val.length > 50) return 'Nama terlalu panjang (maks. 50 karakter)';
                if (!_nameRegex.hasMatch(val)) {
                  return 'Nama hanya boleh mengandung huruf dan spasi';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Email
            _buildLabel('Email'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hint: 'contoh@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                final val = v?.trim() ?? '';
                if (val.isEmpty) return 'Email tidak boleh kosong';
                if (!_emailRegex.hasMatch(val)) {
                  return 'Format email tidak valid (contoh: nama@domain.com)';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Password
            _buildLabel('Password'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _passwordController,
              hint: 'Minimal 6 karakter',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.primaryLighter.withOpacity(0.5),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                if (v.trim().isEmpty) return 'Password tidak boleh hanya spasi';
                if (v.length < 6) return 'Password minimal 6 karakter';
                if (!_hasLetter.hasMatch(v)) return 'Password harus mengandung huruf';
                if (!_hasDigit.hasMatch(v)) return 'Password harus mengandung angka';
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Konfirmasi Password
            _buildLabel('Konfirmasi Password'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _confirmPasswordController,
              hint: 'Ulangi password',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.primaryLighter.withOpacity(0.5),
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Konfirmasi password tidak boleh kosong';
                if (v != _passwordController.text) {
                  return 'Password tidak cocok. Pastikan kedua password sama';
                }
                return null;
              },
            ),

            // Syarat password kecil-kecil
            const SizedBox(height: 10),
            _buildPasswordHints(),

            const SizedBox(height: 28),

            // Tombol Daftar
            _RegisterButton(
              isLoading: _isLoading,
              onTap: _handleRegister,
            ),

            const SizedBox(height: 24),

            // Link ke Login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sudah punya akun? ',
                  style: TextStyle(
                    color: AppColors.primaryLighter.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Masuk',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordHints() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _passwordController,
      builder: (context, value, _) {
        final pw = value.text;
        final hasMin    = pw.length >= 6;
        final hasLetter = _hasLetter.hasMatch(pw);
        final hasDigit  = _hasDigit.hasMatch(pw);
        return Wrap(
          spacing: 14,
          runSpacing: 4,
          children: [
            _buildHintChip('≥6 karakter', hasMin),
            _buildHintChip('Ada huruf', hasLetter),
            _buildHintChip('Ada angka', hasDigit),
          ],
        );
      },
    );
  }

  Widget _buildHintChip(String label, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 12,
          color: isMet ? AppColors.success : AppColors.primaryLighter.withOpacity(0.4),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isMet ? AppColors.successLight : AppColors.primaryLighter.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.white.withOpacity(0.8),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.primaryLighter.withOpacity(0.4),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: AppColors.primaryLighter.withOpacity(0.5), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.white.withOpacity(0.07),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.white.withOpacity(0.15), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        errorStyle: const TextStyle(color: AppColors.dangerLight, fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.dangerLight.withOpacity(0.4), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.dangerLight, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.dangerLight, fontSize: 12),
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
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

// ─── Tombol Register dengan hover effect ─────────────────────────────────────

class _RegisterButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _RegisterButton({required this.isLoading, required this.onTap});

  @override
  State<_RegisterButton> createState() => _RegisterButtonState();
}

class _RegisterButtonState extends State<_RegisterButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: _isHovered
                ? [AppColors.secondary, AppColors.secondaryDark]
                : [AppColors.secondary.withOpacity(0.92), AppColors.secondaryDark],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(_isHovered ? 0.5 : 0.25),
              blurRadius: _isHovered ? 24 : 12,
              spreadRadius: _isHovered ? 2 : 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: widget.isLoading ? null : widget.onTap,
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'DAFTAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                        letterSpacing: 3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
