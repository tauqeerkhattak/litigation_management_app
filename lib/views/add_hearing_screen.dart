import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:litigation_management_app/utils/validators.dart';

import '../models/hearing.dart';
import '../utils/constants.dart';
import '../viewmodels/case_viewmodel.dart';

class AddHearingScreen extends ConsumerStatefulWidget {
  final String caseId;

  const AddHearingScreen({super.key, required this.caseId});

  @override
  ConsumerState<AddHearingScreen> createState() => _AddHearingScreenState();
}

class _AddHearingScreenState extends ConsumerState<AddHearingScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  DateTime? _nextDate;
  final _submittedController = TextEditingController();
  final _happenedController = TextEditingController();
  final _orderController = TextEditingController();

  @override
  void dispose() {
    _submittedController.dispose();
    _happenedController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _saveHearing() {
    if (_formKey.currentState!.validate()) {
      final hearing = Hearing(
        date: _selectedDate,
        submitted: _submittedController.text,
        happened: _happenedController.text,
        order: _orderController.text,
        nextDate: _nextDate,
      );

      ref.read(caseProvider.notifier).addHearing(widget.caseId, hearing);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(caseProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "New Hearing Entry",
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
                  _buildSectionTitle("Hearing Date"),
                  Card(
                    child: ListTile(
                      title: Text(
                        DateFormat('dd-MMM-yyyy').format(_selectedDate),
                      ),
                      trailing: const Icon(
                        Icons.calendar_today,
                        color: AppColors.gold,
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Proceedings Details"),
                  TextFormField(
                    controller: _submittedController,
                    validator: Validators.notEmpty,
                    decoration: const InputDecoration(
                      labelText: "Submitted to Court",
                      hintText: "What was filed or submitted today?",
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _happenedController,
                    validator: Validators.notEmpty,
                    decoration: const InputDecoration(
                      labelText: "What happened?",
                      hintText: "Summary of today's proceedings",
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _orderController,
                    validator: Validators.notEmpty,
                    decoration: const InputDecoration(
                      labelText: "Court Order / Direction",
                      hintText: "Any specific order passed by the court",
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Future Schedule"),
                  Card(
                    child: ListTile(
                      title: const Text("Next Hearing Date"),
                      subtitle: Text(
                        _nextDate != null
                            ? DateFormat('dd-MMM-yyyy').format(_nextDate!)
                            : "Not set yet",
                      ),
                      trailing: const Icon(
                        Icons.calendar_month,
                        color: AppColors.gold,
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              _nextDate ??
                              _selectedDate.add(const Duration(days: 14)),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setState(() => _nextDate = picked);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _saveHearing,
                      child: const Text(
                        "SAVE HEARING ENTRY",
                        style: TextStyle(fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.only(bottom: 12, left: 4),
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
