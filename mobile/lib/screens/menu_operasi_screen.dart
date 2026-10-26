import 'package:flutter/material.dart';
import 'buat_har_screen.dart';
import 'catat_stand_kwh_screen.dart';
import 'lapor_amc_screen.dart';
import 'presensi_gps_screen.dart';
import 'sop_k3_screen.dart';
import 'stok_part_screen.dart';

class MenuOperasiScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const MenuOperasiScreen({super.key, this.onNavigateTab});

  @override
  State<MenuOperasiScreen> createState() => _MenuOperasiScreenState();
}

class _MenuOperasiScreenState extends State<MenuOperasiScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002F55),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Menu Operasi & Utilitas',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
            ),
            Text(
              'Pusat Fitur Terpadu Lapangan Pembangkit PLTD',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Cari menu operasi, fitur, modul K3, atau stand meter...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00A2E8), size: 22),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // KATEGORI 1: PEMELIHARAAN (HAR)
            _buildSectionHeader('PEMELIHARAAN MESIN (HAR)', Icons.build_rounded, const Color(0xFF0072B2)),
            const SizedBox(height: 10),
            _buildFeatureGrid([
              _FeatureItem(
                title: 'Pemeriksaan HAR',
                desc: 'Input checklist HAR preventif & update kondisi mesin',
                icon: Icons.checklist_rounded,
                color: const Color(0xFF00A2E8),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatHARScreen()));
                },
              ),
              _FeatureItem(
                title: 'Lapor Gangguan (AMC)',
                desc: 'Tiket gangguan mesin darurat & corrective maintenance',
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFEF4444),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporAMCScreen()));
                },
              ),
              _FeatureItem(
                title: 'Riwayat Laporan HAR',
                desc: 'Arsip berita acara, log status & validasi SPV',
                icon: Icons.history_edu_rounded,
                color: const Color(0xFF8B5CF6),
                onTap: () {
                  Navigator.pop(context);
                  widget.onNavigateTab?.call(2);
                },
              ),
              _FeatureItem(
                title: 'Kalender Pemeliharaan',
                desc: 'Jadwal HAR 250, 500, 1000 jam & top overhaul',
                icon: Icons.calendar_month_rounded,
                color: const Color(0xFF10B981),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatHARScreen()));
                },
              ),
            ]),
            const SizedBox(height: 24),

            // KATEGORI 2: OPERASI PEMBANGKIT & LOGSHEET
            _buildSectionHeader('OPERASI PEMBANGKIT & ENERGI', Icons.flash_on_rounded, const Color(0xFFF59E0B)),
            const SizedBox(height: 10),
            _buildFeatureGrid([
              _FeatureItem(
                title: 'Logsheet Mesin 48-Slot',
                desc: 'Pencatatan parameter suhu, tekanan & WACB 24 jam',
                icon: Icons.assignment_turned_in_rounded,
                color: const Color(0xFF0072B2),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatHARScreen()));
                },
              ),
              _FeatureItem(
                title: 'Catat Stand KWH & BBM',
                desc: 'Kalkulator SFOC liter/kWh & efisiensi termal',
                icon: Icons.electric_meter_rounded,
                color: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CatatStandKwhScreen()));
                },
              ),
              _FeatureItem(
                title: 'Inventaris Mesin PLTD',
                desc: 'Spesifikasi genset Caterpillar, Cummins & Deutz',
                icon: Icons.precision_manufacturing_rounded,
                color: const Color(0xFF0D9488),
                onTap: () {
                  Navigator.pop(context);
                  widget.onNavigateTab?.call(1);
                },
              ),
              _FeatureItem(
                title: 'Presensi Mandiri GPS',
                desc: 'Absensi geofence operator shift di radius sentral',
                icon: Icons.pin_drop_rounded,
                color: const Color(0xFF10B981),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PresensiGpsScreen()));
                },
              ),
            ]),
            const SizedBox(height: 24),

            // KATEGORI 3: LOGISTIK & GUDANG
            _buildSectionHeader('LOGISTIK & SUKU CADANG', Icons.inventory_2_rounded, const Color(0xFF6366F1)),
            const SizedBox(height: 10),
            _buildFeatureGrid([
              _FeatureItem(
                title: 'Stok Part & Oli Pelumas',
                desc: 'Katalog gudang filter, oli drum & sparepart mesin',
                icon: Icons.warehouse_rounded,
                color: const Color(0xFF6366F1),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StokPartScreen()));
                },
              ),
              _FeatureItem(
                title: 'Export & Import Data',
                desc: 'Unduh laporan resmi Excel .xlsx dan Berita Acara PDF',
                icon: Icons.import_export_rounded,
                color: const Color(0xFF00A2E8),
                onTap: () {
                  Navigator.pop(context);
                  widget.onNavigateTab?.call(2);
                },
              ),
            ]),
            const SizedBox(height: 24),

            // KATEGORI 4: K3 & KESELAMATAN KERJA
            _buildSectionHeader('STANDAR K3 & KESELAMATAN KERJA', Icons.shield_rounded, const Color(0xFF10B981)),
            const SizedBox(height: 10),
            _buildFeatureGrid([
              _FeatureItem(
                title: 'Pedoman K3 & SOP Mesin',
                desc: 'Panduan APD, 7 Golden LOTO Rules & Start-Stop',
                icon: Icons.menu_book_rounded,
                color: const Color(0xFF10B981),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SopK3Screen()));
                },
              ),
              _FeatureItem(
                title: 'Tanggap Darurat 24 Jam',
                desc: 'Prosedur pemadaman api, P3K & hotline dispatcher',
                icon: Icons.emergency_rounded,
                color: const Color(0xFFDC2626),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SopK3Screen()));
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid(List<_FeatureItem> items) {
    final filtered = items.where((i) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return i.title.toLowerCase().contains(q) || i.desc.toLowerCase().contains(q);
    }).toList();

    if (filtered.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final item = filtered[index];
        return InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(item.icon, color: item.color, size: 22),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), height: 1.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FeatureItem {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _FeatureItem({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
