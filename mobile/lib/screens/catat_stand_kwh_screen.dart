import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CatatStandKwhScreen extends StatefulWidget {
  const CatatStandKwhScreen({super.key});

  @override
  State<CatatStandKwhScreen> createState() => _CatatStandKwhScreenState();
}

class _CatatStandKwhScreenState extends State<CatatStandKwhScreen> {
  static const String _keyStandLogs = 'pln_har_stand_meter_logs';

  final _formKey = GlobalKey<FormState>();

  String _selectedUnit = 'PLTD Unit 1 - Cummins KTA50-G3 (1000 kW)';
  String _selectedShift = 'Shift 1 (07:00 - 15:00)';

  final _kwhAwalController = TextEditingController(text: '1245820');
  final _kwhAkhirController = TextEditingController(text: '1249960');

  final _bbmAwalController = TextEditingController(text: '4500');
  final _bbmTerimaController = TextEditingController(text: '0');
  final _bbmAkhirController = TextEditingController(text: '3390');

  double _prodGross = 4140.0;
  double _konsumsiBbm = 1110.0;
  double _sfoc = 0.268;

  bool _isLoading = true;
  List<Map<String, dynamic>> _standLogs = [];

  @override
  void initState() {
    super.initState();
    _recalculate();
    _loadLogs();
  }

