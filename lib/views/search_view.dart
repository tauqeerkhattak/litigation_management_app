import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/case_model.dart';
import '../utils/constants.dart';
import '../viewmodels/case_viewmodel.dart';
import 'case_detail_view.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  String _searchQuery = "";
  CaseStatus? _selectedStatus;
  Court? _selectedCourt;
  CaseNature? _selectedNature;

  @override
  Widget build(BuildContext context) {
    final caseState = ref.watch(caseProvider);
    final allCases = caseState.cases;
    final isLoading = caseState.isLoading;

    final filteredCases = allCases.where((c) {
      final query = _searchQuery.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          c.caseNo.toLowerCase().contains(query) ||
          c.title.toLowerCase().contains(query) ||
          c.parties.toLowerCase().contains(query);

      final matchesStatus =
          _selectedStatus == null || c.status == _selectedStatus;
      final matchesCourt = _selectedCourt == null || c.court == _selectedCourt;
      final matchesNature =
          _selectedNature == null || c.nature == _selectedNature;

      return matchesQuery && matchesStatus && matchesCourt && matchesNature;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Advanced Search")),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : Column(
              children: [
                _buildFilters(),
                Expanded(
                  child: filteredCases.isEmpty
                      ? const Center(
                          child: Text("No cases found matching filters."),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredCases.length,
                          itemBuilder: (context, index) {
                            return _buildCaseResultCard(
                              context,
                              filteredCases[index],
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: "Search by Case No, Title, or Parties...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ""),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Filter by Status",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text("All"),
                      selected: _selectedStatus == null,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedStatus = null);
                      },
                    ),
                  ),
                  ...CaseStatus.values.map((s) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(s.displayName),
                        selected: _selectedStatus == s,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedStatus = s);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Filter by Court",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Court?>(
              value: _selectedCourt,
              items: [
                const DropdownMenuItem<Court?>(
                  value: null,
                  child: Text("All Courts"),
                ),
                ...Court.values.map(
                  (c) => DropdownMenuItem(value: c, child: Text(c.displayName)),
                ),
              ],
              onChanged: (v) => setState(() => _selectedCourt = v),
              decoration: const InputDecoration(isDense: true),
            ),
            const SizedBox(height: 16),
            const Text(
              "Filter by Nature",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<CaseNature?>(
              value: _selectedNature,
              items: [
                const DropdownMenuItem<CaseNature?>(
                  value: null,
                  child: Text("All Natures"),
                ),
                ...CaseNature.values.map(
                  (n) => DropdownMenuItem(value: n, child: Text(n.displayName)),
                ),
              ],
              onChanged: (v) => setState(() => _selectedNature = v),
              decoration: const InputDecoration(isDense: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseResultCard(BuildContext context, Case c) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          if (c.id == null) {
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CaseDetailView(caseId: c.id!)),
          );
        },
        title: Text(
          c.caseNo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    c.status.displayName,
                    style: const TextStyle(color: AppColors.gold, fontSize: 10),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    c.court.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.gold),
      ),
    );
  }
}
