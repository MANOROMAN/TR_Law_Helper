import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FavoriteItem> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadSampleFavorites();
  }

  void _loadSampleFavorites() {
    _favorites = [
      FavoriteItem('Boşanma Davası', 'Aile Hukuku', Icons.family_restroom),
      FavoriteItem('Miras Hukuku', 'Miras Hukuku', Icons.account_balance),
      FavoriteItem('İş Hukuku', 'İş Hukuku', Icons.work),
      FavoriteItem('Ceza Hukuku', 'Ceza Hukuku', Icons.gavel),
    ];
  }

  void _removeFavorite(int index) {
    setState(() {
      _favorites.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Favorilerden kaldırıldı'),
        backgroundColor: AppColors.primaryBlue,
        action: SnackBarAction(
          label: 'Geri Al',
          textColor: AppColors.white,
          onPressed: () {
            // Geri alma işlemi
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.primaryYellow),
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: AppColors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz favori yok',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Favori hukuki dosyalarınızı burada görebilirsiniz',
                    style: TextStyle(fontSize: 16, color: AppColors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final favorite = _favorites[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        favorite.icon,
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      favorite.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    subtitle: Text(
                      favorite.category,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: AppColors.primaryYellow,
                      ),
                      onPressed: () => _removeFavorite(index),
                    ),
                    onTap: () {
                      // Favori detayları
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${favorite.title} açılıyor...'),
                          backgroundColor: AppColors.primaryBlue,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class FavoriteItem {
  final String title;
  final String category;
  final IconData icon;

  FavoriteItem(this.title, this.category, this.icon);
}
