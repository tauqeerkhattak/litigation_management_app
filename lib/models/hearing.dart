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
      'date': date.toIso8601String(),
      'submitted': submitted,
      'happened': happened,
      'order': order,
      'nextDate': nextDate?.toIso8601String(),
    };
  }

  factory Hearing.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Hearing(
      id: docId ?? map['id'],
      caseId: map['caseId'],
      date: DateTime.parse(map['date']),
      submitted: map['submitted'] ?? '',
      happened: map['happened'] ?? '',
      order: map['order'] ?? '',
      nextDate: map['nextDate'] != null ? DateTime.parse(map['nextDate']) : null,
    );
  }
}
