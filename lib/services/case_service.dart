part of 'locator.dart';

class CaseService {
  CaseService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _caseCollection =>
      _db.collection('cases');

  CollectionReference<Map<String, dynamic>> get _hearingCollection =>
      _db.collection('hearings');

  Stream<List<Case>> streamCases() {
    final uid = _userId;
    if (uid == null) return Stream.value([]);

    return _caseCollection.where('userId', isEqualTo: uid).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return Case.fromMap(doc.data(), docId: doc.id);
      }).toList();
    });
  }

  Future<void> saveCase(Case c) async {
    final uid = _userId;
    if (uid == null) throw Exception("User not authenticated");

    final caseData = c.toMap();
    caseData['userId'] = uid;

    if (c.id == null || c.id!.isEmpty) {
      // Let Firebase generate the ID
      caseData.remove('id');
      await _caseCollection.add(caseData);
    } else {
      await _caseCollection.doc(c.id).set(caseData, SetOptions(merge: true));
    }
  }

  Future<void> deleteCase(String id) async {
    await _caseCollection.doc(id).delete();

    // Delete associated hearings
    final hearings = await _hearingCollection
        .where('caseId', isEqualTo: id)
        .get();
    for (var doc in hearings.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> addHearing(String caseId, Hearing hearing) async {
    final hearingData = hearing.toMap();
    hearingData['caseId'] = caseId;

    if (hearing.id == null || hearing.id!.isEmpty) {
      hearingData.remove('id');
      await _hearingCollection.add(hearingData);
    } else {
      await _hearingCollection
          .doc(hearing.id)
          .set(hearingData, SetOptions(merge: true));
    }

    await _updateCaseDates(caseId);
  }

  Future<void> _updateCaseDates(String caseId) async {
    final hearings = await _hearingCollection
        .where('caseId', isEqualTo: caseId)
        .orderBy('date', descending: true)
        .get();

    if (hearings.docs.isNotEmpty) {
      final latestHearingData = hearings.docs.first.data();
      final latestHearing = Hearing.fromMap(
        latestHearingData,
        docId: hearings.docs.first.id,
      );

      await _caseCollection.doc(caseId).update({
        'lastHearing': latestHearing.date.toIso8601String(),
        'nextHearing': latestHearing.nextDate?.toIso8601String(),
      });
    }
  }

  Stream<List<Hearing>> streamHearings(String caseId) {
    return _hearingCollection
        .where('caseId', isEqualTo: caseId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Hearing.fromMap(doc.data(), docId: doc.id))
              .toList();
        });
  }
}
