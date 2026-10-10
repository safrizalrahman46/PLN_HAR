import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'buat_har_screen.dart';

class DaftarMesinScreen extends StatefulWidget {
  const DaftarMesinScreen({super.key});

  @override
  State<DaftarMesinScreen> createState() => _DaftarMesinScreenState();
}

class _DaftarMesinScreenState extends State<DaftarMesinScreen> {
  String selectedFilter = 'Semua';
  final _searchController = TextEditingController();

  final List<Map<String, String>> machines = [
    {
      "id": "000344",
      "name": "PLTD BATU AMPAR #01",
      "type": "DEUTZ BF6M 1013 E",
      "status": "Normal",
      "color": "green"
    },
    {
      "id": "000345",
      "name": "PLTD BATU AMPAR #02",
      "type": "DEUTZ BF6M 1013 E",
      "status": "Perlu Pemeriksaan",
      "color": "amber"
    },
    {
      "id": "000346",
      "name": "PLTD BATU AMPAR #03",
      "type": "CUMMINS KTA50-G3",
      "status": "Maintenance",
      "color": "blue"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Mesin PLTD'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Input
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: AppTheme.outline),
                hintText: 'Cari nama atau kode mesin',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.outlineVariant),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Semua', 'Normal', 'Gangguan', 'Maintenance'].map((filter) {
                  bool isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(filter),
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.outline,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) => setState(() => selectedFilter = filter),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Machine Cards
            Expanded(
              child: ListView.builder(
                itemCount: machines.length,
                itemBuilder: (ctx, idx) {
                  final m = machines[idx];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.outlineVariant),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.engineering, color: AppTheme.primary),
                      ),
                      title: Text(m['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${m['type']!} • ID: ${m['id']!}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BuatHARScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Input Logsheet'),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
