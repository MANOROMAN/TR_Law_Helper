import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/app_colors.dart';

class DocumentsScreen extends StatefulWidget {
  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<Document> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadSampleDocuments();
  }

  void _loadSampleDocuments() {
    _documents = [
      Document('Dava Dilekçesi.pdf', 'PDF', '2.3 MB', DateTime.now().subtract(const Duration(days: 2))),
      Document('Tanık Beyanı.docx', 'DOCX', '1.1 MB', DateTime.now().subtract(const Duration(days: 5))),
      Document('Mahkeme Kararı.pdf', 'PDF', '3.7 MB', DateTime.now().subtract(const Duration(days: 10))),
      Document('Sözleşme.pdf', 'PDF', '1.8 MB', DateTime.now().subtract(const Duration(days: 15))),
    ];
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'png'],
      );

      if (result != null) {
        final file = result.files.first;
        setState(() {
          _documents.add(Document(
            file.name,
            file.extension?.toUpperCase() ?? 'UNKNOWN',
            '${(file.size / 1024 / 1024).toStringAsFixed(1)} MB',
            DateTime.now(),
          ));
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${file.name} başarıyla yüklendi'),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dosya yüklenirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteDocument(Document document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dosyayı Sil'),
        content: Text('${document.name} dosyasını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _documents.remove(document);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${document.name} silindi'),
                  backgroundColor: AppColors.primaryBlue,
                ),
              );
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
            icon: const Icon(Icons.search),
            onPressed: () {
              // Arama fonksiyonu
            },
          ),
        ],
      ),
      body: _documents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 80,
                    color: AppColors.grey,
                  ),
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
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.grey,
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
                          '${document.type} • ${document.size}',
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Yüklenme: ${_formatDate(document.uploadDate)}',
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
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
                              Text('Sil', style: TextStyle(color: Colors.red)),
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
    switch (type) {
      case 'PDF':
        return Colors.red;
      case 'DOCX':
      case 'DOC':
        return Colors.blue;
      case 'TXT':
        return Colors.grey;
      case 'JPG':
      case 'PNG':
        return Colors.green;
      default:
        return AppColors.primaryBlue;
    }
  }

  IconData _getFileTypeIcon(String type) {
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'DOCX':
      case 'DOC':
        return Icons.description;
      case 'TXT':
        return Icons.text_snippet;
      case 'JPG':
      case 'PNG':
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

class Document {
  final String name;
  final String type;
  final String size;
  final DateTime uploadDate;

  Document(this.name, this.type, this.size, this.uploadDate);
}
