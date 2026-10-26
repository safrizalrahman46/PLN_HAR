import 'package:flutter/material.dart';

class SopK3Screen extends StatefulWidget {
  const SopK3Screen({super.key});

  @override
  State<SopK3Screen> createState() => _SopK3ScreenState();
}

class _SopK3ScreenState extends State<SopK3Screen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, bool> _apdChecklist = {
    'Helm Safety Industri (SNI/ANSI Z89.1) dengan tali dagu terpasang': true,
    'Sepatu Safety Steel Toe (Perlindungan benturan 200J & anti-slip oli)': true,
    'Ear Plug / Ear Muff Noise Reduction (Peredam kebisingan mesin >85 dB)': true,
    'Kacamata Pengaman (Safety Goggles) anti-percikan bahan kimia / oli': true,
    'Sarung Tangan Kerja Mekanikal / Isolasi Tegangan Rendah': true,
    'Rompi Reflektif High-Visibility (Hi-Vis PLN)': true,
    'Wearpack / Coverall Katun Tahan Panas Flame-Retardant': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
              'Pedoman K3 & SOP Mesin',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
            ),
            Text(
              'Standar Keselamatan Kerja & Prosedur Operasi Zero Accident',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: const Color(0xFFFFD500),
          indicatorWeight: 3,
          labelColor: const Color(0xFFFFD500),
          unselectedLabelColor: const Color(0xFF94A3B8),
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.shield_rounded, size: 18), text: 'Standar APD'),
            Tab(icon: Icon(Icons.lock_person_rounded, size: 18), text: 'Prosedur LOTO'),
            Tab(icon: Icon(Icons.settings_power_rounded, size: 18), text: 'SOP Start-Stop'),
            Tab(icon: Icon(Icons.emergency_rounded, size: 18), text: 'Tanggap Darurat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApdTab(),
          _buildLotoTab(),
          _buildSopStartStopTab(),
          _buildTanggapDaruratTab(),
        ],
      ),
    );
  }

  // ==================== TAB 1: STANDAR APD ====================
  Widget _buildApdTab() {
    final allChecked = _apdChecklist.values.every((v) => v);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Zero Accident
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF065F46), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF059669).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('KOMITMEN ZERO ACCIDENT', style: TextStyle(color: Color(0xFFA7F3D0), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
                      SizedBox(height: 2),
                      Text('Tidak Ada Pekerjaan yang Bernilai Tanpa Keselamatan Jiwa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Title & Description
          const Text('Checklist Verifikasi Kelayakan APD Shift', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          const Text('Pastikan seluruh Alat Pelindung Diri di bawah ini dalam kondisi layak pakai sebelum memasuki area mesin sentral PLTD.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4)),
          const SizedBox(height: 14),

          // APD Items List
          ..._apdChecklist.keys.map((key) {
            final checked = _apdChecklist[key]!;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: checked ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0)),
              ),
              child: CheckboxListTile(
                value: checked,
                activeColor: const Color(0xFF059669),
                title: Text(
                  key,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: checked ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                  ),
                ),
                onChanged: (val) {
                  setState(() => _apdChecklist[key] = val ?? false);
                },
              ),
            );
          }),
          const SizedBox(height: 16),

          // Submit Verification Button
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: allChecked
                    ? [const Color(0xFF059669), const Color(0xFF10B981)]
                    : [const Color(0xFF64748B), const Color(0xFF94A3B8)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(allChecked
                            ? 'Verifikasi APD Berhasil: Status Siap Masuk Ruang Mesin!'
                            : 'Perhatian: Ada APD yang belum lengkap! Harap penuhi sebelum bekerja.'),
                      ],
                    ),
                    backgroundColor: allChecked ? const Color(0xFF059669) : const Color(0xFFF59E0B),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.assignment_turned_in_rounded, color: Colors.white, size: 20),
              label: Text(
                allChecked ? 'Konfirmasi APD Lengkap & Terverifikasi' : 'Simpan Checklist APD',
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ==================== TAB 2: PROSEDUR LOTO ====================
  Widget _buildLotoTab() {
    final lotoSteps = [
      {
        'step': '01',
        'title': 'Pemberitahuan kepada Operator & Dispatcher',
        'desc': 'Informasikan kepada SPV Operasi dan dispatcher sebelum unit dipadamkan untuk jadwal pemeliharaan (HAR). Pastikan transfer beban ke unit lain aman.',
        'icon': Icons.campaign_rounded,
      },
      {
        'step': '02',
        'title': 'Identifikasi Seluruh Sumber Energi Berbahaya',
        'desc': 'Kenali semua sumber energi: Listrik AC 400V/20kV, DC 24V starting, sistem bahan bakar bertekanan, udara start kompresi 30 bar, dan oli panas bertekanan.',
        'icon': Icons.bolt_rounded,
      },
      {
        'step': '03',
        'title': 'Pemadaman & Penghentian Mesin (Shutdown)',
        'desc': 'Buka breaker generator (OCB/VCB), turunkan putaran mesin ke idle, matikan mesin melalui panel kontrol, dan pastikan flywheel berhenti sempurna.',
        'icon': Icons.power_settings_new_rounded,
      },
      {
        'step': '04',
        'title': 'Pemasangan Gembok LOTO (Lockout)',
        'desc': 'Kunci saklar pemutus MCCB baterai starting, pasang padlock LOTO pada tuas fuel rack stop, dan kunci katup manual saluran udara start 30 bar.',
        'icon': Icons.lock_outline_rounded,
      },
      {
        'step': '05',
        'title': 'Pemasangan Label Bahaya (Tagout)',
        'desc': 'Pasang "DANGER - DO NOT OPERATE" tag dengan mencantumkan nama teknisi, tanggal, divisi, dan estimasi waktu selesai pemeliharaan.',
        'icon': Icons.label_important_rounded,
      },
      {
        'step': '06',
        'title': 'Pembuangan Energi Sisa (Zero Energy Verification)',
        'desc': 'Lakukan bleeding tekanan sisa pada pipa bahan bakar dan tangki udara start. Lepas terminal kutub negatif aki baterai starting.',
        'icon': Icons.air_rounded,
      },
      {
        'step': '07',
        'title': 'Uji Coba Nyala Aman (Zero Energy Test)',
        'desc': 'Tekan tombol start lokal untuk memastikan unit benar-benar tidak dapat berputar (Dead Circuit). Pemeliharaan aman dimulai.',
        'icon': Icons.verified_rounded,
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: lotoSteps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = lotoSteps[index];
        return Container(
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0072B2), Color(0xFF00A2E8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    item['step'] as String,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['desc'] as String,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== TAB 3: SOP START-STOP ====================
  Widget _buildSopStartStopTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSopCard(
            title: '1. Prosedur Pre-Start Inspection (Pemeriksaan Awal)',
            icon: Icons.checklist_rtl_rounded,
            color: const Color(0xFF0072B2),
            steps: const [
              'Periksa level oli karter mesin (antara garis MIN dan MAX pada dipstick).',
              'Periksa level air pendingin radiator (expansion tank) dan visual fan belt.',
              'Drain air kondensasi pada fuel water separator tangki harian BBM.',
              'Cek tegangan baterai starting (harus berada di atas 24.5 Volt DC).',
              'Pastikan ruang mesin bebas dari kain lap, oli tumpah, atau peralatan asing.',
            ],
          ),
          const SizedBox(height: 14),

          _buildSopCard(
            title: '2. Prosedur Starting & Warm-Up',
            icon: Icons.play_arrow_rounded,
            color: const Color(0xFF10B981),
            steps: const [
              'Putar kunci kontak atau tekan tombol START pada panel genset controller.',
              'Batasi cranking maksimal 10 detik. Jika gagal, tunggu 2 menit sebelum start ulang.',
              'Periksa indikator tekanan oli langsung: Harus naik ke minimal 3.0 bar dalam 15 detik!',
              'Jalankan mesin pada putaran idle selama 3-5 menit untuk pemerataan pelumasan.',
              'Naikkan putaran ke rated RPM (1500 RPM untuk 50 Hz). Pastikan frekuensi stabil di 50.0 Hz.',
            ],
          ),
          const SizedBox(height: 14),

          _buildSopCard(
            title: '3. Sinkronisasi & Pembebanan Bertahap',
            icon: Icons.sync_alt_rounded,
            color: const Color(0xFFF59E0B),
            steps: const [
              'Aktifkan modul Automatic Voltage Regulator (AVR) dan periksa tegangan 400V (380-415V).',
              'Nyalakan lampu sinkronoskop atau modul otomatis ComAp/DeepSea.',
              'Tutup Generator Circuit Breaker (GCB) saat jarum sinkronoskop di posisi jam 12.',
              'Beri beban bertahap: 25% (10 menit) -> 50% (15 menit) -> Beban Penuh (Rated Load).',
              'Catat parameter setiap 30 menit ke dalam Logsheet WACB 48-Slot.',
            ],
          ),
          const SizedBox(height: 14),

          _buildSopCard(
            title: '4. Prosedur Normal Shut-Down & Emergency Stop',
            icon: Icons.stop_rounded,
            color: const Color(0xFFEF4444),
            steps: const [
              'Turunkan beban mesin secara bertahap sebelum membuka breaker GCB.',
              'Buka pemutus beban (GCB) dan biarkan mesin cooling down tanpa beban selama 5 menit.',
              'Tekan tombol STOP dan biarkan mesin melambat hingga berhenti sempurna.',
              'Tutup valve utama bahan bakar tangki harian dan matikan auxiliary heater.',
              'DARURAT: Tekan tombol EMERGENCY STOP merah jamur jika terjadi overspeed atau kebakaran!',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSopCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> steps,
  }) {
    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Color(0xFF0F172A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final text = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$idx',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==================== TAB 4: TANGGAP DARURAT ====================
  Widget _buildTanggapDaruratTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emergency Contacts Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF991B1B), Color(0xFFDC2626)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.contact_phone_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text('KONTAK DARURAT OPERASIONAL 24 JAM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12.5)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildEmergencyContactRow('Dispatcher Pengatur Beban PLN', '0811-5200-PLN'),
                _buildEmergencyContactRow('Piket Damkar Sektor Wilayah', '113 / (0536) 3221113'),
                _buildEmergencyContactRow('RS & Ambulans Rujukan K3', '118 / (0536) 3221234'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Protocol Cards
          _buildEmergencyCard(
            title: 'Kebakaran di Area Ruang Mesin PLTD',
            desc: '1. Segera tekan tombol EMERGENCY STOP dan bunyikan sirine bahaya.\n'
                '2. Padamkan api menggunakan APAR CO2 atau Foam (Busa). DILARANG KERAS menyemprotkan air pada panel listrik hidup!\n'
                '3. Evakuasi seluruh personil melalui jalur emergency exit menuju Assembly Point.',
            icon: Icons.local_fire_department_rounded,
            color: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 12),

          _buildEmergencyCard(
            title: 'Penanganan Korban Sengatan Listrik',
            desc: '1. Jangan sentuh korban langsung! Putuskan saklar breaker utama terlebih dahulu.\n'
                '2. Jika saklar jauh, pisahkan korban menggunakan tongkat isolasi kayu/plastik kering.\n'
                '3. Cek pernapasan dan denyut nadi, segera berikan Resusitasi Jantung Paru (CPR) bila perlu, lalu panggil tim medis.',
            icon: Icons.electric_bolt_rounded,
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 12),

          _buildEmergencyCard(
            title: 'Tumpahan Minyak B3 & Solar (Oil Spill)',
            desc: '1. Tutup segera katup sumber kebocoran pipa solar/oli.\n'
                '2. Taburkan serbuk gergaji atau oil spill boom pada parit penampung agar limbah tidak mencemari saluran pembuangan umum.\n'
                '3. Masukkan limbah terkontaminasi ke drum khusus limbah B3 berlabel resmi.',
            icon: Icons.water_drop_rounded,
            color: const Color(0xFF0072B2),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactRow(String label, String number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 11.5, fontWeight: FontWeight.w700)),
          Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
