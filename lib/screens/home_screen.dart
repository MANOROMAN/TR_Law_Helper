import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'ai_chat_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'files_screen.dart';
import 'lawyer_contact_screen.dart';
import 'documents_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import '../constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Her sekmeye uygun sayfaya yönlendirme
    switch (index) {
      case 1: // Arama
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchScreen()),
        );
        break;
      case 2: // Favoriler
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FavoritesScreen()),
        );
        break;
      case 3: // Dosyalar
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FilesScreen()),
        );
        break;
      default: // Ana sayfa (index 0)
        // Zaten ana sayfadayız, hiçbir şey yapmaya gerek yok
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // Header
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
                  bottom: 24.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Hukuki Asistan',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.settings,
                        color: AppColors.primaryYellow,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Menu Cards List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                _buildMenuCard(
                  context,
                  icon: FontAwesomeIcons.robot,
                  title: "AI'ye Sor",
                  subtitle:
                      "Hukuki sorularınızı yazın ve\nyapay zekadan yanıt alın",
                  hasInput: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AIChatScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  icon: FontAwesomeIcons.phone,
                  title: "Avukatla İletişime Geç",
                  subtitle:
                      "Bir avukatla iletişime geçin\nveya bir randevu ayarlayın",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LawyerContactScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  icon: FontAwesomeIcons.fileLines,
                  title: "Dosyalarım",
                  subtitle: "Belgeleri yükleyin\nve saklayın",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  icon: FontAwesomeIcons.calendarDays,
                  title: "Takvim",
                  subtitle:
                      "Duruşmalar ve randevular için\ntakviminizi yönetin",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CalendarScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomNavItem(Icons.home, 0),
                _buildBottomNavItem(Icons.search, 1),
                _buildBottomNavItem(Icons.star_border, 2),
                _buildBottomNavItem(Icons.folder_open_outlined, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool hasInput = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 32),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                      height: 1.3,
                    ),
                  ),
                  if (hasInput) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: const Text(
                              "Mesajınızı yazın...",
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward,
                            color: AppColors.grey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Icon(
        icon,
        color: _selectedIndex == index ? AppColors.primaryBlue : AppColors.grey,
        size: 30,
      ),
    );
  }
}
