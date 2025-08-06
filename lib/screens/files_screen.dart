import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/document.dart';
import '../services/firebase_service.dart';
import '../constants/app_colors.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Document> _documents = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    debugPrint('=== FILES SCREEN INIT ===');
    debugPrint('Kullanıcı ID: $_userId');
    debugPrint(
      'Kullanıcı giriş yapmış mı: ${FirebaseAuth.instance.currentUser != null}',
    );
    if (_userId != null) {
      _loadDocuments();
    } else {
      debugPrint('HATA: Kullanıcı giriş yapmamış');
    }
  }

  void _loadDocuments() async {
    if (_userId == null) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final documentsData = await _firebaseService.getUserDocuments(_userId!);

      if (!mounted) return;
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dosyalar yüklenirken hata oluştu: $e')),
      );
    }
  }

  Future<void> _uploadFile() async {
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
      debugPrint('=== DOSYA YÜKLEME BAŞLATILIYOR ===');
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
          _loadDocuments(); // Reload documents
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
      debugPrint('=== DOSYA YÜKLEME HATASI ===');
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
        !document.isFavorite, // Toggle the current state
      );
      _loadDocuments(); // Reload to update favorite status
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

  void _deleteFile(Document document) {
    if (_userId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dosyayı Sil'),
        content: Text(
          '${document.name} dosyasını silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

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
                debugPrint('=== DOSYA SİLME BAŞLATILIYOR ===');
                debugPrint('Kullanıcı ID: $_userId');
                debugPrint('Dosya ID: ${document.id}');
                debugPrint('Dosya adı: ${document.name}');

                if (_userId != null) {
                  await _firebaseService.deleteDocument(_userId!, document.id);
                  debugPrint('Dosya başarıyla silindi: ${document.id}');

                  // Check if widget is still mounted before accessing context
                  if (!mounted) return;

                  // Close loading dialog first
                  Navigator.of(context).pop();

                  // Reload documents after deletion
                  _loadDocuments();

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${document.name} başarıyla silindi'),
                      backgroundColor: AppColors.primaryBlue,
                    ),
                  );
                } else {
                  debugPrint('HATA: Kullanıcı ID null');
                  // Close loading dialog if userId is null
                  if (!mounted) return;
                  Navigator.of(context).pop();
                }
              } catch (e) {
                debugPrint('=== DOSYA SİLME HATASI ===');
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Belgelerim',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              debugPrint('=== FIREBASE BAĞLANTI TESTİ ===');
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
            onPressed: () {
              showSearch(
                context: context,
                delegate: DocumentSearchDelegate(_documents),
              );
            },
            icon: const Icon(Icons.search, color: AppColors.white),
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
                  Icon(
                    FontAwesomeIcons.fileCirclePlus,
                    size: 80,
                    color: AppColors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Henüz belge yüklenmemiş',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.grey.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İlk belgenizi yüklemek için + butonuna tıklayın',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                final document = _documents[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
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
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${document.type} • ${_formatFileSize(document.fileSize)}',
                          style: TextStyle(
                            color: AppColors.grey.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(document.uploadedAt),
                          style: TextStyle(
                            color: AppColors.grey.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'favorite':
                            _toggleFavorite(document);
                            break;
                          case 'delete':
                            _deleteFile(document);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'favorite',
                          child: Row(
                            children: [
                              Icon(
                                document.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: document.isFavorite
                                    ? Colors.red
                                    : AppColors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                document.isFavorite
                                    ? 'Favorilerden Çıkar'
                                    : 'Favorilere Ekle',
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text('Sil', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.more_vert,
                          color: AppColors.grey.withOpacity(0.6),
                        ),
                      ),
                    ),
                    onTap: () {
                      // Open document or show preview
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadFile,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Belge Yükle',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Color _getFileTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'txt':
        return Colors.grey;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.green;
      default:
        return AppColors.primaryBlue;
    }
  }

  IconData _getFileTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return FontAwesomeIcons.filePdf;
      case 'doc':
      case 'docx':
        return FontAwesomeIcons.fileWord;
      case 'txt':
        return FontAwesomeIcons.fileLines;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return FontAwesomeIcons.fileImage;
      default:
        return FontAwesomeIcons.file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class DocumentSearchDelegate extends SearchDelegate<Document?> {
  final List<Document> documents;

  DocumentSearchDelegate(this.documents);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredDocuments = documents
        .where((doc) => doc.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (filteredDocuments.isEmpty) {
      return const Center(child: Text('Aradığınız belge bulunamadı'));
    }

    return ListView.builder(
      itemCount: filteredDocuments.length,
      itemBuilder: (context, index) {
        final document = filteredDocuments[index];
        return ListTile(
          title: Text(document.name),
          subtitle: Text(document.type),
          onTap: () {
            close(context, document);
          },
        );
      },
    );
  }
}
