import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/case_model.dart';
import '../utils/constants.dart';
import '../viewmodels/case_viewmodel.dart';
import 'case_detail_view.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Case> _getEventsForDay(DateTime day, List<Case> allCases) {
    return allCases.where((c) {
      return c.nextHearing != null && isSameDay(c.nextHearing, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final caseState = ref.watch(caseProvider);
    final allCases = caseState.cases;
    final isLoading = caseState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text("Hearing Calendar")),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : Column(
              children: [
                TableCalendar<Case>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: (day) => _getEventsForDay(day, allCases),
                  calendarStyle: CalendarStyle(
                    markerDecoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppColors.navy.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: _buildEventList(allCases)),
              ],
            ),
    );
  }

  Widget _buildEventList(List<Case> allCases) {
    final events = _getEventsForDay(_selectedDay!, allCases);

    if (events.isEmpty) {
      return const Center(child: Text("No hearings scheduled for this day."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final c = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.border),
          ),
          child: ListTile(
            title: Text(
              c.caseNo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            subtitle: Text("${c.title} • ${c.court.displayName}"),
            trailing: const Icon(Icons.chevron_right, color: AppColors.gold),
            onTap: () {
              if (c.id == null) {
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CaseDetailView(caseId: c.id!),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
