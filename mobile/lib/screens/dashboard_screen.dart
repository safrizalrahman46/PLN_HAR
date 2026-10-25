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
  late final PageController _pageController;
  User? _currentUser;
  UnitModel? _activeUnit;
  List<MachineModel> _unitMachines = [];
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
    _pageController = PageController(initialPage: _currentNavIndex);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final user = await ApiService.getCurrentUser();
    final unit = await ApiService.getSelectedUnit();
    final stats = await ApiService.getDashboardStats(kdUnit: unit.kdUnit);
    final reports = await ApiService.getHARReports(kdUnit: unit.kdUnit);
    final machines = await ApiService.getMachines(kdUnit: unit.kdUnit);

    if (mounted) {
      setState(() {
        _currentUser = user;
        _activeUnit = unit;
        _unitMachines = machines;
        _stats = stats;
        _recentReports = reports.take(4).toList();
        _isLoading = false;
      });
    }
  }

  void _onNavTap(int index) {
    if (_currentNavIndex == index) return;
    setState(() => _currentNavIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  void _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari akun PLN Nusa Daya ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppTheme.outline, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Keluar', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.logout();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _showQRScanModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00A2E8), Color(0xFF00C4FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00A2E8).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.qr_code_scanner_rounded, size: 44, color: Colors.white),
            ),
            const SizedBox(height: 18),
            const Text(
              'Pindai QR / Barcode Mesin PLTD',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Arahkan kamera ke plat QR mesin pembangkit untuk langsung membuka checklist pemeliharaan (HAR) atau pencatatan logsheet 48-slot secara otomatis.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatHARScreen()))
                    .then((_) => _loadDashboardData());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A2E8),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: const Icon(Icons.checklist_rounded, size: 20),
              label: const Text('Buka Checklist HAR Mesin', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _onNavTap(1);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.precision_manufacturing_rounded, size: 18, color: Color(0xFF004F8A)),
              label: const Text('Pilih dari Katalog Mesin', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF004F8A))),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(color: Color(0xFF00A2E8), strokeWidth: 3),
              ),
              const SizedBox(height: 14),
              const Text(
                'Memuat Data PLN HAR & Logsheet...',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    // Responsive Mobile Frame: Prevents layout from ballooning on desktop Chrome
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), // Clean neutral canvas for web preview
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 28,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentNavIndex = index);
              },
              children: [
                // Tab 0: Beranda (PLN Mobile Signature Home)
                _buildDashboardTab(),
                // Tab 1: Aktivitas & Katalog Mesin
                const DaftarMesinScreen(isTab: true),
                // Tab 2: Laporan & Riwayat HAR
                const RiwayatHARScreen(isTab: true),
                // Tab 3: Akun / Profil
                _buildProfileTab(),
              ],
            ),
            bottomNavigationBar: _buildBottomNav(),
          ),
        ),
      ),
    );
  }

  // ==================== TAB 0: BERANDA DASHBOARD (PLN MOBILE STYLE) ====================
  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: const Color(0xFF00A2E8),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // 1. PLN Mobile Sky Header with Floating Status Card & Quick Category Row
          SliverToBoxAdapter(
            child: _buildPLNMobileSkyHeader(),
          ),

          // 2. Curved White Body with 4x3 Grid of Cyan Squircles + Event Carousel
          SliverToBoxAdapter(
            child: _buildPLNMobileWhiteSheetBody(),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // 1. SKY HEADER WITH ILLUSTRATION, FLOATING CARD & 4 QUICK CATEGORIES
  // ====================================================================
  Widget _buildPLNMobileSkyHeader() {
    const dayaMampu = 450;
    const bebanRealtime = 380;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0080C0),
            Color(0xFF00A2E8),
            Color(0xFF00BFEF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: PLN Logo + Sapaan + Notifikasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFD500),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.bolt, size: 11, color: Color(0xFF003865)),
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'PLN MOBILE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF003865),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Halo, ${_currentUser?.name.split(" ").first ?? "Teknisi"} 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Notification Bell with Red Badge
                      Stack(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pemberitahuan: Seluruh jadwal HAR shift aktif telah terverifikasi.'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Refresh Sync
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.sync_rounded, color: Colors.white, size: 19),
                          onPressed: () {
                            _loadDashboardData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Data operasional & unit berhasil disinkronkan.'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Floating Card (Matching Saldo PLN Mobile & EV Poin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF003B66).withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Section 1: Daya Pembangkit
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A2E8).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF00A2E8), size: 18),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Daya Pembangkit',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$bebanRealtime / $dayaMampu kW',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                    const SizedBox(width: 10),

                    // Section 2: Kesiapan EAF
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFFBEB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B), size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kesiapan (EAF)',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '99.2%',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Section 3: Ganti Unit Button
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PilihUnitScreen()))
                            .then((_) => _loadDashboardData());
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A2E8).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.tune_rounded, size: 14, color: Color(0xFF00A2E8)),
                            SizedBox(width: 3),
                            Text(
                              'Unit',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF00A2E8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4 Circular Quick Categories Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickCategoryItem(
                    icon: Icons.power_rounded,
                    label: 'Pembangkit',
                    badgeColor: const Color(0xFFEF4444),
                    onTap: () => _onNavTap(1),
                  ),
                  _buildQuickCategoryItem(
                    icon: Icons.assignment_rounded,
                    label: 'Logsheet',
                    badgeColor: const Color(0xFF00A2E8),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatHARScreen()))
                          .then((_) => _loadDashboardData());
                    },
                  ),
                  _buildQuickCategoryItem(
                    icon: Icons.handyman_rounded,
                    label: 'HAR Harian',
                    badgeColor: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatHARScreen()))
                          .then((_) => _loadDashboardData());
                    },
                  ),
                  _buildQuickCategoryItem(
                    icon: Icons.emergency_rounded,
                    label: 'Lapor AMC',
                    badgeColor: const Color(0xFFF59E0B),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Layanan Pelaporan AMC Siaga 24 Jam.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCategoryItem({
    required IconData icon,
    required String label,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: badgeColor, size: 23),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // 2. CURVED WHITE SHEET BODY WITH COMPACT 4x3 GRID & IMMEDIATE EVENT
  // ====================================================================
  Widget _buildPLNMobileWhiteSheetBody() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // THE 4x3 GRID: COMPACT & TIGHT LAYOUT (NO GIANT HOLES)
          _buildCompactPLNMobileGrid(),
          const SizedBox(height: 22),

          // EVENT SECTION: VISIBLE DIRECTLY BELOW THE GRID
          _buildEventSection(),
          const SizedBox(height: 22),

          // Live Generator Machines Status
          _buildLiveMachineStatusSection(),
          const SizedBox(height: 22),

          // KPI Overview
          _buildKPIBentoSection(),
          const SizedBox(height: 22),

          // 24-Hour WACB Matrix
          _buildWACBSlotMatrix(),
          const SizedBox(height: 22),

          // Recent Activities
          _buildRecentActivitiesSection(),
        ],
      ),
    );
  }

  // ====================================================================
  // COMPACT 4x3 GRID OF 12 CYAN SQUIRCLES (PROPORTIONED PERFECTLY)
  // ====================================================================
  Widget _buildCompactPLNMobileGrid() {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Pemeriksaan\nHAR',
        'icon': Icons.checklist_rounded,
        'onTap': () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatHARScreen()));
          _loadDashboardData();
        },
      },
      {
        'title': 'Logsheet\nMesin',
        'icon': Icons.assignment_turned_in_rounded,
        'onTap': () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatHARScreen()));
          _loadDashboardData();
        },
      },
      {
        'title': 'Lapor Gangguan\n(AMC)',
        'icon': Icons.warning_amber_rounded,
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Laporan Anomali/Gangguan: Seluruh unit beroperasi normal.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      },
      {
        'title': 'Catat Stand\nKWH & BBM',
        'icon': Icons.electric_meter_rounded,
        'onTap': () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatHARScreen()));
          _loadDashboardData();
        },
      },
      {
        'title': 'Inventaris\nMesin PLTD',
        'icon': Icons.precision_manufacturing_rounded,
        'onTap': () => _onNavTap(1),
      },
      {
        'title': 'Riwayat\nLaporan HAR',
        'icon': Icons.history_edu_rounded,
        'onTap': () => _onNavTap(2),
      },
      {
        'title': 'Export &\nImport Data',
        'icon': Icons.import_export_rounded,
        'onTap': () => _onNavTap(2),
      },
      {
        'title': 'Presensi\nMandiri GPS',
        'icon': Icons.pin_drop_rounded,
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Presensi GPS Geofence: Berada di dalam radius unit kerja.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      },
      {
        'title': 'Cetak Berita\nAcara (PDF)',
        'icon': Icons.picture_as_pdf_rounded,
        'onTap': () => _onNavTap(2),
      },
      {
        'title': 'Stok Part &\nOli Pelumas',
        'icon': Icons.inventory_2_rounded,
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gudang Suku Cadang: Stok oli pelumas dan filter tersedia.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      },
      {
        'title': 'Pedoman K3\n& SOP Mesin',
        'icon': Icons.menu_book_rounded,
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Buku Pedoman K3 & SOP Operasi PLTD telah diunduh.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      },
      {
        'title': 'Menu Operasi\nLainnya',
        'icon': Icons.apps_rounded,
        'onTap': _showQRScanModal,
      },
    ];

    // Using 3 compact Rows to guarantee fixed, tight spacing without stretching
    return Column(
      children: [
        _buildGridRow(menuItems.sublist(0, 4)),
        const SizedBox(height: 14),
        _buildGridRow(menuItems.sublist(4, 8)),
        const SizedBox(height: 14),
        _buildGridRow(menuItems.sublist(8, 12)),
      ],
    );
  }

  Widget _buildGridRow(List<Map<String, dynamic>> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Expanded(
          child: InkWell(
            onTap: item['onTap'] as VoidCallback,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Vibrant Cyan Squircle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A2E8), Color(0xFF0090D0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00A2E8).withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(item['icon'] as IconData, color: Colors.white, size: 23),
                  ),
                ),
                const SizedBox(height: 6),
                // Compact 2-Line Label
                SizedBox(
                  height: 28,
                  child: Text(
                    item['title'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      height: 1.18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ====================================================================
  // EVENT & INFORMASI OPERASIONAL CAROUSEL (MATCHING PLN MOBILE)
  // ====================================================================
  Widget _buildEventSection() {
    final events = [
      {
        'tag': 'KEANDALAN OPERASI',
        'title': 'Siaga Kelistrikan PLTD 24 Jam Non-Stop',
        'desc': 'Optimalisasi mutu keandalan pasokan energi di seluruh site pembangkit.',
        'gradient': const [Color(0xFF003F7A), Color(0xFF0072B5)],
        'icon': Icons.bolt_rounded,
      },
      {
        'tag': 'DIGITALISASI WACB',
        'title': 'Sistem Logsheet 48-Slot Terintegrasi Cloud',
        'desc': 'Pencatatan real-time otomatis tersinkronisasi ke portal web resmi.',
        'gradient': const [Color(0xFF006B76), Color(0xFF00A389)],
        'icon': Icons.cloud_sync_rounded,
      },
      {
        'tag': 'BUDAYA K3',
        'title': 'Komitmen Zero Accident Pembangkit PLTD',
        'desc': 'Patuhi SOP pemeliharaan berkala dan penggunaan APD lengkap di lapangan.',
        'gradient': const [Color(0xFF854D0E), Color(0xFFD97706)],
        'icon': Icons.security_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Event & Informasi Operasi',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Lihat Semua',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF00A2E8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final ev = events[index];
              final gradient = ev['gradient'] as List<Color>;

              return Container(
                width: 270,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ev['tag'] as String,
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        Icon(ev['icon'] as IconData, color: Colors.white70, size: 18),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ev['title'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ev['desc'] as String,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Live Generator Status Section
  Widget _buildLiveMachineStatusSection() {
    final machines = _unitMachines.isNotEmpty
        ? _unitMachines
        : [
            MachineModel(id: 1, idMesin: '000581', namaMesin: 'PLTD MUARA PAHU #01 (CATERPILLAR 3512B)', kodeMesinSilm: '2255', sn: '241088', dt: 800, status: 'OPERASI'),
            MachineModel(id: 2, idMesin: '000582', namaMesin: 'PLTD MUARA PAHU #02 (DEUTZ TBD 620)', kodeMesinSilm: '2256', sn: '620104', dt: 600, status: 'OPERASI'),
            MachineModel(id: 3, idMesin: '000583', namaMesin: 'PLTD MUARA PAHU #03 (MITSUBISHI S12R)', kodeMesinSilm: '2257', sn: '120442', dt: 1000, status: 'STANDBY'),
            MachineModel(id: 4, idMesin: '000584', namaMesin: 'PLTD MUARA PAHU #04 (PERKINS 4008)', kodeMesinSilm: '2258', sn: '400812', dt: 750, status: 'GANGGUAN'),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Genset PLTD',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.2),
                ),
                Text(
                  '${machines.length} Genset di ${_activeUnit?.namaUnit ?? "Unit PLTD"}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
            TextButton(
              onPressed: () => _onNavTap(1),
              child: const Row(
                children: [
                  Text('Lihat Semua', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF00A2E8))),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF00A2E8)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 135,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: machines.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final m = machines[index];
              final isOperasi = m.status == 'OPERASI';
              final isStandby = m.status == 'STANDBY';
              final badgeBg = isOperasi
                  ? const Color(0xFFDCFCE7)
                  : (isStandby ? const Color(0xFFFEF3C7) : const Color(0xFFFEE2E2));
              final badgeColor = isOperasi
                  ? const Color(0xFF15803D)
                  : (isStandby ? const Color(0xFFB45309) : const Color(0xFFDC2626));

              return Container(
                width: 210,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Icon(Icons.settings_suggest_rounded, color: Color(0xFF00A2E8), size: 15),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            m.status,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.namaMesin,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Daya Terpasang: ${m.dt} kW',
                          style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: isOperasi ? 0.85 : (isStandby ? 0.0 : 0.0),
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOperasi ? const Color(0xFF10B981) : Colors.grey,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // KPI Bento Cards
  Widget _buildKPIBentoSection() {
    final total = _stats['total'] ?? 0;
    final pending = _stats['pending'] ?? 0;
    final inProgress = _stats['in_progress'] ?? 0;
    final completed = _stats['completed'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ringkasan Kinerja HAR',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A2E8).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'SIKLUS AKTIF',
                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF00A2E8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildKPISubCard(
                  label: 'Total Tiket',
                  value: total.toString(),
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF00A2E8),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildKPISubCard(
                  label: 'Menunggu SPV',
                  value: pending.toString(),
                  icon: Icons.schedule_rounded,
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildKPISubCard(
                  label: 'Pengerjaan',
                  value: inProgress.toString(),
                  icon: Icons.handyman_rounded,
                  color: const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildKPISubCard(
                  label: 'Approved',
                  value: completed.toString(),
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPISubCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  // 24-Hour WACB Matrix
  Widget _buildWACBSlotMatrix() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Matriks 24-Jam Logsheet WACB',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                Text(
                  'Slot jam aktif: 14:00 WITA • Siklus Berjalan',
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
            TextButton(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatHARScreen()));
                _loadDashboardData();
              },
              child: const Text('Input Slot', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF00A2E8))),
            ),
          ],
        ),
        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _wacbTimeSlots.map((slot) {
              final isCurrent = slot == '14:00';
              final isDone = int.tryParse(slot.split(':').first)! <= 14;

              return Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? const Color(0xFF00A2E8)
                      : (isDone ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFF00A2E8)
                        : (isDone ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      slot,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isCurrent
                            ? Colors.white
                            : (isDone ? const Color(0xFF15803D) : const Color(0xFF64748B)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Icon(
                      isCurrent
                          ? Icons.radio_button_checked
                          : (isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked),
                      size: 10,
                      color: isCurrent
                          ? Colors.white
                          : (isDone ? const Color(0xFF15803D) : const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Recent Activities
  Widget _buildRecentActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aktivitas Pemeliharaan Terbaru',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
            ),
            TextButton(
              onPressed: () => _onNavTap(2),
              child: const Text('Semua', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF00A2E8))),
            ),
          ],
        ),
        const SizedBox(height: 6),

        if (_recentReports.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'Belum ada riwayat aktivitas pemeliharaan.',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentReports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final r = _recentReports[index];
              final isApproved = r.status == 'approved';

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isApproved ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isApproved ? Icons.check_circle_rounded : Icons.schedule_rounded,
                        size: 17,
                        color: isApproved ? const Color(0xFF15803D) : const Color(0xFFB45309),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                r.harNumber,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                              ),
                              Text(
                                r.date,
                                style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            r.machineName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 18),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailHARScreen(harId: r.id)),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // ====================================================================
  // SIGNATURE PLN MOBILE BOTTOM NAVIGATION BAR WITH CENTER SCAN VIEW目
  // ====================================================================
  Widget _buildBottomNav() {
    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003865).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 4 Bottom Tab Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(icon: Icons.home_rounded, label: 'Beranda', index: 0),
              _buildBottomNavItem(icon: Icons.sync_rounded, label: 'Aktivitas', index: 1),
              const SizedBox(width: 54), // Empty space for floating center button
              _buildBottomNavItem(icon: Icons.receipt_long_rounded, label: 'Laporan', index: 2),
              _buildBottomNavItem(icon: Icons.person_rounded, label: 'Akun', index: 3),
            ],
          ),

          // SIGNATURE CENTER FLOATING SCAN BUTTON
          Positioned(
            top: -16,
            child: GestureDetector(
              onTap: _showQRScanModal,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00A2E8), Color(0xFF00C4FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00A2E8).withValues(alpha: 0.40),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentNavIndex == index;

    return InkWell(
      onTap: () => _onNavTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00A2E8) : const Color(0xFF94A3B8),
              size: 21,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? const Color(0xFF00A2E8) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 3: PROFIL TAB ====================
  Widget _buildProfileTab() {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Akun Pengguna'),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF00A2E8), Color(0xFF00C4FF)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _currentUser?.name.substring(0, 1).toUpperCase() ?? 'S',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentUser?.name ?? 'Super Admin K3',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_currentUser?.role.toUpperCase() ?? "SUPERADMIN"} • Region Kalimantan 3',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _currentUser?.bio ?? 'Teknisi Operasi & Pemeliharaan Pembangkit PLTD',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Profile Options
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.business_rounded,
                    color: const Color(0xFF00A2E8),
                    title: 'Pilih Lokasi Unit PLTD',
                    subtitle: _activeUnit?.namaUnit ?? 'ULD MUARA PAHU',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PilihUnitScreen()))
                          .then((_) => _loadDashboardData());
                    },
                  ),
                  const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                  _buildProfileTile(
                    icon: Icons.shield_rounded,
                    color: const Color(0xFF10B981),
                    title: 'Standar K3 & Keselamatan Kerja',
                    subtitle: 'Kebijakan Zero Accident & SOP',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                  _buildProfileTile(
                    icon: Icons.logout_rounded,
                    color: Colors.red,
                    title: 'Keluar Akun',
                    subtitle: 'Keluar dari sesi aplikasi mobile ini',
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 18),
    );
  }
}
