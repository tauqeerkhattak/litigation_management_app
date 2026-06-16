import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litigation_management_app/views/login_screen.dart';

import '../models/case_model.dart';
import '../models/user_model.dart';
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
  CaseStatus? _selectedStatus;

  void _listener(AuthState? prev, AuthState next) {
    if (next.user == null) {
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, _listener);
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
          _selectedStatus == null || c.status == _selectedStatus;
      return matchesQuery && matchesStatus;
    }).toList();

    final urgentCount = ref.watch(urgentCasesCountProvider);

    final role = user?.role  ?? UserRole.viewer;


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
                            return
                              CaseCard(c: cases[index]);
                              // _buildCaseCard(cases[index]);
                          },
                        ),
                ),
              ],
            ),

      floatingActionButton: role.canCreateCases
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCaseScreen()),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  Widget _buildDrawer(UserData? user) {
    final name = (user?.name.isEmpty ?? true) ? "Guest" : user!.name;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.navy),
            accountName: Text(name),
            accountEmail: Text(user?.email ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.gold,
              child: Text(
                name.substring(0, 1),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchView()),
            ),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E6EE), width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: Color(0xFF9AA3B2)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Search cases, parties…',
                      style: TextStyle(fontSize: 13, color: Color(0xFFB0B8C4)),
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                          color: const Color(0xFFDDE1E9), width: 0.5),
                    ),
                    child: const Text(
                      '⌘ K',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Filter chips ────────────────────────────────────────
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _filterChip(
                  icon: Icons.list_alt_outlined,
                  label: 'All cases',
                  selected: _selectedStatus == null,
                  dotColor: null,
                  onTap: () => setState(() => _selectedStatus = null),
                ),
                ...CaseStatus.values.map((s) => _filterChip(
                  label: s.displayName,
                  selected: _selectedStatus == s,
                  dotColor: _statusDotColor(s),
                  onTap: () => setState(() => _selectedStatus = s),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    IconData? icon,
    required String label,
    required bool selected,
    required Color? dotColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0C2340) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF0C2340)
                : const Color(0xFFDDE1E9),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 13,
                  color: selected
                      ? const Color(0xFFC9A84C)
                      : const Color(0xFF9AA3B2)),
              const SizedBox(width: 5),
            ] else if (dotColor != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? const Color(0xFFC9A84C)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusDotColor(CaseStatus status) {
    switch (status) {
      case CaseStatus.dismissed:   return const Color(0xFFE24B4A);
      case CaseStatus.stayGranted:  return const Color(0xFFEF9F27);
      case CaseStatus.decided: return const Color(0xFF639922);
      default:                  return const Color(0xFF378ADD);
    }
  }
  // Widget _buildSearchAndFilters() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     color: AppColors.white,
  //     child: Column(
  //       children: [
  //         TextField(
  //           readOnly: true,
  //           onTap: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (_) => const SearchView()),
  //             );
  //           },
  //           decoration: InputDecoration(
  //             hintText: "Search cases, parties...",
  //             prefixIcon: const Icon(Icons.search),
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(12),
  //               borderSide: const BorderSide(color: AppColors.border),
  //             ),
  //             filled: true,
  //             fillColor: AppColors.cream,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         SingleChildScrollView(
  //           scrollDirection: Axis.horizontal,
  //           child: Row(
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.only(right: 8),
  //                 child: FilterChip(
  //                   label: const Text("All"),
  //                   selected: _selectedStatus == null,
  //                   onSelected: (val) {
  //                     setState(() {
  //                       _selectedStatus = null;
  //                     });
  //                   },
  //                 ),
  //               ),
  //               ...CaseStatus.values.map((status) {
  //                 final isSelected = _selectedStatus == status;
  //                 return Padding(
  //                   padding: const EdgeInsets.only(right: 8),
  //                   child: FilterChip(
  //                     label: Text(status.displayName),
  //                     selected: isSelected,
  //                     onSelected: (val) {
  //                       setState(() {
  //                         _selectedStatus = status;
  //                       });
  //                     },
  //                   ),
  //                 );
  //               }),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildCaseCard(Case c) {
  //   return Card(
  //     margin: const EdgeInsets.only(bottom: 16),
  //     child: InkWell(
  //       onTap: () {
  //         if (c.id == null) {
  //           return;
  //         }
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (_) => CaseDetailView(caseId: c.id!)),
  //         );
  //       },
  //       borderRadius: BorderRadius.circular(12),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //             decoration: const BoxDecoration(
  //               color: AppColors.navy,
  //               borderRadius: BorderRadius.only(
  //                 topLeft: Radius.circular(12),
  //                 topRight: Radius.circular(12),
  //               ),
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   c.caseNo,
  //                   style: const TextStyle(
  //                     color: AppColors.gold,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 Container(
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: 8,
  //                     vertical: 2,
  //                   ),
  //                   decoration: BoxDecoration(
  //                     color: AppColors.gold,
  //                     borderRadius: BorderRadius.circular(4),
  //                   ),
  //                   child: Text(
  //                     c.status.displayName.toUpperCase(),
  //                     style: const TextStyle(
  //                       fontSize: 10,
  //                       fontWeight: FontWeight.bold,
  //                       color: AppColors.navy,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(16),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   c.title,
  //                   style: const TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 16,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 Row(
  //                   children: [
  //                     const Icon(
  //                       Icons.balance,
  //                       size: 14,
  //                       color: AppColors.muted,
  //                     ),
  //                     const SizedBox(width: 4),
  //                     Expanded(
  //                       child: Text(
  //                         c.court.displayName,
  //                         style: const TextStyle(color: AppColors.muted),
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                     ),
  //                     const Icon(
  //                       Icons.calendar_month,
  //                       size: 14,
  //                       color: AppColors.muted,
  //                     ),
  //                     const SizedBox(width: 4),
  //                     Text(
  //                       c.nextHearing != null
  //                           ? "Next: ${c.nextHearing!.monthDay}"
  //                           : "No date",
  //                       style: const TextStyle(color: AppColors.muted),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
