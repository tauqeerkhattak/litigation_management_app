import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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

  late TextEditingController _caseNoController;
  late TextEditingController _yearController;
  late TextEditingController _plaintiffController;
  late TextEditingController _respondentController;
  late TextEditingController _notesController;

  String _selectedCourt = courtsList[0];
  String _selectedBench = benchesList[0];
  String _selectedNature = caseNaturesList[0];
  String? _selectedTaluka;
  String? _selectedDepartment;
  String _selectedStatus = "Active";

  @override
  void initState() {
    super.initState();
    final c = widget.caseToEdit;
    _caseNoController = TextEditingController(text: c?.caseNo ?? "");
    _yearController = TextEditingController(
      text: (c?.year ?? DateTime.now().year).toString(),
    );

    String plaintiff = "";
    String respondent = "";
    if (c != null && c.parties.contains(" vs ")) {
      final parts = c.parties.split(" vs ");
      plaintiff = parts[0];
      respondent = parts.length > 1 ? parts[1] : "";
    } else {
      plaintiff = c?.parties ?? "";
    }

    _plaintiffController = TextEditingController(text: plaintiff);
    _respondentController = TextEditingController(text: respondent);
    _notesController = TextEditingController(text: c?.notes ?? "");

    if (c != null) {
      _selectedCourt = c.court;
      _selectedBench = c.bench;
      _selectedNature = c.nature;
      _selectedTaluka = c.taluka;
      _selectedDepartment = c.department;
      _selectedStatus = c.status;
    }
  }

  @override
  void dispose() {
    _caseNoController.dispose();
    _yearController.dispose();
    _plaintiffController.dispose();
    _respondentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveCase() async {
    if (_formKey.currentState!.validate()) {
      final parties =
          "${_plaintiffController.text} vs ${_respondentController.text}";

      final updatedCase =
          widget.caseToEdit?.copyWith(
            caseNo: _caseNoController.text,
            year: int.parse(_yearController.text),
            court: _selectedCourt,
            bench: _selectedBench,
            title: parties,
            parties: parties,
            nature: _selectedNature,
            taluka: _selectedNature == "Revenue" ? _selectedTaluka : null,
            department: _selectedNature == "General Administration"
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
            title: parties,
            parties: parties,
            status: _selectedStatus,
            nature: _selectedNature,
            taluka: _selectedNature == "Revenue" ? _selectedTaluka : null,
            department: _selectedNature == "General Administration"
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
                  DropdownButtonFormField<String>(
                    value: _selectedCourt,
                    items: courtsList
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCourt = v!),
                    decoration: const InputDecoration(labelText: "Court Name"),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Parties Details"),
                  TextFormField(
                    controller: _plaintiffController,
                    decoration: const InputDecoration(
                      labelText: "Plaintiff / Petitioner",
                      hintText: "Enter name of person filing the case",
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      "VS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _respondentController,
                    decoration: const InputDecoration(
                      labelText: "Respondent / Defendant",
                      hintText: "Enter name of the opposing party",
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Case Nature & Category"),
                  DropdownButtonFormField<String>(
                    value: _selectedNature,
                    items: caseNaturesList
                        .map((n) => DropdownMenuItem(value: n, child: Text(n)))
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

                  if (_selectedNature == "Revenue") ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTaluka,
                      hint: const Text("Select Taluka"),
                      items: talukasList
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedTaluka = v),
                      decoration: const InputDecoration(labelText: "Taluka"),
                      validator: (v) =>
                          v == null ? "Required for Revenue cases" : null,
                    ),
                  ],

                  if (_selectedNature == "General Administration") ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      hint: const Text("Select Department"),
                      items: departmentsList
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
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
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    items: ["Active", "Stay Granted", "Decided", "Dismissed"]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
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
