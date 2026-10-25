import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/api_service.dart';
import 'riwayat_har_screen.dart';

class BuatHARScreen extends StatefulWidget {
  final String? initialTimeSlot;
  final MachineModel? preselectedMachine;

  const BuatHARScreen({
    super.key,
    this.initialTimeSlot,
    this.preselectedMachine,
  });

  @override
  State<BuatHARScreen> createState() => _BuatHARScreenState();
}

class _BuatHARScreenState extends State<BuatHARScreen> {
  int _currentStep = 0;
  late ConfettiController _confettiController;
  bool _isLoading = true;
  bool _isSubmitting = false;

  UnitModel? _activeUnit;
  List<MachineModel> _machines = [];
  MachineModel? _selectedMachine;

  // Step 1: Info & Operational Params
  late String _selectedTimeSlot;
  final TextEditingController _customJamController = TextEditingController();
  bool _useCustomJam = false;

  final _dayaMampuController = TextEditingController(text: '450');
  final _bebanController = TextEditingController(text: '380');
  final _standKwhController = TextEditingController(text: '12450.5');
  final _standBbmController = TextEditingController(text: '2800');
  final _jamKerjaController = TextEditingController(text: '1420');
  final _tekOliController = TextEditingController(text: '4.2');

  // Step 2: Realistic Checklist
  final List<HARChecklistItem> _checklists = [
    HARChecklistItem(title: 'Level & Volume Oli Karter', category: 'Sistem Pelumasan', condition: 'baik'),
    HARChecklistItem(title: 'Tekanan Oli Mesin (3.5 - 5.5 Bar)', category: 'Sistem Pelumasan', condition: 'baik'),
    HARChecklistItem(title: 'Filter Pelumas & Bebas Rembesan', category: 'Sistem Pelumasan', condition: 'baik'),
    HARChecklistItem(title: 'Level Coolant / Air Radiator', category: 'Sistem Pendingin', condition: 'baik'),
    HARChecklistItem(title: 'Kondisi & Ketegangan Fan Belt', category: 'Sistem Pendingin', condition: 'baik'),
    HARChecklistItem(title: 'Temperatur Air Pendingin (<85°C)', category: 'Sistem Pendingin', condition: 'baik'),
    HARChecklistItem(title: 'Filter Solar Racor & Saluran Solar', category: 'Sistem Bahan Bakar', condition: 'baik'),
    HARChecklistItem(title: 'Feed Pump & Pipa Injeksi Bebas Bocor', category: 'Sistem Bahan Bakar', condition: 'baik'),
    HARChecklistItem(title: 'Kebersihan Filter Udara (Air Cleaner)', category: 'Sistem Udara', condition: 'baik'),
    HARChecklistItem(title: 'Turbocharger & Pipa Exhaust Manifold', category: 'Sistem Udara', condition: 'baik'),
    HARChecklistItem(title: 'Baterai / Aki Starter & Alternator', category: 'Sistem Elektrikal', condition: 'baik'),
    HARChecklistItem(title: 'Tegangan (380V) & Frekuensi (50Hz)', category: 'Sistem Elektrikal', condition: 'baik'),
  ];

  // Step 3: Temuan & Tindakan
  final _temuanController = TextEditingController(text: 'Kondisi komponen mesin secara umum baik dan dalam batas toleransi aman.');
  final _tindakanController = TextEditingController(text: 'Pemeriksaan rutin berkala, pembersihan filter, dan pengencangan koneksi.');

  // Step 4: Foto
  bool _hasPhotoBefore = true;
  bool _hasPhotoProcess = true;
  bool _hasPhotoAfter = true;

  final List<String> _allTimeSlots = [
    "00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00",
    "07:00", "08:00", "09:00", "10:00", "11:00", "12:00",
    "13:00", "14:00", "15:00", "16:00", "17:00", "18:00",
    "19:00", "20:00", "21:00", "22:00", "23:00", "24:00"
  ];

  @override
  void initState() {
    super.initState();
    _selectedTimeSlot = widget.initialTimeSlot ?? '08:00';
    _customJamController.text = _selectedTimeSlot;
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadInitialData();
  }

