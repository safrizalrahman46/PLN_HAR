import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DetailHARScreen extends StatelessWidget {
  final String harId;
  const DetailHARScreen({super.key, required this.harId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail $harId'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(harId, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const Text('Preventive Maintenance • Slot 08:00', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Menunggu Approval',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSecondaryContainer),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stepper Timeline
            const Text('Timeline Approval', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _TimelineStep(title: 'Dibuat', isDone: true),
                  _TimelineStep(title: 'Diajukan', isDone: true),
                  _TimelineStep(title: 'Review', isCurrent: true),
                  _TimelineStep(title: 'Approval', isDone: false),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Accordions
            ExpansionTile(
              initiallyExpanded: true,
              leading: const Icon(Icons.settings_suggest, color: AppTheme.primary),
              title: const Text('Informasi HAR & Mesin', style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                ListTile(
                  title: const Text('Mesin'),
                  subtitle: const Text('PLTD Batu Ampar #01 (DEUTZ BF6M 1013 E)'),
                ),
                ListTile(
                  title: const Text('Lokasi'),
                  subtitle: const Text('ULD Batu Ampar, Site Bontang'),
                ),
                ListTile(
                  title: const Text('Waktu Laporan'),
                  subtitle: const Text('02 Agustus 2026, 08:00 WIB'),
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.fact_check, color: AppTheme.secondary),
              title: const Text('Checklist Pemeliharaan (WACB)', style: TextStyle(fontWeight: FontWeight.bold)),
              children: const [
                ListTile(title: Text('Pemeriksaan Oli Mesin'), trailing: Text('Baik', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                ListTile(title: Text('Filter Air/Udara'), trailing: Text('Baik', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                ListTile(title: Text('Radiator & Pendingin'), trailing: Text('Baik', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.report_problem, color: Colors.orange),
              title: const Text('Temuan & Tindakan', style: TextStyle(fontWeight: FontWeight.bold)),
              children: const [
                ListTile(
                  title: Text('Temuan Utama'),
                  subtitle: Text('Filter oli sedikit kotor saat inspeksi slot 08:00.'),
                ),
                ListTile(
                  title: Text('Tindakan Pemeliharaan'),
                  subtitle: Text('Dilakukan pembersihan filter oli dan pengencangan klem.'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pengingat approval dikirim ke Supervisor!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.send),
                label: const Text('Kirim Pengingat Approval', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mengunduh Berita Acara PDF...')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.download),
                label: const Text('Download Berita Acara (PDF)', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final bool isDone;
  final bool isCurrent;

  const _TimelineStep({
    required this.title,
    this.isDone = false,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color = isDone
        ? Colors.green
        : isCurrent
            ? AppTheme.primary
            : AppTheme.outlineVariant;

    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: color,
          child: Icon(
            isDone ? Icons.check : (isCurrent ? Icons.edit : Icons.circle),
            size: 14,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent || isDone ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}
