import 'package:cloud_firestore/cloud_firestore.dart';

class Hearing {
  final String? id;
  final String? caseId;
  final DateTime date;
  final String submitted;
  final String happened;
  final String order;
  final DateTime? nextDate;

  Hearing({
    this.id,
    this.caseId,
    required this.date,
    required this.submitted,
    required this.happened,
    required this.order,
    this.nextDate,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (caseId != null) 'caseId': caseId,
      'date': Timestamp.fromDate(date),
      'submitted': submitted,
      'happened': happened,
      'order': order,
      'nextDate': nextDate != null ? Timestamp.fromDate(nextDate!) : null,
    };
  }

  factory Hearing.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Hearing(
      id: docId ?? map['id'],
      caseId: map['caseId'],
      date: map['date'].toDate(),
      submitted: map['submitted'] ?? '',
      happened: map['happened'] ?? '',
      order: map['order'] ?? '',
      nextDate: map['nextDate']?.toDate(),
    );
  }
}
