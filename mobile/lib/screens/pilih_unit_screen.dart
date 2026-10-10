import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class PilihUnitScreen extends StatefulWidget {
  const PilihUnitScreen({super.key});

  @override
  State<PilihUnitScreen> createState() => _PilihUnitScreenState();
}

class _PilihUnitScreenState extends State<PilihUnitScreen> {
  String selectedRegion = 'Kalimantan 3';
  String selectedArea = 'Site Bontang';
  String selectedUnit = 'ULD Batu Ampar';
  bool _isLoading = false;

  void _handleLanjutkan() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Unit Kerja'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Lokasi Kerja',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              const Text(
                'Pilih lokasi sebelum memulai HAR atau Input Logsheet WACB',
                style: TextStyle(fontSize: 12, color: AppTheme.outline),
              ),
              const SizedBox(height: 20),

              // Step Indicator
              Row(
                children: [
                  Expanded(child: Container(height: 4, color: AppTheme.primary)),
                  const SizedBox(width: 4),
                  Expanded(child: Container(height: 4, color: AppTheme.outlineVariant)),
                  const SizedBox(width: 4),
                  Expanded(child: Container(height: 4, color: AppTheme.outlineVariant)),
                ],
              ),
              const SizedBox(height: 24),

              // Dropdown Region
              const Text('Region / Wilayah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.outlineVariant),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedRegion,
                    isExpanded: true,
                    items: ['Kalimantan 3', 'Kalimantan 1', 'Kalimantan 2']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedRegion = val!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dropdown Area
              const Text('Area / Site', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.outlineVariant),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedArea,
                    isExpanded: true,
                    items: ['Site Bontang', 'Site Sangatta', 'Site Berau']
                        .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedArea = val!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dropdown Unit
              const Text('Unit / ULD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.outlineVariant),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedUnit,
                    isExpanded: true,
                    items: ['ULD Batu Ampar', 'ULD Muara Wahau', 'ULD Biduk-Biduk']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedUnit = val!),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outlineVariant),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.location_on, color: AppTheme.onSecondaryContainer),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedUnit,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                              ),
                              Text(
                                '$selectedArea, $selectedRegion',
                                style: const TextStyle(fontSize: 12, color: AppTheme.outline),
                              ),
                              const SizedBox(height: 4),
                              const Row(
                                children: [
                                  Icon(Icons.verified, size: 14, color: AppTheme.primary),
                                  SizedBox(width: 4),
                                  Text(
                                    'Unit Terverifikasi WACB',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLanjutkan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Lanjutkan ke Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.chevron_right),
                          ],
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
