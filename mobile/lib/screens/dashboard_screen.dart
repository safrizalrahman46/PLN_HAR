import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'buat_har_screen.dart';
import 'riwayat_har_screen.dart';
import 'daftar_mesin_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  final List<String> _wacbTimeSlots = [
    "01:00", "02:00", "03:00", "04:00", "05:00", "06:00",
    "07:00", "08:00", "09:00", "10:00", "11:00", "12:00",
    "13:00", "14:00", "15:00", "16:00", "17:00", "18:00",
    "19:00", "20:00", "21:00", "22:00", "23:00", "24:00"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PLN Nusa Daya HAR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.primary),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang, Rahman',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                    Text(
                      'Teknisi Pemeliharaan PLTD',
                      style: TextStyle(fontSize: 12, color: AppTheme.outline),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'ULD Batu Ampar',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bento Grid Summary
            Row(
              children: [
                Expanded(
                  child: _buildBentoCard(
                    title: 'Total HAR',
                    value: '24',
                    icon: Icons.analytics,
                    color: AppTheme.primary,
                    bgColor: AppTheme.surfaceContainerLow,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBentoCard(
                    title: 'Menunggu Approval',
                    value: '4',
                    icon: Icons.pending_actions,
                    color: AppTheme.secondary,
                    bgColor: AppTheme.surfaceContainerLow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildBentoCard(
                    title: 'Sedang Dikerjakan',
                    value: '6',
                    icon: Icons.build,
                    color: AppTheme.primaryContainer,
                    bgColor: AppTheme.surfaceContainerLow,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBentoCard(
                    title: 'Selesai',
                    value: '14',
                    icon: Icons.check_circle,
                    color: Colors.green.shade700,
                    bgColor: Colors.green.shade50,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Primary Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BuatHARScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryContainer,
                  foregroundColor: AppTheme.onSecondaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.add_circle),
                label: const Text(
                  'Buat HAR Baru / Input Logsheet',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Matriks Slot Jam WACB 24 Jam
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status Slot Jam WACB (Bebas Input)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
                Text(
                  'Bisa Semua Jam',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih slot jam kapan saja untuk mulai input logsheet (sebelum/sesudah jam real-time):',
                    style: TextStyle(fontSize: 11, color: AppTheme.outline),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _wacbTimeSlots.map((slot) {
                      bool isDone = ["01:00", "02:00", "03:00", "04:00", "08:00"].contains(slot);
                      bool isDraft = ["05:00", "11:00"].contains(slot);
                      Color chipColor = isDone
                          ? Colors.green.shade100
                          : isDraft
                              ? Colors.amber.shade100
                              : AppTheme.surfaceContainerLow;
                      Color textColor = isDone
                          ? Colors.green.shade900
                          : isDraft
                              ? Colors.amber.shade900
                              : AppTheme.primary;

                      return InkWell(
                        onTap: () {
                          // Unlocked for ALL time slots - operator can click any hour at any real-time
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BuatHARScreen(initialTimeSlot: slot),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: chipColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDone
                                  ? Colors.green
                                  : isDraft
                                      ? Colors.amber
                                      : AppTheme.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                slot,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                isDone ? Icons.check_circle : (isDraft ? Icons.pending : Icons.edit_calendar),
                                size: 12,
                                color: textColor,
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(children: [
                        CircleAvatar(radius: 4, backgroundColor: Colors.green),
                        SizedBox(width: 4),
                        Text('Sudah Terisi (Hijau)', style: TextStyle(fontSize: 10)),
                      ]),
                      Row(children: [
                        CircleAvatar(radius: 4, backgroundColor: Colors.amber),
                        SizedBox(width: 4),
                        Text('Draft (Kuning)', style: TextStyle(fontSize: 10)),
                      ]),
                      Row(children: [
                        CircleAvatar(radius: 4, backgroundColor: AppTheme.primary),
                        SizedBox(width: 4),
                        Text('Siap Input (Klik BEBAS)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ]),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Activity Section
            const Text(
              'Aktivitas Terbaru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            _buildActivityCard(
              harNumber: 'HAR-2026-00021',
              title: 'PLTD Batu Ampar #01',
              subtitle: 'Preventive Maintenance • Slot 08:00',
              status: 'Sedang Dikerjakan',
              statusColor: AppTheme.primaryContainer,
            ),
            const SizedBox(height: 10),
            _buildActivityCard(
              harNumber: 'HAR-2026-00020',
              title: 'PLTD Batu Ampar #02',
              subtitle: 'Corrective Maintenance • Slot 07:00',
              status: 'Menunggu Approval',
              statusColor: AppTheme.secondary,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.outline,
        onTap: (idx) {
          setState(() => _currentNavIndex = idx);
          if (idx == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DaftarMesinScreen()));
          } else if (idx == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatHARScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.engineering), label: 'Daftar Mesin'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
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
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.outline)),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String harNumber,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(harNumber, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.outline)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
            ),
          )
        ],
      ),
    );
  }
}
