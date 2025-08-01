import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FavoriteItem> _favorites = [
    FavoriteItem(
      title: 'Boşanma Davası Süreci',
      description: 'Boşanma davası nasıl açılır ve süreç nasıl işler?',
      category: 'Aile Hukuku',
      dateAdded: DateTime.now().subtract(Duration(days: 2)),
    ),
    FavoriteItem(
      title: 'İş Akdi Feshi',
      description: 'İş akdinin feshi ve işçi hakları hakkında bilgiler',
      category: 'İş Hukuku',
      dateAdded: DateTime.now().subtract(Duration(days: 5)),
    ),
    FavoriteItem(
      title: 'Miras Paylaşımı',
      description: 'Yasal mirasçılar ve miras paylaşım kuralları',
      category: 'Miras Hukuku',
      dateAdded: DateTime.now().subtract(Duration(days: 7)),
    ),
  ];

  void _removeFavorite(int index) {
    setState(() {
      _favorites.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorilerden kaldırıldı')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
        backgroundColor: const Color(0xFF2D3E50),
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz favori eklenmemiş',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Beğendiğiniz konuları favorilere ekleyin',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final favorite = _favorites[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D3E50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.favorite, color: Colors.white),
                    ),
                    title: Text(
                      favorite.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(favorite.description),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                favorite.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${favorite.dateAdded.day}/${favorite.dateAdded.month}/${favorite.dateAdded.year}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share),
                              SizedBox(width: 8),
                              Text('Paylaş'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Kaldır', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'remove') {
                          _removeFavorite(index);
                        } else if (value == 'share') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${favorite.title} paylaşıldı')),
                          );
                        }
                      },
                    ),
                    onTap: () {
                      // Detay sayfasına git
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${favorite.title} açılıyor...')),
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
  final String description;
  final String category;
  final DateTime dateAdded;

  FavoriteItem({
    required this.title,
    required this.description,
    required this.category,
    required this.dateAdded,
  });
}
