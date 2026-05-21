import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_document.dart';
import '../models/case_model.dart';
import '../models/hearing.dart';
import '../services/locator.dart';
import 'base_view_model.dart';

class CaseState {
  final List<Case> cases;
  final bool isLoading;

  CaseState({this.cases = const [], this.isLoading = false});

  CaseState copyWith({List<Case>? cases, bool? isLoading}) {
    return CaseState(
      cases: cases ?? this.cases,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CaseViewModel extends BaseViewModel<CaseState> {
  CaseViewModel() : super(CaseState());
  StreamSubscription? _casesSubscription;

  @override
  void init() {
    super.init();
    _listenToCases();
  }

  void _listenToCases() {
    state = state.copyWith(isLoading: true);
    _casesSubscription?.cancel();
    _casesSubscription = locator<CaseService>().streamCases().listen(
      (cases) {
        state = state.copyWith(cases: cases, isLoading: false);
      },
      onError: (error) {
        state = state.copyWith(isLoading: false);
        // Handle error appropriately
      },
    );
  }

  @override
  void dispose() {
    _casesSubscription?.cancel();
    super.dispose();
  }

  Future<void> addCase(Case newCase) async {
    state = state.copyWith(isLoading: true);
    await runSafely(() async {
      await locator<CaseService>().saveCase(newCase);
    });
    state = state.copyWith(isLoading: false);
  }

  Future<void> updateCase(Case updatedCase) async {
    state = state.copyWith(isLoading: true);
    await runSafely(() async {
      await locator<CaseService>().saveCase(updatedCase);
    });
    state = state.copyWith(isLoading: false);
  }

  Future<void> deleteCase(String caseId) async {
    state = state.copyWith(isLoading: true);
    await runSafely(() async {
      await locator<CaseService>().deleteCase(caseId);
    });
    state = state.copyWith(isLoading: false);
  }

  Future<void> addHearing(String caseId, Hearing hearing) async {
    state = state.copyWith(isLoading: true);
    await runSafely(() async {
      await locator<CaseService>().addHearing(caseId, hearing);

      // We might still want to schedule notifications here
      if (hearing.nextDate != null) {
        final currentCase = state.cases.firstWhere((c) => c.id == caseId);
        locator<NotificationService>().scheduleHearingReminder(
          caseId.hashCode,
          currentCase.caseNo,
          hearing.nextDate!,
        );
      }
    });
    state = state.copyWith(isLoading: false);
  }

  // Document management still uses the Case document's list for now
  // unless the user wants documents global too.
  // Given the request "same for hearing as well", I'll stick to
  // moving hearings but keeping documents in Case for now unless asked.
  // Actually, let's keep it consistent.

  void addDocument(String caseId, AppDocument doc) async {
    state = state.copyWith(isLoading: true);
    await runSafely(() async {
      final currentCase = state.cases.firstWhere((c) => c.id == caseId);
      final updatedCase = currentCase.copyWith(
        documents: [...currentCase.documents, doc],
      );
      await locator<CaseService>().saveCase(updatedCase);
    });
    state = state.copyWith(isLoading: false);
  }

  Future<void> deleteDocument(String caseId, String? docId) async {
    state = state.copyWith(isLoading: true);
    await runSafely(() async {
      final currentCase = state.cases.firstWhere((c) => c.id == caseId);
      final updatedDocs = currentCase.documents
          .where((d) => d.id != docId)
          .toList();

      final docToDelete = currentCase.documents.firstWhere(
        (d) => d.id == docId,
      );
      if (docToDelete.fileName != null) {
        await locator<FileService>().deleteFile(docToDelete.fileName!);
      }

      final updatedCase = currentCase.copyWith(documents: updatedDocs);
      await locator<CaseService>().saveCase(updatedCase);
    });
    state = state.copyWith(isLoading: false);
  }

  Future<void> renameDocument(
    String caseId,
    String? docId,
    String newName,
  ) async {
    state = state.copyWith(isLoading: true);
    await runSafely(() async {
      final currentCase = state.cases.firstWhere((c) => c.id == caseId);
      final updatedDocs = currentCase.documents.map((doc) {
        if (doc.id == docId) {
          return doc.copyWith(name: newName);
        }
        return doc;
      }).toList();

      final updatedCase = currentCase.copyWith(documents: updatedDocs);
      await locator<CaseService>().saveCase(updatedCase);
    });
    state = state.copyWith(isLoading: false);
  }
}

final caseProvider = NotifierProvider<CaseViewModel, CaseState>(() {
  return CaseViewModel();
});

final hearingsProvider = StreamProvider.family<List<Hearing>, String>((
  ref,
  caseId,
) {
  return locator<CaseService>().streamHearings(caseId);
});

final urgentCasesCountProvider = Provider<int>((ref) {
  final caseState = ref.watch(caseProvider);
  return caseState.cases.where((c) {
    if (c.nextHearing == null) return false;
    final diff = c.nextHearing!.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 3;
  }).length;
});
