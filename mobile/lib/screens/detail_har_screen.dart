import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/api_service.dart';
import '../services/export_import_service.dart';

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
  bool _isExporting = false;

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
              Icon(Icons.verified_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Laporan HAR Berhasil Di-Approve dan Disahkan oleh Supervisor!',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }

  void _handleDownloadPdf() async {
    final r = _report;
    if (r == null) return;
    setState(() => _isExporting = true);
    try {
      await ExportImportService.exportSingleHARToPdf(r);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Berita Acara PDF ${r.harNumber} berhasil diunduh.',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _handleDownloadExcel() async {
    final r = _report;
    if (r == null) return;
    setState(() => _isExporting = true);
    try {
      await ExportImportService.exportSingleHARToExcel(r);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.table_chart_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Berita Acara Excel (.xlsx) ${r.harNumber} berhasil diunduh.',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.cardShadow,
                ),
                child: const CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 3),
              ),
              const SizedBox(height: 16),
              const Text(
                'Memuat Berita Acara HAR...',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.outline),
              ),
            ],
          ),
        ),
      );
    }

    final r = _report;
    if (r == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail HAR')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 56, color: AppTheme.outline),
              const SizedBox(height: 12),
              const Text('Data Laporan HAR tidak ditemukan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Kembali ke Riwayat'),
              ),
            ],
          ),
        ),
      );
    }

    final isApproved = r.status == 'approved';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Sleek slate canvas
      body: CustomScrollView(
        slivers: [
          // 1. Bespoke Industrial Hero Header
          _buildSliverHeader(r, isApproved),

          // 2. Main Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline Validasi Dokumen (Connected Step Pipeline)
                  _buildTimelineCard(isApproved),
                  const SizedBox(height: 16),

                  // Machine Identity & Live Telemetry Cockpit
                  _buildMachineTelemetryCard(r),
                  const SizedBox(height: 16),

                  // Checklist Komponen (Sistematis & Berwarna)
                  _buildChecklistSection(r),
                  const SizedBox(height: 16),

                  // Temuan Lapangan & Tindakan Pemeliharaan
                  _buildFindingsAndActionCard(r),
                  const SizedBox(height: 16),

                  // Dokumentasi Foto Lapangan (Visual Evidence)
                  _buildPhotoGalleryCard(r),
                  const SizedBox(height: 16),

                  // Pengesahan & Tanda Tangan Digital
                  _buildSignaturesCard(r, isApproved),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomActionBar(r, isApproved),
    );
  }

  // ==========================================
  // SLIVER HERO APP BAR & HEADER
  // ==========================================
  Widget _buildSliverHeader(HARModel r, bool isApproved) {
    final statusColor = isApproved
        ? const Color(0xFF10B981)
        : (r.status == 'submitted' ? const Color(0xFFF59E0B) : const Color(0xFF0096D6));
    final statusBg = isApproved
        ? const Color(0xFF064E3B)
        : (r.status == 'submitted' ? const Color(0xFF78350F) : const Color(0xFF0C4A6E));
    final statusText = isApproved
        ? 'TERVALIDASI & APPROVED'
        : (r.status == 'submitted' ? 'MENUNGGU APPROVAL SPV' : 'DRAFT LAPORAN');

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF002244),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            tooltip: 'Kembali',
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextButton.icon(
            onPressed: _isExporting ? null : _handleDownloadPdf,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626).withValues(alpha: 0.9),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            icon: _isExporting
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf_rounded, size: 16),
            label: const Text('PDF', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ),
        const SizedBox(width: 6),
        Padding(
          padding: const EdgeInsets.only(right: 12.0, top: 8.0, bottom: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
              tooltip: 'Bagikan',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: 'Berita Acara HAR: ${r.harNumber} - ${r.unitName} (${r.machineName})'));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Nomor & Ringkasan ${r.harNumber} disalin ke clipboard.'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF001B36), Color(0xFF003865), Color(0xFF005691)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Row: Ticket Number & Status Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'PLN HAR',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            r.harNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withValues(alpha: 0.6), width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: statusColor.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Unit Title & Machine Subtitle
                  Text(
                    r.unitName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    r.machineName,
                    style: TextStyle(
                      color: const Color(0xFF67E8F9), // Electric Cyan
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 4 Metadata Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildHeaderMetaChip(Icons.calendar_today_rounded, r.date),
                      _buildHeaderMetaChip(Icons.access_time_filled_rounded, 'Slot ${r.timeSlot} WITA'),
                      _buildHeaderMetaChip(Icons.person_rounded, r.technicianName),
                      _buildHeaderMetaChip(
                        Icons.shield_rounded,
                        r.maintenanceType == 'preventive' ? 'Preventive HAR' : 'Corrective HAR',
                        accent: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderMetaChip(IconData icon, String label, {bool accent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent
            ? AppTheme.accentCyan.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accent
              ? AppTheme.accentCyan.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: accent ? AppTheme.accentCyan : Colors.white70),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: accent ? Colors.white : Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TIMELINE STEPPER CARD (CONNECTED PIPELINE)
  // ==========================================
  Widget _buildTimelineCard(bool isApproved) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0096D6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.alt_route_rounded, color: AppTheme.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Alur Validasi Dokumen HAR',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isApproved ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isApproved ? 'Tahap 4/4 Selesai' : 'Tahap 3/4 Evaluasi',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isApproved ? const Color(0xFF15803D) : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Horizontal Connected Stepper
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepNode(
                stepNum: '1',
                title: 'Dibuat',
                subtitle: 'Teknisi',
                isDone: true,
                isCurrent: false,
              ),
              _buildStepConnector(isDone: true),
              _buildStepNode(
                stepNum: '2',
                title: 'Diajukan',
                subtitle: 'Sistem WACB',
                isDone: true,
                isCurrent: false,
              ),
              _buildStepConnector(isDone: isApproved),
              _buildStepNode(
                stepNum: '3',
                title: 'Review SPV',
                subtitle: 'Evaluasi',
                isDone: isApproved,
                isCurrent: !isApproved,
              ),
              _buildStepConnector(isDone: isApproved),
              _buildStepNode(
                stepNum: '4',
                title: 'Approved',
                subtitle: 'Berita Acara',
                isDone: isApproved,
                isCurrent: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode({
    required String stepNum,
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isCurrent,
  }) {
    Color circleColor;
    Color iconColor;
    Widget innerContent;

    if (isDone) {
      circleColor = const Color(0xFF10B981);
      iconColor = Colors.white;
      innerContent = Icon(Icons.check_rounded, color: iconColor, size: 14);
    } else if (isCurrent) {
      circleColor = AppTheme.primary;
      innerContent = Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      );
    } else {
      circleColor = const Color(0xFFE2E8F0);
      innerContent = Text(
        stepNum,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
      );
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(child: innerContent),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isDone || isCurrent ? FontWeight.w900 : FontWeight.w600,
              color: isDone || isCurrent ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector({required bool isDone}) {
    return Container(
      width: 28,
      height: 3,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // ==========================================
  // MACHINE TELEMETRY & MEASUREMENTS COCKPIT
  // ==========================================
  Widget _buildMachineTelemetryCard(HARModel r) {
    final double loadPercentage = r.dayaMampu > 0 ? (r.beban / r.dayaMampu * 100) : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF004F8A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.speed_rounded, color: AppTheme.primaryDark, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Identitas Mesin & Telemetri',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          r.machineName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: AppTheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.power_rounded, size: 12, color: Color(0xFF2563EB)),
                      SizedBox(width: 4),
                      Text(
                        'PLTD SINKRON',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 4-Card Bento Telemetry Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Row 1: Beban vs Daya Mampu & Tekanan Oli
                Row(
                  children: [
                    // Card Beban
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'BEBAN DAYA',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${loadPercentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF15803D)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  r.beban.toInt().toString(),
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '/ 450 kW',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (loadPercentage / 100).clamp(0.0, 1.0),
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  loadPercentage > 90 ? const Color(0xFFEF4444) : const Color(0xFF0096D6),
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Card Tekanan Oli
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'TEKANAN OLI',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                                ),
                                Icon(Icons.water_drop_rounded, size: 14, color: Color(0xFFF59E0B)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  r.tekananOli.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Bar',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Standar: 3.5 - 5.0 Bar',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 2: Jam Kerja Mesin (HM) & Tegangan Generator
                Row(
                  children: [
                    // Jam Kerja Mesin
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'HOUR METER (HM)',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                                ),
                                Icon(Icons.timelapse_rounded, size: 14, color: Color(0xFF6366F1)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  r.jamKerjaMesin.toInt().toString(),
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Jam',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Servis Berkala: 1,500 HM',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tegangan & Frekuensi
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'OUTPUT GENSET',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                                ),
                                Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFEAB308)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '380',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'V / 50 Hz',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tegangan Stabil 3-Fasa',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CHECKLIST KOMPONEN SECTION
  // ==========================================
  Widget _buildChecklistSection(HARModel r) {
    final total = r.checklists.length;
    final normalCount = r.checklists.where((c) => c.condition.toLowerCase() == 'baik').length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.checklist_rounded, color: Color(0xFF10B981), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Checklist Komponen ($total Item)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const Text(
                          'Pemeriksaan Visual & Pengukuran Fisik',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: AppTheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$normalCount/$total Normal',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Item Tiles
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: r.checklists.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final item = r.checklists[index];
              return _buildChecklistItemTile(item, index + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItemTile(HARChecklistItem item, int index) {
    final condition = item.condition.toLowerCase();

    Color badgeBg;
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (condition == 'rusak') {
      badgeBg = const Color(0xFFFEE2E2);
      badgeColor = const Color(0xFFDC2626);
      badgeText = 'RUSAK';
      badgeIcon = Icons.cancel_rounded;
    } else if (condition == 'perbaikan') {
      badgeBg = const Color(0xFFFEF3C7);
      badgeColor = const Color(0xFFD97706);
      badgeText = 'PERBAIKAN';
      badgeIcon = Icons.build_circle_rounded;
    } else {
      badgeBg = const Color(0xFFDCFCE7);
      badgeColor = const Color(0xFF16A34A);
      badgeText = 'BAIK (NORMAL)';
      badgeIcon = Icons.check_circle_rounded;
    }

    // System icon based on category
    IconData categoryIcon = Icons.build_rounded;
    Color iconColor = AppTheme.primary;
    if (item.category.toLowerCase().contains('pelumas')) {
      categoryIcon = Icons.water_drop_rounded;
      iconColor = const Color(0xFFF59E0B);
    } else if (item.category.toLowerCase().contains('udara')) {
      categoryIcon = Icons.air_rounded;
      iconColor = const Color(0xFF0096D6);
    } else if (item.category.toLowerCase().contains('pendingin')) {
      categoryIcon = Icons.ac_unit_rounded;
      iconColor = const Color(0xFF0284C7);
    } else if (item.category.toLowerCase().contains('listrik') || item.category.toLowerCase().contains('elektrik')) {
      categoryIcon = Icons.bolt_rounded;
      iconColor = const Color(0xFF8B5CF6);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Category Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(categoryIcon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),

          // Title & Category Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                if (item.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Catatan: ${item.notes}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Condition Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(badgeIcon, size: 12, color: badgeColor),
                const SizedBox(width: 5),
                Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: badgeColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FINDINGS & ACTION TAKEN
  // ==========================================
  Widget _buildFindingsAndActionCard(HARModel r) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFFD97706), size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Catatan Temuan & Tindakan',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Temuan Lapangan Callout
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.search_rounded, size: 16, color: Color(0xFF0096D6)),
                    SizedBox(width: 6),
                    Text(
                      'TEMUAN LAPANGAN',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF004F8A)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  r.findingDescription.isNotEmpty
                      ? r.findingDescription
                      : 'Kondisi pelumasan, pendingin, dan getaran generator dalam batas toleransi normal sesuai manual book manufaktur.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tindakan Dilakukan Callout
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.handyman_rounded, size: 16, color: Color(0xFF16A34A)),
                    SizedBox(width: 6),
                    Text(
                      'TINDAKAN PEMELIHARAAN YANG DILAKUKAN',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF15803D)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  r.actionTaken.isNotEmpty
                      ? r.actionTaken
                      : 'Pembersihan elemen saringan udara, penambahan oli pelumas 2 Liter, inspeksi baut pondasi engine, dan pembersihan terminal aki.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FIELD PHOTOS GALLERY
  // ==========================================
  Widget _buildPhotoGalleryCard(HARModel r) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Color(0xFF8B5CF6), size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Dokumentasi Bukti Lapangan',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '3 Foto Terlampir',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Photo Thumbnails
          Row(
            children: [
              Expanded(
                child: _buildPhotoThumbnail(
                  label: 'Before HAR',
                  tag: 'Kondisi Awal',
                  icon: Icons.filter_vintage_rounded,
                  color: const Color(0xFF0284C7),
                  photoData: r.photos.isNotEmpty ? r.photos[0] : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPhotoThumbnail(
                  label: 'Proses Pengerjaan',
                  tag: 'SOP K3',
                  icon: Icons.engineering_rounded,
                  color: const Color(0xFFD97706),
                  photoData: r.photos.length > 1 ? r.photos[1] : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPhotoThumbnail(
                  label: 'After HAR',
                  tag: 'Kondisi Andal',
                  icon: Icons.task_alt_rounded,
                  color: const Color(0xFF16A34A),
                  photoData: r.photos.length > 2 ? r.photos[2] : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail({
    required String label,
    required String tag,
    required IconData icon,
    required Color color,
    String? photoData,
  }) {
    Uint8List? imageBytes;
    if (photoData != null && photoData.isNotEmpty) {
      try {
        final clean = photoData.contains(',') ? photoData.split(',').last : photoData;
        imageBytes = base64Decode(clean);
      } catch (_) {}
    }

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageBytes != null
                        ? Stack(
                            children: [
                              Image.memory(
                                imageBytes,
                                width: double.infinity,
                                height: 240,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  color: Colors.black.withValues(alpha: 0.75),
                                  child: const Text(
                                    'PLN HAR TERVERIFIKASI • Watermark GPS Aktif',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            width: double.infinity,
                            height: 220,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.35)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(icon, size: 56, color: color),
                                const SizedBox(height: 10),
                                Text(
                                  'Dokumentasi Visual Pemeliharaan',
                                  style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Kamera Lapangan Resolusi HD Terverifikasi',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tag: $tag',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                      ),
                      const Text(
                        'GPS Geotag Valid ✓',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.25)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        imageBytes,
                        width: double.infinity,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Icon(icon, color: color, size: 28),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SIGNATURES & VALIDATION SEAL
  // ==========================================
  Widget _buildSignaturesCard(HARModel r, bool isApproved) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF002F55).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.verified_user_rounded, color: Color(0xFF002F55), size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Pengesahan Berita Acara Resmi',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              // Pelaksana
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PETUGAS PELAKSANA',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.technicianName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Teknisi HAR PLTD',
                        style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded, size: 10, color: Color(0xFF15803D)),
                            SizedBox(width: 3),
                            Text(
                              'Ditandatangani',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Supervisor
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isApproved ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isApproved ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SUPERVISOR OPERASI',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Ir. Hendra Wijaya',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'SPV Pemeliharaan KIT',
                        style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isApproved ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isApproved ? Icons.verified_rounded : Icons.schedule_rounded,
                              size: 10,
                              color: isApproved ? const Color(0xFF15803D) : const Color(0xFFB45309),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isApproved ? 'Tervalidasi Digital' : 'Menunggu Approval',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: isApproved ? const Color(0xFF15803D) : const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FLOATING BOTTOM ACTION DECK
  // ==========================================
  Widget _buildBottomActionBar(HARModel r, bool isApproved) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Secondary Action 1: Download PDF
                OutlinedButton.icon(
                  onPressed: _isExporting ? null : _handleDownloadPdf,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
                    foregroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isExporting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFDC2626)))
                      : const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: const Text(
                    'PDF',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),

                // Secondary Action 2: Download Excel
                OutlinedButton.icon(
                  onPressed: _isExporting ? null : _handleDownloadExcel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
                    foregroundColor: const Color(0xFF16A34A),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isExporting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF16A34A)))
                      : const Icon(Icons.table_chart_rounded, size: 18),
                  label: const Text(
                    'Excel',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),

                // Primary Action: Approve (if not approved yet)
                if (!isApproved) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.35),
                            blurRadius: 10,
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _isApproving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.verified_rounded, size: 18),
                        label: const Text(
                          'Approve (SPV)',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
