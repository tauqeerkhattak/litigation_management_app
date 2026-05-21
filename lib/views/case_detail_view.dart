import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_document.dart';
import '../models/case_model.dart';
import '../models/hearing.dart';
import '../services/locator.dart';
import '../utils/constants.dart';
import '../viewmodels/case_viewmodel.dart';
import 'add_hearing_screen.dart';

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
    final caseState = ref.watch(caseProvider);
    final cases = caseState.cases;
    final isLoading = caseState.isLoading;

    if (cases.isEmpty && isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    final c = cases.firstWhere(
      (element) => element.id == widget.caseId,
      orElse: () =>
          cases.isNotEmpty ? cases.first : throw Exception("Case not found"),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              c.title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${c.caseNo} / ${c.year} - ${c.court}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _shareToWhatsApp(c),
            icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 20),
            tooltip: "Share via WhatsApp",
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.gold,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "Hearings"),
            Tab(text: "Documents"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : TabBarView(
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
    final List<List<String>> infoItems = [
      ["Parties", c.parties],
      ["Court", c.court],
      ["Bench", c.bench],
      ["Nature", c.nature],
    ];

    if (c.taluka != null && c.taluka!.isNotEmpty) {
      infoItems.add(["Taluka", c.taluka!]);
    }
    if (c.department != null && c.department!.isNotEmpty) {
      infoItems.add(["Department", c.department!]);
    }

    infoItems.addAll([
      ["Status", c.status],
      [
        "Next Hearing",
        c.nextHearing != null
            ? DateFormat('dd-MMM-yyyy').format(c.nextHearing!)
            : '—',
      ],
    ]);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoGrid(infoItems),
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
    final hearingsAsync = ref.watch(hearingsProvider(widget.caseId));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _showAddHearingScreen,
                icon: const Icon(Icons.add),
                label: const Text("Add Hearing"),
              ),
            ],
          ),
        ),
        Expanded(
          child: hearingsAsync.when(
            data: (hearings) => hearings.isEmpty
                ? const Center(child: Text("No hearings recorded yet"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: hearings.length,
                    itemBuilder: (ctx, i) {
                      final h = hearings[i];
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
                                  DateFormat('dd-MMM-yyyy').format(h.date),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.navy,
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (h.nextDate != null)
                                      Text(
                                        "Next: ${DateFormat('dd-MMM-yyyy').format(h.nextDate!)}",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () =>
                                          _shareHearingToWhatsApp(c, h),
                                      icon: const FaIcon(
                                        FontAwesomeIcons.whatsapp,
                                        size: 16,
                                        color: AppColors.green,
                                      ),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      tooltip: "Share Hearing details",
                                    ),
                                  ],
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
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
            error: (err, stack) => Center(child: Text("Error: $err")),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _viewDocument(d),
                        icon: const Icon(
                          Icons.visibility,
                          size: 18,
                          color: AppColors.gold,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 18),
                        onSelected: (value) {
                          if (c.id == null) {
                            return;
                          }
                          if (value == 'rename') {
                            _showRenameDialog(c.id!, d);
                          } else if (value == 'delete') {
                            _showDeleteConfirmDialog(c.id!, d);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'rename',
                            child: Text('Rename'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
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

  void _showRenameDialog(String caseId, AppDocument doc) {
    final controller = TextEditingController(text: doc.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Rename Document"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "New Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(caseProvider.notifier)
                    .renameDocument(caseId, doc.id, controller.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Rename"),
          ),
        ],
      ),
    );
  }


  void _showDeleteConfirmDialog(String caseId, AppDocument doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Document"),
        content: Text("Are you sure you want to delete '${doc.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              ref.read(caseProvider.notifier).deleteDocument(caseId, doc.id);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddHearingScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => AddHearingScreen(caseId: widget.caseId),
      ),
    );
  }

  Future<void> _uploadDocument(String? caseId) async {
    if (caseId == null) {
      return;
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    // FilePickerResult? result = await FilePicker.pickFiles();   //muneeb
    if (result != null) {
      PlatformFile file = result.files.first;
      if (file.path != null) {
        final savedPath = await locator<FileService>().saveFile(
          File(file.path!),
        );

        final newDoc = AppDocument(
          type: docTypesList[0],
          name: file.name,
          fileName: savedPath,
          uploadedAt: DateTime.now(),
          size: "${(file.size / 1024).toStringAsFixed(1)} KB",
        );
        ref.read(caseProvider.notifier).addDocument(caseId, newDoc);
      }
    }
  }

  void _shareToWhatsApp(Case c) async {
    final nextDate = c.nextHearing != null
        ? DateFormat('dd-MMM-yyyy').format(c.nextHearing!)
        : 'Not yet scheduled';

    String message =
        "Litigation Management - DC Office Sukkur\n\n"
        "Court: ${c.court}\n"
        "Case: ${c.caseNo} / ${c.year}\n"
        "Parties: ${c.title}\n"
        "Taluka: ${c.taluka ?? 'N/A'}\n"
        "Dept: ${c.department ?? 'N/A'}\n"
        "Next Hearing: $nextDate\n\n"
        "Notes: ${c.notes}";

    await _launchWhatsApp(message);
  }

  void _shareHearingToWhatsApp(Case c, Hearing h) async {
    String message =
        "Hearing Update - DC Office Sukkur\n\n"
        "Court: ${c.court}\n"
        "Case: ${c.caseNo} / ${c.year}\n"
        "Hearing Date: ${DateFormat('dd-MMM-yyyy').format(h.date)}\n\n"
        "Proceedings:\n${h.happened.isEmpty ? 'N/A' : h.happened}\n\n"
        "Court Order:\n${h.order.isEmpty ? 'N/A' : h.order}\n\n"
        "Next Date: ${h.nextDate != null ? DateFormat('dd-MMM-yyyy').format(h.nextDate!) : 'Not fixed'}";

    await _launchWhatsApp(message);
  }

  Future<void> _launchWhatsApp(String message) async {
    final url = "whatsapp://send?text=${Uri.encodeComponent(message)}";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not launch WhatsApp")),
        );
      }
    }
  }
}
