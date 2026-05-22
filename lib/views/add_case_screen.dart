import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litigation_management_app/utils/validators.dart';

import '../models/case_model.dart';
import '../utils/constants.dart';
import '../viewmodels/case_viewmodel.dart';

class AddCaseScreen extends ConsumerStatefulWidget {
  final Case? caseToEdit;
  const AddCaseScreen({super.key, this.caseToEdit});

  @override
  ConsumerState<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends ConsumerState<AddCaseScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _caseNoController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final List<TextEditingController> _plaintiffControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _respondentControllers = [
    TextEditingController(),
  ];
  final TextEditingController _notesController = TextEditingController();

  Court _selectedCourt = Court.highCourt;
  Bench _selectedBench = Bench.singleBench;
  CaseNature _selectedNature = CaseNature.revenue;
  Taluka? _selectedTaluka;
  Department? _selectedDepartment;
  CaseStatus _selectedStatus = CaseStatus.active;

  @override
  void initState() {
    super.initState();
    final c = widget.caseToEdit;
    if (c == null) {
      return;
    }
    _plaintiffControllers.clear();
    _respondentControllers.clear();
    _caseNoController.text = c.caseNo;
    _yearController.text = (c.year).toString();
    for (final plaintiff in c.plaintiffs) {
      _plaintiffControllers.add(TextEditingController(text: plaintiff));
    }
    for (final respondent in c.respondents) {
      _respondentControllers.add(TextEditingController(text: respondent));
    }
    _notesController.text = c.notes;
    _selectedCourt = c.court;
    _selectedBench = c.bench;
    _selectedNature = c.nature;
    _selectedTaluka = c.taluka;
    _selectedDepartment = c.department;
    _selectedStatus = c.status;
  }

