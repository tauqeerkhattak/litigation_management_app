import 'dart:async';
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litigation_management_app/exceptions/app_exception.dart';
import 'package:litigation_management_app/utils/constants.dart';
import 'package:litigation_management_app/viewmodels/auth_viewmodel.dart';

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
        log('ERROR: $error');
        state = state.copyWith(isLoading: false);
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

  void addDocument(String caseId, DocumentType selectedType) async {
    await runSafely(() async {
      state = state.copyWith(isLoading: true);
    //  final FilePickerResult? result = await FilePicker.pickFiles(
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'txt'],
      );

      if (result == null || result.files.isEmpty) {
        throw AppException('No document selected!');
      }

      final pickedFile = result.files.first;

      final userId = ref.read(authProvider).user!.id;
      final url = await locator<FileService>().uploadFile(
        userId,
        caseId,
        pickedFile,
      );
      final newDoc = AppDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: selectedType,
        name: pickedFile.name,
        url: url,
        uploadedAt: DateTime.now(),
        size: pickedFile.size > 0
            ? "${(pickedFile.size / 1024).toStringAsFixed(1)} KB"
            : "200 KB",
      );
      final currentCase = state.cases.firstWhere((c) => c.id == caseId);
      final updatedCase = currentCase.copyWith(
        documents: [...currentCase.documents, newDoc],
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
      final userId = ref.read(authProvider).user!.id;
      await locator<FileService>().deleteFile(userId, caseId, docToDelete.url!);

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
