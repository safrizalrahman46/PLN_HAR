import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import '../models/models.dart';
import 'file_saver.dart';

class ImportResult {
  final String fileName;
  final String fileType;
  final List<HARModel> parsedReports;
  final List<MachineModel> parsedMachines;
  final String? errorMessage;

  ImportResult({
    required this.fileName,
    required this.fileType,
    this.parsedReports = const [],
    this.parsedMachines = const [],
    this.errorMessage,
  });

  bool get isSuccess => errorMessage == null && (parsedReports.isNotEmpty || parsedMachines.isNotEmpty);
}

class ExportImportService {
  // ==================== 1. EXPORT REKAP HAR TO PDF ====================
  static Future<void> exportHARListToPdf(List<HARModel> reports, {String? unitName}) async {
    final pdf = pw.Document();
    final unitTitle = unitName ?? (reports.isNotEmpty ? reports.first.unitName : 'PLTD WILAYAH KALTIM 3');
    final printDate = DateTime.now().toString().substring(0, 19);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PT PLN (PERSERO) - PLN NUSA DAYA',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.blue900),
                      ),
                      pw.Text(
                        'DIVISI KEANDALAN OPERASI & PEMELIHARAAN PEMBANGKIT PLTD',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Unit Layanan: $unitTitle',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'BERITA ACARA REKAPITULASI HAR',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                      ),
                      pw.Text('Waktu Cetak: $printDate', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                      pw.Text('Total: ${reports.length} Laporan', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1.5, color: PdfColors.blue900),
              pw.SizedBox(height: 10),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Sistem Manajemen Pemeliharaan PLN HAR Mobile - Dokumen Sah Pembangkit',
                style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
              ),
              pw.Text(
                'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            // KPI Summary Row
            pw.Row(
              children: [
                _buildPdfKpiBox('Total Laporan', '${reports.length}', PdfColors.blue),
                pw.SizedBox(width: 8),
                _buildPdfKpiBox(
                  'Approved (SPV)',
                  '${reports.where((r) => r.status == 'approved').length}',
                  PdfColors.green,
                ),
                pw.SizedBox(width: 8),
                _buildPdfKpiBox(
                  'Menunggu Approval',
                  '${reports.where((r) => r.status == 'submitted').length}',
                  PdfColors.orange,
                ),
                pw.SizedBox(width: 8),
                _buildPdfKpiBox(
                  'Draft',
                  '${reports.where((r) => r.status == 'draft').length}',
                  PdfColors.grey,
                ),
              ],
            ),
            pw.SizedBox(height: 14),

            // Main Table
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
              rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
              oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              headers: [
                'No',
                'No. Tiket HAR',
                'Tanggal',
                'Jam',
                'Nama Mesin Genset',
                'Teknisi',
                'Tipe HAR',
                'Prioritas',
                'Status',
                'Hasil Akhir',
              ],
              data: List<List<String>>.generate(reports.length, (index) {
                final r = reports[index];
                return [
                  '${index + 1}',
                  r.harNumber,
                  r.date,
                  r.timeSlot,
                  r.machineName,
                  r.technicianName,
                  r.maintenanceType.toUpperCase(),
                  r.priority,
                  r.status == 'approved' ? 'APPROVED' : (r.status == 'submitted' ? 'PENDING SPV' : 'DRAFT'),
                  r.finalResult,
                ];
              }),
            ),

            pw.SizedBox(height: 24),

            // Signatures block
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Dilaporkan Oleh,', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('Teknisi Pemeliharaan PLTD', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    pw.SizedBox(height: 38),
                    pw.Text('( Ahmad Teknisi / Pelaksana )', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text('NIP. 9418293PLN', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Mengetahui & Menyetujui,', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('Supervisor Operasi & Keandalan (SPV)', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    pw.SizedBox(height: 38),
                    pw.Text('( Super Admin K3 / SPV HAR )', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text('NIP. 8916321PLN', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    final fileName = 'REKAP_HAR_${unitTitle.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    downloadFile(bytes, fileName, mimeType: 'application/pdf');
  }

  static pw.Widget _buildPdfKpiBox(String title, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 1),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(title, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800)),
            pw.Text(
              value,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Styling for Excel Cells
  static CellStyle _excelHeaderStyle({ExcelColor? bgColor}) {
    return CellStyle(
      bold: true,
      fontSize: 10,
      fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
      backgroundColorHex: bgColor ?? ExcelColor.fromHexString('FF004B87'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      leftBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('FFE2E8F0')),
      rightBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('FFE2E8F0')),
      topBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('FFE2E8F0')),
      bottomBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('FFE2E8F0')),
    );
  }

  static CellStyle _excelDataStyle({
    bool isOdd = false,
    HorizontalAlign align = HorizontalAlign.Left,
    bool bold = false,
    ExcelColor? fontColor,
    ExcelColor? bgColor,
  }) {
    final defaultBg = isOdd ? ExcelColor.fromHexString('FFF8FAFC') : ExcelColor.fromHexString('FFFFFFFF');
    return CellStyle(
      bold: bold,
      fontSize: 9,
      fontColorHex: fontColor ?? ExcelColor.fromHexString('FF1E293B'),
      backgroundColorHex: bgColor ?? defaultBg,
      horizontalAlign: align,
      verticalAlign: VerticalAlign.Center,
      leftBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('FFE2E8F0')),
      rightBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('FFE2E8F0')),
      topBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('FFE2E8F0')),
      bottomBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('FFE2E8F0')),
    );
  }

  // ==================== 2. EXPORT SINGLE HAR DETAIL TO PDF ====================
  static Future<void> exportSingleHARToPdf(HARModel report) async {
    final pdf = pw.Document();

    // Extract valid photos if available
    final List<Uint8List> validPhotoBytes = [];
    for (final p in report.photos) {
      if (p.isEmpty) continue;
      try {
        final clean = p.contains(',') ? p.split(',').last : p;
        final decoded = base64Decode(clean);
        if (decoded.isNotEmpty) {
          validPhotoBytes.add(decoded);
        }
      } catch (_) {}
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PT PLN (PERSERO) - PLN NUSA DAYA',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.blue900),
                      ),
                      pw.Text(
                        'DIVISI KEANDALAN OPERASI & PEMELIHARAAN PEMBANGKIT PLTD',
                        style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Unit Layanan: ${report.unitName}',
                        style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: pw.BoxDecoration(
                      color: report.status == 'approved' ? PdfColors.green50 : PdfColors.amber50,
                      border: pw.Border.all(
                        color: report.status == 'approved' ? PdfColors.green700 : PdfColors.amber700,
                        width: 1.2,
                      ),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          report.status == 'approved' ? 'STATUS: APPROVED ✓' : 'STATUS: MENUNGGU APPROVAL SPV',
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold,
                            color: report.status == 'approved' ? PdfColors.green900 : PdfColors.amber900,
                          ),
                        ),
                        pw.Text('No. Tiket: ${report.harNumber}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1.5, color: PdfColors.blue900),
              pw.SizedBox(height: 8),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Sistem Manajemen Pemeliharaan PLN HAR Mobile - Berita Acara Sah Elektronik',
                style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
              ),
              pw.Text(
                'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            // Title Bar
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: const pw.BoxDecoration(color: PdfColors.blue900, borderRadius: pw.BorderRadius.all(pw.Radius.circular(4))),
              child: pw.Center(
                child: pw.Text('BERITA ACARA PEMELIHARAAN (HAR) & LOGSHEET MESIN PEMBANGKIT', style: pw.TextStyle(color: PdfColors.white, fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
              ),
            ),
            pw.SizedBox(height: 8),

            // Identitas Laporan Grid
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        _buildPdfDetailRow('Nomor Berita Acara', report.harNumber),
                        _buildPdfDetailRow('Unit Layanan PLTD', report.unitName),
                        _buildPdfDetailRow('Mesin Pembangkit', report.machineName),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 14),
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        _buildPdfDetailRow('Tanggal & Jam Slot', '${report.date} (${report.timeSlot})'),
                        _buildPdfDetailRow('Teknisi Pelaksana', report.technicianName),
                        _buildPdfDetailRow('Tipe / Prioritas', '${report.maintenanceType.toUpperCase()} / Prioritas ${report.priority}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Parameter Operasi WACB
            pw.Text('Parameter Operasional Pembangkit (WACB):', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.SizedBox(height: 4),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellAlignment: pw.Alignment.center,
              headers: ['Daya Mampu', 'Beban Mesin', 'Stand kWh', 'Stand BBM', 'Tekanan Oli', 'Jam Kerja Mesin'],
              data: [
                [
                  '${report.dayaMampu.toInt()} kW',
                  '${report.beban.toInt()} kW',
                  '${report.standKwh}',
                  '${report.standBbm.toInt()} L',
                  '${report.tekananOli} Bar',
                  '${report.jamKerjaMesin.toInt()} Jam',
                ],
              ],
            ),
            pw.SizedBox(height: 10),

            // Checklist Items Table
            pw.Text('Daftar Periksa Fisik & Komponen Mesin (Checklist):', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.SizedBox(height: 4),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
              cellStyle: const pw.TextStyle(fontSize: 7.5),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3.5),
              headers: ['No', 'Kategori', 'Item Pemeriksaan', 'Kondisi Fisik', 'Catatan Teknisi'],
              data: List<List<String>>.generate(report.checklists.length, (idx) {
                final c = report.checklists[idx];
                return [
                  '${idx + 1}',
                  c.category,
                  c.title,
                  c.condition.toUpperCase(),
                  c.notes.isNotEmpty ? c.notes : '-',
                ];
              }),
            ),
            pw.SizedBox(height: 10),

            // Temuan & Tindakan
            pw.Text('Temuan & Rekomendasi Tindakan:', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.SizedBox(height: 4),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue200),
                borderRadius: pw.BorderRadius.circular(4),
                color: PdfColors.blue50,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Temuan: ${report.findingDescription.isNotEmpty ? report.findingDescription : "-"}', style: const pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(height: 2),
                  pw.Text('Tindakan Dilakukan: ${report.actionTaken.isNotEmpty ? report.actionTaken : "-"}', style: const pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(height: 2),
                  pw.Text('Hasil Akhir Evaluasi: ${report.finalResult}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                ],
              ),
            ),

            // Foto Dokumentasi (Real Captured Photos)
            if (validPhotoBytes.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              pw.Text('DOKUMENTASI FOTO FISIK LAPANGAN (VERIFIKASI KAMERA & GEOTAG):', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
              pw.SizedBox(height: 5),
              pw.Row(
                children: List<pw.Widget>.generate(validPhotoBytes.length > 3 ? 3 : validPhotoBytes.length, (i) {
                  final labels = ['Foto Sebelum (Before)', 'Saat Pekerjaan (Process)', 'Setelah Selesai (After)'];
                  final lbl = i < labels.length ? labels[i] : 'Foto Lapangan ${i + 1}';
                  return pw.Expanded(
                    child: pw.Container(
                      margin: const pw.EdgeInsets.symmetric(horizontal: 3),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Container(
                            width: double.infinity,
                            padding: const pw.EdgeInsets.symmetric(vertical: 3),
                            color: PdfColors.blue50,
                            child: pw.Center(
                              child: pw.Text(lbl, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                            ),
                          ),
                          pw.ClipRRect(
                            child: pw.Image(pw.MemoryImage(validPhotoBytes[i]), height: 95, fit: pw.BoxFit.cover),
                          ),
                          pw.Container(
                            width: double.infinity,
                            padding: const pw.EdgeInsets.symmetric(vertical: 2),
                            color: PdfColors.grey100,
                            child: pw.Center(
                              child: pw.Text('Watermark GPS Valid ✓', style: const pw.TextStyle(fontSize: 6, color: PdfColors.green800)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],

            pw.SizedBox(height: 18),

            // Tanda Tangan
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Pelaksana Pemeliharaan,', style: const pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(height: 32),
                    pw.Text(report.technicianName, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Teknisi PLTD (NIP: 199504122019031001)', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.blue800, width: 1),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text('TERVALIDASI ELEKTRONIK', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.Text('PLN HAR MOBILE', style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey700)),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Mengetahui & Menyetujui,', style: const pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(height: 32),
                    pw.Text('Super Admin K3 / SPV HAR', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Supervisor Operasi & Keandalan', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    final fileName = 'BERITA_ACARA_${report.harNumber}.pdf';
    downloadFile(bytes, fileName, mimeType: 'application/pdf');
  }

  // ==================== 2B. EXPORT SINGLE HAR DETAIL TO EXCEL (.XLSX) ====================
  static Future<void> exportSingleHARToExcel(HARModel report) async {
    final excel = Excel.createExcel();
    final sheetName = 'Berita_Acara_HAR';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    void setCell(int col, int row, CellValue value, CellStyle style) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
      cell.value = value;
      cell.cellStyle = style;
    }

    // Set Column Widths (6 columns: A to F)
    sheet.setColumnWidth(0, 8.0);
    sheet.setColumnWidth(1, 26.0);
    sheet.setColumnWidth(2, 34.0);
    sheet.setColumnWidth(3, 20.0);
    sheet.setColumnWidth(4, 30.0);
    sheet.setColumnWidth(5, 20.0);

    // Row 0: Company Banner
    sheet.setRowHeight(0, 34.0);
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0),
      customValue: TextCellValue('PT PLN (PERSERO) - PLN NUSA DAYA'),
    );
    sheet.setMergedCellStyle(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellStyle(
        bold: true,
        fontSize: 13,
        fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
        backgroundColorHex: ExcelColor.fromHexString('FF002244'),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      ),
    );

    // Row 1: Document Title
    sheet.setRowHeight(1, 24.0);
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 1),
      customValue: TextCellValue('LEMBAR BERITA ACARA PEMELIHARAAN (HAR) MESIN PLTD'),
    );
    sheet.setMergedCellStyle(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      CellStyle(
        bold: true,
        fontSize: 11,
        fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
        backgroundColorHex: ExcelColor.fromHexString('FF0072B2'),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      ),
    );

    // Row 2: Subtitle
    sheet.setRowHeight(2, 20.0);
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2),
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 2),
      customValue: TextCellValue('No. Berita Acara: ${report.harNumber} | Status: ${report.status.toUpperCase()} | Unit: ${report.unitName}'),
    );
    sheet.setMergedCellStyle(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2),
      CellStyle(
        italic: true,
        fontSize: 9,
        fontColorHex: ExcelColor.fromHexString('FF1E293B'),
        backgroundColorHex: ExcelColor.fromHexString('FFF1F5F9'),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      ),
    );

    // Row 3: Blank separator
    sheet.setRowHeight(3, 8.0);

    // Section 1: IDENTITAS DOKUMEN & MESIN
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4),
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 4),
      customValue: TextCellValue('1. IDENTITAS DOKUMEN & UNIT PEMBANGKIT'),
    );
    sheet.setMergedCellStyle(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4),
      _excelHeaderStyle(bgColor: ExcelColor.fromHexString('FF004B87')),
    );

    final meta = [
      ['Nomor Tiket HAR', report.harNumber, 'Tanggal Inspeksi', report.date],
      ['Unit Layanan PLTD', report.unitName, 'Jam Slot Operasi', report.timeSlot],
      ['Mesin Pembangkit', report.machineName, 'Teknisi Pelaksana', report.technicianName],
      ['Tipe Pemeliharaan', report.maintenanceType.toUpperCase(), 'Prioritas HAR', report.priority],
      ['Status Berita Acara', report.status.toUpperCase(), 'Hasil Akhir', report.finalResult],
    ];

    for (int m = 0; m < meta.length; m++) {
      final rIdx = 5 + m;
      final isOdd = m % 2 == 1;
      setCell(0, rIdx, TextCellValue(''), _excelDataStyle(isOdd: isOdd));
      setCell(1, rIdx, TextCellValue(meta[m][0]), _excelDataStyle(isOdd: isOdd, bold: true));
      setCell(2, rIdx, TextCellValue(meta[m][1]), _excelDataStyle(isOdd: isOdd));
      setCell(3, rIdx, TextCellValue(meta[m][2]), _excelDataStyle(isOdd: isOdd, bold: true));
      setCell(4, rIdx, TextCellValue(meta[m][3]), _excelDataStyle(isOdd: isOdd));
      setCell(5, rIdx, TextCellValue(''), _excelDataStyle(isOdd: isOdd));
    }

    // Section 2: PARAMETER OPERASIONAL WACB
    const wacbRow = 11;
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: wacbRow),
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: wacbRow),
      customValue: TextCellValue('2. PARAMETER OPERASIONAL PEMBANGKIT (WACB)'),
    );
    sheet.setMergedCellStyle(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: wacbRow),
      _excelHeaderStyle(bgColor: ExcelColor.fromHexString('FF004B87')),
    );

    final paramHeaders = ['Daya Mampu', 'Beban Mesin', 'Stand kWh', 'Stand BBM', 'Tekanan Oli', 'Jam Kerja Mesin'];
    for (int p = 0; p < paramHeaders.length; p++) {
      setCell(p, wacbRow + 1, TextCellValue(paramHeaders[p]), _excelHeaderStyle(bgColor: ExcelColor.fromHexString('FF0284C7')));
    }

    final paramValues = [
      '${report.dayaMampu.toInt()} kW',
      '${report.beban.toInt()} kW',
      '${report.standKwh}',
      '${report.standBbm.toInt()} Liter',
      '${report.tekananOli} Bar',
      '${report.jamKerjaMesin.toInt()} HM',
    ];
    for (int p = 0; p < paramValues.length; p++) {
      setCell(p, wacbRow + 2, TextCellValue(paramValues[p]), _excelDataStyle(align: HorizontalAlign.Center, bold: true));
    }

    // Section 3: CHECKLIST ITEMS
    const checkRow = wacbRow + 4;
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: checkRow),
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: checkRow),
      customValue: TextCellValue('3. DAFTAR PERIKSA FISIK & KOMPONEN MESIN (CHECKLIST)'),
    );
    sheet.setMergedCellStyle(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: checkRow),
      _excelHeaderStyle(bgColor: ExcelColor.fromHexString('FF004B87')),
    );

    final checkHeaders = ['NO', 'KATEGORI SISTEM', 'ITEM PEMERIKSAAN', 'KONDISI FISIK', 'CATATAN PEMERIKSAAN', 'STATUS'];
    for (int ch = 0; ch < checkHeaders.length; ch++) {
      setCell(ch, checkRow + 1, TextCellValue(checkHeaders[ch]), _excelHeaderStyle(bgColor: ExcelColor.fromHexString('FF0284C7')));
    }

    for (int cIdx = 0; cIdx < report.checklists.length; cIdx++) {
      final c = report.checklists[cIdx];
      final rIdx = checkRow + 2 + cIdx;
      final isOdd = cIdx % 2 == 1;

      final condBg = c.condition == 'baik'
          ? ExcelColor.fromHexString('FFDCFCE7')
          : (c.condition == 'perbaikan' ? ExcelColor.fromHexString('FFFEF3C7') : ExcelColor.fromHexString('FFFEE2E2'));
      final condText = c.condition == 'baik'
          ? ExcelColor.fromHexString('FF166534')
          : (c.condition == 'perbaikan' ? ExcelColor.fromHexString('FF92400E') : ExcelColor.fromHexString('FF991B1B'));

      setCell(0, rIdx, IntCellValue(cIdx + 1), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center));
      setCell(1, rIdx, TextCellValue(c.category), _excelDataStyle(isOdd: isOdd, bold: true));
      setCell(2, rIdx, TextCellValue(c.title), _excelDataStyle(isOdd: isOdd));
      setCell(3, rIdx, TextCellValue(c.condition.toUpperCase()), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center, bold: true, bgColor: condBg, fontColor: condText));
      setCell(4, rIdx, TextCellValue(c.notes.isNotEmpty ? c.notes : '-'), _excelDataStyle(isOdd: isOdd));
      setCell(5, rIdx, TextCellValue('TERVERIFIKASI'), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center));
    }

    // Section 4: TEMUAN & REKOMENDASI
    final findRow = checkRow + 3 + report.checklists.length;
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: findRow),
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: findRow),
      customValue: TextCellValue('4. TEMUAN PEMERIKSAAN & TINDAKAN PERBAIKAN'),
    );
    sheet.setMergedCellStyle(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: findRow),
      _excelHeaderStyle(bgColor: ExcelColor.fromHexString('FF004B87')),
    );

    setCell(0, findRow + 1, TextCellValue('Temuan Lapangan'), _excelDataStyle(bold: true));
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: findRow + 1),
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: findRow + 1),
      customValue: TextCellValue(report.findingDescription.isNotEmpty ? report.findingDescription : 'Kondisi mesin normal'),
    );
    sheet.setMergedCellStyle(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: findRow + 1), _excelDataStyle());

    setCell(0, findRow + 2, TextCellValue('Tindakan Dilakukan'), _excelDataStyle(bold: true));
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: findRow + 2),
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: findRow + 2),
      customValue: TextCellValue(report.actionTaken.isNotEmpty ? report.actionTaken : 'Pemeliharaan rutin terjadwal'),
    );
    sheet.setMergedCellStyle(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: findRow + 2), _excelDataStyle());

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final fileName = 'BERITA_ACARA_${report.harNumber}.xlsx';
      downloadFile(fileBytes, fileName, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    }
  }

  static pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
          ),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
          ),
        ],
      ),
    );
  }

  // ==================== 3. EXPORT REKAP HAR TO EXCEL (.XLSX) ====================
  static Future<void> exportHARListToExcel(List<HARModel> reports, {String? unitName}) async {
    final excel = Excel.createExcel();
    final sheetName = 'Rekap_HAR';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    final unitTitle = unitName ?? (reports.isNotEmpty ? reports.first.unitName : 'PLTD WILAYAH KALTIM 3');
    final printDate = DateTime.now().toString().substring(0, 19);

    void setCell(int col, int row, CellValue value, CellStyle style) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
      cell.value = value;
      cell.cellStyle = style;
    }

    // Set Column Widths (21 columns)
    final colWidths = [
      8.0,   // NO
      22.0,  // NO TIKET HAR
      14.0,  // TANGGAL
      12.0,  // JAM SLOT
      14.0,  // KODE UNIT
      28.0,  // UNIT PLTD
      14.0,  // ID MESIN
      36.0,  // NAMA MESIN GENERATOR
      16.0,  // TIPE HAR
      14.0,  // PRIORITAS
      24.0,  // TEKNISI PELAKSANA
      20.0,  // STATUS LAPORAN
      18.0,  // HASIL AKHIR
      18.0,  // DAYA MAMPU (kW)
      18.0,  // BEBAN MESIN (kW)
      18.0,  // STAND KWH
      18.0,  // STAND BBM (L)
      18.0,  // TEKANAN OLI (Bar)
      22.0,  // JAM KERJA MESIN (HM)
      45.0,  // TEMUAN PEMERIKSAAN
      45.0,  // TINDAKAN PERBAIKAN
    ];
    for (int c = 0; c < colWidths.length; c++) {
      sheet.setColumnWidth(c, colWidths[c]);
    }

    // Row 0: Company Banner
    sheet.setRowHeight(0, 36.0);
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 20, rowIndex: 0),
      customValue: TextCellValue('PT PLN (PERSERO) - PLN NUSA DAYA'),
    );
    final companyStyle = CellStyle(
      bold: true,
      fontSize: 13,
      fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('FF002244'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    sheet.setMergedCellStyle(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), companyStyle);

    // Row 1: Document Title
    sheet.setRowHeight(1, 24.0);
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      CellIndex.indexByColumnRow(columnIndex: 20, rowIndex: 1),
      customValue: TextCellValue('REKAPITULASI LAPORAN PEMELIHARAAN (HAR) & LOGSHEET MESIN PEMBANGKIT PLTD'),
    );
    final titleStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('FF0072B2'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    sheet.setMergedCellStyle(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1), titleStyle);

    // Row 2: Subtitle Metadata
    sheet.setRowHeight(2, 20.0);
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2),
      CellIndex.indexByColumnRow(columnIndex: 20, rowIndex: 2),
      customValue: TextCellValue('Unit Layanan: $unitTitle | Waktu Ekspor: $printDate WITA | Total Terdata: ${reports.length} Laporan HAR'),
    );
    final subtitleStyle = CellStyle(
      italic: true,
      fontSize: 9,
      fontColorHex: ExcelColor.fromHexString('FF1E293B'),
      backgroundColorHex: ExcelColor.fromHexString('FFF1F5F9'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    sheet.setMergedCellStyle(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2), subtitleStyle);

    // Row 3: Blank separator
    sheet.setRowHeight(3, 10.0);

    // Row 4: Column Headers
    sheet.setRowHeight(4, 26.0);
    final headers = [
      'NO',
      'NO TIKET HAR',
      'TANGGAL',
      'JAM SLOT',
      'KODE UNIT',
      'UNIT PLTD',
      'ID MESIN',
      'NAMA MESIN GENERATOR',
      'TIPE HAR',
      'PRIORITAS',
      'TEKNISI PELAKSANA',
      'STATUS LAPORAN',
      'HASIL AKHIR',
      'DAYA MAMPU (kW)',
      'BEBAN MESIN (kW)',
      'STAND KWH',
      'STAND BBM (L)',
      'TEKANAN OLI (Bar)',
      'JAM KERJA MESIN (HM)',
      'TEMUAN PEMERIKSAAN',
      'TINDAKAN PERBAIKAN',
    ];

    for (int c = 0; c < headers.length; c++) {
      setCell(c, 4, TextCellValue(headers[c]), _excelHeaderStyle());
    }

    // Rows 5+: Data Rows
    for (int i = 0; i < reports.length; i++) {
      final r = reports[i];
      final rowIdx = 5 + i;
      final isOdd = i % 2 == 1;
      sheet.setRowHeight(rowIdx, 22.0);

      // Status color
      ExcelColor? statusBg;
      ExcelColor? statusText;
      final st = r.status.toLowerCase();
      if (st == 'approved') {
        statusBg = ExcelColor.fromHexString('FFDCFCE7');
        statusText = ExcelColor.fromHexString('FF166534');
      } else if (st == 'submitted') {
        statusBg = ExcelColor.fromHexString('FFFEF3C7');
        statusText = ExcelColor.fromHexString('FF92400E');
      } else {
        statusBg = ExcelColor.fromHexString('FFF1F5F9');
        statusText = ExcelColor.fromHexString('FF475569');
      }

      // Priority color
      ExcelColor? prioColor;
      if (r.priority == 'HIGH' || r.priority == 'CRITICAL') {
        prioColor = ExcelColor.fromHexString('FFDC2626');
      }

      setCell(0, rowIdx, IntCellValue(i + 1), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center));
      setCell(1, rowIdx, TextCellValue(r.harNumber), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center, bold: true));
      setCell(2, rowIdx, TextCellValue(r.date), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center));
      setCell(3, rowIdx, TextCellValue(r.timeSlot), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center));
      setCell(4, rowIdx, TextCellValue(r.kdUnit), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center));
      setCell(5, rowIdx, TextCellValue(r.unitName), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Left));
      setCell(6, rowIdx, TextCellValue(r.idMesin), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center));
      setCell(7, rowIdx, TextCellValue(r.machineName), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Left, bold: true));
      setCell(8, rowIdx, TextCellValue(r.maintenanceType.toUpperCase()), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center));
      setCell(9, rowIdx, TextCellValue(r.priority), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center, bold: prioColor != null, fontColor: prioColor));
      setCell(10, rowIdx, TextCellValue(r.technicianName), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Left));
      setCell(11, rowIdx, TextCellValue(r.status == 'approved' ? 'APPROVED' : (r.status == 'submitted' ? 'PENDING SPV' : 'DRAFT')), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center, bold: true, bgColor: statusBg, fontColor: statusText));
      setCell(12, rowIdx, TextCellValue(r.finalResult), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center));
      setCell(13, rowIdx, DoubleCellValue(r.dayaMampu), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Right));
      setCell(14, rowIdx, DoubleCellValue(r.beban), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Right));
      setCell(15, rowIdx, DoubleCellValue(r.standKwh), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Right));
      setCell(16, rowIdx, DoubleCellValue(r.standBbm), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Right));
      setCell(17, rowIdx, DoubleCellValue(r.tekananOli), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Right));
      setCell(18, rowIdx, DoubleCellValue(r.jamKerjaMesin), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Right));
      setCell(19, rowIdx, TextCellValue(r.findingDescription), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Left));
      setCell(20, rowIdx, TextCellValue(r.actionTaken), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Left));
    }

    // Sheet 2: Summary KPI
    final summarySheet = excel['Ringkasan_KPI'];
    summarySheet.setColumnWidth(0, 40.0);
    summarySheet.setColumnWidth(1, 24.0);

    // Title
    summarySheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0),
      customValue: TextCellValue('RINGKASAN INDIKATOR KINERJA PEMELIHARAAN (KPI HAR)'),
    );
    summarySheet.setMergedCellStyle(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellStyle(
        bold: true,
        fontSize: 11,
        fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
        backgroundColorHex: ExcelColor.fromHexString('FF002244'),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      ),
    );

    // KPI Header
    summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
      ..value = TextCellValue('INDIKATOR PARAMETER')
      ..cellStyle = _excelHeaderStyle();
    summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2))
      ..value = TextCellValue('NILAI PENCAPAIAN')
      ..cellStyle = _excelHeaderStyle();

    final kpis = [
      ['Total Laporan HAR Terdata', '${reports.length} Laporan'],
      ['Laporan Disetujui (Approved SPV)', '${reports.where((r) => r.status == 'approved').length} Laporan'],
      ['Laporan Menunggu Approval SPV', '${reports.where((r) => r.status == 'submitted').length} Laporan'],
      ['Laporan Status Draft', '${reports.where((r) => r.status == 'draft').length} Laporan'],
      ['Rata-rata Tekanan Oli Mesin', reports.isNotEmpty ? '${(reports.fold<double>(0, (s, r) => s + r.tekananOli) / reports.length).toStringAsFixed(2)} Bar' : '0.0 Bar'],
      ['Rata-rata Beban Operasi Mesin', reports.isNotEmpty ? '${(reports.fold<double>(0, (s, r) => s + r.beban) / reports.length).toStringAsFixed(1)} kW' : '0.0 kW'],
      ['Unit Layanan Pembangkit', unitTitle],
      ['Waktu Ekspor Laporan', printDate],
    ];

    for (int k = 0; k < kpis.length; k++) {
      final rIdx = 3 + k;
      final isOdd = k % 2 == 1;
      summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rIdx))
        ..value = TextCellValue(kpis[k][0])
        ..cellStyle = _excelDataStyle(isOdd: isOdd, bold: true);
      summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rIdx))
        ..value = TextCellValue(kpis[k][1])
        ..cellStyle = _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center, bold: true, fontColor: ExcelColor.fromHexString('FF0072B2'));
    }

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final unitClean = unitTitle.replaceAll(' ', '_');
      final fileName = 'REKAP_HAR_${unitClean}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      downloadFile(fileBytes, fileName, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    }
  }

  // ==================== 4. EXPORT REKAP HAR TO CSV ====================
  static Future<void> exportHARListToCsv(List<HARModel> reports) async {
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln('No,No Tiket HAR,Tanggal,Jam Slot,Kode Unit,Unit PLTD,ID Mesin,Nama Mesin,Tipe HAR,Prioritas,Teknisi,Status,Hasil Akhir,Daya Mampu,Beban,Stand kWh,Temuan,Tindakan');

    for (int i = 0; i < reports.length; i++) {
      final r = reports[i];
      final line = [
        '${i + 1}',
        '"${r.harNumber}"',
        '"${r.date}"',
        '"${r.timeSlot}"',
        '"${r.kdUnit}"',
        '"${r.unitName}"',
        '"${r.idMesin}"',
        '"${r.machineName}"',
        '"${r.maintenanceType}"',
        '"${r.priority}"',
        '"${r.technicianName}"',
        '"${r.status}"',
        '"${r.finalResult}"',
        '${r.dayaMampu}',
        '${r.beban}',
        '${r.standKwh}',
        '"${r.findingDescription.replaceAll('"', '""')}"',
        '"${r.actionTaken.replaceAll('"', '""')}"',
      ].join(',');
      buffer.writeln(line);
    }

    final bytes = utf8.encode(buffer.toString());
    final fileName = 'REKAP_HAR_${DateTime.now().millisecondsSinceEpoch}.csv';
    downloadFile(bytes, fileName, mimeType: 'text/csv');
  }

  // ==================== 5. EXPORT REKAP HAR TO JSON ====================
  static Future<void> exportHARListToJson(List<HARModel> reports) async {
    final list = reports.map((r) => r.toJson()).toList();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(list);
    final bytes = utf8.encode(jsonStr);
    final fileName = 'BACKUP_HAR_${DateTime.now().millisecondsSinceEpoch}.json';
    downloadFile(bytes, fileName, mimeType: 'application/json');
  }

  // ==================== 6. EXPORT MESIN TO EXCEL & PDF ====================
  static Future<void> exportMachinesToExcel(List<MachineModel> machines, String unitName) async {
    final excel = Excel.createExcel();
    final sheetName = 'Daftar_Mesin';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    final printDate = DateTime.now().toString().substring(0, 19);

    void setCell(int col, int row, CellValue value, CellStyle style) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
      cell.value = value;
      cell.cellStyle = style;
    }

    // Set Column Widths (9 columns)
    final colWidths = [
      8.0,   // NO
      16.0,  // ID MESIN
      36.0,  // NAMA MESIN GENERATOR
      18.0,  // KODE SILM
      24.0,  // SERIAL NUMBER
      22.0,  // DAYA TERPASANG (kW)
      20.0,  // TIPE MESIN
      20.0,  // STATUS OPERASI
      14.0,  // KODE UNIT
    ];
    for (int c = 0; c < colWidths.length; c++) {
      sheet.setColumnWidth(c, colWidths[c]);
    }

    // Row 0: Company Banner
    sheet.setRowHeight(0, 34.0);
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0),
      customValue: TextCellValue('PT PLN (PERSERO) - PLN NUSA DAYA'),
    );
    sheet.setMergedCellStyle(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellStyle(
        bold: true,
        fontSize: 13,
        fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
        backgroundColorHex: ExcelColor.fromHexString('FF002244'),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      ),
    );

    // Row 1: Document Title
    sheet.setRowHeight(1, 24.0);
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 1),
      customValue: TextCellValue('INVENTARIS & DATABASE MESIN PEMBANGKIT PLTD'),
    );
    sheet.setMergedCellStyle(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      CellStyle(
        bold: true,
        fontSize: 11,
        fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
        backgroundColorHex: ExcelColor.fromHexString('FF0072B2'),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      ),
    );

    // Row 2: Subtitle Metadata
    sheet.setRowHeight(2, 20.0);
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2),
      CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 2),
      customValue: TextCellValue('Unit Layanan: $unitName | Tanggal Ekspor: $printDate WITA | Total Terdata: ${machines.length} Unit Mesin'),
    );
    sheet.setMergedCellStyle(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2),
      CellStyle(
        italic: true,
        fontSize: 9,
        fontColorHex: ExcelColor.fromHexString('FF1E293B'),
        backgroundColorHex: ExcelColor.fromHexString('FFF1F5F9'),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      ),
    );

    // Row 3: Blank separator
    sheet.setRowHeight(3, 8.0);

    // Row 4: Column Headers
    sheet.setRowHeight(4, 26.0);
    final headers = [
      'NO',
      'ID MESIN',
      'NAMA MESIN GENERATOR',
      'KODE SILM',
      'SERIAL NUMBER',
      'DAYA TERPASANG (kW)',
      'TIPE MESIN',
      'STATUS OPERASI',
      'KODE UNIT',
    ];
    for (int c = 0; c < headers.length; c++) {
      setCell(c, 4, TextCellValue(headers[c]), _excelHeaderStyle());
    }

    // Rows 5+: Data Rows
    for (int i = 0; i < machines.length; i++) {
      final m = machines[i];
      final rowIdx = 5 + i;
      final isOdd = i % 2 == 1;
      sheet.setRowHeight(rowIdx, 22.0);

      // Status color
      ExcelColor statusBg;
      ExcelColor statusText;
      final st = m.status.toLowerCase();
      if (st.contains('operasi') || st.contains('normal')) {
        statusBg = ExcelColor.fromHexString('FFDCFCE7');
        statusText = ExcelColor.fromHexString('FF166534');
      } else if (st.contains('standby')) {
        statusBg = ExcelColor.fromHexString('FFE0F2FE');
        statusText = ExcelColor.fromHexString('FF0369A1');
      } else {
        statusBg = ExcelColor.fromHexString('FFFEF3C7');
        statusText = ExcelColor.fromHexString('FF92400E');
      }

      setCell(0, rowIdx, IntCellValue(i + 1), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center));
      setCell(1, rowIdx, TextCellValue(m.idMesin), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center));
      setCell(2, rowIdx, TextCellValue(m.namaMesin), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Left, bold: true));
      setCell(3, rowIdx, TextCellValue(m.kodeMesinSilm), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center));
      setCell(4, rowIdx, TextCellValue(m.sn), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center));
      setCell(5, rowIdx, DoubleCellValue(m.dt), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Right));
      setCell(6, rowIdx, TextCellValue(m.tipeMesin), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center));
      setCell(7, rowIdx, TextCellValue(m.status.toUpperCase()), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center, bold: true, bgColor: statusBg, fontColor: statusText));
      setCell(8, rowIdx, TextCellValue(m.kdUnit), _excelDataStyle(isOdd: isOdd, align: HorizontalAlign.Center));
    }

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final fileName = 'INVENTARIS_MESIN_${unitName.replaceAll(' ', '_')}.xlsx';
      downloadFile(fileBytes, fileName, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    }
  }

  // ==================== 7. IMPORT HANDLER (EXCEL, CSV, JSON) ====================
  static Future<ImportResult> pickAndParseFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv', 'json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult(
          fileName: '',
          fileType: '',
          errorMessage: 'Pemilihan file dibatalkan.',
        );
      }

      final file = result.files.first;
      final fileName = file.name;
      final extension = (file.extension ?? '').toLowerCase();
      final bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        return ImportResult(
          fileName: fileName,
          fileType: extension,
          errorMessage: 'File kosong atau tidak dapat dibaca.',
        );
      }

      if (extension == 'xlsx' || extension == 'xls') {
        return _parseExcel(bytes, fileName, extension);
      } else if (extension == 'csv') {
        return _parseCsv(bytes, fileName);
      } else if (extension == 'json') {
        return _parseJson(bytes, fileName);
      } else {
        return ImportResult(
          fileName: fileName,
          fileType: extension,
          errorMessage: 'Format file .$extension tidak didukung. Harap pilih .xlsx, .csv, atau .json.',
        );
      }
    } catch (e) {
      return ImportResult(
        fileName: '',
        fileType: '',
        errorMessage: 'Terjadi kesalahan saat membaca file: $e',
      );
    }
  }

  static ImportResult _parseExcel(List<int> bytes, String fileName, String extension) {
    try {
      final excel = Excel.decodeBytes(bytes);
      final List<HARModel> parsed = [];

      for (var table in excel.tables.keys) {
        final rows = excel.tables[table]!.rows;
        if (rows.length <= 1) continue;

        // Row 0 is header, parse from row 1
        for (int i = 1; i < rows.length; i++) {
          final row = rows[i];
          if (row.isEmpty) continue;

          String getVal(int idx) {
            if (idx >= row.length || row[idx] == null) return '';
            return row[idx]!.value.toString().trim();
          }

          final harNumber = getVal(1).isNotEmpty ? getVal(1) : 'HAR-IMP-${DateTime.now().millisecondsSinceEpoch}-$i';
          final date = getVal(2).isNotEmpty ? getVal(2) : DateTime.now().toString().substring(0, 10);
          final timeSlot = getVal(3).isNotEmpty ? getVal(3) : '08:00';
          final kdUnit = getVal(4).isNotEmpty ? getVal(4) : '0283';
          final unitName = getVal(5).isNotEmpty ? getVal(5) : 'ULD MUARA PAHU';
          final idMesin = getVal(6).isNotEmpty ? getVal(6) : '000581';
          final machineName = getVal(7).isNotEmpty ? getVal(7) : 'PLTD MUARA PAHU #01 (CATERPILLAR 3512B)';
          final maintenanceType = getVal(8).isNotEmpty ? getVal(8).toLowerCase() : 'preventive';
          final priority = getVal(9).isNotEmpty ? getVal(9).toUpperCase() : 'NORMAL';
          final technician = getVal(10).isNotEmpty ? getVal(10) : 'Teknisi Impor';
          final status = getVal(11).isNotEmpty ? getVal(11).toLowerCase() : 'submitted';
          final finalResult = getVal(12).isNotEmpty ? getVal(12) : 'Normal Andal';
          final finding = getVal(18).isNotEmpty ? getVal(18) : 'Hasil impor logsheet lapangan';
          final action = getVal(19).isNotEmpty ? getVal(19) : 'Pengecekan parameter operasional rutin';

          parsed.add(
            HARModel(
              id: 'imp-$i-${DateTime.now().millisecondsSinceEpoch}',
              harNumber: harNumber,
              kdUnit: kdUnit,
              unitName: unitName,
              idMesin: idMesin,
              machineName: machineName,
              date: date,
              timeSlot: timeSlot,
              status: status.contains('app') ? 'approved' : 'submitted',
              priority: priority,
              maintenanceType: maintenanceType,
              technicianName: technician,
              findingDescription: finding,
              actionTaken: action,
              finalResult: finalResult,
              checklists: [
                HARChecklistItem(title: 'Level & Tekanan Oli Mesin', category: 'Sistem Pelumasan', condition: 'baik'),
                HARChecklistItem(title: 'Sistem Pendingin & Radiator', category: 'Sistem Pendingin', condition: 'baik'),
                HARChecklistItem(title: 'Sistem Bahan Bakar Solar', category: 'Sistem Bahan Bakar', condition: 'baik'),
              ],
            ),
          );
        }
      }

      if (parsed.isEmpty) {
        return ImportResult(
          fileName: fileName,
          fileType: extension,
          errorMessage: 'Tidak ditemukan baris data valid di dalam spreadsheet Excel ini.',
        );
      }

      return ImportResult(
        fileName: fileName,
        fileType: extension,
        parsedReports: parsed,
      );
    } catch (e) {
      return ImportResult(
        fileName: fileName,
        fileType: extension,
        errorMessage: 'Gagal memproses file Excel: $e',
      );
    }
  }

  static ImportResult _parseCsv(List<int> bytes, String fileName) {
    try {
      final content = utf8.decode(bytes);
      final lines = const LineSplitter().convert(content);
      if (lines.length <= 1) {
        return ImportResult(
          fileName: fileName,
          fileType: 'csv',
          errorMessage: 'File CSV kosong atau hanya memiliki baris judul.',
        );
      }

      final List<HARModel> parsed = [];
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        // Split by comma or semicolon
        final delimiter = line.contains(';') ? ';' : ',';
        final cols = line.split(delimiter).map((c) => c.replaceAll('"', '').trim()).toList();

        if (cols.length >= 4) {
          final harNumber = cols.length > 1 && cols[1].isNotEmpty ? cols[1] : 'HAR-CSV-$i';
          final date = cols.length > 2 && cols[2].isNotEmpty ? cols[2] : DateTime.now().toString().substring(0, 10);
          final timeSlot = cols.length > 3 && cols[3].isNotEmpty ? cols[3] : '08:00';
          final kdUnit = cols.length > 4 && cols[4].isNotEmpty ? cols[4] : '0283';
          final unitName = cols.length > 5 && cols[5].isNotEmpty ? cols[5] : 'ULD MUARA PAHU';
          final idMesin = cols.length > 6 && cols[6].isNotEmpty ? cols[6] : '000581';
          final machineName = cols.length > 7 && cols[7].isNotEmpty ? cols[7] : 'PLTD MUARA PAHU #01';
          final technician = cols.length > 10 && cols[10].isNotEmpty ? cols[10] : 'Teknisi CSV';

          parsed.add(
            HARModel(
              id: 'csv-$i-${DateTime.now().millisecondsSinceEpoch}',
              harNumber: harNumber,
              kdUnit: kdUnit,
              unitName: unitName,
              idMesin: idMesin,
              machineName: machineName,
              date: date,
              timeSlot: timeSlot,
              status: 'submitted',
              priority: 'NORMAL',
              maintenanceType: 'preventive',
              technicianName: technician,
              findingDescription: 'Impor data CSV logsheet',
              actionTaken: 'Inspeksi berkala',
              finalResult: 'Normal Andal',
              checklists: [
                HARChecklistItem(title: 'Pemeriksaan Rutin Sistem', category: 'Umum', condition: 'baik'),
              ],
            ),
          );
        }
      }

      return ImportResult(
        fileName: fileName,
        fileType: 'csv',
        parsedReports: parsed,
      );
    } catch (e) {
      return ImportResult(
        fileName: fileName,
        fileType: 'csv',
        errorMessage: 'Gagal memproses file CSV: $e',
      );
    }
  }

  static ImportResult _parseJson(List<int> bytes, String fileName) {
    try {
      final content = utf8.decode(bytes);
      final decoded = jsonDecode(content);

      if (decoded is List) {
        final reports = decoded.map((item) => HARModel.fromJson(item)).toList();
        return ImportResult(
          fileName: fileName,
          fileType: 'json',
          parsedReports: reports,
        );
      } else if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('reports') && decoded['reports'] is List) {
          final reports = (decoded['reports'] as List).map((item) => HARModel.fromJson(item)).toList();
          return ImportResult(
            fileName: fileName,
            fileType: 'json',
            parsedReports: reports,
          );
        }
        final single = HARModel.fromJson(decoded);
        return ImportResult(
          fileName: fileName,
          fileType: 'json',
          parsedReports: [single],
        );
      }

      return ImportResult(
        fileName: fileName,
        fileType: 'json',
        errorMessage: 'Struktur JSON tidak sesuai format Laporan HAR.',
      );
    } catch (e) {
      return ImportResult(
        fileName: fileName,
        fileType: 'json',
        errorMessage: 'Gagal membaca format JSON: $e',
      );
    }
  }

  // ==================== 8. TEMPLATE DOWNLOADER ====================
  static Future<void> downloadExcelTemplate() async {
    final excel = Excel.createExcel();
    final sheetName = 'Template_HAR';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    void setCell(int col, int row, CellValue value, CellStyle style) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
      cell.value = value;
      cell.cellStyle = style;
    }

    final colWidths = [
      8.0, 20.0, 16.0, 14.0, 14.0, 28.0, 14.0, 36.0, 16.0, 14.0, 24.0, 18.0, 18.0, 40.0, 40.0,
    ];
    for (int c = 0; c < colWidths.length; c++) {
      sheet.setColumnWidth(c, colWidths[c]);
    }

    // Row 0: Company Banner
    sheet.setRowHeight(0, 34.0);
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: 0),
      customValue: TextCellValue('PT PLN (PERSERO) - TEMPLATE IMPORT DATA HAR & LOGSHEET MESIN PLTD'),
    );
    sheet.setMergedCellStyle(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellStyle(
        bold: true,
        fontSize: 12,
        fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
        backgroundColorHex: ExcelColor.fromHexString('FF002244'),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      ),
    );

    // Row 1: Instruction
    sheet.setRowHeight(1, 20.0);
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: 1),
      customValue: TextCellValue('Petunjuk: Jangan ubah susunan kolom. Isi data mulai dari baris ke-4. Format tanggal YYYY-MM-DD dan jam HH:MM.'),
    );
    sheet.setMergedCellStyle(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      CellStyle(
        italic: true,
        fontSize: 9,
        fontColorHex: ExcelColor.fromHexString('FF1E293B'),
        backgroundColorHex: ExcelColor.fromHexString('FFFEF3C7'),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      ),
    );

    // Row 2: Headers
    sheet.setRowHeight(2, 26.0);
    final headers = [
      'NO',
      'NO TIKET HAR',
      'TANGGAL (YYYY-MM-DD)',
      'JAM SLOT (HH:MM)',
      'KODE UNIT',
      'UNIT PLTD',
      'ID MESIN',
      'NAMA MESIN',
      'TIPE HAR',
      'PRIORITAS',
      'TEKNISI',
      'STATUS',
      'HASIL AKHIR',
      'TEMUAN',
      'TINDAKAN',
    ];
    for (int c = 0; c < headers.length; c++) {
      setCell(c, 2, TextCellValue(headers[c]), _excelHeaderStyle());
    }

    // Row 3: Example row
    sheet.setRowHeight(3, 22.0);
    setCell(0, 3, IntCellValue(1), _excelDataStyle(align: HorizontalAlign.Center));
    setCell(1, 3, TextCellValue('HAR-2026-00099'), _excelDataStyle(align: HorizontalAlign.Center, bold: true));
    setCell(2, 3, TextCellValue('2026-08-05'), _excelDataStyle(align: HorizontalAlign.Center));
    setCell(3, 3, TextCellValue('08:00'), _excelDataStyle(align: HorizontalAlign.Center));
    setCell(4, 3, TextCellValue('0283'), _excelDataStyle(align: HorizontalAlign.Center));
    setCell(5, 3, TextCellValue('ULD MUARA PAHU'), _excelDataStyle(align: HorizontalAlign.Left));
    setCell(6, 3, TextCellValue('000581'), _excelDataStyle(align: HorizontalAlign.Center));
    setCell(7, 3, TextCellValue('PLTD MUARA PAHU #01 (CATERPILLAR 3512B)'), _excelDataStyle(align: HorizontalAlign.Left, bold: true));
    setCell(8, 3, TextCellValue('preventive'), _excelDataStyle(align: HorizontalAlign.Center));
    setCell(9, 3, TextCellValue('NORMAL'), _excelDataStyle(align: HorizontalAlign.Center));
    setCell(10, 3, TextCellValue('Ahmad Teknisi'), _excelDataStyle(align: HorizontalAlign.Left));
    setCell(11, 3, TextCellValue('submitted'), _excelDataStyle(align: HorizontalAlign.Center, bold: true, bgColor: ExcelColor.fromHexString('FFFEF3C7'), fontColor: ExcelColor.fromHexString('FF92400E')));
    setCell(12, 3, TextCellValue('Normal Andal'), _excelDataStyle(align: HorizontalAlign.Center));
    setCell(13, 3, TextCellValue('Tekanan oli stabil pada 4.2 Bar.'), _excelDataStyle(align: HorizontalAlign.Left));
    setCell(14, 3, TextCellValue('Pemeriksaan berkala level oli dan filter solar.'), _excelDataStyle(align: HorizontalAlign.Left));

    final fileBytes = excel.save();
    if (fileBytes != null) {
      downloadFile(fileBytes, 'TEMPLATE_IMPORT_HAR_PLTD.xlsx', mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    }
  }
}
