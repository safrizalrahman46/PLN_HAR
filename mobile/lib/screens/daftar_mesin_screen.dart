import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/api_service.dart';
import 'buat_har_screen.dart';
import '../services/export_import_service.dart';

class DaftarMesinScreen extends StatefulWidget {
  final bool isTab;
  const DaftarMesinScreen({super.key, this.isTab = false});

  @override
  State<DaftarMesinScreen> createState() => _DaftarMesinScreenState();
}

class _DaftarMesinScreenState extends State<DaftarMesinScreen> {
  String _selectedFilter = 'Semua';
  final _searchController = TextEditingController();
  List<MachineModel> _machines = [];
  UnitModel? _activeUnit;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() async {
    final unit = await ApiService.getSelectedUnit();
    final machines = await ApiService.getMachines(kdUnit: unit.kdUnit);
    if (mounted) {
      setState(() {
        _activeUnit = unit;
        _machines = machines;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase().trim();
    final filtered = _machines.where((m) {
      final matchesFilter = _selectedFilter == 'Semua' || m.status.toUpperCase() == _selectedFilter.toUpperCase();
      final matchesSearch = query.isEmpty ||
          m.namaMesin.toLowerCase().contains(query) ||
          m.idMesin.toLowerCase().contains(query) ||
          m.sn.toLowerCase().contains(query) ||
          m.kodeMesinSilm.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isTab,
        title: const Text('Inventaris Mesin PLTD'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart_rounded, color: Color(0xFF16A34A)),
            tooltip: 'Export Excel Mesin (.xlsx)',
            onPressed: () async {
              await ExportImportService.exportMachinesToExcel(_machines, _activeUnit?.namaUnit ?? 'PLTD');
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text('Inventaris mesin ${_activeUnit?.namaUnit ?? ""} berhasil diexport ke Excel.'),
                    ],
                  ),
                  backgroundColor: AppTheme.accentGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Mesin',
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unit Header Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.outlineVariant),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.location_on_rounded, size: 20, color: AppTheme.primary),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Lokasi Unit Pembangkit', style: TextStyle(fontSize: 10, color: AppTheme.outline)),
                                Text(
                                  _activeUnit?.namaUnit ?? 'ULD Batu Ampar',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_machines.length} Unit Mesin',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
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
                        hintText: 'Cari mesin, tipe generator, atau Serial No...',
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
                      children: ['Semua', 'OPERASI', 'STANDBY', 'GANGGUAN'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFilter = filter),
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
                                filter,
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

                  // Machine List
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, size: 54, color: AppTheme.outline.withValues(alpha: 0.4)),
                                const SizedBox(height: 12),
                                const Text(
                                  'Mesin tidak ditemukan',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textDark),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Coba ubah kata kunci pencarian atau filter status.',
                                  style: TextStyle(fontSize: 12, color: AppTheme.outline),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (ctx, idx) {
                              final m = filtered[idx];
                              Color statusColor = AppTheme.accentGreen;
                              Color statusBg = const Color(0xFFDCFCE7);
                              String statusText = 'OPERASI (Normal)';

                              if (m.status.toUpperCase() == 'STANDBY') {
                                statusColor = const Color(0xFF2563EB);
                                statusBg = const Color(0xFFEFF6FF);
                                statusText = 'STANDBY (Siaga)';
                              } else if (m.status.toUpperCase() == 'GANGGUAN') {
                                statusColor = AppTheme.accentRed;
                                statusBg = const Color(0xFFFEE2E2);
                                statusText = 'GANGGUAN (Perlu HAR)';
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppTheme.outlineVariant),
                                  boxShadow: AppTheme.softShadow,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: statusBg,
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: Icon(
                                              Icons.precision_manufacturing_rounded,
                                              color: statusColor,
                                              size: 26,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  m.namaMesin,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 14,
                                                    color: AppTheme.textDark,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  'ID Mesin: ${m.idMesin} • SN: ${m.sn.isNotEmpty ? m.sn : "-"}',
                                                  style: const TextStyle(fontSize: 11, color: AppTheme.outline),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: statusBg,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              statusText,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: statusColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            _buildMetric('Daya Terpasang', '${m.dt.toInt()} kW', Icons.bolt_rounded),
                                            Container(height: 20, width: 1, color: AppTheme.outlineVariant),
                                            _buildMetric('Bahan Bakar', 'B35 Solar', Icons.local_gas_station_rounded),
                                            Container(height: 20, width: 1, color: AppTheme.outlineVariant),
                                            _buildMetric('Kode SILM', m.kodeMesinSilm.isNotEmpty ? m.kodeMesinSilm : '2255514', Icons.qr_code_rounded),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Container(
                                        width: double.infinity,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.plnElectricGradient,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: AppTheme.glowShadow,
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => BuatHARScreen(preselectedMachine: m),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          icon: const Icon(Icons.assignment_turned_in_rounded, size: 18, color: Colors.white),
                                          label: const Text(
                                            'Isi Checklist & Logsheet Mesin Ini',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppTheme.primary),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.outline)),
      ],
    );
  }
}
