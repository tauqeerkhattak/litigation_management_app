import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/constants.dart';

class AppDocument {
  final String? id;
  final DocumentType type;
  final String name;
  final String? url;
  final DateTime uploadedAt;
  final String? size;

  AppDocument({
    this.id,
    required this.type,
    required this.name,
    this.url,
    required this.uploadedAt,
    this.size,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'fileName': url,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'size': size,
    };
  }

  factory AppDocument.fromMap(Map<String, dynamic> map) {
    return AppDocument(
      id: map['id'],
      type: DocumentType.values.byName(map['type'] ?? 'other'),
      name: map['name'],
      url: map['fileName'],
      uploadedAt: map['uploadedAt'].toDate(),
      size: map['size'],
    );
  }

  AppDocument copyWith({
    String? id,
    DocumentType? type,
    String? name,
    String? fileName,
    DateTime? uploadedAt,
    String? size,
  }) {
    return AppDocument(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      url: fileName ?? this.url,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      size: size ?? this.size,
    );
  }
}
