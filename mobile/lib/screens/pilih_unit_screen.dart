import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/api_service.dart';
import 'dashboard_screen.dart';

class UnitStats {
  final int totalMachines;
  final String capacity;
  final String systemType;
  final String status;

  const UnitStats({
    required this.totalMachines,
    required this.capacity,
    required this.systemType,
    this.status = 'Online & Andal',
  });
}

class PilihUnitScreen extends StatefulWidget {
  const PilihUnitScreen({super.key});

  @override
  State<PilihUnitScreen> createState() => _PilihUnitScreenState();
}

class _PilihUnitScreenState extends State<PilihUnitScreen> {
  List<UnitModel> _allUnits = [];
  String _selectedArea = 'Semua Area';
  final TextEditingController _searchController = TextEditingController();
  UnitModel? _selectedUnit;
  bool _isLoading = true;
  User? _currentUser;
  bool _isGridView = true; // Default view is modern Card Grid!

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  UnitStats _getUnitStats(String kdUnit) {
    switch (kdUnit) {
      case '0264':
        return const UnitStats(totalMachines: 5, capacity: '750 kW', systemType: 'Isolated');
      case '0283':
        return const UnitStats(totalMachines: 4, capacity: '3.15 MW', systemType: 'Grid Sistem');
      case '0265':
        return const UnitStats(totalMachines: 2, capacity: '2.00 MW', systemType: 'Pesisir');
      case '0279':
        return const UnitStats(totalMachines: 3, capacity: '1.20 MW', systemType: 'Isolated');
      case '0281':
        return const UnitStats(totalMachines: 3, capacity: '1.00 MW', systemType: 'Isolated');
      case '0288':
        return const UnitStats(totalMachines: 4, capacity: '1.50 MW', systemType: 'Pulau Terluar');
      default:
        return const UnitStats(totalMachines: 3, capacity: '1.00 MW', systemType: 'Isolated');
    }
  }

  void _loadData() async {
    final user = await ApiService.getCurrentUser();
    final units = await ApiService.getUnits();
    final currentUnit = await ApiService.getSelectedUnit();

    if (mounted) {
      setState(() {
        _currentUser = user;
        _allUnits = units;
        _selectedUnit = units.firstWhere(
          (u) => u.kdUnit == currentUnit.kdUnit,
          orElse: () => units.first,
        );
        _isLoading = false;
      });
    }
  }

