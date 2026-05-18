class AppDocument {
  final String id;
  final String type;
  final String name;
  final String? fileName;
  final DateTime uploadedAt;
  final String? size;

  AppDocument({
    required this.id,
    required this.type,
    required this.name,
    this.fileName,
    required this.uploadedAt,
    this.size,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'fileName': fileName,
      'uploadedAt': uploadedAt.toIso8601String(),
      'size': size,
    };
  }

  factory AppDocument.fromMap(Map<String, dynamic> map) {
    return AppDocument(
      id: map['id'],
      type: map['type'],
      name: map['name'],
      fileName: map['fileName'],
      uploadedAt: DateTime.parse(map['uploadedAt']),
      size: map['size'],
    );
  }
}
