import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StokPartScreen extends StatefulWidget {
  const StokPartScreen({super.key});

  @override
  State<StokPartScreen> createState() => _StokPartScreenState();
}

class _StokPartScreenState extends State<StokPartScreen> {
  static const String _keyInventory = 'pln_har_sparepart_inventory';

  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  bool _isLoading = true;
  List<Map<String, dynamic>> _inventory = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_keyInventory);

    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(rawJson);
        _inventory = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (_) {
        _inventory = _getDefaultSampleInventory();
      }
    } else {
      _inventory = _getDefaultSampleInventory();
      await _saveInventory();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveInventory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyInventory, jsonEncode(_inventory));
  }

  List<Map<String, dynamic>> _getDefaultSampleInventory() {
    return [
      {
        'id': 'PRT-FLT-001',
        'nama': 'Filter Oli Mesin Lube Oil Baldwin B7299',
        'kategori': 'Filter & Separator',
        'nomorPart': 'B7299 / CAT 1R-0716',
        'lokasi': 'Rak Gudang A-02',
        'stok': 14,
        'minStok': 6,
        'satuan': 'Pcs',
        'peruntukan': 'PLTD Cat 3516B / Cummins KTA50',
      },
      {
        'id': 'PRT-FLT-002',
        'nama': 'Filter Solar Primer Fleetguard FF5327',
        'kategori': 'Filter & Separator',
        'nomorPart': 'FF5327 / 3315843',
        'lokasi': 'Rak Gudang A-04',
        'stok': 4,
        'minStok': 8,
        'satuan': 'Pcs',
        'peruntukan': 'Cummins KTA50-G3',
      },
      {
        'id': 'PRT-FLT-003',
        'nama': 'Filter Udara Primary Donaldson P181054',
        'kategori': 'Filter & Separator',
        'nomorPart': 'P181054 / Heavy Duty',
        'lokasi': 'Rak Gudang A-06',
        'stok': 8,
        'minStok': 4,
        'satuan': 'Pcs',
        'peruntukan': 'All Diesel Generating Sets',
      },
      {
        'id': 'PRT-OIL-001',
        'nama': 'Oli Mesin Pertamina Meditran S SAE 40',
        'kategori': 'Pelumas & Coolant',
        'nomorPart': 'MED-S-SAE40-DRUM',
        'lokasi': 'Gudang B3 Bay Drum 1',
        'stok': 6,
        'minStok': 3,
        'satuan': 'Drum (209L)',
        'peruntukan': 'Pelumas Utama Silinder PLTD',
      },
      {
        'id': 'PRT-OIL-002',
        'nama': 'Oli Pelumas Shell Rimula R4 X 15W-40',
        'kategori': 'Pelumas & Coolant',
        'nomorPart': 'RIM-R4X-15W40',
        'lokasi': 'Gudang B3 Bay Drum 2',
        'stok': 2,
        'minStok': 3,
        'satuan': 'Drum (209L)',
        'peruntukan': 'Mesin High Speed Diesel',
      },
      {
        'id': 'PRT-OIL-003',
        'nama': 'Radiator Coolant Premix 50/50 Heavy Duty',
        'kategori': 'Pelumas & Coolant',
        'nomorPart': 'CLNT-HD-5050',
        'lokasi': 'Rak Kimia B-01',
        'stok': 18,
        'minStok': 10,
        'satuan': 'Pail (20L)',
        'peruntukan': 'Sistem Pendingin Radiator',
      },
      {
        'id': 'PRT-ENG-001',
        'nama': 'Fuel Injection Nozzle Bosch DLLA150P',
        'kategori': 'Komponen Mesin',
        'nomorPart': '0433171387 / DLLA150P',
        'lokasi': 'Lemari Presisi C-01',
        'stok': 12,
        'minStok': 8,
        'satuan': 'Set',
        'peruntukan': 'Injector Injector Assembly',
      },
      {
        'id': 'PRT-ENG-002',
        'nama': 'Piston Ring Set Caterpillar 3516B',
        'kategori': 'Komponen Mesin',
        'nomorPart': 'CAT-9Y-7212',
        'lokasi': 'Lemari Presisi C-03',
        'stok': 3,
        'minStok': 6,
        'satuan': 'Set',
        'peruntukan': 'Overhaul Cylinder Cat 3516B',
      },
      {
        'id': 'PRT-ENG-003',
        'nama': 'Gasket Cylinder Head Deutz BV6M628',
        'kategori': 'Komponen Mesin',
        'nomorPart': 'DTZ-0428-3380',
        'lokasi': 'Rak Flat D-01',
        'stok': 5,
        'minStok': 4,
        'satuan': 'Pcs',
        'peruntukan': 'Deutz Medium Speed Engine',
      },
      {
        'id': 'PRT-ELC-001',
        'nama': 'Pressure Transmitter Danfoss MBS3000',
        'kategori': 'Elektrikal & Sensor',
        'nomorPart': 'MBS3000-060G1125',
        'lokasi': 'Lemari Sensor E-01',
        'stok': 5,
        'minStok': 2,
        'satuan': 'Unit',
        'peruntukan': 'Monitoring Tekanan Oli 0-10 Bar',
      },
      {
        'id': 'PRT-ELC-002',
        'nama': 'Automatic Voltage Regulator (AVR) SX460',
        'kategori': 'Elektrikal & Sensor',
        'nomorPart': 'STAMFORD-SX460',
        'lokasi': 'Lemari Elektrikal E-02',
        'stok': 2,
        'minStok': 2,
        'satuan': 'Unit',
        'peruntukan': 'Generator Brushless Excitation',
      },
    ];
  }

  void _showPakaiPartModal(Map<String, dynamic> item) {
    final qtyController = TextEditingController(text: '1');
    final catatanController = TextEditingController();
    String selectedUnitTarget = 'PLTD Unit 1 - Cummins KTA50-G3';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Catat Pemakaian Suku Cadang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Item summary box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0072B2).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF0072B2), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['nama'] ?? '', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          Text('Sisa Stok Tersedia: ${item['stok']} ${item['satuan']}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF059669), fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('Unit Mesin Pemakai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: selectedUnitTarget,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'PLTD Unit 1 - Cummins KTA50-G3', child: Text('PLTD Unit 1 - Cummins KTA50-G3', style: TextStyle(fontSize: 13))),
                  DropdownMenuItem(value: 'PLTD Unit 2 - Caterpillar 3516B', child: Text('PLTD Unit 2 - Caterpillar 3516B', style: TextStyle(fontSize: 13))),
                  DropdownMenuItem(value: 'PLTD Unit 3 - Deutz BV6M628', child: Text('PLTD Unit 3 - Deutz BV6M628', style: TextStyle(fontSize: 13))),
                  DropdownMenuItem(value: 'Auxiliary System / Kompresor', child: Text('Auxiliary System / Kompresor', style: TextStyle(fontSize: 13))),
                ],
                onChanged: (v) => selectedUnitTarget = v!,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jumlah Digunakan (${item['satuan']})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Keperluan / Pekerjaan HAR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: catatanController,
                          decoration: InputDecoration(
                            hintText: 'Contoh: HAR 250 Jam',
                            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Button Submit
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0072B2), Color(0xFF00A2E8)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final qty = int.tryParse(qtyController.text) ?? 1;
                    if (qty <= 0) return;
                    if (qty > (item['stok'] as int)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Jumlah melebihi sisa stok di gudang.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      item['stok'] = (item['stok'] as int) - qty;
                    });
                    _saveInventory();

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Berhasil mengeluarkan $qty ${item['satuan']} ${item['nama']} untuk $selectedUnitTarget.'),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Konfirmasi Pengeluaran Part', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _inventory.where((item) {
      final matchCat = _selectedCategory == 'Semua' || item['kategori'] == _selectedCategory;
      final q = _searchQuery.toLowerCase();
      final matchQuery = q.isEmpty ||
          (item['nama'] as String).toLowerCase().contains(q) ||
          (item['nomorPart'] as String).toLowerCase().contains(q) ||
          (item['lokasi'] as String).toLowerCase().contains(q);
      return matchCat && matchQuery;
    }).toList();

    final totalSKU = _inventory.length;
    final needReorder = _inventory.where((i) => (i['stok'] as int) <= (i['minStok'] as int)).length;
    final aman = totalSKU - needReorder;

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
              'Stok Part & Oli Pelumas',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
            ),
            Text(
              'Manajemen Suku Cadang & Pelumas PLTD',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadInventory,
            tooltip: 'Segarkan Stok',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A2E8)))
          : Column(
              children: [
                // Top KPI Summary
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF002F55),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildKpiBox(
                          title: 'Total Katalog',
                          value: '$totalSKU Item',
                          icon: Icons.inventory_2_outlined,
                          color: const Color(0xFF00A2E8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildKpiBox(
                          title: 'Stok Aman',
                          value: '$aman Item',
                          icon: Icons.check_circle_rounded,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildKpiBox(
                          title: 'Reorder / Low',
                          value: '$needReorder Item',
                          icon: Icons.notification_important_rounded,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Cari nama filter, oli pelumas, nozzle, atau part number...',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00A2E8), size: 20),
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
                ),

                // Category Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'Filter & Separator', 'Pelumas & Coolant', 'Komponen Mesin', 'Elektrikal & Sensor'].map((cat) {
                        final isSel = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: isSel ? Colors.white : const Color(0xFF475569))),
                            selected: isSel,
                            selectedColor: const Color(0xFF0072B2),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: isSel ? const Color(0xFF0072B2) : const Color(0xFFCBD5E1)),
                            onSelected: (_) => setState(() => _selectedCategory = cat),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Parts List
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.search_off_rounded, size: 40, color: Color(0xFF94A3B8)),
                              ),
                              const SizedBox(height: 12),
                              const Text('Tidak ada suku cadang yang cocok.', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF64748B))),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return _buildPartCard(item);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildKpiBox({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildPartCard(Map<String, dynamic> item) {
    final stok = item['stok'] as int;
    final minStok = item['minStok'] as int;
    final isLow = stok <= minStok;
    final ratio = (stok / (minStok * 2.5)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isLow ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0)),
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
        children: [
          // Header Row: Category Badge & Stock Alert
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0072B2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item['kategori'] ?? '',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0072B2)),
                ),
              ),
              if (isLow)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFEF4444)),
                      SizedBox(width: 4),
                      Text('STOK KRITIS', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFFEF4444))),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('TERSEDIA', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Part Name
          Text(
            item['nama'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),

          // Part Number & Location
          Row(
            children: [
              const Icon(Icons.qr_code_2_rounded, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text('P/N: ${item['nomorPart']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
              const Spacer(),
              const Icon(Icons.place_outlined, size: 14, color: Color(0xFF00A2E8)),
              const SizedBox(width: 4),
              Text(item['lokasi'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF00A2E8))),
            ],
          ),
          const SizedBox(height: 12),

          // Stock Gauge Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sisa: $stok ${item['satuan']}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isLow ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                ),
              ),
              Text(
                'Min Buffer: $minStok ${item['satuan']}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                isLow ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Bottom Action Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showPakaiPartModal(item),
              icon: const Icon(Icons.handyman_rounded, size: 16, color: Color(0xFF0072B2)),
              label: const Text('Catat Pengeluaran / Pakai Part', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF0072B2))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0072B2)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
