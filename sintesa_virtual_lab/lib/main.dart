import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/intro_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const VirtualLabApp());
}

class VirtualLabApp extends StatelessWidget {
  const VirtualLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Lab - Asam Basa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF002259),
          brightness: Brightness.dark,
        ),
        fontFamily: 'sans-serif',
        useMaterial3: true,
      ),
      home: const IntroScreen(),
    );
  }
}
