import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'screens/intro_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const VirtualLabApp());
}

class VirtualLabApp extends StatelessWidget {
  const VirtualLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Lab Sintesa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

/// Wrapper yang menentukan halaman awal berdasarkan status login.
/// - Jika sudah login  → DashboardScreen
/// - Jika belum login  → LoginScreen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Saat masih loading state dari Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashLoader();
        }

        // Jika user sudah login sebelumnya
        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen();
        }

        // Belum login → ke Login
        return const LoginScreen();
      },
    );
  }
}

/// Loading screen sementara Firebase mengecek sesi
class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo_sintesa.png', height: 80),
              const SizedBox(height: 32),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: AppColors.secondary,
                  strokeWidth: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
