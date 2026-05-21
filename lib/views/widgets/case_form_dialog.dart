import 'package:flutter/material.dart';

import '../../models/case_model.dart';
import '../../utils/constants.dart';

class CaseFormDialog extends StatefulWidget {
  final Case? caseToEdit;
  final Function(Case) onSave;

  const CaseFormDialog({super.key, required this.onSave, this.caseToEdit});

  @override
  State<CaseFormDialog> createState() => _CaseFormDialogState();
}

class _CaseFormDialogState extends State<CaseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _caseNoController;
  late TextEditingController _yearController;
  late TextEditingController _titleController;
  late TextEditingController _partiesController;
  late TextEditingController _notesController;

  late String _selectedCourt;
  late String _selectedBench;
  late String _selectedNature;

  @override
  void initState() {
    super.initState();
    final c = widget.caseToEdit;
    _caseNoController = TextEditingController(text: c?.caseNo ?? "");
    _yearController = TextEditingController(text: (c?.year ?? 2024).toString());
    _titleController = TextEditingController(text: c?.title ?? "");
    _partiesController = TextEditingController(text: c?.parties ?? "");
    _notesController = TextEditingController(text: c?.notes ?? "");

    _selectedCourt = c?.court ?? courtsList[0];
    _selectedBench = c?.bench ?? benchesList[0];
    _selectedNature = c?.nature ?? caseNaturesList[0];
  }

  @override
  void dispose() {
    _caseNoController.dispose();
    _yearController.dispose();
    _titleController.dispose();
    _partiesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.caseToEdit != null;
    return AlertDialog(
      title: Text(
        isEditing ? "Edit Case File" : "New Case File",
        style: const TextStyle(color: AppColors.navy),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _caseNoController,
                      decoration: const InputDecoration(
                        labelText: "Case No (e.g. W.P 234)",
                      ),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(labelText: "Year"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: _selectedCourt,
              //  initialValue: _selectedCourt,
                items: courtsList
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCourt = v!),
                decoration: const InputDecoration(labelText: "Court"),
              ),
              DropdownButtonFormField<String>(
                value: _selectedNature,
             //   initialValue: _selectedNature,
                items: caseNaturesList
                    .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedNature = v!),
                decoration: const InputDecoration(labelText: "Nature of Case"),
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Case Title"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _partiesController,
                decoration: const InputDecoration(
                  labelText: "Parties (Petitioner vs Respondent)",
                ),
                maxLines: 2,
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: "Brief Notes"),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final updatedCase =
                  widget.caseToEdit?.copyWith(
                    caseNo: _caseNoController.text,
                    year: int.parse(_yearController.text),
                    court: _selectedCourt,
                    bench: _selectedBench,
                    title: _titleController.text,
                    parties: _partiesController.text,
                    nature: _selectedNature,
                    notes: _notesController.text,
                  ) ??
                  Case(
                    caseNo: _caseNoController.text,
                    year: int.parse(_yearController.text),
                    court: _selectedCourt,
                    bench: _selectedBench,
                    title: _titleController.text,
                    parties: _partiesController.text,
                    firstHearing: DateTime.now(),
                    lastHearing: DateTime.now(),
                    nextHearing: null,
                    status: "Active",
                    nature: _selectedNature,
                    notes: _notesController.text,
                    documents: [],
                  );
              widget.onSave(updatedCase);
            }
          },
          child: Text(isEditing ? "Update File" : "Create File"),
        ),
      ],
    );
  }
}
