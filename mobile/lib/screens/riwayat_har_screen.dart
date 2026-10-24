import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/api_service.dart';
import '../services/export_import_service.dart';
import 'detail_har_screen.dart';

class RiwayatHARScreen extends StatefulWidget {
  final bool isTab;
  const RiwayatHARScreen({super.key, this.isTab = false});

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

  void _showExportModal(List<HARModel> currentFiltered) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Export Laporan & Berita Acara',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                      ),
                      Text(
                        '${currentFiltered.length} Data Siap Diekspor',
                        style: const TextStyle(fontSize: 12, color: AppTheme.outline, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('PLN NUSA DAYA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppTheme.outlineVariant),
              const SizedBox(height: 12),

              // Option 1: PDF
              _buildExportOption(
                icon: Icons.picture_as_pdf_rounded,
                iconColor: const Color(0xFFEF4444),
                iconBg: const Color(0xFFFEE2E2),
                title: 'Cetak Berita Acara PDF (Landscape)',
                subtitle: 'Format resmi bertanda tangan SPV & Teknisi, siap diarsipkan.',
                badge: 'RESMI',
                badgeColor: const Color(0xFFDC2626),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ExportImportService.exportHARListToPdf(currentFiltered);
                  _showSuccessExportSnackBar('Dokumen Berita Acara PDF berhasil diunduh.');
                },
              ),

              // Option 2: Excel (.xlsx)
              _buildExportOption(
                icon: Icons.table_chart_rounded,
                iconColor: const Color(0xFF16A34A),
                iconBg: const Color(0xFFDCFCE7),
                title: 'Unduh Spreadsheet Excel (.xlsx)',
                subtitle: 'File Excel resmi dengan 2 sheet: Data Rekap HAR & Ringkasan KPI.',
                badge: 'EXCEL',
                badgeColor: const Color(0xFF15803D),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ExportImportService.exportHARListToExcel(currentFiltered);
                  _showSuccessExportSnackBar('File Excel (.xlsx) berhasil diunduh.');
                },
              ),

              // Option 3: CSV
              _buildExportOption(
                icon: Icons.text_snippet_rounded,
                iconColor: const Color(0xFF0284C7),
                iconBg: const Color(0xFFE0F2FE),
                title: 'Unduh Format CSV (.csv)',
                subtitle: 'Data terpisah koma untuk integrasi sistem analitik & BI.',
                badge: 'CSV',
                badgeColor: const Color(0xFF0369A1),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ExportImportService.exportHARListToCsv(currentFiltered);
                  _showSuccessExportSnackBar('File CSV berhasil diunduh.');
                },
              ),

              // Option 4: JSON Backup
              _buildExportOption(
                icon: Icons.data_object_rounded,
                iconColor: const Color(0xFF7C3AED),
                iconBg: const Color(0xFFF3E8FF),
                title: 'Cadangkan Database JSON (.json)',
                subtitle: 'Salinan cadangan lengkap seluruh parameter dan checklist.',
                badge: 'BACKUP',
                badgeColor: const Color(0xFF6D28D9),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ExportImportService.exportHARListToJson(currentFiltered);
                  _showSuccessExportSnackBar('Backup JSON berhasil diunduh.');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(badge, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: badgeColor)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 10.5, color: AppTheme.outline),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppTheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessExportSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleImport() async {
    final result = await ExportImportService.pickAndParseFile();

    if (!mounted) return;

    if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
      if (result.errorMessage != 'Pemilihan file dibatalkan.') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage!),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (result.parsedReports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data tiket HAR yang dapat dibaca dari file ini.'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show Preview & Confirmation Dialog
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.file_upload_rounded, color: AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Konfirmasi Impor Data',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file_rounded, size: 18, color: AppTheme.primaryDark),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${result.fileName} (${result.fileType.toUpperCase()})',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Terdeteksi ${result.parsedReports.length} laporan pemeliharaan baru siap disimpan:',
                  style: const TextStyle(fontSize: 12, color: AppTheme.outline),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: result.parsedReports.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final item = result.parsedReports[index];
                      return ListTile(
                        dense: true,
                        title: Text(item.harNumber, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                        subtitle: Text('${item.machineName} • Slot ${item.timeSlot}', style: const TextStyle(fontSize: 10)),
                        trailing: Text(item.date, style: const TextStyle(fontSize: 10, color: AppTheme.outline)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: AppTheme.outline, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final count = await ApiService.importReports(result.parsedReports);
                await _loadReports();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Berhasil mengimpor $count laporan pemeliharaan!'),
                        ],
                      ),
                      backgroundColor: AppTheme.accentGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Simpan Data (${result.parsedReports.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
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
        automaticallyImplyLeading: !widget.isTab,
        title: const Text('Riwayat HAR & Logsheet'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined, color: AppTheme.primaryDark),
            tooltip: 'Impor File (.xlsx, .csv, .json)',
            onPressed: _handleImport,
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppTheme.primaryDark),
            tooltip: 'Export Laporan (PDF, Excel, CSV)',
            onPressed: () => _showExportModal(filtered),
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
                    // Export & Import Quick Hub Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.outlineVariant),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showExportModal(filtered),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.file_download_rounded, size: 16),
                              label: const Text('Export Data', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _handleImport,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                                side: const BorderSide(color: AppTheme.primary, width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.file_upload_rounded, size: 16),
                              label: const Text('Import File', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () async {
                              await ExportImportService.downloadExcelTemplate();
                              _showSuccessExportSnackBar('Template Excel berhasil diunduh.');
                            },
                            tooltip: 'Unduh Template Excel',
                            icon: const Icon(Icons.download_for_offline_rounded, color: AppTheme.secondary),
                            style: IconButton.styleFrom(
                              backgroundColor: AppTheme.secondary.withValues(alpha: 0.1),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

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
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Reports List Count & Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${filtered.length} Laporan Pemeliharaan',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark),
                        ),
                        Text(
                          'Unit Terpilih',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Reports List View
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tidak ada laporan HAR ditemukan.',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                Color statusBg = const Color(0xFFDCFCE7);
                                Color statusColor = AppTheme.accentGreen;
                                String statusText = 'Approved (Selesai)';

                                if (item.status == 'submitted') {
                                  statusBg = const Color(0xFFFEF3C7);
                                  statusColor = const Color(0xFFD97706);
                                  statusText = 'Menunggu SPV';
                                } else if (item.status == 'draft') {
                                  statusBg = const Color(0xFFEFF6FF);
                                  statusColor = AppTheme.primary;
                                  statusText = 'Draft Laporan';
                                } else if (item.status == 'rejected') {
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
