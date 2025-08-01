import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'ai_chat_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'files_screen.dart';
import 'lawyer_contact_screen.dart';
import 'documents_screen.dart';
import 'calendar_screen.dart';

class HomeScreen extends StatefulWidget {
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
      backgroundColor: const Color(0xFFF4F6F8), // Light grey background
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            color: const Color(0xFF2D3E50),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 20.0, bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hukuki Asistan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
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
                  subtitle: "Hukuki sorularınızı yazın ve\nyapay zekadan yanıt alın",
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
                  subtitle: "Bir avukatla iletişime geçin\nveya bir randevu ayarlayın",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LawyerContactScreen()),
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
                      MaterialPageRoute(builder: (context) => DocumentsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  icon: FontAwesomeIcons.calendarDays,
                  title: "Takvim",
                  subtitle: "Duruşmalar ve randevular için\ntakviminizi yönetin",
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF2D3E50),
              size: 32,
            ),
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
                      color: Color(0xFF2D3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                  if (hasInput) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Mesajınızı yazın...",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.grey[500],
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
        color: _selectedIndex == index ? const Color(0xFF2D3E50) : Colors.grey[400],
        size: 30,
      ),
    );
  }
}
