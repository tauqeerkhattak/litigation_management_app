part of 'locator.dart';

class CaseService {
  CaseService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Stream<List<Case>> streamCases() {
    final uid = _userId;
    if (uid == null) return Stream.value([]);

    return _db.collection('cases').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Case.fromMap(doc.data(), docId: doc.id);
      }).toList();
    });
  }

  Future<void> saveCase(Case c) async {
    final uid = _userId;
    if (uid == null) throw Exception("User not authenticated");

    final caseData = c.copyWith(userId: uid);

    if (c.id == null || c.id!.isEmpty) {
      final doc = _db.collection('cases').doc();
      await doc.set(caseData.copyWith(id: doc.id).toMap());
    } else {
      await _db
          .collection('cases')
          .doc(c.id)
          .set(caseData.toMap(), SetOptions(merge: true));
    }
  }

  Future<void> deleteCase(String id) async {
    await _db.collection('cases').doc(id).delete();

    // Delete associated hearings
    final hearings = await _db
        .collection('hearings')
        .where('case_id', isEqualTo: id)
        .get();
    for (var doc in hearings.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> addHearing(String caseId, Hearing hearing) async {
    final hearingData = hearing.copyWith(caseId: caseId);

    if (hearing.id == null || hearing.id!.isEmpty) {
      final doc = _db.collection('hearings').doc();
      await doc.set(hearingData.copyWith(id: doc.id).toMap());
    } else {
      await _db
          .collection('hearings')
          .doc(hearing.id)
          .set(hearingData.toMap(), SetOptions(merge: true));
    }

    await _updateCaseDates(caseId);
  }

  Future<void> _updateCaseDates(String caseId) async {
    final hearings = await _db
        .collection('hearings')
        .where('case_id', isEqualTo: caseId)
        .orderBy('date', descending: true)
        .get();

    if (hearings.docs.isNotEmpty) {
      final latestHearingData = hearings.docs.first.data();
      final latestHearing = Hearing.fromMap(
        latestHearingData,
        docId: hearings.docs.first.id,
      );
      await _db.collection('cases').doc(caseId).update({
        'last_hearing': Timestamp.fromDate(latestHearing.date),
        'next_hearing': latestHearing.nextDate != null
            ? Timestamp.fromDate(latestHearing.nextDate!)
            : null,
      });
    }
  }

  Stream<List<Hearing>> streamHearings(String caseId) {
    return _db
        .collection('hearings')
        .where('case_id', isEqualTo: caseId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Hearing.fromMap(doc.data(), docId: doc.id))
              .toList();
        });
  }
}
