import 'package:flutter/material.dart';
import 'buat_har_screen.dart';
import 'lapor_amc_screen.dart';
import 'sop_k3_screen.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  String _selectedFilter = 'Semua';

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'NOTIF-001',
      'title': 'Peringatan Pemeliharaan Berkala 250 Jam',
      'desc': 'Unit 1 (Cummins KTA50-G3) telah mencapai 248 jam operasi. Segera persiapkan filter oli lube oil dan checklist HAR 250 Jam.',
      'waktu': '15 menit yang lalu',
      'kategori': 'Jadwal HAR',
      'isRead': false,
      'isUrgent': true,
      'icon': Icons.build_circle_rounded,
      'color': Color(0xFFF59E0B),
      'target': 'har',
    },
    {
      'id': 'NOTIF-002',
      'title': 'Laporan Gangguan AMC Baru Terdaftar',
      'desc': 'Tiket AMC-2026-10-001: Tekanan oli turun di bawah batas aman pada pembebanan 850 kW telah dipublikasikan oleh Teknisi.',
      'waktu': '2 jam yang lalu',
      'kategori': 'Darurat/AMC',
      'isRead': false,
      'isUrgent': true,
      'icon': Icons.warning_amber_rounded,
      'color': Color(0xFFEF4444),
      'target': 'amc',
    },
    {
      'id': 'NOTIF-003',
      'title': 'Verifikasi Kelayakan K3 & LOTO Disetujui',
      'desc': 'Pengajuan Lockout/Tagout untuk overhaul silinder unit 2 telah diverifikasi oleh SPV K3. Zero Energy State terkonfirmasi.',
      'waktu': 'Kemarin, 16:30',
      'kategori': 'K3 Pembangkit',
      'isRead': true,
      'isUrgent': false,
      'icon': Icons.shield_rounded,
      'color': Color(0xFF10B981),
      'target': 'k3',
    },
    {
      'id': 'NOTIF-004',
      'title': 'Instruksi Siaga Kelistrikan Akhir Pekan',
      'desc': 'Pastikan kesiapan seluruh genset PLTD (Daya Mampu Pasok > 2,800 kW) untuk mengantisipasi lonjakan beban puncak malam minggu.',
      'waktu': '2 hari yang lalu',
      'kategori': 'Pengumuman',
      'isRead': true,
      'isUrgent': false,
      'icon': Icons.campaign_rounded,
      'color': Color(0xFF0072B2),
      'target': 'info',
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi ditandai telah dibaca.'),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleTap(Map<String, dynamic> item) {
    setState(() {
      item['isRead'] = true;
    });

    final target = item['target'];
    if (target == 'har') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatHARScreen()));
    } else if (target == 'amc') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporAMCScreen()));
    } else if (target == 'k3') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SopK3Screen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _notifications.where((n) {
      if (_selectedFilter == 'Semua') return true;
      return n['kategori'] == _selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002F55),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifikasi & Info Operasi',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
            ),
            Text(
              'Pemberitahuan Siaga Pembangkit, Jadwal HAR & K3',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text('Tandai Dibaca', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Semua', 'Darurat/AMC', 'Jadwal HAR', 'K3 Pembangkit', 'Pengumuman'].map((cat) {
                  final isSel = _selectedFilter == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: isSel ? Colors.white : const Color(0xFF475569))),
                      selected: isSel,
                      selectedColor: const Color(0xFF0072B2),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: isSel ? const Color(0xFF0072B2) : const Color(0xFFCBD5E1)),
                      onSelected: (_) => setState(() => _selectedFilter = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = filtered[index];
                final isRead = item['isRead'] as bool;
                final color = item['color'] as Color;

                return InkWell(
                  onTap: () => _handleTap(item),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.white : const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isRead ? const Color(0xFFE2E8F0) : const Color(0xFFBAE6FD)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item['icon'] as IconData, color: color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item['kategori'] ?? '',
                                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: color),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    item['waktu'] ?? '',
                                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                                  ),
                                  if (!isRead) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF00A2E8),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['title'] ?? '',
                                style: TextStyle(
                                  fontWeight: isRead ? FontWeight.w800 : FontWeight.w900,
                                  fontSize: 13.5,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['desc'] ?? '',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
