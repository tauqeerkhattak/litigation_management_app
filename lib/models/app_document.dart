import '../utils/constants.dart';

class AppDocument {
  final String? id;
  final DocumentType type;
  final String name;
  final String? fileName;
  final DateTime uploadedAt;
  final String? size;

  AppDocument({
    this.id,
    required this.type,
    required this.name,
    this.fileName,
    required this.uploadedAt,
    this.size,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'fileName': fileName,
      'uploadedAt': uploadedAt.toIso8601String(),
      'size': size,
    };
  }

  factory AppDocument.fromMap(Map<String, dynamic> map) {
    return AppDocument(
      id: map['id'],
      type: DocumentType.values.byName(map['type'] ?? 'other'),
      name: map['name'],
      fileName: map['fileName'],
      uploadedAt: DateTime.parse(map['uploadedAt']),
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
      fileName: fileName ?? this.fileName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      size: size ?? this.size,
    );
  }
}
