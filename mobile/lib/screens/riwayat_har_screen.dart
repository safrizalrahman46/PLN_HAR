import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'detail_har_screen.dart';

class RiwayatHARScreen extends StatelessWidget {
  const RiwayatHARScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      {
        "id": "HAR-2026-00021",
        "unit": "ULD Batu Ampar",
        "machine": "PLTD Batu Ampar #01",
        "date": "02 Ags 2026 • Slot 08:00",
        "status": "Selesai",
        "color": Colors.green,
      },
      {
        "id": "HAR-2026-00020",
        "unit": "ULD Batu Ampar",
        "machine": "PLTD Batu Ampar #02",
        "date": "01 Ags 2026 • Slot 07:00",
        "status": "Menunggu Approval",
        "color": Colors.orange.shade800,
      },
      {
        "id": "HAR-2026-00019",
        "unit": "ULD Batu Ampar",
        "machine": "PLTD Batu Ampar #03",
        "date": "31 Jul 2026 • Slot 16:00",
        "status": "Perlu Revisi",
        "color": Colors.red.shade700,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat HAR & Logsheet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: AppTheme.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mengunduh Laporan Excel (.xlsx)...')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filter Header
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Cari nomor HAR atau mesin',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.outlineVariant),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  style: IconButton.styleFrom(backgroundColor: AppTheme.primary),
                )
              ],
            ),
            const SizedBox(height: 16),

            // List of Reports
            Expanded(
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (ctx, idx) {
                  final item = reports[idx];
                  Color color = item['color'] as Color;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.outlineVariant),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(item['id'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['machine'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(item['date'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.outline)),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['status'] as String,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailHARScreen(harId: item['id'] as String)),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
