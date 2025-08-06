import 'package:cloud_firestore/cloud_firestore.dart';

class Document {
  final String id;
  final String name;
  final String type;
  final String url;
  final int fileSize;
  final DateTime uploadedAt;
  final bool isFavorite;
  final String userId;

  Document({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.fileSize,
    required this.uploadedAt,
    this.isFavorite = false,
    required this.userId,
  });

  factory Document.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Document(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      url: data['url'] ?? '',
      fileSize: data['fileSize'] ?? 0,
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
      isFavorite: data['isFavorite'] ?? false,
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'url': url,
      'fileSize': fileSize,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'isFavorite': isFavorite,
      'userId': userId,
    };
  }

  Document copyWith({
    String? id,
    String? name,
    String? type,
    String? url,
    int? fileSize,
    DateTime? uploadedAt,
    bool? isFavorite,
    String? userId,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      url: url ?? this.url,
      fileSize: fileSize ?? this.fileSize,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      userId: userId ?? this.userId,
    );
  }

  String get formattedSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String get fileExtension {
    return type.toUpperCase();
  }
}
