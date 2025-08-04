import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // Header - Profil
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 20.0,
                  bottom: 32.0,
                ),
                child: Column(
                  children: [
                    // Profil Fotoğrafı
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primaryBlue,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Kullanıcı Adı
                    const Text(
                      'Kullanıcı Adı',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'kullanici@email.com',
                      style: TextStyle(
                        color: AppColors.accentSilver,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Profil Menüleri
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildProfileCard(
                    context,
                    icon: FontAwesomeIcons.user,
                    title: "Kişisel Bilgiler",
                    subtitle: "Ad, soyad ve iletişim bilgilerini düzenle",
                    onTap: () {
                      // Kişisel bilgiler sayfasına git
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildProfileCard(
                    context,
                    icon: FontAwesomeIcons.briefcase,
                    title: "Hukuki Geçmiş",
                    subtitle: "Geçmiş davalar ve hukuki işlemleriniz",
                    onTap: () {
                      // Hukuki geçmiş sayfasına git
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildProfileCard(
                    context,
                    icon: FontAwesomeIcons.bell,
                    title: "Bildirim Ayarları",
                    subtitle: "Bildirimleri özelleştirin",
                    onTap: () {
                      // Bildirim ayarları sayfasına git
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildProfileCard(
                    context,
                    icon: FontAwesomeIcons.shield,
                    title: "Gizlilik & Güvenlik",
                    subtitle: "Hesap güvenliği ve gizlilik ayarları",
                    onTap: () {
                      // Gizlilik ayarları sayfasına git
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildProfileCard(
                    context,
                    icon: FontAwesomeIcons.questionCircle,
                    title: "Yardım & Destek",
                    subtitle: "SSS, iletişim ve teknik destek",
                    onTap: () {
                      // Yardım sayfasına git
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildProfileCard(
                    context,
                    icon: FontAwesomeIcons.info,
                    title: "Uygulama Hakkında",
                    subtitle: "Sürüm bilgileri ve yasal uyarılar",
                    onTap: () {
                      // Hakkında sayfasına git
                    },
                  ),
                  const SizedBox(height: 32),
                  // Çıkış Yap Butonu
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentRed,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            FontAwesomeIcons.arrowRightFromBracket,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Çıkış Yap',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Çıkış Yap',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'İptal',
                style: TextStyle(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Çıkış yapma işlemini burada gerçekleştir
                // Örneğin: login sayfasına yönlendir
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentRed,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Çıkış Yap',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