  @override
  void dispose() {
    _caseNoController.dispose();
    _yearController.dispose();
    for (final c in _plaintiffControllers) {
      c.dispose();
    }
    for (final c in _respondentControllers) {
      c.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  void _saveCase() async {
    if (_formKey.currentState!.validate()) {
      final plaintiffs = _plaintiffControllers
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final respondents = _respondentControllers
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final title =
          "${_plaintiffControllers.first.text} vs ${_respondentControllers.first.text}";

      final updatedCase =
          widget.caseToEdit?.copyWith(
            caseNo: _caseNoController.text,
            year: int.parse(_yearController.text),
            court: _selectedCourt,
            bench: _selectedBench,
            title: title,
            plaintiffs: plaintiffs,
            respondents: respondents,
            nature: _selectedNature,
            taluka: _selectedNature == CaseNature.revenue
                ? _selectedTaluka
                : null,
            department: _selectedNature == CaseNature.generalAdministration
                ? _selectedDepartment
                : null,
            notes: _notesController.text,
            status: _selectedStatus,
          ) ??
          Case(
            caseNo: _caseNoController.text,
            year: int.parse(_yearController.text),
            court: _selectedCourt,
            bench: _selectedBench,
            title: title,
            plaintiffs: plaintiffs,
            respondents: respondents,
            status: _selectedStatus,
            nature: _selectedNature,
            taluka: _selectedNature == CaseNature.revenue
                ? _selectedTaluka
                : null,
            department: _selectedNature == CaseNature.generalAdministration
                ? _selectedDepartment
                : null,
            notes: _notesController.text,
            documents: [],
          );

      if (widget.caseToEdit != null) {
        ref.read(caseProvider.notifier).updateCase(updatedCase);
      } else {
        ref.read(caseProvider.notifier).addCase(updatedCase);
      }

      if (mounted) Navigator.pop(context);
    }
  }
  // void _saveCase() async {
  //   if (_formKey.currentState!.validate()) {
  //     final plaintiffStr =
  //     _plaintiffControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).join(", ");
  //     final respondentStr =
  //     _respondentControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).join(", ");
  //     final parties = "$plaintiffStr vs $respondentStr";
  //     // final parties =
  //     //     "${_plaintiffController.text} vs ${_respondentController.text}";
  //
  //     final updatedCase =
  //         widget.caseToEdit?.copyWith(

  //           caseNo: _caseNoController.text,
  //           year: int.parse(_yearController.text),
  //           court: _selectedCourt,
  //           bench: _selectedBench,
  //           // title: parties,
  //           // parties: parties,
  //           plaintiffs: _plaintiffControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
  //           respondents: _respondentControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
  //           title: "${_plaintiffControllers.first.text} vs ${_respondentControllers.first.text}",
  //
  //           nature: _selectedNature,
  //           taluka: _selectedNature == "Revenue" ? _selectedTaluka : null,
  //           department: _selectedNature == "General Administration"
  //               ? _selectedDepartment
  //               : null,
  //           notes: _notesController.text,
  //           status: _selectedStatus,
  //         ) ??
  //         Case(
  //           caseNo: _caseNoController.text,
  //           year: int.parse(_yearController.text),
  //           court: _selectedCourt,
  //           bench: _selectedBench,
  //           title: title, // yhn error hai
  //           plaintiffs: plaintiffStr,// yhn error hai error:The argument type 'String' can't be assigned to the parameter type 'List<String>'. (Documentation)
  //           respondents: respondents, // yhn error hai
  //           status: _selectedStatus,
  //           nature: _selectedNature,
  //           taluka: _selectedNature == "Revenue" ? _selectedTaluka : null,
  //           department: _selectedNature == "General Administration"
  //               ? _selectedDepartment
  //               : null,
  //           notes: _notesController.text,
  //           documents: [],
  //         );
  //
  //     if (widget.caseToEdit != null) {
  //       ref.read(caseProvider.notifier).updateCase(updatedCase);
  //     } else {
  //       ref.read(caseProvider.notifier).addCase(updatedCase);
  //     }
  //
  //     if (mounted) Navigator.pop(context);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.caseToEdit != null;
    final isLoading = ref.watch(caseProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? "Edit Case File" : "New Case File",
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Basic Information"),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _caseNoController,
                          decoration: const InputDecoration(
                            labelText: "Case / CP Number",
                            hintText: "e.g. W.P. 2341",
                          ),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _yearController,
                          decoration: const InputDecoration(labelText: "Year"),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Court>(
                    initialValue: _selectedCourt,
                    items: Court.values
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCourt = v!),
                    decoration: const InputDecoration(labelText: "Court Name"),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Bench>(
                    initialValue: _selectedBench,
                    items: Bench.values
                        .map(
                          (b) => DropdownMenuItem(
                            value: b,
                            child: Text(b.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedBench = v!),
                    decoration: const InputDecoration(labelText: "Bench"),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Parties Details"),

                  ..._plaintiffControllers.indexed.map((data) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: data.$2,
                              decoration: InputDecoration(
                                labelText: data.$1 == 0
                                    ? "Plaintiff / Petitioner"
                                    : "Plaintiff ${data.$1 + 1}",
                                hintText: "Enter name",
                              ),
                              validator: Validators.notEmpty,
                            ),
                          ),
                          if (_plaintiffControllers.length > 1) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => setState(() {
                                data.$2.dispose();
                                _plaintiffControllers.removeAt(data.$1);
                              }),
                              icon: const Icon(Icons.close, size: 18),
                              color: Colors.redAccent,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  TextButton.icon(
                    onPressed: () => setState(
                      () => _plaintiffControllers.add(TextEditingController()),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add Plaintiff"),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      "VS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // --- RESPONDENTS ---
                  ..._respondentControllers.asMap().entries.map((entry) {
                    final i = entry.key;
                    final ctrl = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: ctrl,
                              decoration: InputDecoration(
                                labelText: i == 0
                                    ? "Respondent / Defendant"
                                    : "Respondent ${i + 1}",
                                hintText: "Enter name",
                              ),
                              validator: i == 0
                                  ? (v) => v!.isEmpty ? "Required" : null
                                  : null,
                            ),
                          ),
                          if (_respondentControllers.length > 1) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => setState(() {
                                _respondentControllers[i].dispose();
                                _respondentControllers.removeAt(i);
                              }),
                              icon: const Icon(Icons.close, size: 18),
                              color: Colors.redAccent,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  TextButton.icon(
                    onPressed: () => setState(
                      () => _respondentControllers.add(TextEditingController()),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add Respondent"),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Case Nature & Category"),
                  DropdownButtonFormField<CaseNature>(
                    initialValue: _selectedNature,
                    items: CaseNature.values
                        .map(
                          (n) => DropdownMenuItem(
                            value: n,
                            child: Text(n.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedNature = v!;
                        _selectedTaluka = null;
                        _selectedDepartment = null;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Nature of Case",
                    ),
                  ),

                  if (_selectedNature == CaseNature.revenue) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Taluka>(
                      initialValue: _selectedTaluka,
                      hint: const Text("Select Taluka"),
                      items: Taluka.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedTaluka = v),
                      decoration: const InputDecoration(labelText: "Taluka"),
                      validator: (v) =>
                          v == null ? "Required for Revenue cases" : null,
                    ),
                  ],

                  if (_selectedNature == CaseNature.generalAdministration) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Department>(
                      initialValue: _selectedDepartment,
                      hint: const Text("Select Department"),
                      items: Department.values
                          .map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: Text(d.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedDepartment = v),
                      decoration: const InputDecoration(
                        labelText: "Department",
                      ),
                      validator: (v) =>
                          v == null ? "Required for Gen Admin cases" : null,
                    ),
                  ],

                  const SizedBox(height: 24),
                  _buildSectionTitle("Additional Information"),
                  DropdownButtonFormField<CaseStatus>(
                    initialValue: _selectedStatus,
                    items: CaseStatus.values
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedStatus = v!),
                    decoration: const InputDecoration(
                      labelText: "Current Status",
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: "Brief Notes / Details",
                      hintText:
                          "Enter any specific details or current situation",
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _saveCase,
                      child: Text(
                        isEditing ? "UPDATE CASE FILE" : "CREATE CASE FILE",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }
}
