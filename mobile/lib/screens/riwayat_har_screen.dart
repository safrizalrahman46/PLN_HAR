import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/api_service.dart';
import 'detail_har_screen.dart';

class RiwayatHARScreen extends StatefulWidget {
  const RiwayatHARScreen({super.key});

  @override
  State<RiwayatHARScreen> createState() => _RiwayatHARScreenState();
}

class _RiwayatHARScreenState extends State<RiwayatHARScreen> {
  List<HARModel> _reports = [];
  bool _isLoading = true;
  String _selectedStatus = 'Semua';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    final list = await ApiService.getHARReports();
    if (mounted) {
      setState(() {
        _reports = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase().trim();
    final filtered = _reports.where((r) {
      bool matchesStatus = true;
      if (_selectedStatus == 'Menunggu SPV') matchesStatus = r.status == 'submitted';
      if (_selectedStatus == 'Approved') matchesStatus = r.status == 'approved';
      if (_selectedStatus == 'Draft') matchesStatus = r.status == 'draft';

      bool matchesSearch = query.isEmpty ||
          r.harNumber.toLowerCase().contains(query) ||
          r.machineName.toLowerCase().contains(query) ||
          r.unitName.toLowerCase().contains(query) ||
          r.technicianName.toLowerCase().contains(query);

      return matchesStatus && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Riwayat HAR & Logsheet'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppTheme.primaryDark),
            tooltip: 'Export Berita Acara (.xlsx)',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rekapitulasi HAR & Logsheet berhasil diexport ke format Excel.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: _loadReports,
              color: AppTheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.outline),
                          hintText: 'Cari No. HAR, nama mesin, atau teknisi...',
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['Semua', 'Menunggu SPV', 'Approved', 'Draft'].map((status) {
                          final isSelected = _selectedStatus == status;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedStatus = status),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.primary : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? AppTheme.primary : AppTheme.outlineVariant,
                                  ),
                                  boxShadow: isSelected ? AppTheme.glowShadow : AppTheme.softShadow,
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppTheme.outline,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Reports List
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 54, color: AppTheme.outline.withValues(alpha: 0.4)),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Belum ada tiket pemeliharaan',
                                    style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textDark),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Laporan yang telah diinput akan tercatat di sini.',
                                    style: TextStyle(fontSize: 12, color: AppTheme.outline),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (ctx, idx) {
                                final item = filtered[idx];
                                Color statusBg = const Color(0xFFDCFCE7);
                                Color statusColor = const Color(0xFF16A34A);
                                String statusText = 'Approved';

                                if (item.status == 'submitted') {
                                  statusBg = const Color(0xFFFEF3C7);
                                  statusColor = const Color(0xFFD97706);
                                  statusText = 'Menunggu SPV';
                                } else if (item.status == 'draft') {
                                  statusBg = const Color(0xFFEFF6FF);
                                  statusColor = const Color(0xFF2563EB);
                                  statusText = 'Draft';
                                } else if (item.status == 'revision') {
                                  statusBg = const Color(0xFFFEE2E2);
                                  statusColor = AppTheme.accentRed;
                                  statusText = 'Perlu Revisi';
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: AppTheme.outlineVariant),
                                    boxShadow: AppTheme.softShadow,
                                  ),
                                  child: InkWell(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => DetailHARScreen(harId: item.id)),
                                      );
                                      _loadReports();
                                    },
                                    borderRadius: BorderRadius.circular(18),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.primary.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primary, size: 16),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    item.harNumber,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      color: AppTheme.primaryDark,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: statusBg,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  statusText,
                                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            item.machineName,
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on_rounded, size: 12, color: AppTheme.outline),
                                              const SizedBox(width: 3),
                                              Text(
                                                item.unitName,
                                                style: const TextStyle(fontSize: 11, color: AppTheme.outline),
                                              ),
                                              const SizedBox(width: 8),
                                              Text('•', style: TextStyle(color: Colors.grey.shade400)),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.schedule_rounded, size: 12, color: AppTheme.outline),
                                              const SizedBox(width: 3),
                                              Text(
                                                'Slot ${item.timeSlot} (${item.date})',
                                                style: const TextStyle(fontSize: 11, color: AppTheme.outline),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.surfaceContainerLow,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.person_rounded, size: 13, color: AppTheme.outline),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Oleh: ${item.technicianName}',
                                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Text('Beban: ', style: TextStyle(fontSize: 10, color: AppTheme.outline)),
                                                    Text(
                                                      '${item.beban.toInt()} kW',
                                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
