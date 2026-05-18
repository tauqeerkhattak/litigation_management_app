import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/case_model.dart';
import '../../utils/constants.dart';

class CaseFormDialog extends StatefulWidget {
  final Function(Case) onSave;

  const CaseFormDialog({super.key, required this.onSave});

  @override
  State<CaseFormDialog> createState() => _CaseFormDialogState();
}

class _CaseFormDialogState extends State<CaseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _caseNoController = TextEditingController();
  final _yearController = TextEditingController(text: "2024");
  final _titleController = TextEditingController();
  final _partiesController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedCourt = COURTS[0];
  String _selectedBench = BENCHES[0];
  String _selectedNature = CASE_NATURES[0];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Case File", style: TextStyle(color: AppColors.navy)),
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
                      decoration: const InputDecoration(labelText: "Case No (e.g. W.P 234)"),
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
                items: COURTS.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCourt = v!),
                decoration: const InputDecoration(labelText: "Court"),
              ),
              DropdownButtonFormField<String>(
                value: _selectedNature,
                items: CASE_NATURES.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
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
                decoration: const InputDecoration(labelText: "Parties (Petitioner vs Respondent)"),
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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newCase = Case(
                id: const Uuid().v4(),
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
                hearings: [],
                documents: [],
              );
              widget.onSave(newCase);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
          child: const Text("Create File"),
        ),
      ],
    );
  }
}
