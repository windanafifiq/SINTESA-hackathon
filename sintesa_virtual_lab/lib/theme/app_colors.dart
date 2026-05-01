import 'package:flutter/material.dart';

class AppColors {
  // Neutrals
  static const Color neutral900 = Color(0xFF19191A);
  static const Color neutral800 = Color(0xFF393A3A);
  static const Color neutral700 = Color(0xFF575959);
  static const Color neutral100 = Color(0xFFF4F4F4);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Primary
  static const Color primary = Color(0xFF002259);
  static const Color primaryLight = Color(0xFF5779AF);
  static const Color primaryLighter = Color(0xFFBAD0F4);

  // Secondary
  static const Color secondary = Color(0xFFF68048);
  static const Color secondaryDark = Color(0xFFB35122);
  static const Color secondaryLight = Color(0xFFFFB38F);

  // Success
  static const Color success = Color(0xFFA7FF6D);
  static const Color successDark = Color(0xFF215200);
  static const Color successLight = Color(0xFFCCFFCC);
  static const Color successLighter = Color(0xFFCEFFCE);

  // Info
  static const Color info = Color(0xFF4E91FF);
  static const Color infoDark = Color(0xFF0B357B);
  static const Color infoLight = Color(0xFFC9DDFF);
  // BAD0F4 is already in primaryLighter, we can reuse or define here
  static const Color infoLighter = Color(0xFFBAD0F4); 

  // Warning
  static const Color warning = Color(0xFFFFE048);
  static const Color warningDark = Color(0xFF776300);
  static const Color warningOrange = Color(0xFFFFA600);
  static const Color warningLight = Color(0xFFFFF5C5);

  // Danger
  static const Color danger = Color(0xFFDB0000);
  static const Color dangerDark = Color(0xFF600000);
  static const Color dangerLight = Color(0xFFFF6161);
}