  void _loadInitialData() async {
    final unit = await ApiService.getSelectedUnit();
    final machines = await ApiService.getMachines(kdUnit: unit.kdUnit);
    if (mounted) {
      setState(() {
        _activeUnit = unit;
        _machines = machines;
        if (widget.preselectedMachine != null) {
          _selectedMachine = machines.firstWhere(
            (m) => m.idMesin == widget.preselectedMachine!.idMesin,
            orElse: () => machines.first,
          );
        } else {
          _selectedMachine = machines.isNotEmpty ? machines.first : null;
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _customJamController.dispose();
    _dayaMampuController.dispose();
    _bebanController.dispose();
    _standKwhController.dispose();
    _standBbmController.dispose();
    _jamKerjaController.dispose();
    _tekOliController.dispose();
    _temuanController.dispose();
    _tindakanController.dispose();
    super.dispose();
  }

  String get _finalJamValue {
    if (_useCustomJam && _customJamController.text.trim().isNotEmpty) {
      return _customJamController.text.trim();
    }
    return _selectedTimeSlot;
  }

  void _setAllChecklist(String condition) {
    setState(() {
      for (var item in _checklists) {
        item.condition = condition;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Semua 12 checklist diatur ke: ${condition.toUpperCase()}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _applyQuickTemplate(String temuan, String tindakan) {
    setState(() {
      _temuanController.text = temuan;
      _tindakanController.text = tindakan;
    });
  }

  void _handleSubmit() async {
    if (_selectedMachine == null) return;
    setState(() => _isSubmitting = true);

    final generatedNumber = 'HAR-2026-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(5, '0')}';

    final newHAR = HARModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      harNumber: generatedNumber,
      kdUnit: _activeUnit?.kdUnit ?? '0264',
      unitName: _activeUnit?.namaUnit ?? 'ULD BATU AMPAR',
      idMesin: _selectedMachine!.idMesin,
      machineName: _selectedMachine!.namaMesin,
      date: '2026-08-${DateTime.now().day.toString().padLeft(2, '0')}',
      timeSlot: _finalJamValue,
      status: 'submitted',
      priority: 'NORMAL',
      maintenanceType: 'preventive',
      technicianName: 'Ahmad Teknisi',
      findingDescription: _temuanController.text,
      actionTaken: _tindakanController.text,
      finalResult: 'Normal Andal',
      dayaMampu: double.tryParse(_dayaMampuController.text) ?? 450.0,
      beban: double.tryParse(_bebanController.text) ?? 380.0,
      standKwh: double.tryParse(_standKwhController.text) ?? 12450.5,
      standBbm: double.tryParse(_standBbmController.text) ?? 2800.0,
      jamKerjaMesin: double.tryParse(_jamKerjaController.text) ?? 1420.0,
      tekananOli: double.tryParse(_tekOliController.text) ?? 4.2,
      checklists: _checklists,
      photos: [
        if (_hasPhotoBefore) 'foto_before.jpg',
        if (_hasPhotoProcess) 'foto_process.jpg',
        if (_hasPhotoAfter) 'foto_after.jpg',
      ],
    );

    await ApiService.submitHAR(newHAR);
    setState(() => _isSubmitting = false);
    _confettiController.play();

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 28),
              ),
              const SizedBox(width: 12),
              const Text('Checklist Terkirim!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nomor Tiket: $generatedNumber', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.accentGreen)),
                    const SizedBox(height: 4),
                    Text('Mesin: ${_selectedMachine!.namaMesin}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('Slot: $_finalJamValue • Menunggu Validasi SPV', style: const TextStyle(fontSize: 11, color: AppTheme.outline)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Data pemeliharaan & pembacaan parameter telah tersimpan ke database regional PLN Nusa Daya.',
                style: TextStyle(fontSize: 12, color: AppTheme.outline),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RiwayatHARScreen()),
                );
              },
              child: const Text('Buka Riwayat', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ke Dashboard', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.primary)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('Checklist HAR & Logsheet (${_currentStep + 1}/5)'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Responsive Horizontal Step Tracker Header (Never Overflows!)
              _buildResponsiveStepHeader(),

              // 2. Active Step Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  physics: const BouncingScrollPhysics(),
                  child: _buildStepContent(_currentStep),
                ),
              ),

              // 3. Bottom Action Navigation Bar
              _buildBottomActionButtons(),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }

  // 1. Responsive Horizontal Step Header (Guaranteed NO Overflow)
  Widget _buildResponsiveStepHeader() {
    final stepNames = [
      {'title': 'Info Mesin', 'icon': Icons.tune_rounded},
      {'title': 'Checklist (12)', 'icon': Icons.checklist_rounded},
      {'title': 'Temuan & Solusi', 'icon': Icons.assignment_late_rounded},
      {'title': 'Foto Dokumentasi', 'icon': Icons.photo_camera_rounded},
      {'title': 'Review & Kirim', 'icon': Icons.verified_rounded},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Column(
        children: [
          // Linear progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / 5,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00A2E8)),
                minHeight: 5,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Horizontal scrollable step pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: List.generate(stepNames.length, (index) {
                final isCurrent = _currentStep == index;
                final isPassed = _currentStep > index;
                final item = stepNames[index];

                return GestureDetector(
                  onTap: () => setState(() => _currentStep = index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFF00A2E8)
                          : isPassed
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFF008CC8)
                            : isPassed
                                ? const Color(0xFF86EFAC)
                                : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent
                                ? Colors.white
                                : isPassed
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF94A3B8),
                          ),
                          child: Center(
                            child: isPassed
                                ? const Icon(Icons.check, size: 12, color: Colors.white)
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: isCurrent ? const Color(0xFF00A2E8) : Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                            color: isCurrent
                                ? Colors.white
                                : isPassed
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Active Step Content Dispatcher
  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _buildStep1Info();
      case 1:
        return _buildStep2Checklist();
      case 2:
        return _buildStep3Temuan();
      case 3:
        return _buildStep4Foto();
      case 4:
        return _buildStep5Review();
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1: Info Mesin & Parameter
  Widget _buildStep1Info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Mesin Pembangkit', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primary, width: 1.5),
            boxShadow: AppTheme.softShadow,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<MachineModel>(
              value: _selectedMachine,
              isExpanded: true,
              items: _machines.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(m.namaMesin, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedMachine = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Time Slot Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Slot Jam Laporan (00:00 - 24:00)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
            TextButton(
              onPressed: () => setState(() => _useCustomJam = !_useCustomJam),
              child: Text(
                _useCustomJam ? 'Pilih dari List' : 'Ketik Jam Manual',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary),
              ),
            ),
          ],
        ),
        if (!_useCustomJam) ...[
          DropdownButtonFormField<String>(
            initialValue: _allTimeSlots.contains(_selectedTimeSlot) ? _selectedTimeSlot : _allTimeSlots.first,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            items: _allTimeSlots.map((t) => DropdownMenuItem(value: t, child: Text('Slot $t WITA', style: const TextStyle(fontWeight: FontWeight.w700)))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedTimeSlot = val);
            },
          ),
        ] else ...[
          TextField(
            controller: _customJamController,
            decoration: InputDecoration(
              hintText: 'Contoh: 11:30 atau 07:15',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
        const SizedBox(height: 18),

        // Technical Measurements
        const Text('Parameter Operasi Real-Time', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildParamField('Daya Mampu (kW)', _dayaMampuController)),
            const SizedBox(width: 10),
            Expanded(child: _buildParamField('Beban (kW)', _bebanController)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildParamField('Stand KWH', _standKwhController)),
            const SizedBox(width: 10),
            Expanded(child: _buildParamField('Stand BBM (L)', _standBbmController)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildParamField('Jam Kerja (HM)', _jamKerjaController)),
            const SizedBox(width: 10),
            Expanded(child: _buildParamField('Tek. Oli (Bar)', _tekOliController)),
          ],
        ),
      ],
    );
  }

  // Step 2: Realistic Checklist
  Widget _buildStep2Checklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Item Inspeksi Komponen', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
            ElevatedButton.icon(
              onPressed: () => _setAllChecklist('baik'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.flash_on_rounded, size: 14),
              label: const Text('Set Semua BAIK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ..._checklists.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: item.condition == 'rusak'
                    ? AppTheme.accentRed
                    : item.condition == 'perbaikan'
                        ? AppTheme.secondary
                        : AppTheme.outlineVariant,
              ),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(item.category, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.outline)),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildChecklistChip(item, 'baik', 'Baik', AppTheme.accentGreen),
                    _buildChecklistChip(item, 'perbaikan', 'Perlu Cek', const Color(0xFFD97706)),
                    _buildChecklistChip(item, 'rusak', 'Rusak', AppTheme.accentRed),
                    _buildChecklistChip(item, 'skip', 'Skip', Colors.grey),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Step 3: Temuan & Tindakan
  Widget _buildStep3Temuan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Template Cepat (Ketuk untuk Mengisi):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.outline)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ActionChip(
              label: const Text('✅ Mesin Normal & Andal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              onPressed: () => _applyQuickTemplate('Kondisi mesin normal dan parameter dalam batas aman.', 'Pemeriksaan rutin berkala dan pembersihan area unit.'),
            ),
            ActionChip(
              label: const Text('🔧 Bersihkan Filter Oli', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              onPressed: () => _applyQuickTemplate('Filter oli sedikit tersumbat residu pembakaran.', 'Dilakukan pembersihan housing filter dan penggantian elemen.'),
            ),
            ActionChip(
              label: const Text('💧 Cek Air Radiator', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              onPressed: () => _applyQuickTemplate('Level coolant radiator turun 5 cm dari batas normal.', 'Penambahan cairan coolant dan pengecekan kebocoran klem selang.'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Deskripsi Temuan Lapangan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
        const SizedBox(height: 6),
        TextField(
          controller: _temuanController,
          maxLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 14),
        const Text('Tindakan Pemeliharaan / Solusi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
        const SizedBox(height: 6),
        TextField(
          controller: _tindakanController,
          maxLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  // Step 4: Foto Dokumentasi
  Widget _buildStep4Foto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dokumentasi Foto Lapangan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
        const SizedBox(height: 4),
        const Text('Lampirkan foto fisik komponen mesin sebelum, saat, dan sesudah pemeliharaan.', style: TextStyle(fontSize: 12, color: AppTheme.outline)),
        const SizedBox(height: 14),
        _buildPhotoSlot('Foto Sebelum (Before)', _hasPhotoBefore, () => setState(() => _hasPhotoBefore = !_hasPhotoBefore)),
        const SizedBox(height: 10),
        _buildPhotoSlot('Foto Saat Pekerjaan (Process)', _hasPhotoProcess, () => setState(() => _hasPhotoProcess = !_hasPhotoProcess)),
        const SizedBox(height: 10),
        _buildPhotoSlot('Foto Setelah Selesai (After)', _hasPhotoAfter, () => setState(() => _hasPhotoAfter = !_hasPhotoAfter)),
      ],
    );
  }

  // Step 5: Review & Submit
  Widget _buildStep5Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.primary, width: 1.5),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _activeUnit?.namaUnit ?? 'ULD BATU AMPAR',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.primaryDark),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('SIAP SUBMIT', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
              const Divider(height: 16),
              Text('Mesin: ${_selectedMachine?.namaMesin ?? "-"}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 2),
              Text('Slot Jam Laporan: $_finalJamValue WITA (24 Jam)', style: const TextStyle(fontSize: 12, color: AppTheme.outline)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Daya Mampu: ${_dayaMampuController.text} kW', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('Beban: ${_bebanController.text} kW', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tek. Oli: ${_tekOliController.text} Bar', style: const TextStyle(fontSize: 12)),
                        Text('Jam Kerja: ${_jamKerjaController.text} HM', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text('Checklist Komponen: ${_checklists.where((c) => c.condition == 'baik').length}/${_checklists.length} Baik', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 4),
              Text('Temuan: ${_temuanController.text.isNotEmpty ? _temuanController.text : "Kondisi mesin normal"}', style: const TextStyle(fontSize: 11, color: AppTheme.outline), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Bottom Action Navigation Bar (Responsive, Never Overflows)
  Widget _buildBottomActionButtons() {
    final isLastStep = _currentStep == 4;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Back Button
            if (_currentStep > 0) ...[
              OutlinedButton.icon(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF475569)),
                label: const Text('Kembali', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF475569))),
              ),
              const SizedBox(width: 10),
            ],

            // Next / Submit Button
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: isLastStep
                      ? const LinearGradient(
                          colors: [Color(0xFFFFD500), Color(0xFFFFB700)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF0072B2), Color(0xFF00A2E8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isLastStep
                          ? const Color(0xFFFFD500).withValues(alpha: 0.4)
                          : const Color(0xFF00A2E8).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          if (!isLastStep) {
                            setState(() => _currentStep++);
                          } else {
                            _handleSubmit();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLastStep ? 'Kirim Laporan HAR' : 'Lanjutkan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: isLastStep ? const Color(0xFF002244) : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              isLastStep ? Icons.send_rounded : Icons.arrow_forward_rounded,
                              size: 16,
                              color: isLastStep ? const Color(0xFF002244) : Colors.white,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParamField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.outline)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistChip(HARChecklistItem item, String val, String label, Color color) {
    final isSelected = item.condition == val;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : color)),
      selected: isSelected,
      selectedColor: color,
      onSelected: (_) => setState(() => item.condition = val),
    );
  }

  Widget _buildPhotoSlot(String label, bool isAttached, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isAttached ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isAttached ? AppTheme.accentGreen : AppTheme.outlineVariant),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isAttached ? AppTheme.accentGreen.withValues(alpha: 0.15) : AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isAttached ? Icons.check_circle_rounded : Icons.camera_alt_rounded,
                color: isAttached ? AppTheme.accentGreen : AppTheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
                  const SizedBox(height: 2),
                  Text(
                    isAttached ? 'Foto terlampir (Watermark GPS & Time aktif)' : 'Ketuk untuk mengambil / melampirkan foto',
                    style: const TextStyle(fontSize: 11, color: AppTheme.outline),
                  ),
                ],
              ),
            ),
            Icon(Icons.touch_app_rounded, size: 16, color: AppTheme.outline.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}
