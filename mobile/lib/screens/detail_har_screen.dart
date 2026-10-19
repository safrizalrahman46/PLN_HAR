import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/api_service.dart';

class DetailHARScreen extends StatefulWidget {
  final String harId;
  const DetailHARScreen({super.key, required this.harId});

  @override
  State<DetailHARScreen> createState() => _DetailHARScreenState();
}

class _DetailHARScreenState extends State<DetailHARScreen> {
  HARModel? _report;
  bool _isLoading = true;
  bool _isApproving = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() async {
    final report = await ApiService.getHARDetail(widget.harId);
    if (mounted) {
      setState(() {
        _report = report;
        _isLoading = false;
      });
    }
  }

  void _handleApprove() async {
    setState(() => _isApproving = true);
    await ApiService.approveHAR(widget.harId);
    if (mounted) {
      setState(() {
        _report?.status = 'approved';
        _isApproving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Laporan HAR Berhasil Di-Approve oleh Supervisor!'),
            ],
          ),
          backgroundColor: AppTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final r = _report;
    if (r == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail HAR')),
        body: const Center(child: Text('Data HAR tidak ditemukan')),
      );
    }

    final isApproved = r.status == 'approved';
    final statusBg = isApproved
        ? const Color(0xFFDCFCE7)
        : (r.status == 'submitted' ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF));
    final statusColor = isApproved
        ? const Color(0xFF16A34A)
        : (r.status == 'submitted' ? const Color(0xFFD97706) : const Color(0xFF2563EB));
    final statusLabel = isApproved
        ? 'Approved / Selesai'
        : (r.status == 'submitted' ? 'Menunggu Approval' : 'Draft Laporan');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(r.harNumber),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppTheme.primaryDark),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tautan Berita Acara ${r.harNumber} disalin ke clipboard.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.plnHeroGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        r.harNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${r.unitName} • Slot Jam ${r.timeSlot} WITA',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pelaksana: ${r.technicianName} • ${r.date}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Stepper Timeline Approval
            const Text(
              'Timeline Validasi Dokumen',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textDark),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.outlineVariant),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const _TimelineStep(title: 'Dibuat', isDone: true),
                  const _TimelineStep(title: 'Diajukan', isDone: true),
                  _TimelineStep(title: 'Review SPV', isDone: isApproved, isCurrent: !isApproved),
                  _TimelineStep(title: 'Approved', isDone: isApproved),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Machine & Operational Details Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.outlineVariant),
                boxShadow: AppTheme.softShadow,
              ),
              child: ExpansionTile(
                initiallyExpanded: true,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.settings_suggest_rounded, color: AppTheme.primary, size: 20),
                ),
                title: const Text('Identitas Mesin & Pengukuran', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
                children: [
                  ListTile(
                    title: const Text('Mesin PLTD', style: TextStyle(fontSize: 11, color: AppTheme.outline)),
                    subtitle: Text(r.machineName, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textDark, fontSize: 13)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Daya Mampu: ${r.dayaMampu.toInt()} kW', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              Text('Beban: ${r.beban.toInt()} kW', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tek. Oli: ${r.tekananOli} Bar', style: const TextStyle(fontSize: 12)),
                              Text('Jam Mesin: ${r.jamKerjaMesin.toInt()} HM', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Checklist Expansion
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.outlineVariant),
                boxShadow: AppTheme.softShadow,
              ),
              child: ExpansionTile(
                initiallyExpanded: true,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fact_check_rounded, color: AppTheme.textDark, size: 20),
                ),
                title: Text('Checklist Komponen (${r.checklists.length} Item)', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
                children: r.checklists.map((c) {
                  Color cColor = AppTheme.accentGreen;
                  Color cBg = const Color(0xFFDCFCE7);
                  if (c.condition == 'rusak') {
                    cColor = AppTheme.accentRed;
                    cBg = const Color(0xFFFEE2E2);
                  } else if (c.condition == 'perbaikan') {
                    cColor = const Color(0xFFD97706);
                    cBg = const Color(0xFFFEF3C7);
                  } else if (c.condition == 'skip') {
                    cColor = Colors.grey;
                    cBg = Colors.grey.shade100;
                  }

                  return ListTile(
                    dense: true,
                    title: Text(c.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    subtitle: Text(c.category, style: const TextStyle(fontSize: 10, color: AppTheme.outline)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        c.condition.toUpperCase(),
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: cColor),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Findings & Action
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.outlineVariant),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.report_problem_rounded, color: Color(0xFFD97706), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text('Temuan & Tindakan Pemeliharaan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Temuan Lapangan:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.outline)),
                  const SizedBox(height: 2),
                  Text(r.findingDescription.isNotEmpty ? r.findingDescription : 'Tidak ada temuan anomali.', style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
                  const SizedBox(height: 10),
                  const Text('Tindakan Dilakukan:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.outline)),
                  const SizedBox(height: 2),
                  Text(r.actionTaken.isNotEmpty ? r.actionTaken : 'Pemeriksaan operasional rutin.', style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Photos
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.outlineVariant),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.photo_library_rounded, color: AppTheme.primary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text('Dokumentasi Foto Lapangan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildThumbnail('Before', Icons.image_rounded),
                      _buildThumbnail('Process', Icons.image_rounded),
                      _buildThumbnail('After', Icons.image_rounded),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Action Buttons
            if (!isApproved) ...[
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isApproving ? null : _handleApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: _isApproving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.verified_rounded, size: 20),
                  label: const Text('Setujui & Approve HAR (1-Klik SPV)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mengunduh Berita Acara PDF & Excel untuk ${r.harNumber}...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryDark,
                  side: const BorderSide(color: AppTheme.outlineVariant),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.file_download_outlined, size: 20),
                label: const Text('Unduh Berita Acara (.pdf / .xlsx)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 86,
          height: 66,
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 28),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.outline)),
      ],
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
    Color color = isDone ? AppTheme.accentGreen : (isCurrent ? AppTheme.primary : AppTheme.outlineVariant);
    return Column(
      children: [
        Icon(
          isDone ? Icons.check_circle_rounded : (isCurrent ? Icons.radio_button_checked : Icons.radio_button_unchecked),
          size: 22,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isDone || isCurrent ? FontWeight.w800 : FontWeight.w500,
            color: isDone || isCurrent ? AppTheme.textDark : AppTheme.outline,
          ),
        ),
      ],
    );
  }
}
