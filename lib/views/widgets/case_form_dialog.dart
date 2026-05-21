import 'package:flutter/material.dart';

import '../../models/case_model.dart';
import '../../utils/constants.dart';

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
  late TextEditingController _notesController;
  late List<TextEditingController> _plaintiffControllers;
  late List<TextEditingController> _respondentControllers;

  late String _selectedCourt;
  late String _selectedBench;
  late String _selectedNature;

  @override
  void initState() {
    super.initState();
    final c = widget.caseToEdit;

    _caseNoController = TextEditingController(text: c?.caseNo ?? "");
    _yearController = TextEditingController(
        text: (c?.year ?? DateTime.now().year).toString());
    _notesController = TextEditingController(text: c?.notes ?? "");

    _plaintiffControllers = (c?.plaintiffs.isNotEmpty == true
        ? c!.plaintiffs
        : [""])
        .map((p) => TextEditingController(text: p))
        .toList();

    _respondentControllers = (c?.respondents.isNotEmpty == true
        ? c!.respondents
        : [""])
        .map((r) => TextEditingController(text: r))
        .toList();

    _selectedCourt = c?.court ?? courtsList[0];
    _selectedBench = c?.bench ?? benchesList[0];
    _selectedNature = c?.nature ?? caseNaturesList[0];
  }

  @override
  void dispose() {
    _caseNoController.dispose();
    _yearController.dispose();
    _notesController.dispose();
    for (final c in _plaintiffControllers) c.dispose();
    for (final c in _respondentControllers) c.dispose();
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
                          labelText: "Case No (e.g. W.P 234)"),
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
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCourt,
                items: courtsList
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCourt = v!),
                decoration: const InputDecoration(labelText: "Court"),
              ),
              DropdownButtonFormField<String>(
                value: _selectedNature,
                items: caseNaturesList
                    .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedNature = v!),
                decoration: const InputDecoration(labelText: "Nature of Case"),
              ),
              const SizedBox(height: 12),

              // --- PLAINTIFFS ---
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Plaintiff / Petitioner",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              ..._plaintiffControllers.asMap().entries.map((entry) {
                final i = entry.key;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          hintText: i == 0
                              ? "Enter name"
                              : "Plaintiff ${i + 1}",
                        ),
                        validator: i == 0
                            ? (v) => v!.isEmpty ? "Required" : null
                            : null,
                      ),
                    ),
                    if (_plaintiffControllers.length > 1)
                      IconButton(
                        onPressed: () => setState(() {
                          _plaintiffControllers[i].dispose();
                          _plaintiffControllers.removeAt(i);
                        }),
                        icon: const Icon(Icons.close, size: 16),
                        color: Colors.redAccent,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 28, minHeight: 28),
                      ),
                  ],
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() =>
                      _plaintiffControllers.add(TextEditingController())),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add Plaintiff",
                      style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4)),
                ),
              ),

              const Center(
                child: Text("VS",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold)),
              ),

              // --- RESPONDENTS ---
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Respondent / Defendant",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              ..._respondentControllers.asMap().entries.map((entry) {
                final i = entry.key;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          hintText: i == 0
                              ? "Enter name"
                              : "Respondent ${i + 1}",
                        ),
                        validator: i == 0
                            ? (v) => v!.isEmpty ? "Required" : null
                            : null,
                      ),
                    ),
                    if (_respondentControllers.length > 1)
                      IconButton(
                        onPressed: () => setState(() {
                          _respondentControllers[i].dispose();
                          _respondentControllers.removeAt(i);
                        }),
                        icon: const Icon(Icons.close, size: 16),
                        color: Colors.redAccent,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 28, minHeight: 28),
                      ),
                  ],
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() =>
                      _respondentControllers.add(TextEditingController())),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add Respondent",
                      style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4)),
                ),
              ),

              const SizedBox(height: 8),
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
              final plaintiffs = _plaintiffControllers
                  .map((c) => c.text.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              final respondents = _respondentControllers
                  .map((c) => c.text.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              final title =
                  "${plaintiffs.first} vs ${respondents.first}";

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
                    notes: _notesController.text,
                  ) ??
                      Case(
                        caseNo: _caseNoController.text,
                        year: int.parse(_yearController.text),
                        court: _selectedCourt,
                        bench: _selectedBench,
                        title: title,
                        plaintiffs: plaintiffs,
                        respondents: respondents,
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
// class CaseFormDialog extends StatefulWidget {
//   final Case? caseToEdit;
//   final Function(Case) onSave;
//
//   const CaseFormDialog({super.key, required this.onSave, this.caseToEdit});
//
//   @override
//   State<CaseFormDialog> createState() => _CaseFormDialogState();
// }
//
// class _CaseFormDialogState extends State<CaseFormDialog> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _caseNoController;
//   late TextEditingController _yearController;
//   late TextEditingController _titleController;
//   late TextEditingController _partiesController;
//   late TextEditingController _notesController;
//
//   late String _selectedCourt;
//   late String _selectedBench;
//   late String _selectedNature;
//
//   @override
//   void initState() {
//     super.initState();
//     final c = widget.caseToEdit;
//     _caseNoController = TextEditingController(text: c?.caseNo ?? "");
//     _yearController = TextEditingController(text: (c?.year ?? 2024).toString());
//     _titleController = TextEditingController(text: c?.title ?? "");
//     _partiesController = TextEditingController(text: c?.parties ?? "");
//     _notesController = TextEditingController(text: c?.notes ?? "");
//
//     _selectedCourt = c?.court ?? courtsList[0];
//     _selectedBench = c?.bench ?? benchesList[0];
//     _selectedNature = c?.nature ?? caseNaturesList[0];
//   }
//
//   @override
//   void dispose() {
//     _caseNoController.dispose();
//     _yearController.dispose();
//     _titleController.dispose();
//     _partiesController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isEditing = widget.caseToEdit != null;
//     return AlertDialog(
//       title: Text(
//         isEditing ? "Edit Case File" : "New Case File",
//         style: const TextStyle(color: AppColors.navy),
//       ),
//       content: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: TextFormField(
//                       controller: _caseNoController,
//                       decoration: const InputDecoration(
//                         labelText: "Case No (e.g. W.P 234)",
//                       ),
//                       validator: (v) => v!.isEmpty ? "Required" : null,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _yearController,
//                       decoration: const InputDecoration(labelText: "Year"),
//                       keyboardType: TextInputType.number,
//                     ),
//                   ),
//                 ],
//               ),
//               DropdownButtonFormField<String>(
//                 value: _selectedCourt,
//               //  initialValue: _selectedCourt,
//                 items: courtsList
//                     .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//                     .toList(),
//                 onChanged: (v) => setState(() => _selectedCourt = v!),
//                 decoration: const InputDecoration(labelText: "Court"),
//               ),
//               DropdownButtonFormField<String>(
//                 value: _selectedNature,
//              //   initialValue: _selectedNature,
//                 items: caseNaturesList
//                     .map((n) => DropdownMenuItem(value: n, child: Text(n)))
//                     .toList(),
//                 onChanged: (v) => setState(() => _selectedNature = v!),
//                 decoration: const InputDecoration(labelText: "Nature of Case"),
//               ),
//               TextFormField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(labelText: "Case Title"),
//                 validator: (v) => v!.isEmpty ? "Required" : null,
//               ),
//               TextFormField(
//                 controller: _partiesController,
//                 decoration: const InputDecoration(
//                   labelText: "Parties (Petitioner vs Respondent)",
//                 ),
//                 maxLines: 2,
//               ),
//               TextFormField(
//                 controller: _notesController,
//                 decoration: const InputDecoration(labelText: "Brief Notes"),
//                 maxLines: 3,
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text("Cancel"),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (_formKey.currentState!.validate()) {
//               // ✅ Pehle lists banao
//               final plaintiffs = _plaintiffControllers
//                   .map((c) => c.text.trim())
//                   .where((s) => s.isNotEmpty)
//                   .toList();
//               final respondents = _respondentControllers
//                   .map((c) => c.text.trim())
//                   .where((s) => s.isNotEmpty)
//                   .toList();
//               final title =
//                   "${_plaintiffControllers.first.text} vs ${_respondentControllers.first.text}";
//
//               final updatedCase =
//                   widget.caseToEdit?.copyWith(
//                     caseNo: _caseNoController.text,
//                     year: int.parse(_yearController.text),
//                     court: _selectedCourt,
//                     bench: _selectedBench,
//                     title: title,
//                     plaintiffs: plaintiffs,    // ✅
//                     respondents: respondents,  // ✅
//                     nature: _selectedNature,
//                     notes: _notesController.text,
//                   ) ??
//                       Case(
//                         caseNo: _caseNoController.text,
//                         year: int.parse(_yearController.text),
//                         court: _selectedCourt,
//                         bench: _selectedBench,
//                         title: title,
//                         plaintiffs: plaintiffs,    // ✅
//                         respondents: respondents,  // ✅
//                         firstHearing: DateTime.now(),
//                         lastHearing: DateTime.now(),
//                         nextHearing: null,
//                         status: "Active",
//                         nature: _selectedNature,
//                         notes: _notesController.text,
//                         documents: [],
//                       );
//               widget.onSave(updatedCase);
//             }
//           },
//           child: Text(isEditing ? "Update File" : "Create File"),
//         ),
//         // ElevatedButton(
//         //   onPressed: () {
//         //     if (_formKey.currentState!.validate()) {
//         //       final updatedCase =
//         //           widget.caseToEdit?.copyWith(
//         //             caseNo: _caseNoController.text,
//         //             year: int.parse(_yearController.text),
//         //             court: _selectedCourt,
//         //             bench: _selectedBench,
//         //             title: _titleController.text,
//         //             plaintiffs: plan.text,
//         //             nature: _selectedNature,
//         //             notes: _notesController.text,
//         //           ) ??
//         //           Case(
//         //             caseNo: _caseNoController.text,
//         //             year: int.parse(_yearController.text),
//         //             court: _selectedCourt,
//         //             bench: _selectedBench,
//         //             title: _titleController.text,
//         //             parties: _partiesController.text,
//         //             firstHearing: DateTime.now(),
//         //             lastHearing: DateTime.now(),
//         //             nextHearing: null,
//         //             status: "Active",
//         //             nature: _selectedNature,
//         //             notes: _notesController.text,
//         //             documents: [],
//         //           );
//         //       widget.onSave(updatedCase);
//         //     }
//         //   },
//         //   child: Text(isEditing ? "Update File" : "Create File"),
//         // ),
//       ],
//     );
//   }
// }
