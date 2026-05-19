import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/case_model.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/case_viewmodel.dart';
import 'add_case_screen.dart';
import 'calendar_view.dart';
import 'case_detail_view.dart';
import 'search_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = "All";

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final caseState = ref.watch(caseProvider);
    final allCases = caseState.cases;
    final isLoading = caseState.isLoading;
    final query = _searchController.text.toLowerCase();

    final cases = allCases.where((c) {
      final matchesQuery =
          c.caseNo.toLowerCase().contains(query) ||
          c.title.toLowerCase().contains(query);
      final matchesStatus =
          _selectedStatus == "All" || c.status == _selectedStatus;
      return matchesQuery && matchesStatus;
    }).toList();

    final urgentCount = ref.watch(urgentCasesCountProvider);

    return Scaffold(
      drawer: _buildDrawer(user),
      appBar: AppBar(
        title: Text(
          "D.C. SUKKUR LITIGATION",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchView()),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {},
              ),
              if (urgentCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$urgentCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : Column(
              children: [
                _buildSearchAndFilters(),
                Expanded(
                  child: cases.isEmpty
                      ? const Center(child: Text("No cases found"))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: cases.length,
                          itemBuilder: (context, index) {
                            return _buildCaseCard(cases[index]);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCaseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDrawer(user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.navy),
            accountName: Text(user?.name ?? "Guest"),
            accountEmail: Text(user?.email ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.gold,
              child: Text(
                user?.name.substring(0, 1) ?? "G",
                style: const TextStyle(fontSize: 24, color: AppColors.navy),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text("Hearing Calendar"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarView()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        children: [
          TextField(
            readOnly: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchView()),
              );
            },
            decoration: InputDecoration(
              hintText: "Search cases, parties...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              filled: true,
              fillColor: AppColors.cream,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["All", "Active", "Stay Granted", "Decided"].map((
                status,
              ) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCard(Case c) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          if (c.id == null) {
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CaseDetailView(caseId: c.id!)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    c.caseNo,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      c.status.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.balance,
                        size: 14,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          c.court,
                          style: const TextStyle(color: AppColors.muted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_month,
                        size: 14,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        c.nextHearing != null
                            ? "Next: ${c.nextHearing!.monthDay}"
                            : "No date",
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