  void _recalculate() {
    final kwhAwal = double.tryParse(_kwhAwalController.text) ?? 0.0;
    final kwhAkhir = double.tryParse(_kwhAkhirController.text) ?? 0.0;
    _prodGross = (kwhAkhir - kwhAwal).clamp(0.0, 99999999.0);

    final bbmAwal = double.tryParse(_bbmAwalController.text) ?? 0.0;
    final bbmTerima = double.tryParse(_bbmTerimaController.text) ?? 0.0;
    final bbmAkhir = double.tryParse(_bbmAkhirController.text) ?? 0.0;
    _konsumsiBbm = ((bbmAwal + bbmTerima) - bbmAkhir).clamp(0.0, 99999999.0);

    if (_prodGross > 0) {
      _sfoc = _konsumsiBbm / _prodGross;
    } else {
      _sfoc = 0.0;
    }

    setState(() {});
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_keyStandLogs);

    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(rawJson);
        _standLogs = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (_) {
        _standLogs = _getDefaultLogs();
      }
    } else {
      _standLogs = _getDefaultLogs();
      await _saveLogs();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStandLogs, jsonEncode(_standLogs));
  }

  List<Map<String, dynamic>> _getDefaultLogs() {
    final now = DateTime.now();
    final df = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return [
      {
        'unit': 'PLTD Unit 1 - Cummins KTA50-G3',
        'shift': 'Shift 1 (Pagi)',
        'waktu': df.format(now.subtract(const Duration(days: 1))),
        'gross': '4,280 kWh',
        'solar': '1,150 Liter',
        'sfoc': '0.268 L/kWh',
        'status': 'Sangat Efisien',
      },
      {
        'unit': 'PLTD Unit 2 - Caterpillar 3516B',
        'shift': 'Shift 2 (Siang)',
        'waktu': df.format(now.subtract(const Duration(days: 1, hours: 8))),
        'gross': '6,540 kWh',
        'solar': '1,780 Liter',
        'sfoc': '0.272 L/kWh',
        'status': 'Sangat Efisien',
      },
      {
        'unit': 'PLTD Unit 1 - Cummins KTA50-G3',
        'shift': 'Shift 3 (Malam)',
        'waktu': df.format(now.subtract(const Duration(days: 2))),
        'gross': '3,920 kWh',
        'solar': '1,090 Liter',
        'sfoc': '0.278 L/kWh',
        'status': 'Normal Sesuai Standar',
      },
    ];
  }

  void _simpanPencatatan() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final df = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    String statusEfisiensi = 'Normal';
    if (_sfoc < 0.275) {
      statusEfisiensi = 'Sangat Efisien';
    } else if (_sfoc <= 0.300) {
      statusEfisiensi = 'Normal Sesuai Standar';
    } else {
      statusEfisiensi = 'Boros (Perlu Cek)';
    }

    final newLog = {
      'unit': _selectedUnit.split(' (')[0],
      'shift': _selectedShift,
      'waktu': df.format(now),
      'gross': '${NumberFormat('#,##0').format(_prodGross)} kWh',
      'solar': '${NumberFormat('#,##0').format(_konsumsiBbm)} Liter',
      'sfoc': '${_sfoc.toStringAsFixed(3)} L/kWh',
      'status': statusEfisiensi,
    };

    setState(() {
      _standLogs.insert(0, newLog);
    });
    await _saveLogs();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text('Data stand meter berhasil disimpan (SFOC: ${_sfoc.toStringAsFixed(3)} L/kWh).'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color sfocColor = const Color(0xFF10B981);
    String sfocLabel = 'EFISIENSI PRIMA (< 0.280 L/kWh)';
    if (_sfoc > 0.300) {
      sfocColor = const Color(0xFFEF4444);
      sfocLabel = 'KONSUMSI BOROS (> 0.300 L/kWh)';
    } else if (_sfoc >= 0.275) {
      sfocColor = const Color(0xFFF59E0B);
      sfocLabel = 'EFISIENSI NORMAL (0.275 - 0.300 L/kWh)';
    }

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
              'Catat Stand KWH & BBM',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
            ),
            Text(
              'Stand Meter Produksi & Kalkulator SFOC Pembangkit',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A2E8)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Top Calculated SFOC Indicator Card
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF002F55), Color(0xFF00437A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Hasil Perhitungan SFOC',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF64748B)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: sfocColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                sfocLabel,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: sfocColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _sfoc.toStringAsFixed(3),
                              style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: sfocColor, letterSpacing: -1),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Liter / kWh',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Text('Produksi Gross', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text('${NumberFormat('#,##0').format(_prodGross)} kWh', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                            Expanded(
                              child: Column(
                                children: [
                                  const Text('Konsumsi BBM', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text('${NumberFormat('#,##0').format(_konsumsiBbm)} Liter', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form Inputs
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Unit selector
                    const Text('Unit Mesin Pembangkit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'PLTD Unit 1 - Cummins KTA50-G3 (1000 kW)', child: Text('PLTD Unit 1 - Cummins KTA50-G3 (1000 kW)', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'PLTD Unit 2 - Caterpillar 3516B (1200 kW)', child: Text('PLTD Unit 2 - Caterpillar 3516B (1200 kW)', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'PLTD Unit 3 - Deutz BV6M628 (800 kW)', child: Text('PLTD Unit 3 - Deutz BV6M628 (800 kW)', style: TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) => setState(() => _selectedUnit = v!),
                    ),
                    const SizedBox(height: 16),

                    // Shift selector
                    const Text('Shift Operasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedShift,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Shift 1 (07:00 - 15:00)', child: Text('Shift 1 (07:00 - 15:00)', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'Shift 2 (15:00 - 23:00)', child: Text('Shift 2 (15:00 - 23:00)', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'Shift 3 (23:00 - 07:00)', child: Text('Shift 3 (23:00 - 07:00)', style: TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) => setState(() => _selectedShift = v!),
                    ),
                    const SizedBox(height: 20),

                    // Section: Stand KWH Meter
                    const Row(
                      children: [
                        Icon(Icons.electric_meter_rounded, color: Color(0xFF0072B2), size: 18),
                        SizedBox(width: 6),
                        Text('Stand Meter KWH Produksi Generator', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Stand Awal (kWh)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _kwhAwalController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _recalculate(),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Stand Akhir (kWh)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _kwhAkhirController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _recalculate(),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section: Bahan Bakar Minyak (Solar / HSD)
                    const Row(
                      children: [
                        Icon(Icons.local_gas_station_rounded, color: Color(0xFFF59E0B), size: 18),
                        SizedBox(width: 6),
                        Text('Level Tangki Harian BBM Solar (Liter)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Level Awal (L)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _bbmAwalController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _recalculate(),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Penerimaan (L)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _bbmTerimaController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _recalculate(),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Level Akhir (L)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _bbmAkhirController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _recalculate(),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF0072B2), Color(0xFF00A2E8)]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00A2E8).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _simpanPencatatan,
                        icon: const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                        label: const Text('Simpan Data Stand & Hasil SFOC', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // History Section
                    const Text('Riwayat Stand Meter & SFOC Terakhir', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const SizedBox(height: 12),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _standLogs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = _standLogs[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item['unit'] ?? '', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5, color: Color(0xFF0F172A))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(item['status'] ?? '', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item['shift']} | ${item['waktu']}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                  Text(item['sfoc'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0072B2))),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Gross: ${item['gross']} • BBM: ${item['solar']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      },
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
}
