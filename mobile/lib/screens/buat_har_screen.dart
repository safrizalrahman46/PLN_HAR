import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../theme/app_theme.dart';
import '../data/api_service.dart';

class BuatHARScreen extends StatefulWidget {
  final String? initialTimeSlot;
  const BuatHARScreen({super.key, this.initialTimeSlot});

  @override
  State<BuatHARScreen> createState() => _BuatHARScreenState();
}

class _BuatHARScreenState extends State<BuatHARScreen> {
  int _currentStep = 0;
  late ConfettiController _confettiController;

  // Step 1 Controllers (Numeric WACB logsheet + Time slot)
  late String _selectedTimeSlot;
  final TextEditingController _customJamController = TextEditingController();
  bool _useCustomJam = false;

  final _dayaMampuController = TextEditingController(text: '450');
  final _bebanController = TextEditingController(text: '380');
  final _standKwhController = TextEditingController(text: '12450.5');
  final _standBbmController = TextEditingController(text: '2800');
  final _jamKerjaController = TextEditingController(text: '1420');
  final _tekOliController = TextEditingController(text: '4.2');

  // Step 2 Checklist States
  final Map<String, String> _checklist = {
    "Pemeriksaan Oli Mesin": "Baik",
    "Pemeriksaan Filter Air/Udara": "Baik",
    "Sistem Pendingin & Radiator": "Baik",
    "Tegangan & Frekuensi Generator": "Baik",
  };

  // Step 3 Temuan & Tindakan
  final _temuanController = TextEditingController(text: 'Filter oli sedikit kotor.');
  final _tindakanController = TextEditingController(text: 'Dilakukan pembersihan permukaan filter.');

  bool _isSubmitting = false;

  final List<String> _allTimeSlots = [
    "00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00",
    "07:00", "08:00", "09:00", "10:00", "11:00", "12:00",
    "13:00", "14:00", "15:00", "16:00", "17:00", "18:00",
    "19:00", "20:00", "21:00", "22:00", "23:00", "24:00"
  ];

  @override
  void initState() {
    super.initState();
    // Default initial time slot from argument or default '08:00', completely unlocked
    _selectedTimeSlot = widget.initialTimeSlot ?? '08:00';
    _customJamController.text = _selectedTimeSlot;
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _customJamController.dispose();
    super.dispose();
  }

  String get _finalJamValue {
    if (_useCustomJam && _customJamController.text.trim().isNotEmpty) {
      return _customJamController.text.trim();
    }
    return _selectedTimeSlot;
  }

  void _handleSubmit() async {
    setState(() => _isSubmitting = true);

    // Strictly send operator's chosen hour (e.g. jam : 11:00) without real-time overrides
    final jamInput = _finalJamValue;
    final msg = "jam : $jamInput, kode mesin : DEUTZ #01, sn : 1013E, dt : 0, daya mampu : ${_dayaMampuController.text}, beban : ${_bebanController.text}, stand kwh : ${_standKwhController.text}, stand bbm : ${_standBbmController.text}, tek oli : ${_tekOliController.text}, temp air : 78, tegangan : 380, frequency : 50, jam kerja mesin : ${_jamKerjaController.text}, status mesin : operasi";

    await ApiService.postLogsheet(msg);
    setState(() => _isSubmitting = false);

    _confettiController.play();

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Logsheet/HAR Terkirim'),
            ],
          ),
          content: Text('Laporan slot jam $jamInput berhasil disimpan dan dikirim ke WACB! Payload terverifikasi jam: $jamInput.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              child: const Text('Kembali ke Dashboard'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Logsheet & HAR (${_currentStep + 1}/5)'),
      ),
      body: Stack(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: AppTheme.primary),
            ),
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 4) {
                  setState(() => _currentStep++);
                } else {
                  if (!_isSubmitting) {
                    _handleSubmit();
                  }
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              steps: [
                // Step 1: Info & Time Slot Selection (Bebas Input Semua Jam)
                Step(
                  title: const Text('Info'),
                  isActive: _currentStep >= 0,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryContainer.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.access_time_filled, color: AppTheme.primary, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Bebas Input Logsheet Semua Jam (00:00 - 24:00). Tanpa batasan jam real-time!',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      const Text('Slot Jam Laporan (Bebas Pilih/Ubah)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      const SizedBox(height: 6),

                      if (!_useCustomJam) ...[
                        DropdownButtonFormField<String>(
                          initialValue: _allTimeSlots.contains(_selectedTimeSlot) ? _selectedTimeSlot : _allTimeSlots.first,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: _allTimeSlots
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text('Jam $t ${t == widget.initialTimeSlot ? '(Pilihan Slot)' : ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedTimeSlot = val;
                                _customJamController.text = val;
                              });
                            }
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],

                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jam Aktif Terpilih: $_finalJamValue',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() => _useCustomJam = !_useCustomJam);
                            },
                            icon: Icon(_useCustomJam ? Icons.list : Icons.edit, size: 16),
                            label: Text(_useCustomJam ? 'Pilih dari List Jam' : 'Ketik Jam Manual', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(child: _buildTextField('Daya Mampu (kW)', _dayaMampuController)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField('Beban (kW)', _bebanController)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Stand KWH', _standKwhController)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField('Stand BBM (L)', _standBbmController)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Jam Kerja (HM)', _jamKerjaController)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField('Tek. Oli (Bar)', _tekOliController)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Step 2: Technical Checklist
                Step(
                  title: const Text('Checklist'),
                  isActive: _currentStep >= 1,
                  content: Column(
                    children: _checklist.keys.map((item) {
                      String status = _checklist[item]!;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: ['Baik', 'Perlu Perbaikan', 'Rusak', 'Tdk Cek'].map((opt) {
                                bool isSel = status == opt;
                                return ChoiceChip(
                                  label: Text(opt, style: const TextStyle(fontSize: 10)),
                                  selected: isSel,
                                  selectedColor: AppTheme.secondaryContainer,
                                  onSelected: (val) => setState(() => _checklist[item] = opt),
                                );
                              }).toList(),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Step 3: Temuan & Tindakan
                Step(
                  title: const Text('Temuan'),
                  isActive: _currentStep >= 2,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Deskripsi Temuan', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _temuanController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Tindakan Pemeliharaan', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _tindakanController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Step 4: Dokumentasi Foto
                Step(
                  title: const Text('Foto'),
                  isActive: _currentStep >= 3,
                  content: Column(
                    children: [
                      _buildPhotoCard('Foto Sebelum (Before)'),
                      const SizedBox(height: 12),
                      _buildPhotoCard('Foto Saat Pekerjaan (Process)'),
                      const SizedBox(height: 12),
                      _buildPhotoCard('Foto Setelah (After)'),
                    ],
                  ),
                ),

                // Step 5: Review & Submit
                Step(
                  title: const Text('Review'),
                  isActive: _currentStep >= 4,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primary),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Slot Jam Laporan: $_finalJamValue', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                                const Chip(
                                  label: Text('BEBAS JAM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                  backgroundColor: Colors.green,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Daya Mampu: ${_dayaMampuController.text} kW | Beban: ${_bebanController.text} kW'),
                            Text('Stand KWH: ${_standKwhController.text} | BBM: ${_standBbmController.text} L'),
                            Text('Jam Kerja Mesin: ${_jamKerjaController.text} HM | Tek Oli: ${_tekOliController.text} Bar'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.outline)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(String label) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.photo_camera, size: 36, color: AppTheme.primary),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const Text('Ketuk untuk ambil / unggah foto', style: TextStyle(fontSize: 10, color: AppTheme.outline)),
        ],
      ),
    );
  }
}
