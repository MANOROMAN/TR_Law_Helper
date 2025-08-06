import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../constants/app_colors.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  User? _currentUser;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    _currentUser = _firebaseService.currentUser;
    if (_currentUser != null) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    if (_currentUser != null) {
      final profile = await _firebaseService.getUserProfile(_currentUser!.uid);
      if (mounted) {
        setState(() {
          _userProfile = profile;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _firebaseService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çıkış yapılırken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
                    Text(
                      _userProfile != null 
                          ? '${_userProfile!['firstName']} ${_userProfile!['lastName']}'
                          : _currentUser?.displayName ?? 'Kullanıcı',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentUser?.email ?? 'kullanici@email.com',
                      style: const TextStyle(
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
                      _showPersonalInfoDialog();
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildProfileCard(
                    context,
                    icon: FontAwesomeIcons.briefcase,
                    title: "Hukuki Geçmiş",
                    subtitle: "Geçmiş davalar ve hukuki işlemleriniz",
                    onTap: () {
                      _showLegalHistoryDialog();
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildProfileCard(
                    context,
                    icon: FontAwesomeIcons.bell,
                    title: "Bildirim Ayarları",
                    subtitle: "Bildirimleri özelleştirin",
                    onTap: () {
                      _showNotificationSettingsDialog();
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildProfileCard(
                    context,
                    icon: FontAwesomeIcons.shield,
                    title: "Gizlilik & Güvenlik",
                    subtitle: "Hesap güvenliği ve gizlilik ayarları",
                    onTap: () {
                      _showPrivacySettingsDialog();
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildProfileCard(
                    context,
                    icon: FontAwesomeIcons.questionCircle,
                    title: "Yardım & Destek",
                    subtitle: "SSS, iletişim ve teknik destek",
                    onTap: () {
                      _showHelpSupportDialog();
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildProfileCard(
                    context,
                    icon: FontAwesomeIcons.info,
                    title: "Uygulama Hakkında",
                    subtitle: "Sürüm bilgileri ve yasal uyarılar",
                    onTap: () {
                      _showAboutDialog();
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
                _signOut();
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

  void _showPersonalInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kişisel Bilgiler'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Ad Soyad', _userProfile != null 
                  ? '${_userProfile!['firstName']} ${_userProfile!['lastName']}'
                  : 'Bilgi yok'),
              _buildInfoRow('E-posta', _currentUser?.email ?? 'Bilgi yok'),
              _buildInfoRow('Cinsiyet', _userProfile?['gender'] ?? 'Belirtilmemiş'),
              _buildInfoRow('Yaş', _userProfile?['age']?.toString() ?? 'Belirtilmemiş'),
              _buildInfoRow('Ülke', _userProfile?['country'] ?? 'Türkiye'),
              _buildInfoRow('Kayıt Tarihi', _currentUser?.metadata.creationTime?.toString().split(' ')[0] ?? 'Bilgi yok'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showLegalHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hukuki Geçmiş'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 64, color: AppColors.grey),
            SizedBox(height: 16),
            Text('Henüz hukuki geçmişiniz bulunmuyor.'),
            SizedBox(height: 8),
            Text('Yapacağınız danışmanlıklar ve işlemler burada görünecektir.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bildirim Ayarları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Güncellemeler'),
              subtitle: const Text('Uygulama güncellemeleri'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Hukuki Bildirimler'),
              subtitle: const Text('Önemli hukuki duyurular'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Hatırlatıcılar'),
              subtitle: const Text('Randevu ve işlem hatırlatıcıları'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gizlilik & Güvenlik'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🔐 Hesap Güvenliği', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• İki faktörlü kimlik doğrulama aktif'),
              Text('• Şifre son değiştirilme: 30 gün önce'),
              SizedBox(height: 16),
              Text('🛡️ Gizlilik', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Verileriniz şifrelenerek saklanır'),
              Text('• Kişisel bilgiler üçüncü taraflarla paylaşılmaz'),
              Text('• KVKK uyumlu veri işleme'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yardım & Destek'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📞 İletişim', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('E-posta: destek@tckai.com'),
              Text('Telefon: +90 (312) 123-4567'),
              SizedBox(height: 16),
              Text('❓ Sık Sorulan Sorular', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• TCK AI nasıl kullanılır?'),
              Text('• Hukuki danışmanlık ücretsiz mi?'),
              Text('• Belgelerim güvende mi?'),
              SizedBox(height: 16),
              Text('🕐 Destek Saatleri', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Pazartesi - Cuma: 09:00 - 18:00'),
              Text('Cumartesi: 10:00 - 16:00'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uygulama Hakkında'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📱 TCK AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('Sürüm: 1.0.0'),
              SizedBox(height: 16),
              Text('📜 Açıklama', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Türk Ceza Kanunu odaklı yapay zeka destekli hukuki danışmanlık uygulaması.'),
              SizedBox(height: 16),
              Text('⚖️ Yasal Uyarı', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Bu uygulama genel bilgi amaçlıdır. Kesin hukuki tavsiye için avukata danışın.'),
              SizedBox(height: 16),
              Text('👨‍💻 Geliştirici', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('© 2024 TCK AI Takımı'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
