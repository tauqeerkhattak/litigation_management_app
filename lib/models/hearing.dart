class Hearing {
  final String id;
  final DateTime date;
  final String submitted;
  final String happened;
  final String order;
  final DateTime? nextDate;

  Hearing({
    required this.id,
    required this.date,
    required this.submitted,
    required this.happened,
    required this.order,
    this.nextDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'submitted': submitted,
      'happened': happened,
      'order': order,
      'nextDate': nextDate?.toIso8601String(),
    };
  }

  factory Hearing.fromMap(Map<String, dynamic> map) {
    return Hearing(
      id: map['id'],
      date: DateTime.parse(map['date']),
      submitted: map['submitted'],
      happened: map['happened'],
      order: map['order'],
      nextDate: map['nextDate'] != null ? DateTime.parse(map['nextDate']) : null,
    );
  }
}
