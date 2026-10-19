import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/api_service.dart';
import 'buat_har_screen.dart';
import 'riwayat_har_screen.dart';
import 'daftar_mesin_screen.dart';
import 'pilih_unit_screen.dart';
import 'login_screen.dart';
import 'detail_har_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;
  User? _currentUser;
  UnitModel? _activeUnit;
  Map<String, int> _stats = {
    'total': 0,
    'pending': 0,
    'in_progress': 0,
    'completed': 0,
  };
  List<HARModel> _recentReports = [];
  bool _isLoading = true;

  final List<String> _wacbTimeSlots = [
    "01:00", "02:00", "03:00", "04:00", "05:00", "06:00",
    "07:00", "08:00", "09:00", "10:00", "11:00", "12:00",
    "13:00", "14:00", "15:00", "16:00", "17:00", "18:00",
    "19:00", "20:00", "21:00", "22:00", "23:00", "24:00"
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final user = await ApiService.getCurrentUser();
    final unit = await ApiService.getSelectedUnit();
    final stats = await ApiService.getDashboardStats(kdUnit: unit.kdUnit);
    final reports = await ApiService.getHARReports(kdUnit: unit.kdUnit);

    if (mounted) {
      setState(() {
        _currentUser = user;
        _activeUnit = unit;
        _stats = stats;
        _recentReports = reports.take(4).toList();
        _isLoading = false;
      });
    }
  }

  void _handleLogout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _showProfileModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.plnHeroGradient,
                    ),
                    child: Center(
                      child: Text(
                        _currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUser?.name ?? 'Teknisi PLTD',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.onPrimaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _currentUser?.role.toUpperCase() ?? 'TEKNISI',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Unit PLTD Aktif', style: TextStyle(fontSize: 10, color: AppTheme.outline)),
                          Text(
                            _activeUnit?.namaUnit ?? 'ULD Batu Ampar',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PilihUnitScreen()))
                            .then((_) => _loadDashboardData());
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Ubah Unit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppTheme.outlineVariant),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                ),
                title: const Text('Keluar dari Akun', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  _handleLogout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: AppTheme.primary,
        child: CustomScrollView(
          slivers: [
            // PLN Mobile Signature Hero Header with floating status card
            SliverToBoxAdapter(
              child: _buildPLNMobileHeader(),
            ),

            // Main Content Body
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // PLN Mobile 4-Column Service Grid
                  _buildServiceGrid(),
                  const SizedBox(height: 20),

                  // Highlights / Kesiapan Mesin Banner
                  _buildReliabilityBanner(),
                  const SizedBox(height: 20),

                  // KPI Bento Cards
                  _buildKPIBentoSection(),
                  const SizedBox(height: 22),

                  // 24-Hour WACB Quick Slot Chips
                  _buildWACBSlotMatrix(),
                  const SizedBox(height: 22),

                  // Recent Activities Feed
                  _buildRecentActivitiesSection(),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // PLN Mobile Hero Header & Floating Status Card
  Widget _buildPLNMobileHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Top Gradient Container
        Container(
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 60),
          decoration: const BoxDecoration(
            gradient: AppTheme.plnHeroGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              // Top Bar: User Greeting + Notifications & Profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _showProfileModal,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: AppTheme.secondaryContainer, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Halo, ${_currentUser?.name.split(" ").first ?? "Teknisi"} 👋',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.bolt, size: 12, color: AppTheme.secondaryContainer),
                              const SizedBox(width: 3),
                              Text(
                                '${_currentUser?.role.toUpperCase() ?? "TEKNISI"} • Kaltim 3',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _loadDashboardData,
                        icon: const Icon(Icons.sync_rounded, color: Colors.white, size: 22),
                        tooltip: 'Segarkan Data',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: _showProfileModal,
                        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
                        tooltip: 'Menu Akun',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // Floating Unit Card (Like PLN Mobile ID Pelanggan card)
        Positioned(
          left: 16,
          right: 16,
          bottom: -32,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.power_rounded, color: AppTheme.primary, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _activeUnit?.namaUnit ?? 'ULD BATU AMPAR',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.accentGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${_activeUnit?.namaArea ?? "SITE BONTANG"} • ANDAL',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PilihUnitScreen()))
                            .then((_) => _loadDashboardData());
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.outlineVariant),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Ganti Unit',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppTheme.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppTheme.outlineVariant),
                const SizedBox(height: 10),
                // Mini metric indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHeaderMetric('Daya Mampu', '450 kW', Icons.offline_bolt_rounded, AppTheme.primary),
                    Container(height: 24, width: 1, color: AppTheme.outlineVariant),
                    _buildHeaderMetric('Beban Realtime', '380 kW', Icons.speed_rounded, AppTheme.secondary),
                    Container(height: 24, width: 1, color: AppTheme.outlineVariant),
                    _buildHeaderMetric('Kesiapan (EAF)', '99.2%', Icons.check_circle_outline_rounded, AppTheme.accentGreen),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.outline)),
      ],
    );
  }

  // PLN Mobile 4-Column Service Grid
  Widget _buildServiceGrid() {
    final services = [
      {
        'title': 'Checklist HAR',
        'icon': Icons.assignment_turned_in_rounded,
        'color': AppTheme.primary,
        'bg': const Color(0xFFE0F2FE),
        'action': () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatHARScreen()));
          _loadDashboardData();
        },
      },
      {
        'title': 'Input Logsheet',
        'icon': Icons.speed_rounded,
        'color': const Color(0xFFEA580C),
        'bg': const Color(0xFFFFEDD5),
        'action': () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatHARScreen()));
          _loadDashboardData();
        },
      },
      {
        'title': 'Katalog Mesin',
        'icon': Icons.precision_manufacturing_rounded,
        'color': const Color(0xFF0284C7),
        'bg': const Color(0xFFE0F7FA),
        'action': () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const DaftarMesinScreen()));
        },
      },
      {
        'title': 'Riwayat HAR',
        'icon': Icons.history_rounded,
        'color': const Color(0xFF0D9488),
        'bg': const Color(0xFFCCFBF1),
        'action': () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatHARScreen()));
          _loadDashboardData();
        },
      },
      {
        'title': 'Jadwal HAR',
        'icon': Icons.calendar_month_rounded,
        'color': const Color(0xFF7C3AED),
        'bg': const Color(0xFFEDE9FE),
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jadwal Pemeliharaan Periode Ini: Terjadwal Normal.')),
          );
        },
      },
      {
        'title': 'Anomali Mesin',
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFDC2626),
        'bg': const Color(0xFFFEE2E2),
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada anomali kritis pada unit ini.')),
          );
        },
      },
      {
        'title': 'Katalog Part',
        'icon': Icons.inventory_2_rounded,
        'color': const Color(0xFF16A34A),
        'bg': const Color(0xFFDCFCE7),
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stok filter dan sparepart tersedia di gudang site.')),
          );
        },
      },
      {
        'title': 'Semua Menu',
        'icon': Icons.grid_view_rounded,
        'color': const Color(0xFF475569),
        'bg': const Color(0xFFF1F5F9),
        'action': () => _showProfileModal(),
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (context, index) {
          final s = services[index];
          return InkWell(
            onTap: s['action'] as VoidCallback,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: s['bg'] as Color,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: (s['color'] as Color).withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    s['icon'] as IconData,
                    color: s['color'] as Color,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s['title'] as String,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Reliability Banner (PLN Mobile highlight banner)
  Widget _buildReliabilityBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.darkCardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.bolt_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 12, color: AppTheme.textDark),
                          SizedBox(width: 4),
                          Text(
                            'OPERASIONAL PRIMA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Keandalan Pembangkit PLTD',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Input checklist tepat waktu menjamin performa mesin 100% andal.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatHARScreen()));
                  _loadDashboardData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryContainer,
                  foregroundColor: AppTheme.textDark,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Isi HAR', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Bento KPI Cards (Tasktugas clean card style)
  Widget _buildKPIBentoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ringkasan Pemeliharaan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
            ),
            Text(
              'Bulan Ini',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.outline),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                title: 'Total Laporan',
                value: '${_stats['total'] ?? 0}',
                icon: Icons.analytics_rounded,
                color: AppTheme.primary,
                bgColor: const Color(0xFFF0F9FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBentoCard(
                title: 'Menunggu SPV',
                value: '${_stats['pending'] ?? 0}',
                icon: Icons.hourglass_top_rounded,
                color: const Color(0xFFD97706),
                bgColor: const Color(0xFFFEF3C7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                title: 'Sedang Proses',
                value: '${_stats['in_progress'] ?? 0}',
                icon: Icons.engineering_rounded,
                color: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBentoCard(
                title: 'Approved / Selesai',
                value: '${_stats['completed'] ?? 0}',
                icon: Icons.check_circle_rounded,
                color: AppTheme.accentGreen,
                bgColor: const Color(0xFFECFDF5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineVariant),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.outline),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 24-Hour WACB Quick Slot Grid
  Widget _buildWACBSlotMatrix() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 18, color: AppTheme.primary),
                  SizedBox(width: 6),
                  Text(
                    'Slot Jam Logsheet WACB (24 Jam)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'SIAP INPUT',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.accentGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Ketuk slot jam untuk langsung mencatat parameter operasional mesin:',
            style: TextStyle(fontSize: 11, color: AppTheme.outline),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _wacbTimeSlots.map((slot) {
              return InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BuatHARScreen(initialTimeSlot: slot),
                    ),
                  );
                  _loadDashboardData();
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        slot,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit_note_rounded, size: 14, color: AppTheme.primary),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Recent Activities Section
  Widget _buildRecentActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aktivitas HAR Terbaru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatHARScreen()))
                    .then((_) => _loadDashboardData());
              },
              child: const Row(
                children: [
                  Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                  Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppTheme.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ..._recentReports.map((r) {
          Color statusBg = const Color(0xFFDCFCE7);
          Color statusColor = const Color(0xFF16A34A);
          String statusText = 'Approved';

          if (r.status == 'submitted') {
            statusBg = const Color(0xFFFEF3C7);
            statusColor = const Color(0xFFD97706);
            statusText = 'Menunggu SPV';
          } else if (r.status == 'draft') {
            statusBg = const Color(0xFFEFF6FF);
            statusColor = const Color(0xFF2563EB);
            statusText = 'Draft';
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.outlineVariant),
              boxShadow: AppTheme.softShadow,
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailHARScreen(harId: r.id)),
                ).then((_) => _loadDashboardData());
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.assignment_rounded, color: AppTheme.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                r.harNumber,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: statusColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            r.machineName,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Slot Jam ${r.timeSlot} • ${r.date} • Oleh ${r.technicianName}',
                            style: const TextStyle(fontSize: 10, color: AppTheme.outline),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.outline),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // Modern PLN Mobile Styled Bottom Navigation Bar
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Beranda'),
              _buildNavItem(1, Icons.precision_manufacturing_rounded, 'Mesin'),
              _buildNavItem(2, Icons.history_rounded, 'Riwayat'),
              _buildNavItem(3, Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentNavIndex == index;
    return InkWell(
      onTap: () async {
        setState(() => _currentNavIndex = index);
        if (index == 1) {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const DaftarMesinScreen()));
          _loadDashboardData();
        } else if (index == 2) {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatHARScreen()));
          _loadDashboardData();
        } else if (index == 3) {
          _showProfileModal();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primary : AppTheme.outline,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
