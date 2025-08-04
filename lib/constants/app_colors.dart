import 'package:flutter/material.dart';

class AppColors {
  // Ana renkler - Beyaz ve Mavi Tonla rı
  static const Color primaryBlue = Color(0xFF1976D2); // Ana mavi - güvenilir
  static const Color secondaryBlue = Color(0xFF42A5F5); // Orta mavi - canlı
  static const Color lightBlue = Color(0xFF90CAF9); // Açık mavi - yumuşak
  
  // Beyaz tonları - temiz ve minimal
  static const Color primaryWhite = Color(0xFFFFFFFF); // Ana beyaz
  static const Color offWhite = Color(0xFFFFFFFF); // Ana beyaz ile aynı
  static const Color lightWhite = Color(0xFFFFFFFF); // Ana beyaz ile aynı
  
  // Açık mavi tonları - modern vurgular
  static const Color skyBlue = Color(0xFFBBDEFB); // Gökyüzü mavisi - kartlar
  static const Color softBlue = Color(0xFFE3F2FD); // Çok açık mavi - arka plan
  static const Color navyBlue = Color(0xFF0D47A1); // Lacivert - vurgular
  
  // Vurgu renkleri - kontrastlı ve profesyonel
  static const Color accentRed = Color(0xFFE53935); // Kırmızı - favoriler için
  static const Color accentTeal = Color(0xFFFFFFFF); // Beyaz - profesyonel vurgu
  static const Color accentGray = Color(0xFF607D8B); // Gri - nötr vurgu
  
  // Nötr renkler - dengeli ve profesyonel
  static const Color white = Color(0xFFFFFFFF); // Saf beyaz
  static const Color black = Color(0xFF212121); // Modern siyah
  static const Color grey = Color(0xFF757575); // Orta gri
  static const Color darkGrey = Color(0xFF424242); // Koyu gri
  
  // Text renkleri - okunabilir ve profesyonel
  static const Color textPrimary = Color(0xFF212121); // Ana metin - siyah
  static const Color textSecondary = Color(0xFF1976D2); // İkincil metin - mavi
  static const Color textLight = Color(0xFF757575); // Açık metin - gri
  
  // Gölge rengi
  static const Color shadowColor = Color(0x1A1976D2); // Mavi gölge
  
  // Arka plan renkleri
  static const Color backgroundColor = softBlue;
  static const Color cardBackground = primaryWhite;
  static const Color surfaceBackground = primaryWhite;
  
  // Gradient renkler - mavi ve beyaz geçişler
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryBlue, secondaryBlue],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [white, primaryBlue],
  );
  
  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lightWhite, primaryWhite],
  );
  
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightBlue, skyBlue],
  );
  
  // Eski renk adları için yönlendirmeler (geriye uyumluluk)
  static const Color primaryGreen = primaryBlue; // Mavi ana renk
  static const Color secondaryGreen = secondaryBlue; // Orta mavi
  static const Color lightGreen = lightBlue; // Açık mavi
  static const Color primaryWarm = primaryBlue;
  static const Color secondaryWarm = secondaryBlue;
  static const Color lightWarm = primaryWhite;
  static const Color accentSage = navyBlue; // Lacivert vurgu
  static const Color accentTerra = accentTeal; // Teal vurgu
  static const Color accentNavy = navyBlue; // Lacivert
  static const Color accentSky = lightBlue; // Açık mavi
  static const Color primaryYellow = accentTeal; // Teal
  static const Color accentSilver = skyBlue; // Gökyüzü mavisi
  static const Color accentSteel = primaryBlue; // Mavi vurgu
  static const Color darkBlue = navyBlue; // Lacivert
  static const Color primaryBrown = primaryBlue; // Mavi
  static const Color secondaryBrown = secondaryBlue; // Orta mavi
  static const Color darkBrown = navyBlue; // Lacivert
  static const Color lightGold = accentTeal; // Teal
  static const Color primaryCream = primaryWhite; // Ana beyaz
  static const Color secondaryCream = primaryWhite; // Ana beyaz
  static const Color lightCream = softBlue; // Açık mavi
  static const Color primaryBlack = black; // Siyah
  static const Color secondaryBlack = darkGrey; // Koyu gri
  static const Color lightBlack = grey; // Orta gri
  static const Color primaryGrey = grey; // Orta gri
  static const Color secondaryGrey = darkGrey; // Koyu gri
  static const Color lightGrey = skyBlue; // Gökyüzü mavisi
  static const Color accentDarkGrey = primaryBlue; // Mavi
  static const Color accentMediumGrey = secondaryBlue; // Orta mavi
  static const Color accentLightGrey = lightBlue; // Açık mavi
  static const Color primaryPurple = primaryBlue; // Mavi
  static const Color secondaryPurple = secondaryBlue; // Orta mavi
  static const Color lightPurple = lightBlue; // Açık mavi
  static const Color lavender = softBlue; // Açık mavi
  static const Color lilac = skyBlue; // Gökyüzü mavisi
  static const Color softLavender = softBlue; // Açık mavi
  static const Color accentGold = accentTeal; // Teal
  static const Color accentRose = accentRed; // Kırmızı (favoriler için)
  static const Color accentBlue = primaryBlue; // Mavi
  static const Color mintGreen = skyBlue; // Gökyüzü mavisi
  static const Color softMint = softBlue; // Açık mavi
  static const Color darkMint = navyBlue; // Lacivert
  
  // Özel durum renkleri - mavi ve kırmızı tonlar
  static const Color success = secondaryBlue; // Başarı - mavi
  static const Color warning = white; // Uyarı - beyaz
  static const Color error = accentRed; // Hata - kırmızı
  static const Color info = primaryBlue; // Bilgi - mavi
}