class CaseCard extends StatelessWidget {
  const CaseCard({super.key, required this.c});
  final Case c;

  Color get _statusColor {
    switch (c.status) {
      case CaseStatus.dismissed:   return const Color(0xFFE24B4A);
      case CaseStatus.decided: return const Color(0xFF639922);
      case CaseStatus.stayGranted:  return const Color(0xFFEF9F27);
      default:                  return const Color(0xFF378ADD);
    }
  }

  Color get _badgeBg {
    switch (c.status) {
      case CaseStatus.dismissed:   return const Color(0xFFFCEBEB);
      case CaseStatus.decided: return const Color(0xFFEAF3DE);
      case CaseStatus.stayGranted:  return const Color(0xFFFAEEDA);
      default:                  return const Color(0xFFE6F1FB);
    }
  }

  Color get _badgeText {
    switch (c.status) {
      case CaseStatus.dismissed:   return const Color(0xFFA32D2D);
      case CaseStatus.decided: return const Color(0xFF3B6D11);
      case CaseStatus.stayGranted:  return const Color(0xFF854F0B);
      default:                  return const Color(0xFF185FA5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (c.id == null) return;
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => CaseDetailView(caseId: c.id!)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8EBF0), width: 0.5),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left accent stripe ──────────────────────────
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),

              // ── Card content ────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: case no + badge
                      Row(
                        children: [
                          const Icon(Icons.folder_outlined,
                              size: 13, color: Color(0xFF9AA3B2)),
                          const SizedBox(width: 5),
                          Text(
                            c.caseNo,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0.4,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: _badgeBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              c.status.displayName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _badgeText,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Title
                      Text(
                        c.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                          height: 1.35,
                        ),
                      ),

                      const SizedBox(height: 10),
                      const Divider(height: 1, color: Color(0xFFF0F2F5)),
                      const SizedBox(height: 10),

                      // Meta row
                      Row(
                        children: [
                          Expanded(
                            child: _MetaItem(
                              icon: Icons.balance_outlined,
                              label: c.court.displayName,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _MetaItem(
                            icon: Icons.event_outlined,
                            label: c.nextHearing != null
                                ? c.nextHearing!.monthDay
                                : 'No date set',
                            colored: c.nextHearing != null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    this.colored = false,
  });

  final IconData icon;
  final String label;
  final bool colored;

  @override
  Widget build(BuildContext context) {
    final color =
    colored ? const Color(0xFF185FA5) : const Color(0xFF9AA3B2);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: colored ? FontWeight.w500 : FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}