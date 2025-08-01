import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DocumentsScreen extends StatefulWidget {
  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<DocumentItem> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dosyalarım"),
        backgroundColor: const Color(0xFF2D3E50),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _pickFile,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        backgroundColor: const Color(0xFF2D3E50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _documents.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                return _buildDocumentCard(_documents[index], index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.folderOpen,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Henüz belge yüklenmemiş",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Belgelerinizi yüklemek için + butonuna basın",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.upload_file),
            label: const Text("Belge Yükle"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3E50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(DocumentItem document, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getFileTypeColor(document.extension),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getFileTypeIcon(document.extension),
            color: Colors.white,
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
              document.category,
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Yüklenme: ${document.uploadDate}",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _deleteDocument(index);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sil'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFileTypeColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getFileTypeIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return FontAwesomeIcons.filePdf;
      case 'doc':
      case 'docx':
        return FontAwesomeIcons.fileWord;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return FontAwesomeIcons.fileImage;
      default:
        return FontAwesomeIcons.file;
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        await _showCategoryDialog(result.files.single);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dosya seçerken bir hata oluştu: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showCategoryDialog(PlatformFile file) async {
    String? selectedCategory;
    final categories = [
      'Sözleşme',
      'Dava Dosyası',
      'Kimlik Belgesi',
      'Mali Belge',
      'Miras Belgesi',
      'Boşanma Belgesi',
      'Diğer'
    ];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Belge Kategorisi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.map((category) => 
            RadioListTile<String>(
              title: Text(category),
              value: category,
              groupValue: selectedCategory,
              onChanged: (value) {
                selectedCategory = value;
                Navigator.of(context).pop();
              },
            ),
          ).toList(),
        ),
      ),
    );

    if (selectedCategory != null) {
      _addDocument(file, selectedCategory!);
    }
  }

  void _addDocument(PlatformFile file, String category) {
    final document = DocumentItem(
      name: file.name,
      extension: file.extension ?? '',
      category: category,
      uploadDate: DateTime.now().toString().substring(0, 10),
      path: file.path ?? '',
    );

    setState(() {
      _documents.add(document);
    });

    _saveDocuments();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Belge başarıyla yüklendi'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteDocument(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Belgeyi Sil'),
        content: const Text('Bu belgeyi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _documents.removeAt(index);
              });
              _saveDocuments();
              Navigator.of(context).pop();
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson = prefs.getString('documents') ?? '[]';
    final documentsList = jsonDecode(documentsJson) as List;
    
    setState(() {
      _documents = documentsList
          .map((doc) => DocumentItem.fromJson(doc))
          .toList();
    });
  }

  Future<void> _saveDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson = jsonEncode(
      _documents.map((doc) => doc.toJson()).toList(),
    );
    await prefs.setString('documents', documentsJson);
  }
}

class DocumentItem {
  final String name;
  final String extension;
  final String category;
  final String uploadDate;
  final String path;

  DocumentItem({
    required this.name,
    required this.extension,
    required this.category,
    required this.uploadDate,
    required this.path,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'extension': extension,
      'category': category,
      'uploadDate': uploadDate,
      'path': path,
    };
  }

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      name: json['name'],
      extension: json['extension'],
      category: json['category'],
      uploadDate: json['uploadDate'],
      path: json['path'],
    );
  }
}