  void _handleLanjutkan() async {
    if (_selectedUnit == null) return;
    setState(() => _isLoading = true);
    await ApiService.saveSelectedUnit(_selectedUnit!);
    if (mounted) {
      setState(() => _isLoading = false);
      if (Navigator.canPop(context)) {
        Navigator.pop(context, _selectedUnit);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bontangCount = _allUnits.where((u) => u.namaArea.toUpperCase().contains('BONTANG')).length;
    final berauCount = _allUnits.where((u) => u.namaArea.toUpperCase().contains('BERAU')).length;

    final filterAreas = [
      {'label': 'Semua Area', 'count': _allUnits.length},
      {'label': 'SITE BONTANG', 'count': bontangCount},
      {'label': 'SITE BERAU', 'count': berauCount},
    ];

    final query = _searchController.text.toLowerCase().trim();

    final filteredUnits = _allUnits.where((u) {
      final matchesArea = _selectedArea == 'Semua Area' ||
          u.namaArea.toUpperCase() == _selectedArea.toUpperCase();
      final matchesSearch = query.isEmpty ||
          u.namaUnit.toLowerCase().contains(query) ||
          u.kdUnit.toLowerCase().contains(query) ||
          u.namaArea.toLowerCase().contains(query);
      return matchesArea && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Pilih Unit Layanan PLTD'),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          if (_currentUser != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Image.asset('assets/images/LOGOPLN.png', width: 14, height: 14, fit: BoxFit.contain),
                  const SizedBox(width: 5),
                  Text(
                    _currentUser!.role.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppTheme.primary),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Executive Hero Context Card
                        _buildHeroCard(),
                        const SizedBox(height: 18),

                        // Search Input
                        _buildSearchBar(),
                        const SizedBox(height: 14),

                        // Area Filter Chips
                        _buildAreaChips(filterAreas),
                        const SizedBox(height: 20),

                        // Section Title & View Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Daftar Unit Pembangkit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textDark,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${filteredUnits.length} Unit Tersedia • Ketuk untuk memilih',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.outline),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.outlineVariant),
                                boxShadow: AppTheme.softShadow,
                              ),
                              padding: const EdgeInsets.all(3),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildViewToggleBtn(
                                    icon: Icons.grid_view_rounded,
                                    isSelected: _isGridView,
                                    tooltip: 'Grid Card',
                                    onTap: () => setState(() => _isGridView = true),
                                  ),
                                  _buildViewToggleBtn(
                                    icon: Icons.view_agenda_rounded,
                                    isSelected: !_isGridView,
                                    tooltip: 'Wide Card',
                                    onTap: () => setState(() => _isGridView = false),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Empty State or Unit Cards
                        if (filteredUnits.isEmpty)
                          _buildEmptyState()
                        else if (_isGridView)
                          _buildGridCardLayout(filteredUnits)
                        else
                          ...filteredUnits.map((u) => _buildWideCard(u)),
                      ],
                    ),
                  ),
                ),

                // Sticky Floating Selection Bottom Bar
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003865), Color(0xFF005A9C), Color(0xFF0082C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Stack(
        children: [
          // Background subtle lightning accent
          Positioned(
            right: -15,
            bottom: -20,
            child: Opacity(
              opacity: 0.12,
              child: const Icon(
                Icons.bolt_rounded,
                size: 140,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/LOGOPLN.png',
                          width: 36,
                          height: 36,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _currentUser?.name ?? 'Super Admin K3 (PLN Nusa Daya)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Regional Kalimantan 3 • Divisi Keandalan Pembangkit',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Hero Mini Statistics Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeroStatItem(Icons.factory_outlined, '${_allUnits.length} Unit PLTD'),
                      Container(width: 1, height: 16, color: Colors.white.withValues(alpha: 0.2)),
                      _buildHeroStatItem(Icons.location_on_outlined, '2 Site Wilayah'),
                      Container(width: 1, height: 16, color: Colors.white.withValues(alpha: 0.2)),
                      _buildHeroStatItem(Icons.check_circle_outline_rounded, 'Andal & Siaga'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.85)),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.92),
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppTheme.textDark),
        decoration: InputDecoration(
          hintText: 'Cari nama PLTD, kode unit, atau area...',
          hintStyle: const TextStyle(color: AppTheme.outline, fontSize: 13, fontWeight: FontWeight.w500),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18, color: AppTheme.outline),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildAreaChips(List<Map<String, dynamic>> filterAreas) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filterAreas.map((item) {
          final label = item['label'] as String;
          final count = item['count'] as int;
          final isSelected = _selectedArea == label;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedArea = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.plnElectricGradient : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppTheme.outlineVariant,
                    width: 1.2,
                  ),
                  boxShadow: isSelected ? AppTheme.glowShadow : AppTheme.softShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.bolt, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textDark,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : AppTheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildViewToggleBtn({
    required IconData icon,
    required bool isSelected,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : AppTheme.outline,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 40, color: AppTheme.primary),
          ),
          const SizedBox(height: 14),
          const Text(
            'Unit PLTD Tidak Ditemukan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            'Tidak ada unit yang sesuai dengan kata kunci "${_searchController.text}".',
            style: const TextStyle(fontSize: 12, color: AppTheme.outline),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() => _selectedArea = 'Semua Area');
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reset Filter Pencarian'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCardLayout(List<UnitModel> units) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 750;
        final isTablet = constraints.maxWidth > 520 && !isDesktop;
        final crossAxisCount = isDesktop ? 3 : (isTablet ? 3 : 2);
        final childAspectRatio = isDesktop ? 0.88 : (constraints.maxWidth < 360 ? 0.74 : 0.77);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: units.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final unit = units[index];
            return _buildGridCard(unit);
          },
        );
      },
    );
  }

  Widget _buildGridCard(UnitModel unit) {
    final isSelected = _selectedUnit?.kdUnit == unit.kdUnit;
    final stats = _getUnitStats(unit.kdUnit);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppTheme.primary : AppTheme.outlineVariant,
          width: isSelected ? 2.5 : 1.2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _selectedUnit = unit);
          },
          onDoubleTap: () {
            setState(() => _selectedUnit = unit);
            _handleLanjutkan();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Electric Icon + Active Checkmark
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.plnElectricGradient : null,
                        color: isSelected ? null : AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.electric_bolt_rounded,
                        color: isSelected ? Colors.white : AppTheme.primary,
                        size: 22,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppTheme.primary : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppTheme.primary : AppTheme.outlineVariant,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 15, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ID Code Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.15)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ID ${unit.kdUnit}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? AppTheme.primary : AppTheme.outline,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Unit Name
                Text(
                  unit.namaUnit,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: isSelected ? AppTheme.primaryDark : AppTheme.textDark,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Location Area
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: isSelected ? AppTheme.primary : AppTheme.outline,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        unit.namaArea,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppTheme.primary : AppTheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Machine & Capacity Specs Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.95)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary.withValues(alpha: 0.25)
                          : AppTheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.precision_manufacturing_rounded, size: 12, color: AppTheme.outline),
                          const SizedBox(width: 3),
                          Text(
                            '${stats.totalMachines} Mesin',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                          ),
                        ],
                      ),
                      Text(
                        stats.capacity,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? AppTheme.primaryDark : AppTheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Status Indicator
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Expanded(
                      child: Text(
                        'Online & Andal',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentGreen,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideCard(UnitModel unit) {
    final isSelected = _selectedUnit?.kdUnit == unit.kdUnit;
    final stats = _getUnitStats(unit.kdUnit);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppTheme.primary : AppTheme.outlineVariant,
          width: isSelected ? 2.5 : 1.2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedUnit = unit),
          onDoubleTap: () {
            setState(() => _selectedUnit = unit);
            _handleLanjutkan();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.plnElectricGradient : null,
                        color: isSelected ? null : AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.electric_bolt_rounded,
                        color: isSelected ? Colors.white : AppTheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  unit.namaUnit,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.5,
                                    color: isSelected ? AppTheme.primaryDark : AppTheme.textDark,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primary.withValues(alpha: 0.15)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ID ${unit.kdUnit}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? AppTheme.primary : AppTheme.outline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 13, color: AppTheme.outline),
                              const SizedBox(width: 4),
                              Text(
                                unit.namaArea,
                                style: const TextStyle(fontSize: 11.5, color: AppTheme.outline, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppTheme.outlineVariant,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                stats.systemType,
                                style: const TextStyle(fontSize: 11, color: AppTheme.outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppTheme.primary : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppTheme.primary : AppTheme.outlineVariant,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppTheme.outlineVariant),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.precision_manufacturing_rounded, size: 13, color: AppTheme.outline),
                              const SizedBox(width: 4),
                              Text(
                                '${stats.totalMachines} Mesin Aktif',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.flash_on_rounded, size: 13, color: AppTheme.secondary),
                              const SizedBox(width: 3),
                              Text(
                                stats.capacity,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Online & Andal',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accentGreen),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final stats = _selectedUnit != null ? _getUnitStats(_selectedUnit!.kdUnit) : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'UNIT TERPILIH:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.outline,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedUnit?.namaUnit ?? 'Pilih Salah Satu Unit',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: AppTheme.primaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_selectedUnit != null && stats != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${_selectedUnit!.namaArea} • ${stats.totalMachines} Mesin (${stats.capacity})',
                      style: const TextStyle(fontSize: 11, color: AppTheme.outline, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: _selectedUnit != null ? AppTheme.plnElectricGradient : null,
                color: _selectedUnit == null ? AppTheme.surfaceContainerHigh : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _selectedUnit != null ? AppTheme.glowShadow : null,
              ),
              child: ElevatedButton.icon(
                onPressed: _selectedUnit == null ? null : _handleLanjutkan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: AppTheme.outline,
                  disabledBackgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Text(
                  'Buka Dashboard',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                label: const Icon(Icons.arrow_forward_rounded, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
