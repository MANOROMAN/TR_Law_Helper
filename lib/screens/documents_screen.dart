import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../services/firebase_service.dart';
import '../constants/app_colors.dart';
import '../models/document.dart';

class DocumentsScreen extends StatefulWidget {
  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Document> _documents = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    debugPrint('=== DOCUMENTS SCREEN INIT ===');
    debugPrint('Kullanıcı ID: $_userId');
    debugPrint(
      'Kullanıcı giriş yapmış mı: ${FirebaseAuth.instance.currentUser != null}',
    );
    if (_userId != null) {
      _loadDocuments();
    } else {
      debugPrint('HATA: Kullanıcı giriş yapmamış');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadDocuments() {
    if (_userId == null) return;

    debugPrint('Dokümanlar yükleniyor...');
    _firebaseService
        .getUserDocumentsStream(_userId!)
        .listen(
          (documentsData) {
            if (!mounted) return;
            debugPrint('Dokümanlar güncellendi: ${documentsData.length} adet');
            setState(() {
              _documents = documentsData.map((data) {
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
          },
          onError: (error) {
            debugPrint('Doküman yükleme hatası: $error');
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Dokümanlar yüklenirken hata oluştu: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
  }

  Future<void> _pickFile() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önce giriş yapın'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      debugPrint('=== DOSYA YÜKLEME BAŞLATILIYOR (DOCUMENTS) ===');
      debugPrint('Kullanıcı ID: $_userId');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null) {
        debugPrint('Dosya seçildi: ${result.files.single.name}');
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        String fileExtension = fileName.split('.').last.toLowerCase();

        debugPrint('Dosya yolu: ${file.path}');
        debugPrint('Dosya var mı: ${await file.exists()}');
        debugPrint('Dosya boyutu: ${await file.length()} bytes');

        // Show loading dialog
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Dosya yükleniyor...'),
              ],
            ),
          ),
        );

        debugPrint('Firebase service çağrılıyor...');
        String? downloadUrl = await _firebaseService.uploadDocument(
          userId: _userId!,
          documentFile: file,
          documentName: fileName,
          documentType: fileExtension.toUpperCase(),
        );

        debugPrint('Firebase service yanıtı: $downloadUrl');

        if (!mounted) return;
        Navigator.of(context).pop(); // Close loading dialog

        if (downloadUrl != null && downloadUrl.isNotEmpty) {
          debugPrint('Dosya başarıyla yüklendi: $downloadUrl');
          if (!mounted) return;

          String message;
          if (downloadUrl == 'local_only') {
            message =
                '$fileName bilgileri kaydedildi (dosya içeriği yüklenemedi)';
          } else if (downloadUrl == 'upload_failed') {
            message =
                '$fileName bilgileri kaydedildi (dosya yükleme başarısız)';
          } else {
            message = '$fileName başarıyla yüklendi';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: downloadUrl.startsWith('http')
                  ? AppColors.primaryBlue
                  : Colors.orange,
            ),
          );
        } else {
          debugPrint('Dosya yükleme başarısız - downloadUrl null veya boş');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dosya yükleme başarısız'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        debugPrint('Dosya seçimi iptal edildi');
      }
    } catch (e) {
      debugPrint('=== DOSYA YÜKLEME HATASI (DOCUMENTS) ===');
      debugPrint('Hata türü: ${e.runtimeType}');
      debugPrint('Hata mesajı: $e');
      debugPrint('Stack trace: ${StackTrace.current}');

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog if open
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Tamam',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  Future<void> _toggleFavorite(Document document) async {
    if (_userId == null) return;

    try {
      await _firebaseService.toggleFavorite(
        _userId!,
        document.id,
        !document.isFavorite,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            document.isFavorite
                ? '${document.name} favorilerden çıkarıldı'
                : '${document.name} favorilere eklendi',
          ),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteDocument(Document document) async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı girişi gerekli'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dosyayı Sil'),
        content: Text(
          '${document.name} dosyasını silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Show loading dialog
              if (!mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Dosya siliniyor...'),
                    ],
                  ),
                ),
              );

              // Ensure loading dialog is closed after a timeout
              Future.delayed(const Duration(seconds: 30), () {
                if (mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              });

              try {
                debugPrint('=== DOSYA SİLME BAŞLATILIYOR (DOCUMENTS) ===');
                debugPrint('Kullanıcı ID: $_userId');
                debugPrint('Dosya ID: ${document.id}');
                debugPrint('Dosya adı: ${document.name}');

                await _firebaseService.deleteDocument(_userId!, document.id);
                debugPrint('Dosya başarıyla silindi: ${document.id}');

                // Check if widget is still mounted before accessing context
                if (!mounted) return;

                // Close loading dialog first
                Navigator.of(context).pop();

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${document.name} başarıyla silindi'),
                    backgroundColor: AppColors.primaryBlue,
                  ),
                );
              } catch (e) {
                debugPrint('=== DOSYA SİLME HATASI (DOCUMENTS) ===');
                debugPrint('Hata türü: ${e.runtimeType}');
                debugPrint('Hata mesajı: $e');
                debugPrint('Stack trace: ${StackTrace.current}');

                // Check if widget is still mounted before accessing context
                if (!mounted) return;

                // Close loading dialog first
                Navigator.of(context).pop();

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Dosya silinemedi: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dosyalarım'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.primaryYellow),
        actions: [
          IconButton(
            onPressed: () async {
              debugPrint('=== FIREBASE BAĞLANTI TESTİ (DOCUMENTS) ===');
              try {
                bool testResult = await _firebaseService
                    .testStorageConnection();
                debugPrint('Test sonucu: $testResult');
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      testResult
                          ? 'Firebase bağlantısı başarılı'
                          : 'Firebase bağlantısı başarısız',
                    ),
                    backgroundColor: testResult
                        ? AppColors.primaryBlue
                        : Colors.red,
                  ),
                );
              } catch (e) {
                debugPrint('Test hatası: $e');
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Test hatası: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.wifi, color: AppColors.white),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Arama fonksiyonu
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _documents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 80, color: AppColors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz dosya yok',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dosya eklemek için + butonuna tıklayın',
                    style: TextStyle(fontSize: 16, color: AppColors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                final document = _documents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getFileTypeColor(document.type),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getFileTypeIcon(document.type),
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      document.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${document.type} • ${document.formattedSize}',
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Yüklenme: ${_formatDate(document.uploadedAt)}',
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            document.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: document.isFavorite
                                ? AppColors.accentRed
                                : AppColors.grey,
                          ),
                          onPressed: () => _toggleFavorite(document),
                        ),
                        PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility),
                                  SizedBox(width: 8),
                                  Text('Görüntüle'),
                                ],
                              ),
                            ),
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
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Sil',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            switch (value) {
                              case 'view':
                                // Dosya görüntüleme
                                break;
                              case 'share':
                                // Dosya paylaşma
                                break;
                              case 'delete':
                                _deleteDocument(document);
                                break;
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // Dosya detayları
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${document.name} açılıyor...'),
                          backgroundColor: AppColors.primaryBlue,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add),
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
