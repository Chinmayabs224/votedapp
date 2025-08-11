import 'package:flutter/material.dart';

/// Color palette configuration for the Bockvote application
class AppColors {
  // Backwards-compatibility aliases for legacy usages
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray600;
  static const Color border = gray200;
  // Primary color swatch
  static const Map<int, Color> primarySwatch = {
    50: Color(0xFFF9F5FA),   // #f9f5fa
    100: Color(0xFFF3EBF4),  // #f3ebf4
    200: Color(0xFFE6D7E9),  // #e6d7e9
    300: Color(0xFFD4B6D8),  // #d4b6d8
    400: Color(0xFFC095C3),  // #c095c3
    500: Color(0xFFAC77AC),  // #ac77ac
    600: Color(0xFF924C92),  // #924c92 - Main brand
    700: Color(0xFF7A3F7A),  // #7a3f7a - Headers
    800: Color(0xFF653565),  // #653565
    900: Color(0xFF542C54),  // #542c54
  };

  static const MaterialColor primary = MaterialColor(0xFF924C92, primarySwatch);
  
  // Semantic colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // Gray scale
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  
  // Additional brand colors for compatibility
  static const Color primary100 = Color(0xFFF3EBF4);
  static const Color primary200 = Color(0xFFE6D7E9);
  static const Color primary400 = Color(0xFFC095C3);
  static const Color primary500 = Color(0xFFAC77AC);
  static const Color primary600 = Color(0xFF924C92);
  static const Color primary700 = Color(0xFF7A3F7A);
  
  // Utility colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
  
  // Status colors
  static const Color neutral = Color(0xFF9E9E9E);
}
