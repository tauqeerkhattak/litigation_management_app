import 'app_document.dart';
import 'hearing.dart';

class Case {
  final String? id;
  final String? userId;
  final String caseNo;
  final int year;
  final String court;
  final String bench;
  final String title;
  final String parties;
  final DateTime? firstHearing;
  final DateTime? lastHearing;
  final DateTime? nextHearing;
  final String status;
  final String notes;
  final String nature;
  final String? department;
  final String? taluka;
  final List<AppDocument> documents;

  Case({
    this.id,
    this.userId,
    required this.caseNo,
    required this.year,
    required this.court,
    required this.bench,
    required this.title,
    required this.parties,
    this.firstHearing,
    this.lastHearing,
    this.nextHearing,
    required this.status,
    required this.notes,
    required this.nature,
    this.department,
    this.taluka,
    required this.documents,
  });

  Case copyWith({
    String? id,
    String? userId,
    String? caseNo,
    int? year,
    String? court,
    String? bench,
    String? title,
    String? parties,
    DateTime? firstHearing,
    DateTime? lastHearing,
    DateTime? nextHearing,
    String? status,
    String? notes,
    String? nature,
    String? department,
    String? taluka,
    List<AppDocument>? documents,
  }) {
    return Case(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      caseNo: caseNo ?? this.caseNo,
      year: year ?? this.year,
      court: court ?? this.court,
      bench: bench ?? this.bench,
      title: title ?? this.title,
      parties: parties ?? this.parties,
      firstHearing: firstHearing ?? this.firstHearing,
      lastHearing: lastHearing ?? this.lastHearing,
      nextHearing: nextHearing ?? this.nextHearing,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      nature: nature ?? this.nature,
      department: department ?? this.department,
      taluka: taluka ?? this.taluka,
      documents: documents ?? this.documents,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      'caseNo': caseNo,
      'year': year,
      'court': court,
      'bench': bench,
      'title': title,
      'parties': parties,
      'firstHearing': firstHearing?.toIso8601String(),
      'lastHearing': lastHearing?.toIso8601String(),
      'nextHearing': nextHearing?.toIso8601String(),
      'status': status,
      'notes': notes,
      'nature': nature,
      'department': department,
      'taluka': taluka,
      'documents': documents.map((x) => x.toMap()).toList(),
    };
  }

  factory Case.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Case(
      id: docId ?? map['id'],
      userId: map['userId'],
      caseNo: map['caseNo'] ?? '',
      year: map['year'] ?? DateTime.now().year,
      court: map['court'] ?? '',
      bench: map['bench'] ?? '',
      title: map['title'] ?? '',
      parties: map['parties'] ?? '',
      firstHearing: map['firstHearing'] != null
          ? DateTime.parse(map['firstHearing'])
          : null,
      lastHearing: map['lastHearing'] != null
          ? DateTime.parse(map['lastHearing'])
          : null,
      nextHearing: map['nextHearing'] != null
          ? DateTime.parse(map['nextHearing'])
          : null,
      status: map['status'] ?? 'Active',
      notes: map['notes'] ?? '',
      nature: map['nature'] ?? '',
      department: map['department'],
      taluka: map['taluka'],
      documents: List<AppDocument>.from(
        map['documents']?.map((x) => AppDocument.fromMap(x)) ?? [],
      ),
    );
  }
}
