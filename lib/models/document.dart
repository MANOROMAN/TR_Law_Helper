import 'package:cloud_firestore/cloud_firestore.dart';

class Document {
  final String id;
  final String name;
  final String type;
  final String size;
  final DateTime uploadDate;
  final String downloadURL;

  Document({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.uploadDate,
    required this.downloadURL,
  });

  // Firestore'dan veri oluşturma
  factory Document.fromFirestore(Map<String, dynamic> data, String id) {
    return Document(
      id: id,
      name: data['name'] ?? 'Unknown',
      type: data['type'] ?? 'Unknown',
      size: data['size'] ?? 'Unknown',
      uploadDate: (data['uploadDate'] as Timestamp).toDate(),
      downloadURL: data['downloadURL'] ?? 'Unknown',
    );
  }

  // Firestore'a veri gönderme
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'size': size,
      'uploadDate': uploadDate,
      'downloadURL': downloadURL,
    };
  }

  // Dosya boyutunu formatlama
  String get formattedFileSize {
    int fileSize = int.tryParse(size) ?? 0;
    if (fileSize < 1024) {
      return '${fileSize} B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // Dosya uzantısını alma
  String get fileExtension {
    List<String> parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  // Dosya tipini belirleme
  String get fileTypeIcon {
    switch (fileExtension) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return '🖼️';
      case 'mp4':
      case 'avi':
      case 'mov':
        return '🎥';
      case 'mp3':
      case 'wav':
        return '🎵';
      default:
        return '📎';
    }
  }

  // Dosya tipini Türkçe olarak alma
  String get fileTypeName {
    switch (fileExtension) {
      case 'pdf':
        return 'PDF Belgesi';
      case 'doc':
      case 'docx':
        return 'Word Belgesi';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'Resim';
      case 'mp4':
      case 'avi':
      case 'mov':
        return 'Video';
      case 'mp3':
      case 'wav':
        return 'Ses Dosyası';
      default:
        return 'Dosya';
    }
  }

  // Yüklenme tarihini formatlama
  String get formattedUploadDate {
    DateTime now = DateTime.now();
    Duration difference = now.difference(uploadDate);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} dakika önce';
      } else {
        return '${difference.inHours} saat önce';
      }
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${uploadDate.day}/${uploadDate.month}/${uploadDate.year}';
    }
  }

  @override
  String toString() {
    return 'Document(id: $id, name: $name, type: $type, size: $size)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Document && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
