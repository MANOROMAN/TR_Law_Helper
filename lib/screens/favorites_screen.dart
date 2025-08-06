import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../models/document.dart';
import '../services/firebase_service.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Document> _favorites = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    if (_userId != null) {
      _loadFavorites();
    }
  }

  void _loadFavorites() {
    if (_userId == null) return;

    _firebaseService.getFavoriteDocumentsStream(_userId!).listen((
      favoritesData,
    ) {
      setState(() {
        _favorites = favoritesData.map((data) {
          return Document(
            id: data['id'] ?? '',
            name: data['name'] ?? '',
            type: data['type'] ?? '',
            url: data['url'] ?? '',
            fileSize: data['fileSize'] ?? 0,
            uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
            isFavorite: data['isFavorite'] ?? false,
            userId: data['userId'] ?? '',
          );
        }).toList();
        _isLoading = false;
      });
    });
  }

  Future<void> _removeFavorite(Document document) async {
    if (_userId == null) return;

    try {
      await _firebaseService.toggleFavorite(_userId!, document.id, false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${document.name} favorilerden kaldırıldı'),
          backgroundColor: AppColors.primaryBlue,
          action: SnackBarAction(
            label: 'Geri Al',
            textColor: AppColors.white,
            onPressed: () async {
              await _firebaseService.toggleFavorite(
                _userId!,
                document.id,
                true,
              );
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: AppColors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Favori dosyanız yok!',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
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
                        color: _getFileTypeColor(favorite.type),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getFileTypeIcon(favorite.type),
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      favorite.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${favorite.type} • ${favorite.formattedSize}',
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Yüklenme: ${_formatDate(favorite.uploadedAt)}',
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: AppColors.accentRed,
                      ),
                      onPressed: () => _removeFavorite(favorite),
                    ),
                    onTap: () {
                      // Favori detayları
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${favorite.name} açılıyor...'),
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

  Color _getFileTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'PDF':
        return Colors.red;
      case 'DOCX':
      case 'DOC':
        return Colors.blue;
      case 'TXT':
        return Colors.grey;
      case 'JPG':
      case 'PNG':
      case 'JPEG':
        return Colors.green;
      default:
        return AppColors.primaryBlue;
    }
  }

  IconData _getFileTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'DOCX':
      case 'DOC':
        return Icons.description;
      case 'TXT':
        return Icons.text_snippet;
      case 'JPG':
      case 'PNG':
      case 'JPEG':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
