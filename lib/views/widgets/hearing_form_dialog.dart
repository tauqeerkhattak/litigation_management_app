import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/hearing.dart';
import '../../utils/constants.dart';

class HearingFormDialog extends StatefulWidget {
  final Function(Hearing) onSave;

  const HearingFormDialog({super.key, required this.onSave});

  @override
  State<HearingFormDialog> createState() => _HearingFormDialogState();
}

class _HearingFormDialogState extends State<HearingFormDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  DateTime? _nextDate;
  final _submittedController = TextEditingController();
  final _happenedController = TextEditingController();
  final _orderController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Hearing Entry", style: TextStyle(color: AppColors.navy)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Hearing Date"),
                subtitle: Text(DateFormat('dd-MMM-yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              TextFormField(
                controller: _submittedController,
                decoration: const InputDecoration(labelText: "Submitted to Court"),
                maxLines: 2,
              ),
              TextFormField(
                controller: _happenedController,
                decoration: const InputDecoration(labelText: "What happened?"),
                maxLines: 2,
              ),
              TextFormField(
                controller: _orderController,
                decoration: const InputDecoration(labelText: "Court Order/Direction"),
                maxLines: 2,
              ),
              ListTile(
                title: const Text("Next Date (Optional)"),
                subtitle: Text(_nextDate != null
                    ? DateFormat('dd-MMM-yyyy').format(_nextDate!)
                    : "Not set"),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _nextDate ?? _selectedDate.add(const Duration(days: 14)),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _nextDate = picked);
                },
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
              final hearing = Hearing(
                id: const Uuid().v4(),
                date: _selectedDate,
                submitted: _submittedController.text,
                happened: _happenedController.text,
                order: _orderController.text,
                nextDate: _nextDate,
              );
              widget.onSave(hearing);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
          child: const Text("Save Entry"),
        ),
      ],
    );
  }
}
