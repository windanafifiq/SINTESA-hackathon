import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
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

  Future<void> _showForgotPasswordDialog() async {
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSending = false;
    bool isSent = false;
    String? dialogError;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> sendReset() async {
              if (!formKey.currentState!.validate()) return;
              setSheetState(() {
                isSending = true;
                dialogError = null;
              });
              try {
                await _authService.resetPassword(
                  email: emailCtrl.text.trim(),
                );
                setSheetState(() => isSent = true);
              } on Exception catch (e) {
                final err = e.toString();
                setSheetState(() {
                  dialogError = err.contains('email-not-found')
                      ? 'Email tidak terdaftar. Pastikan email sudah benar.'
                      : err.contains('user-not-found')
                          ? 'Email tidak terdaftar. Periksa kembali.'
                          : err.contains('invalid-email')
                              ? 'Format email tidak valid.'
                              : err.contains('network-request-failed')
                                  ? 'Tidak ada koneksi internet.'
                                  : 'Gagal mengirim email. Coba lagi.';
                });
              } finally {
                setSheetState(() => isSending = false);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0B357B),
                      Color(0xFF1A1A3E),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Icon + Judul
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.secondary, AppColors.secondaryDark],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.lock_reset_rounded,
                              color: AppColors.white, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lupa Password?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.white.withOpacity(0.95),
                              ),
                            ),
                            Text(
                              'Kami kirimkan link reset ke email Anda',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryLighter.withOpacity(0.65),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // State: sudah terkirim
                    if (isSent) ...
                    [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.successLight.withOpacity(0.4),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.mark_email_read_rounded,
                                color: AppColors.successLight, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              'Email Terkirim!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Periksa kotak masuk email Anda dan\nikuti petunjuk untuk reset password.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.primaryLighter.withOpacity(0.7),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Tutup',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ]
                    // State: form input email
                    else ...
                    [
                      // Error banner
                      if (dialogError != null) ...
                      [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.dangerLight.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: AppColors.dangerLight, size: 16),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  dialogError!,
                                  style: const TextStyle(
                                    color: AppColors.dangerLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Input email
                      Form(
                        key: formKey,
                        child: TextFormField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                              color: AppColors.white, fontSize: 14),
                          validator: (v) {
                            final val = v?.trim() ?? '';
                            if (val.isEmpty) return 'Email tidak boleh kosong';
                            if (!RegExp(
                              r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
                            ).hasMatch(val)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Masukkan email terdaftar',
                            hintStyle: TextStyle(
                              color: AppColors.primaryLighter.withOpacity(0.4),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppColors.primaryLighter.withOpacity(0.5),
                              size: 20,
                            ),
                            filled: true,
                            fillColor: AppColors.white.withOpacity(0.07),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: AppColors.white.withOpacity(0.15),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.secondary,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: AppColors.danger),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: AppColors.danger, width: 1.5),
                            ),
                            errorStyle: const TextStyle(
                              color: AppColors.dangerLight,
                              fontSize: 11,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tombol kirim
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [AppColors.secondary, AppColors.secondaryDark],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: isSending ? null : sendReset,
                            child: Center(
                              child: isSending
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: AppColors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'KIRIM LINK RESET',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.white,
                                        letterSpacing: 2,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Tombol batal
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                AppColors.primaryLighter.withOpacity(0.6),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    emailCtrl.dispose();
  }

  // Regex email: harus ada karakter@domain.tld
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  String _parseFirebaseError(String error) {
    if (error.contains('user-not-found') ||
        error.contains('wrong-password') ||
        error.contains('invalid-credential') ||
        error.contains('INVALID_LOGIN_CREDENTIALS')) {
      return 'Email atau password salah. Periksa kembali.';
    } else if (error.contains('invalid-email')) {
      return 'Format email tidak valid.';
    } else if (error.contains('user-disabled')) {
      return 'Akun ini telah dinonaktifkan. Hubungi admin.';
    } else if (error.contains('operation-not-allowed')) {
      return 'Login dengan email belum diaktifkan.';
    } else if (error.contains('too-many-requests')) {
      return 'Terlalu banyak percobaan login. Coba lagi beberapa menit lagi.';
    } else if (error.contains('network-request-failed')) {
      return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
    }
    return 'Terjadi kesalahan tak terduga. Silakan coba lagi.';
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final isSmall = MediaQuery.of(context).size.width < 400;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
            Positioned(
              bottom: 100,
              right: -60,
              child: _buildCircleDecor(180, AppColors.secondary.withOpacity(0.04)),
            ),

            // Konten Utama
            AnimatedBuilder(
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
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 16 : 24,
                      vertical: isPortrait ? 24 : 12,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo Card
                          ScaleTransition(
                            scale: _pulseAnim,
                            child: _buildLogoCard(isSmall: isSmall),
                          ),

                          SizedBox(height: isPortrait ? 24 : 16),

                          // Form Card
                          _buildFormCard(isSmall: isSmall),
                          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                        ],
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

  Widget _buildLogoCard({bool isSmall = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isSmall ? 16 : 22,
        horizontal: isSmall ? 16 : 24,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
            height: isSmall ? 40 : 50,
          ),
          SizedBox(width: isSmall ? 12 : 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SINTESA',
                style: TextStyle(
                  fontSize: isSmall ? 20 : 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white.withOpacity(0.95),
                  letterSpacing: 5,
                ),
              ),
              Text(
                'Virtual Laboratory',
                style: TextStyle(
                  fontSize: isSmall ? 10 : 12,
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

  Widget _buildFormCard({bool isSmall = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 20 : 28),
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
              'Selamat Datang!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.white.withOpacity(0.95),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Masuk ke akun Anda untuk melanjutkan.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primaryLighter.withOpacity(0.65),
              ),
            ),

            const SizedBox(height: 32),

            // Error message
            if (_errorMessage != null) _buildErrorBanner(),

            // Email Field
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

            // Password Field
            _buildLabel('Password'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _passwordController,
              hint: 'Masukkan password',
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
                return null;
              },
            ),

            // Link Lupa Password
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: GestureDetector(
                  onTap: _showForgotPasswordDialog,
                  child: Text(
                    'Lupa Password?',
                    style: TextStyle(
                      color: AppColors.secondary.withOpacity(0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.secondary.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Tombol Login
            _LoginButton(
              isLoading: _isLoading,
              onTap: _handleLogin,
            ),

            const SizedBox(height: 24),

            // Link ke Register
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Belum punya akun? ',
                  style: TextStyle(
                    color: AppColors.primaryLighter.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, animation, __) =>
                            const RegisterScreen(),
                        transitionsBuilder: (_, animation, __, child) =>
                            FadeTransition(opacity: animation, child: child),
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  child: Text(
                    'Daftar Sekarang',
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
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 14,
      ),
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

// ─── Tombol Login dengan hover effect ───────────────────────────────────────

class _LoginButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _LoginButton({required this.isLoading, required this.onTap});

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {
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
                      'MASUK',
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
