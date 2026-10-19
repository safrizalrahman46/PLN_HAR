import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/api_service.dart';
import 'dashboard_screen.dart';

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final areas = ['Semua Area', 'SITE BONTANG', 'SITE BERAU'];
    final query = _searchController.text.toLowerCase().trim();

    final filteredUnits = _allUnits.where((u) {
      final matchesArea = _selectedArea == 'Semua Area' || u.namaArea.toUpperCase() == _selectedArea.toUpperCase();
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
        actions: [
          if (_currentUser != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 4),
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Context Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppTheme.plnHeroGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.power_rounded, color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentUser?.name ?? 'Teknisi PLTD',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Regional Kalimantan 3 • Divisi Keandalan Pembangkit',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Search Input
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Cari nama unit PLTD atau kode unit...',
                              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.outline),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Area Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: areas.map((area) {
                              final isSelected = _selectedArea == area;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedArea = area),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppTheme.primary : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected ? AppTheme.primary : AppTheme.outlineVariant,
                                      ),
                                      boxShadow: isSelected ? AppTheme.glowShadow : AppTheme.softShadow,
                                    ),
                                    child: Text(
                                      area,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : AppTheme.outline,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Section Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Daftar Unit Tersedia',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                            ),
                            Text(
                              '${filteredUnits.length} Unit',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.outline),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Unit Cards
                        ...filteredUnits.map((unit) {
                          final isSelected = _selectedUnit?.kdUnit == unit.kdUnit;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? AppTheme.primary : AppTheme.outlineVariant,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected ? AppTheme.glowShadow : AppTheme.softShadow,
                            ),
                            child: InkWell(
                              onTap: () => setState(() => _selectedUnit = unit),
                              borderRadius: BorderRadius.circular(18),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primary
                                            : AppTheme.primary.withValues(alpha: 0.1),
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
                                                    fontSize: 14,
                                                    color: isSelected ? AppTheme.primaryDark : AppTheme.textDark,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppTheme.primary.withValues(alpha: 0.15)
                                                      : AppTheme.surfaceContainer,
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
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on_rounded, size: 13, color: AppTheme.outline),
                                              const SizedBox(width: 4),
                                              Text(
                                                unit.namaArea,
                                                style: const TextStyle(fontSize: 11, color: AppTheme.outline),
                                              ),
                                              const SizedBox(width: 10),
                                              Container(
                                                width: 5,
                                                height: 5,
                                                decoration: const BoxDecoration(
                                                  color: AppTheme.accentGreen,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              const Text(
                                                'Online & Andal',
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.accentGreen),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
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
                                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Bottom Sticky Floating Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Unit Terpilih:', style: TextStyle(fontSize: 10, color: AppTheme.outline)),
                            Text(
                              _selectedUnit?.namaUnit ?? 'Belum Dipilih',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: AppTheme.primaryDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppTheme.plnElectricGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppTheme.glowShadow,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _selectedUnit == null ? null : _handleLanjutkan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Text('Buka Dashboard', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                          label: const Icon(Icons.arrow_forward_rounded, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
