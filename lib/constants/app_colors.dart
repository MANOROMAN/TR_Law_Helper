import 'package:flutter/material.dart';

class AppColors {
  // Ana renkler - Lady Justice temasına uygun
  static const Color primaryBlue = Color(0xFF1E3A8A); // Koyu mavi
  static const Color secondaryBlue = Color(0xFF3B82F6); // Orta mavi
  static const Color lightBlue = Color(0xFF60A5FA); // Açık mavi
  
  static const Color primaryYellow = Color(0xFFFFD700); // Altın sarısı
  static const Color secondaryYellow = Color(0xFFFFEB3B); // Orta sarı
  static const Color lightYellow = Color(0xFFFFF59D); // Açık sarı
  
  // Nötr renkler
  static const Color white = Colors.white;
  static const Color lightGrey = Color(0xFFF8F9FA);
  static const Color grey = Color(0xFF6C757D);
  static const Color darkGrey = Color(0xFF495057);
  
  // Arka plan renkleri
  static const Color backgroundColor = white;
  static const Color cardBackground = white;
  static const Color surfaceBackground = lightGrey;
  
  // Gradient renkler
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryBlue, secondaryBlue],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryYellow, secondaryYellow],
  );
} 