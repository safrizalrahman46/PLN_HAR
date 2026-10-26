import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaporAMCScreen extends StatefulWidget {
  const LaporAMCScreen({super.key});

  @override
  State<LaporAMCScreen> createState() => _LaporAMCScreenState();
}

class _LaporAMCScreenState extends State<LaporAMCScreen> {
  static const String _keyAmcReports = 'pln_har_amc_reports';

  String _selectedFilter = 'Semua';
  bool _isLoading = true;
  List<Map<String, dynamic>> _reports = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_keyAmcReports);

    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(rawJson);
        _reports = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (_) {
        _reports = _getDefaultSampleReports();
      }
    } else {
      _reports = _getDefaultSampleReports();
      await _saveReports();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAmcReports, jsonEncode(_reports));
  }

  List<Map<String, dynamic>> _getDefaultSampleReports() {
    final now = DateTime.now();
    final df = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return [
      {
        'id': 'AMC-2026-10-001',
        'unit': 'PLTD Unit 2 - Caterpillar 3516B',
        'kategori': 'Mekanikal',
        'tingkat': 'Kritis',
        'judul': 'Penurunan Tekanan Oli Pelumas (Lube Oil Drop)',
        'deskripsi': 'Tekanan oli pelumas turun di bawah 2.8 bar pada saat pembebanan 850 kW. Terdengar indikasi vibrasi berlebih pada blok silinder sisi kanan.',
        'tindakan': 'Unit segera diturunkan ke idle 500 RPM, pemeriksaan filter oli pelumas dan cek kebocoran seal pompa oli sekunder.',
        'pelapor': 'Ahmad Fauzi (Teknisi Mesin)',
        'waktu': df.format(now.subtract(const Duration(hours: 2, minutes: 15))),
        'status': 'Proses Penanganan',
        'fotoBase64': null,
      },
      {
        'id': 'AMC-2026-10-002',
        'unit': 'PLTD Unit 1 - Cummins KTA50-G3',
        'kategori': 'Elektrikal',
        'tingkat': 'Sedang',
        'judul': 'Fluktuasi Tegangan AVR Exciter Generator',
        'deskripsi': 'Output tegangan phase R-S mengalami swing +/- 15V saat terjadi hentakan beban malam. Dioda penyearah rotating exciter perlu diperiksa.',
        'tindakan': 'Penggantian modul varistor dan kalibrasi trimpot stabilitas pada AVR Stamford.',
        'pelapor': 'Bambang S. (Teknisi Listrik)',
        'waktu': df.format(now.subtract(const Duration(days: 1, hours: 4))),
        'status': 'Selesai',
        'fotoBase64': null,
      },
      {
        'id': 'AMC-2026-10-003',
        'unit': 'Auxiliary - Kompresor Starting Udara',
        'kategori': 'Instrumentasi',
        'tingkat': 'Tinggi',
        'judul': 'Pressure Switch Auto-Cut Off Macet',
        'deskripsi': 'Kompresor udara start 30 bar tidak berhenti otomatis saat tabung terisi penuh. Pressure safety valve sempat meletup.',
        'tindakan': 'Cleaning contactor pressure switch Danfoss dan penyesuaian pegas kalibrasi stop.',
        'pelapor': 'Dedi Mulyadi (Operator Jaga)',
        'waktu': df.format(now.subtract(const Duration(days: 2, hours: 8))),
        'status': 'Selesai',
        'fotoBase64': null,
      },
    ];
  }

  void _showBuatLaporanModal() {
    final formKey = GlobalKey<FormState>();
    final judulController = TextEditingController();
    final deskripsiController = TextEditingController();
    final tindakanController = TextEditingController();
    final pelaporController = TextEditingController(text: 'Operator Jaga Shift');

    String selectedUnit = 'PLTD Unit 1 - Cummins KTA50-G3';
    String selectedKategori = 'Mekanikal';
    String selectedTingkat = 'Tinggi';
    String? fotoBase64;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.90,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Modal Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Form Lapor Gangguan AMC',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                            ),
                            Text(
                              'Corrective Maintenance Siaga Pembangkit',
                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),

                // Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Unit Pembangkit Dropdown
                          const Text('Unit Mesin Pembangkit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: selectedUnit,
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
                              DropdownMenuItem(value: 'Auxiliary - Kompresor Starting Udara', child: Text('Auxiliary - Kompresor Udara 30 Bar', style: TextStyle(fontSize: 13))),
                              DropdownMenuItem(value: 'Gardu Induk / Trafo Step-Up 20kV', child: Text('Gardu Induk / Trafo Step-Up 20kV', style: TextStyle(fontSize: 13))),
                            ],
                            onChanged: (v) => setModalState(() => selectedUnit = v!),
                          ),
                          const SizedBox(height: 16),

                          // Row: Kategori & Tingkat Kritis
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Kategori Gangguan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      initialValue: selectedKategori,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFFF8FAFC),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'Mekanikal', child: Text('Mekanikal', style: TextStyle(fontSize: 13))),
                                        DropdownMenuItem(value: 'Elektrikal', child: Text('Elektrikal', style: TextStyle(fontSize: 13))),
                                        DropdownMenuItem(value: 'Instrumentasi', child: Text('Instrumentasi', style: TextStyle(fontSize: 13))),
                                        DropdownMenuItem(value: 'Bahan Bakar', child: Text('Bahan Bakar', style: TextStyle(fontSize: 13))),
                                      ],
                                      onChanged: (v) => setModalState(() => selectedKategori = v!),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Tingkat Keparahan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      initialValue: selectedTingkat,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFFF8FAFC),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'Kritis', child: Text('Kritis / Darurat', style: TextStyle(fontSize: 13, color: Color(0xFFEF4444), fontWeight: FontWeight.bold))),
                                        DropdownMenuItem(value: 'Tinggi', child: Text('Tinggi', style: TextStyle(fontSize: 13, color: Color(0xFFF97316), fontWeight: FontWeight.bold))),
                                        DropdownMenuItem(value: 'Sedang', child: Text('Sedang', style: TextStyle(fontSize: 13, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold))),
                                        DropdownMenuItem(value: 'Ringan', child: Text('Ringan / Pantau', style: TextStyle(fontSize: 13, color: Color(0xFF00A2E8), fontWeight: FontWeight.bold))),
                                      ],
                                      onChanged: (v) => setModalState(() => selectedTingkat = v!),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Judul Gangguan
                          const Text('Judul / Gejala Utama Kerusakan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: judulController,
                            decoration: InputDecoration(
                              hintText: 'Contoh: Suhu Radiator Melebihi Batas Normal (>95°C)',
                              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),

                          // Uraian Deskripsi
                          const Text('Kronologi & Detail Gangguan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: deskripsiController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Jelaskan kondisi saat gangguan terjadi, getaran, suara abnormal, atau alarm yang aktif...',
                              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Detail wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),

                          // Rekomendasi Tindakan
                          const Text('Rekomendasi Tindakan / Kebutuhan Part', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: tindakanController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Contoh: Siapkan thermogun, periksa fan belt radiator dan bersihkan fin pendingin.',
                              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Nama Pelapor
                          const Text('Nama Pelapor / Teknisi Bertugas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: pelaporController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama pelapor wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),

                          // Foto Kerusakan
                          const Text('Foto Dokumentasi Kerusakan Mesin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                          const SizedBox(height: 8),
                          if (fotoBase64 != null)
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    base64Decode(fotoBase64!),
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    radius: 16,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                                      onPressed: () => setModalState(() => fotoBase64 = null),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final picked = await _picker.pickImage(source: ImageSource.camera, maxWidth: 800, imageQuality: 70);
                                      if (picked != null) {
                                        final bytes = await picked.readAsBytes();
                                        setModalState(() => fotoBase64 = base64Encode(bytes));
                                      }
                                    },
                                    icon: const Icon(Icons.camera_alt_rounded, size: 18, color: Color(0xFF00A2E8)),
                                    label: const Text('Buka Kamera', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00A2E8))),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFF00A2E8)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 70);
                                      if (picked != null) {
                                        final bytes = await picked.readAsBytes();
                                        setModalState(() => fotoBase64 = base64Encode(bytes));
                                      }
                                    },
                                    icon: const Icon(Icons.photo_library_rounded, size: 18, color: Color(0xFF64748B)),
                                    label: const Text('Dari Galeri', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 24),

                          // Tombol Submit Laporan
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  final newId = 'AMC-${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${(_reports.length + 1).toString().padLeft(3, '0')}';
                                  final newReport = {
                                    'id': newId,
                                    'unit': selectedUnit,
                                    'kategori': selectedKategori,
                                    'tingkat': selectedTingkat,
                                    'judul': judulController.text.trim(),
                                    'deskripsi': deskripsiController.text.trim(),
                                    'tindakan': tindakanController.text.trim().isNotEmpty ? tindakanController.text.trim() : 'Sedang dalam evaluasi teknisi lapangan.',
                                    'pelapor': pelaporController.text.trim(),
                                    'waktu': DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(DateTime.now()),
                                    'status': 'Laporan Baru (Open)',
                                    'fotoBase64': fotoBase64,
                                  };

                                  setState(() {
                                    _reports.insert(0, newReport);
                                  });
                                  _saveReports();

                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded, color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text('Laporan gangguan $newId berhasil dipublikasikan.'),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFF10B981),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                              label: const Text('Kirim Tiket Laporan Gangguan', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDetailLaporan(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0072B2).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['id'] ?? 'AMC',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0072B2), fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item['unit'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tingkat & Status Badges
                    Row(
                      children: [
                        _buildTingkatBadge(item['tingkat'] ?? 'Sedang'),
                        const SizedBox(width: 8),
                        _buildStatusBadge(item['status'] ?? 'Open'),
                        const Spacer(),
                        Text(
                          item['waktu'] ?? '',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      item['judul'] ?? '',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 14),

                    // Detail Kronologi Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.notes_rounded, size: 16, color: Color(0xFF0072B2)),
                              SizedBox(width: 6),
                              Text('Kronologi Kejadian & Gejala', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF0072B2))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['deskripsi'] ?? '-',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Tindakan Lanjutan Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF059669)),
                              SizedBox(width: 6),
                              Text('Tindakan Korektif & Rekomendasi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF059669))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['tindakan'] ?? '-',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF065F46), height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Pelapor Info
                    Row(
                      children: [
                        const Icon(Icons.person_pin_rounded, size: 18, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text('Pelapor: ${item['pelapor'] ?? 'Teknisi'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Foto Attachment if any
                    if (item['fotoBase64'] != null) ...[
                      const Text('Dokumentasi Foto di Lapangan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(item['fotoBase64']),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Action buttons to update status
                    Row(
                      children: [
                        if (item['status'] != 'Selesai')
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  item['status'] = 'Selesai';
                                });
                                _saveReports();
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Status gangguan diperbarui menjadi "Selesai (Closed)".'),
                                    backgroundColor: Color(0xFF10B981),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.done_all_rounded, size: 18, color: Colors.white),
                              label: const Text('Tandai Selesai Diperbaiki', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
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
    );
  }

  Widget _buildTingkatBadge(String tingkat) {
    Color bg;
    Color fg;
    switch (tingkat.toLowerCase()) {
      case 'kritis':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFEF4444);
        break;
      case 'tinggi':
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFFF97316);
        break;
      case 'sedang':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      default:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF00A2E8);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        tingkat.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: fg, letterSpacing: 0.3),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    if (status.toLowerCase().contains('selesai')) {
      bg = const Color(0xFFECFDF5);
      fg = const Color(0xFF10B981);
    } else if (status.toLowerCase().contains('proses')) {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF2563EB);
    } else {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        status,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _reports.where((r) {
      if (_selectedFilter == 'Semua') return true;
      if (_selectedFilter == 'Aktif' && r['status'] != 'Selesai') return true;
      if (_selectedFilter == 'Selesai' && r['status'] == 'Selesai') return true;
      if (_selectedFilter == 'Kritis' && (r['tingkat'] as String).toLowerCase() == 'kritis') return true;
      return true;
    }).toList();

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
              'Lapor Gangguan (AMC)',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
            ),
            Text(
              'Corrective Maintenance & Gangguan Mesin',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadReports,
            tooltip: 'Segarkan Data',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showBuatLaporanModal,
        backgroundColor: const Color(0xFFEF4444),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_alert_rounded, size: 20),
        label: const Text('Lapor Gangguan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A2E8)))
          : Column(
              children: [
                // Top Statistics Banner
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF002F55),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Laporan',
                          value: '${_reports.length}',
                          icon: Icons.assignment_late_outlined,
                          color: const Color(0xFF00A2E8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Gangguan Aktif',
                          value: '${_reports.where((r) => r['status'] != 'Selesai').length}',
                          icon: Icons.warning_rounded,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Diselesaikan',
                          value: '${_reports.where((r) => r['status'] == 'Selesai').length}',
                          icon: Icons.check_circle_outline_rounded,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter Chips
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'Aktif', 'Kritis', 'Selesai'].map((f) {
                        final isSel = _selectedFilter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(f, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: isSel ? Colors.white : const Color(0xFF475569))),
                            selected: isSel,
                            selectedColor: const Color(0xFF0072B2),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: isSel ? const Color(0xFF0072B2) : const Color(0xFFCBD5E1)),
                            onSelected: (_) => setState(() => _selectedFilter = f),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // List of AMC Tickets
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.verified_rounded, size: 48, color: Color(0xFF10B981)),
                              ),
                              const SizedBox(height: 12),
                              const Text('Seluruh Unit Mesin Beroperasi Normal', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                              const SizedBox(height: 4),
                              const Text('Tidak ada laporan gangguan aktif pada filter ini.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return _buildTicketCard(item);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> item) {
    return InkWell(
      onTap: () => _showDetailLaporan(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: ID, Tingkat, Status
            Row(
              children: [
                Text(
                  item['id'] ?? 'AMC',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0072B2), fontSize: 11.5),
                ),
                const SizedBox(width: 8),
                _buildTingkatBadge(item['tingkat'] ?? 'Sedang'),
                const Spacer(),
                _buildStatusBadge(item['status'] ?? 'Open'),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              item['judul'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),

            // Unit
            Row(
              children: [
                const Icon(Icons.precision_manufacturing_rounded, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item['unit'] ?? '',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Short Description
            Text(
              item['deskripsi'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
            ),
            const SizedBox(height: 12),

            // Bottom metadata
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 13, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text(
                      item['pelapor'] ?? 'Teknisi',
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  item['waktu'] ?? '',
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
