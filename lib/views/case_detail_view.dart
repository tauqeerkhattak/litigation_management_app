import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/app_document.dart';
import '../models/case_model.dart';
import '../services/locator.dart';
import '../utils/constants.dart';
import '../viewmodels/case_viewmodel.dart';
import 'widgets/hearing_form_dialog.dart';

class CaseDetailView extends ConsumerStatefulWidget {
  final String caseId;

  const CaseDetailView({super.key, required this.caseId});

  @override
  ConsumerState<CaseDetailView> createState() => _CaseDetailViewState();
}

class _CaseDetailViewState extends ConsumerState<CaseDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final cases = ref.watch(caseProvider);
    final c = cases.firstWhere(
      (element) => element.id == widget.caseId,
      orElse: () => cases.first,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              c.title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            Text(
              "${c.caseNo} / ${c.year} • ${c.court}",
              style: const TextStyle(fontSize: 10, color: AppColors.muted),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.gold,
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "Hearings"),
            Tab(text: "Documents"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(c),
          _buildHearingsTab(c),
          _buildDocumentsTab(c),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Case c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoGrid([
            ["Parties", c.parties],
            ["Court", c.court],
            ["Bench", c.bench],
            ["Nature", c.nature],
            ["Status", c.status],
            [
              "Next Hearing",
              c.nextHearing != null
                  ? DateFormat('dd-MMM-yyyy').format(c.nextHearing!)
                  : '—',
            ],
          ]),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "NOTES / BACKGROUND",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  c.notes,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(List<List<String>> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              items[i][0].toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              items[i][1],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHearingsTab(Case c) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _showAddHearingDialog,
                icon: const Icon(Icons.add),
                label: const Text("Add Hearing"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navy,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: c.hearings.length,
            itemBuilder: (ctx, i) {
              final h = c.hearings.reversed.toList()[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "📅 ${DateFormat('dd-MMM-yyyy').format(h.date)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.navy,
                          ),
                        ),
                        if (h.nextDate != null)
                          Text(
                            "Next: ${DateFormat('dd-MMM-yyyy').format(h.nextDate!)}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildHearingDetail(
                      "Submitted",
                      h.submitted,
                      AppColors.gold,
                    ),
                    _buildHearingDetail(
                      "Proceedings",
                      h.happened,
                      AppColors.navy,
                    ),
                    _buildHearingDetail(
                      "Court Order",
                      h.order,
                      const Color(0xFF2980B9),
                      isOrder: true,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHearingDetail(
    String label,
    String text,
    Color color, {
    bool isOrder = false,
  }) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: isOrder ? const EdgeInsets.all(8) : null,
            decoration: isOrder
                ? BoxDecoration(
                    color: const Color(0xFFEEF6FB),
                    border: const Border(
                      left: BorderSide(color: Color(0xFF2980B9), width: 3),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Text(text, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(Case c) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => _uploadDocument(c.id),
                icon: const Icon(Icons.upload_file),
                label: const Text("Upload Document"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: c.documents.length,
            itemBuilder: (ctx, i) {
              final d = c.documents[i];
              return Card(
                color: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: ListTile(
                  leading: const Icon(Icons.description, color: AppColors.navy),
                  title: Text(
                    d.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    "${d.type} • ${DateFormat('dd-MMM-yyyy').format(d.uploadedAt)}",
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: IconButton(
                    onPressed: () => _viewDocument(d),
                    icon: const Icon(
                      Icons.visibility,
                      size: 18,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _viewDocument(AppDocument doc) async {
    if (doc.fileName != null) {
      // final result = await OpenFile.open(doc.fileName);
      // if (result.type != ResultType.done) {
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text("Could not open file: ${result.message}")),
      //     );
      //   }
      // }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("File path not found.")));
    }
  }

  void _showAddHearingDialog() {
    showDialog(
      context: context,
      builder: (ctx) => HearingFormDialog(
        onSave: (h) {
          ref.read(caseProvider.notifier).addHearing(widget.caseId, h);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Future<void> _uploadDocument(String caseId) async {
    FilePickerResult? result = await FilePicker.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      if (file.path != null) {
        final savedPath = await locator<FileService>().saveFile(
          File(file.path!),
        );

        final newDoc = AppDocument(
          id: const Uuid().v4(),
          type: DOC_TYPES[0],
          name: file.name,
          fileName: savedPath,
          uploadedAt: DateTime.now(),
          size: "${(file.size / 1024).toStringAsFixed(1)} KB",
        );
        ref.read(caseProvider.notifier).addDocument(caseId, newDoc);
      }
    }
  }
}
