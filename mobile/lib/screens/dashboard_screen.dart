import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
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
import 'lapor_amc_screen.dart';
import 'presensi_gps_screen.dart';
import 'stok_part_screen.dart';
import 'sop_k3_screen.dart';
import 'catat_stand_kwh_screen.dart';
import 'notifikasi_screen.dart';
import 'menu_operasi_screen.dart';

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

  // Profile Management State & Biodata Controllers
  final _profileNameController = TextEditingController();
  final _profileUsernameController = TextEditingController();
  final _profileNipController = TextEditingController();
  final _profileJabatanController = TextEditingController();
  final _profileDivisiController = TextEditingController();
  final _profileEmailController = TextEditingController();
  final _profilePhoneController = TextEditingController();
  final _profileTtlController = TextEditingController();
  final _profileAlamatController = TextEditingController();
  final _profileBioController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedAvatarPreset = '1';
  String? _customPhotoBase64;
  bool _obscureOldPass = true;
  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;
  bool _showPasswordSection = false;
  bool _isSavingProfile = false;

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
    _profileNameController.dispose();
    _profileUsernameController.dispose();
    _profileNipController.dispose();
    _profileJabatanController.dispose();
    _profileDivisiController.dispose();
    _profileEmailController.dispose();
    _profilePhoneController.dispose();
    _profileTtlController.dispose();
    _profileAlamatController.dispose();
    _profileBioController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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

        if (user != null) {
          _profileNameController.text = user.name;
          _profileUsernameController.text = user.username;
          _profileNipController.text = user.nip;
          _profileJabatanController.text = user.jabatan;
          _profileDivisiController.text = user.divisi;
          _profileEmailController.text = user.email;
          _profilePhoneController.text = user.phone;
          _profileTtlController.text = user.ttl;
          _profileAlamatController.text = user.alamat;
          _profileBioController.text = user.bio;
          _selectedAvatarPreset = user.avatarPreset;
          _customPhotoBase64 = user.photoBase64;
        }
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

  void _showUpdateHARModal() {
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
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0072B2), Color(0xFF00C4FF)],
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
              child: const Icon(Icons.edit_note_rounded, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Update Pemeliharaan (HAR)',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pilih opsi update cepat untuk pemeliharaan preventif mesin PLTD, pencatatan logsheet 48-slot, atau scan plat QR unit.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 20),
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
              icon: const Icon(Icons.edit_calendar_rounded, size: 20),
              label: const Text('Input & Update Checklist HAR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatHARScreen()))
                    .then((_) => _loadDashboardData());
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Color(0xFF00A2E8), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 18, color: Color(0xFF00A2E8)),
              label: const Text('Pindai QR / Barcode Plat Mesin', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF00A2E8))),
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
              label: const Text('Pilih dari Katalog Mesin PLTD', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF004F8A))),
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
                            Image.asset(
                              'assets/images/LOGOPLN.png',
                              width: 16,
                              height: 16,
                              fit: BoxFit.contain,
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                      flex: 11,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A2E8).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF00A2E8), size: 16),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Daya Pembangkit',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '$bebanRealtime / $dayaMampu kW',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    Container(width: 1, height: 26, margin: const EdgeInsets.symmetric(horizontal: 6), color: const Color(0xFFE2E8F0)),

                    // Section 2: Kesiapan EAF
                    Expanded(
                      flex: 9,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFFBEB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B), size: 16),
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Kesiapan (EAF)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                SizedBox(height: 1),
                                Text(
                                  '99.2%',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 4),

                    // Section 3: Ganti Unit Button
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PilihUnitScreen()))
                            .then((_) => _loadDashboardData());
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A2E8).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tune_rounded, size: 13, color: Color(0xFF00A2E8)),
                            SizedBox(width: 3),
                            Text(
                              'Unit',
                              style: TextStyle(
                                fontSize: 10,
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
                    badgeColor: const Color(0xFFEF4444),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LaporAMCScreen()),
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
        'onTap': () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporAMCScreen()));
          _loadDashboardData();
        },
      },
      {
        'title': 'Catat Stand\nKWH & BBM',
        'icon': Icons.electric_meter_rounded,
        'onTap': () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const CatatStandKwhScreen()));
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
        'onTap': () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const PresensiGpsScreen()));
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
        'onTap': () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const StokPartScreen()));
        },
      },
      {
        'title': 'Pedoman K3\n& SOP Mesin',
        'icon': Icons.menu_book_rounded,
        'onTap': () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const SopK3Screen()));
        },
      },
      {
        'title': 'Menu Operasi\nLainnya',
        'icon': Icons.apps_rounded,
        'onTap': () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => MenuOperasiScreen(onNavigateTab: _onNavTap)));
        },
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MenuOperasiScreen(onNavigateTab: _onNavTap)),
                );
              },
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

              return InkWell(
                onTap: () {
                  if (index == 0) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporAMCScreen()));
                  } else if (index == 1) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatHARScreen()));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SopK3Screen()));
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
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

          // SIGNATURE CENTER FLOATING "UPDATE HAR" BUTTON
          Positioned(
            top: -18,
            child: GestureDetector(
              onTap: _showUpdateHARModal,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0072B2), Color(0xFF00A2E8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00A2E8).withValues(alpha: 0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Center(
                  child: Icon(Icons.bolt_rounded, color: Color(0xFFFFD500), size: 30),
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

  // ==================== TAB 3: PROFIL TAB (LENGKAP BIODATA & UNGGAH FOTO) ====================
  Widget _buildProfileTab() {
    final roleName = _currentUser?.role.toUpperCase() ?? 'TEKNISI';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Profil & Biodata Pegawai', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Simpan Biodata',
            icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF00A2E8)),
            onPressed: _isSavingProfile ? null : _saveProfileChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. Avatar & Profile Header Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF003865).withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  // Circular Avatar (Custom Photo or Preset) with Camera Edit Badge
                  Stack(
                    children: [
                      _buildProfileAvatarWidget(88),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showAvatarPickerModal,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00A2E8), Color(0xFF0072B2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 15, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Name, Role & NIP
                  Text(
                    _profileNameController.text.isNotEmpty ? _profileNameController.text : (_currentUser?.name ?? 'Teknisi PLTD'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A2E8).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          roleName,
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF0072B2)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '@${_profileUsernameController.text.isNotEmpty ? _profileUsernameController.text : (_currentUser?.username ?? "kal3")}',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                        ),
                      ),
                      if (_profileNipController.text.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'NIP. ${_profileNipController.text}',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      GestureDetector(
                        onTap: _showAvatarPickerModal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF00A2E8).withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_a_photo_rounded, size: 13, color: Color(0xFF00A2E8)),
                              SizedBox(width: 5),
                              Text('Unggah Foto / Pilih Avatar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF00A2E8))),
                            ],
                          ),
                        ),
                      ),
                      if (_customPhotoBase64 != null)
                        GestureDetector(
                          onTap: () {
                            setState(() => _customPhotoBase64 = null);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Foto kustom dihapus, beralih ke avatar karakter PLN.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.delete_outline_rounded, size: 13, color: Colors.red),
                                SizedBox(width: 4),
                                Text('Hapus Foto', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.red)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Biodata & Identitas Kepegawaian PLN
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.badge_rounded, color: Color(0xFF00A2E8), size: 19),
                      SizedBox(width: 8),
                      Text('Identitas & Biodata Pegawai PLN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildProfileInputField('Nama Lengkap & Gelar', _profileNameController, Icons.person_rounded),
                  const SizedBox(height: 12),
                  _buildProfileInputField('NIP (Nomor Induk Pegawai)', _profileNipController, Icons.pin_rounded),
                  const SizedBox(height: 12),
                  _buildProfileInputField('Username Kredensial Login', _profileUsernameController, Icons.account_circle_outlined),
                  const SizedBox(height: 12),
                  _buildProfileInputField('Jabatan / Posisi Penugasan', _profileJabatanController, Icons.engineering_rounded),
                  const SizedBox(height: 12),
                  _buildProfileInputField('Divisi / Unit Kerja Induk', _profileDivisiController, Icons.domain_rounded),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Kontak & Domisili
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.contact_mail_rounded, color: Color(0xFF10B981), size: 19),
                      SizedBox(width: 8),
                      Text('Kontak & Domisili Pegawai', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildProfileInputField('Email Dinas PLN', _profileEmailController, Icons.alternate_email_rounded, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _buildProfileInputField('Nomor WhatsApp / HP Aktif', _profilePhoneController, Icons.phone_android_rounded, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildProfileInputField('Tempat & Tanggal Lahir (TTL)', _profileTtlController, Icons.cake_outlined),
                  const SizedBox(height: 12),
                  _buildProfileInputField('Alamat Posko / Domisili Kerja', _profileAlamatController, Icons.home_outlined),
                  const SizedBox(height: 12),
                  _buildProfileInputField('Bio & Catatan Penugasan', _profileBioController, Icons.notes_rounded, maxLines: 2),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Penugasan Pembangkit Aktif
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A2E8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.business_rounded, color: Color(0xFF00A2E8), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Unit Pembangkit Aktif', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                        const SizedBox(height: 2),
                        Text(
                          _activeUnit?.namaUnit ?? 'ULD MUARA PAHU',
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PilihUnitScreen()))
                          .then((_) => _loadDashboardData());
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF00A2E8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    child: const Text('Ganti Unit', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Change Password Collapsible Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => setState(() => _showPasswordSection = !_showPasswordSection),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.lock_reset_rounded, color: Color(0xFFD97706), size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ubah Kata Sandi (Password)', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                                SizedBox(height: 2),
                                Text('Perbarui kredensial login akun Anda', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          Icon(
                            _showPasswordSection ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: const Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_showPasswordSection) ...[
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildProfilePasswordField(
                            label: 'Password Lama',
                            controller: _oldPasswordController,
                            obscure: _obscureOldPass,
                            onToggle: () => setState(() => _obscureOldPass = !_obscureOldPass),
                          ),
                          const SizedBox(height: 12),
                          _buildProfilePasswordField(
                            label: 'Password Baru',
                            controller: _newPasswordController,
                            obscure: _obscureNewPass,
                            onToggle: () => setState(() => _obscureNewPass = !_obscureNewPass),
                          ),
                          const SizedBox(height: 12),
                          _buildProfilePasswordField(
                            label: 'Konfirmasi Password Baru',
                            controller: _confirmPasswordController,
                            obscure: _obscureConfirmPass,
                            onToggle: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 6. Primary Save Changes Button
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0072B2), Color(0xFF00A2E8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00A2E8).withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSavingProfile ? null : _saveProfileChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSavingProfile
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Simpan Perubahan Biodata & Akun',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // 7. Secondary Options (K3 Policy & Logout)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.shield_rounded,
                    color: const Color(0xFF10B981),
                    title: 'Standar K3 & Keselamatan Kerja',
                    subtitle: 'Kebijakan Zero Accident & SOP Pembangkit',
                    onTap: _showK3PolicyModal,
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

  // Profile Avatar Widget (Supports custom uploaded photo or preset)
  Widget _buildProfileAvatarWidget(double size) {
    if (_customPhotoBase64 != null && _customPhotoBase64!.isNotEmpty) {
      try {
        final imageBytes = base64Decode(_customPhotoBase64!);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF003865).withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.memory(
              imageBytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPresetAvatarWidget(_selectedAvatarPreset, size),
            ),
          ),
        );
      } catch (_) {}
    }
    return _buildPresetAvatarWidget(_selectedAvatarPreset, size);
  }

  // Preset Avatar Widget Generator
  Widget _buildPresetAvatarWidget(String presetId, double size) {
    List<Color> colors;
    IconData icon;

    switch (presetId) {
      case '2':
        colors = [const Color(0xFFF59E0B), const Color(0xFFD97706)];
        icon = Icons.engineering_rounded;
        break;
      case '3':
        colors = [const Color(0xFF0D9488), const Color(0xFF059669)];
        icon = Icons.precision_manufacturing_rounded;
        break;
      case '4':
        colors = [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)];
        icon = Icons.manage_accounts_rounded;
        break;
      case '5':
        colors = [const Color(0xFF10B981), const Color(0xFF059669)];
        icon = Icons.build_rounded;
        break;
      case '6':
        colors = [const Color(0xFF7C3AED), const Color(0xFF4F46E5)];
        icon = Icons.shield_rounded;
        break;
      case '1':
      default:
        colors = [const Color(0xFF0072B2), const Color(0xFF00A2E8)];
        icon = Icons.bolt_rounded;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: size * 0.48),
      ),
    );
  }

  // Interactive Avatar Picker Modal (Gallery Upload + PLN Character Presets)
  void _showAvatarPickerModal() {
    final avatars = [
      {'id': '1', 'name': 'Petir PLN', 'desc': 'Karakter Utama', 'icon': Icons.bolt_rounded, 'color': const Color(0xFF00A2E8)},
      {'id': '2', 'name': 'Helm K3', 'desc': 'Safety Officer', 'icon': Icons.engineering_rounded, 'color': const Color(0xFFF59E0B)},
      {'id': '3', 'name': 'Mesin Genset', 'desc': 'Operator PLTD', 'icon': Icons.precision_manufacturing_rounded, 'color': const Color(0xFF0D9488)},
      {'id': '4', 'name': 'Supervisor', 'desc': 'SPV Operasional', 'icon': Icons.manage_accounts_rounded, 'color': const Color(0xFF3B82F6)},
      {'id': '5', 'name': 'Teknisi HAR', 'desc': 'Mekanik Lapangan', 'icon': Icons.build_rounded, 'color': const Color(0xFF10B981)},
      {'id': '6', 'name': 'Inspektur K3', 'desc': 'Zero Accident', 'icon': Icons.shield_rounded, 'color': const Color(0xFF7C3AED)},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Foto & Avatar Profil Pegawai', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              const SizedBox(height: 4),
              const Text('Unggah foto asli dari galeri HP atau pilih karakter avatar PLN', style: TextStyle(fontSize: 12, color: Color(0xFF64748B)), textAlign: TextAlign.center),
              const SizedBox(height: 18),

              // Button 1: Unggah Foto dari Galeri HP
              InkWell(
                onTap: () async {
                  try {
                    final result = await FilePicker.pickFiles(
                      type: FileType.image,
                      allowMultiple: false,
                      withData: true,
                    );
                    if (result != null && result.files.isNotEmpty) {
                      final file = result.files.first;
                      Uint8List? data = file.bytes;
                      if (data == null && file.path != null) {
                        data = await File(file.path!).readAsBytes();
                      }
                      if (data != null) {
                        final base64String = base64Encode(data);
                        setState(() {
                          _customPhotoBase64 = base64String;
                        });
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Foto profil berhasil diunggah! Tekan "Simpan Perubahan Biodata & Akun" untuk menyimpan permanen.'),
                              backgroundColor: Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal memilih foto: $e'), backgroundColor: Colors.redAccent),
                      );
                    }
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF003865), Color(0xFF0072B2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF003865).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Unggah Foto dari Galeri HP',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13.5),
                      ),
                    ],
                  ),
                ),
              ),

              if (_customPhotoBase64 != null) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _customPhotoBase64 = null);
                    setModalState(() {});
                  },
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 16),
                  label: const Text('Hapus Foto Kustom (Kembali ke Avatar PLN)', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],

              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Atau Pilih Karakter Avatar PLN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                  ),
                  Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                ],
              ),
              const SizedBox(height: 14),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: avatars.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (ctx, index) {
                  final a = avatars[index];
                  final isSelected = _selectedAvatarPreset == a['id'] && _customPhotoBase64 == null;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatarPreset = a['id'] as String;
                        _customPhotoBase64 = null;
                      });
                      setModalState(() {});
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00A2E8).withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF00A2E8) : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildPresetAvatarWidget(a['id'] as String, 46),
                          const SizedBox(height: 6),
                          Text(
                            a['name'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                              color: isSelected ? const Color(0xFF0072B2) : const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            a['desc'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Save Profile & Password Changes
  void _saveProfileChanges() async {
    final name = _profileNameController.text.trim();
    final username = _profileUsernameController.text.trim();
    final nip = _profileNipController.text.trim();
    final jabatan = _profileJabatanController.text.trim();
    final divisi = _profileDivisiController.text.trim();
    final email = _profileEmailController.text.trim();
    final phone = _profilePhoneController.text.trim();
    final ttl = _profileTtlController.text.trim();
    final alamat = _profileAlamatController.text.trim();
    final bio = _profileBioController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (name.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama lengkap dan Username/NIP tidak boleh kosong.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (newPass.isNotEmpty) {
      if (newPass != confirmPass) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konfirmasi password baru tidak cocok.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (newPass.length < 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password baru minimal 4 karakter.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() => _isSavingProfile = true);

    final updated = await ApiService.updateProfile(
      name: name,
      username: username,
      nip: nip,
      jabatan: jabatan,
      divisi: divisi,
      email: email,
      phone: phone,
      ttl: ttl,
      alamat: alamat,
      bio: bio,
      avatarPreset: _selectedAvatarPreset,
      photoBase64: _customPhotoBase64,
      clearPhoto: _customPhotoBase64 == null,
      newPassword: newPass.isNotEmpty ? newPass : null,
    );

    setState(() {
      _isSavingProfile = false;
      if (updated != null) {
        _currentUser = updated;
      }
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _showPasswordSection = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Biodata & profil pegawai $name berhasil disimpan permanen!'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // Profile Input Field Helper
  Widget _buildProfileInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: const Color(0xFF00A2E8)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // Profile Password Field Helper
  Widget _buildProfilePasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF00A2E8)),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: const Color(0xFF94A3B8)),
                onPressed: onToggle,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // K3 Zero Accident Policy -> Now navigates directly to SopK3Screen
  void _showK3PolicyModal() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SopK3Screen()));
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
