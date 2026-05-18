import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_document.dart';
import '../models/case_model.dart';
import '../models/hearing.dart';
import '../services/locator.dart';
import 'base_view_model.dart';

class CaseViewModel extends BaseViewModel<List<Case>> {
  CaseViewModel() : super([]);

  @override
  void init() {
    super.init();
    _loadCases();
  }

  Future<void> _loadCases() async {
    final storage = locator<StorageService>();
    final loadedCases = await storage.loadCases();
    if (loadedCases.isEmpty) {
      state = _initialCases;
      await storage.saveCases(state);
    } else {
      state = loadedCases;
    }
  }

  static final List<Case> _initialCases = [
    Case(
      id: "c1",
      caseNo: "W.P. 2341",
      year: 2024,
      court: "High Court",
      bench: "Single Bench",
      title: "Ghulam Hussain vs Deputy Commissioner Sukkur",
      parties: "Ghulam Hussain (Petitioner) / DC Sukkur (Respondent)",
      firstHearing: DateTime(2024, 3, 10),
      lastHearing: DateTime(2025, 4, 22),
      nextHearing: DateTime(2025, 5, 19),
      status: "Active",
      nature: "General Recruitment",
      notes:
          "Service matter. Employee claims wrongful termination. Parawise comments already submitted.",
      hearings: [
        Hearing(
          id: "h1",
          date: DateTime(2025, 4, 22),
          submitted: "Compliance report",
          happened: "Court examined parawise comments",
          order: "Case adjourned to 19-May-2025",
          nextDate: DateTime(2025, 5, 19),
        ),
      ],
      documents: [
        AppDocument(
          id: "d1",
          type: "Parawise Comments",
          name: "PC dated 15-Mar-2024",
          uploadedAt: DateTime(2024, 3, 15),
          size: "245 KB",
        ),
      ],
    ),
    Case(
      id: "c2",
      caseNo: "C.A. 112",
      year: 2023,
      court: "Civil Court",
      bench: "Single Bench",
      title: "Muhammad Rafiq vs Revenue Department",
      parties: "Muhammad Rafiq (Plaintiff) / Revenue Dept (Defendant)",
      firstHearing: DateTime(2023, 7, 15),
      lastHearing: DateTime(2025, 3, 1),
      nextHearing: DateTime.now().add(const Duration(days: 2)),
      status: "Stay Granted",
      nature: "Revenue (Rohri)",
      notes: "Land dispute. Stay order in effect. Written statement submitted.",
      hearings: [],
      documents: [],
    ),
  ];

  Future<void> _save() async {
    await locator<StorageService>().saveCases(state);
  }

  void addCase(Case newCase) {
    state = [...state, newCase];
    _save();
  }

  void updateCase(Case updatedCase) {
    state = [
      for (final c in state)
        if (c.id == updatedCase.id) updatedCase else c,
    ];
    _save();
  }

  void addHearing(String caseId, Hearing hearing) {
    state = [
      for (final c in state)
        if (c.id == caseId)
          c.copyWith(
            hearings: [...c.hearings, hearing],
            lastHearing: hearing.date,
            nextHearing: hearing.nextDate ?? c.nextHearing,
          )
        else
          c,
    ];

    if (hearing.nextDate != null) {
      final c = state.firstWhere((e) => e.id == caseId);
      locator<NotificationService>().scheduleHearingReminder(
        c.id.hashCode,
        c.caseNo,
        hearing.nextDate!,
      );
    }

    _save();
  }

  void addDocument(String caseId, AppDocument doc) {
    state = [
      for (final c in state)
        if (c.id == caseId) c.copyWith(documents: [...c.documents, doc]) else c,
    ];
    _save();
  }
}

final caseProvider = NotifierProvider<CaseViewModel, List<Case>>(() {
  return CaseViewModel();
});

final searchQueryProvider = Provider.autoDispose<String>((ref) => "");
final filterStatusProvider = Provider.autoDispose<String>((ref) => "All");

final filteredCasesProvider = Provider<List<Case>>((ref) {
  final cases = ref.watch(caseProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final filterStatus = ref.watch(filterStatusProvider);

  return cases.where((c) {
    final matchesQuery =
        c.caseNo.toLowerCase().contains(query) ||
        c.title.toLowerCase().contains(query);
    final matchesStatus = filterStatus == "All" || c.status == filterStatus;
    return matchesQuery && matchesStatus;
  }).toList();
});

final urgentCasesCountProvider = Provider<int>((ref) {
  final cases = ref.watch(caseProvider);
  return cases.where((c) {
    if (c.nextHearing == null) return false;
    final diff = c.nextHearing!.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 3;
  }).length;
});
