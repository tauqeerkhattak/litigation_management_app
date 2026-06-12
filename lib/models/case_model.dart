import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/constants.dart';
import 'app_document.dart';

class Case {
  final String? id;
  final String? userId;
  final String caseNo;
  final int year;
  final Court court;
  final Bench bench;
  final String title;
  final List<String> plaintiffs;
  final List<String> respondents;
  final DateTime? firstHearing;
  final DateTime? lastHearing;
  final DateTime? nextHearing;
  final CaseStatus status;
  final String notes;
  final CaseNature nature;
  final Department? department;
  final Taluka? taluka;
  final List<AppDocument> documents;

  Case({
    this.id,
    this.userId,
    required this.caseNo,
    required this.year,
    required this.court,
    required this.bench,
    required this.title,
    required this.plaintiffs,
    required this.respondents,
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

  String get parties => "${plaintiffs.join(', ')} vs ${respondents.join(', ')}";

  Case copyWith({
    String? id,
    String? userId,
    String? caseNo,
    int? year,
    Court? court,
    Bench? bench,
    String? title,
    List<String>? plaintiffs,
    List<String>? respondents,
    DateTime? firstHearing,
    DateTime? lastHearing,
    DateTime? nextHearing,
    CaseStatus? status,
    String? notes,
    CaseNature? nature,
    Department? department,
    Taluka? taluka,
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
      plaintiffs: plaintiffs ?? this.plaintiffs,
      respondents: respondents ?? this.respondents,
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
      'id': id,
      'user_id': userId,
      'case_no': caseNo,
      'year': year,
      'court': court.name,
      'bench': bench.name,
      'title': title,
      'plaintiffs': plaintiffs,
      'respondents': respondents,
      'first_hearing': firstHearing != null
          ? Timestamp.fromDate(firstHearing!)
          : null,
      'last_hearing': lastHearing != null
          ? Timestamp.fromDate(lastHearing!)
          : null,
      'next_hearing': nextHearing != null
          ? Timestamp.fromDate(nextHearing!)
          : null,
      'status': status.name,
      'notes': notes,
      'nature': nature.name,
      if (department != null) 'department': department!.name,
      if (taluka != null) 'taluka': taluka!.name,
      'documents': documents.map((x) => x.toMap()).toList(),
    };
  }

  factory Case.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Case(
      id: docId ?? map['id'],
      userId: map['user_id'],
      caseNo: map['case_no'] ?? '',
      year: map['year'] ?? DateTime.now().year,
      court: Court.values.byName(map['court'] ?? 'other'),
      bench: Bench.values.byName(map['bench'] ?? 'singleBench'),
      title: map['title'] ?? '',
      plaintiffs: map['plaintiffs'] != null
          ? List<String>.from(map['plaintiffs'])
          : [],
      respondents: map['respondents'] != null
          ? List<String>.from(map['respondents'])
          : [],
      firstHearing: (map['first_hearing'] as Timestamp?)?.toDate(),
      lastHearing: (map['last_hearing'] as Timestamp?)?.toDate(),
      nextHearing: (map['next_hearing'] as Timestamp?)?.toDate(),
      status: CaseStatus.values.byName(map['status'] ?? 'active'),
      notes: map['notes'] ?? '',
      nature: CaseNature.values.byName(map['nature'] ?? 'other'),
      department: map['department'] != null
          ? Department.values.byName(map['department'])
          : null,
      taluka: map['taluka'] != null
          ? Taluka.values.byName(map['taluka'])
          : null,
      documents: List<AppDocument>.from(
        map['documents']?.map((x) => AppDocument.fromMap(x)) ?? [],
      ),
    );
  }
}
