import 'package:flutter/material.dart';

class FilesScreen extends StatefulWidget {
  @override
  _FilesScreenState createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  List<DocumentItem> _documents = [
    DocumentItem(
      name: 'Boşanma Dilekçesi.pdf',
      type: 'PDF',
      size: '2.3 MB',
      category: 'Dilekçeler',
      dateModified: DateTime.now().subtract(Duration(days: 1)),
      icon: Icons.picture_as_pdf,
      color: Colors.red,
    ),
    DocumentItem(
      name: 'İş Sözleşmesi Taslağı.docx',
      type: 'DOCX',
      size: '1.8 MB',
      category: 'Sözleşmeler',
      dateModified: DateTime.now().subtract(Duration(days: 3)),
      icon: Icons.description,
      color: Colors.blue,
    ),
    DocumentItem(
      name: 'Mahkeme Kararı.jpg',
      type: 'JPG',
      size: '4.1 MB',
      category: 'Kararlar',
      dateModified: DateTime.now().subtract(Duration(days: 5)),
      icon: Icons.image,
      color: Colors.green,
    ),
    DocumentItem(
      name: 'Vekalet Sözleşmesi.pdf',
      type: 'PDF',
      size: '1.2 MB',
      category: 'Sözleşmeler',
      dateModified: DateTime.now().subtract(Duration(days: 8)),
      icon: Icons.picture_as_pdf,
      color: Colors.red,
    ),
  ];

  String _selectedCategory = 'Tümü';
  final List<String> _categories = ['Tümü', 'Dilekçeler', 'Sözleşmeler', 'Kararlar', 'Diğer'];

  List<DocumentItem> get _filteredDocuments {
    if (_selectedCategory == 'Tümü') {
      return _documents;
    }
    return _documents.where((doc) => doc.category == _selectedCategory).toList();
  }

  void _showAddDocumentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Belge Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Fotoğraf Çek'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kamera açılıyor...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Galeri açılıyor...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_upload),
                title: const Text('Dosya Yükle'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dosya seçici açılıyor...')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Belgelerim'),
        backgroundColor: const Color(0xFF2D3E50),
      ),
      body: Column(
        children: [
          // Kategori filtreleri
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: const Color(0xFF2D3E50),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Belge listesi
          Expanded(
            child: _filteredDocuments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Bu kategoride belge yok',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredDocuments.length,
                    itemBuilder: (context, index) {
                      final document = _filteredDocuments[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: document.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(document.icon, color: document.color),
                          ),
                          title: Text(
                            document.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${document.type} • ${document.size}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${document.dateModified.day}/${document.dateModified.month}/${document.dateModified.year}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  document.category,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'open',
                                child: Row(
                                  children: [
                                    Icon(Icons.open_in_new),
                                    SizedBox(width: 8),
                                    Text('Aç'),
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
                                case 'open':
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${document.name} açılıyor...')),
                                  );
                                  break;
                                case 'share':
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${document.name} paylaşılıyor...')),
                                  );
                                  break;
                                case 'delete':
                                  setState(() {
                                    _documents.remove(document);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Belge silindi')),
                                  );
                                  break;
                              }
                            },
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${document.name} açılıyor...')),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDocumentDialog,
        backgroundColor: const Color(0xFF2D3E50),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DocumentItem {
  final String name;
  final String type;
  final String size;
  final String category;
  final DateTime dateModified;
  final IconData icon;
  final Color color;

  DocumentItem({
    required this.name,
    required this.type,
    required this.size,
    required this.category,
    required this.dateModified,
    required this.icon,
    required this.color,
  });
}
