import 'dart:convert';
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

  // ==================== 2. EXPORT SINGLE HAR DETAIL TO PDF ====================
  static Future<void> exportSingleHARToPdf(HARModel report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
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
                        'LEMBAR BERITA ACARA PEMELIHARAAN (HAR) MESIN PLTD',
                        style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: report.status == 'approved' ? PdfColors.green50 : PdfColors.orange50,
                      border: pw.Border.all(
                        color: report.status == 'approved' ? PdfColors.green : PdfColors.orange,
                        width: 1,
                      ),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      report.status.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: report.status == 'approved' ? PdfColors.green800 : PdfColors.orange800,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1.5, color: PdfColors.blue900),
              pw.SizedBox(height: 10),

              // Identitas Laporan
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  children: [
                    _buildPdfDetailRow('Nomor Berita Acara', report.harNumber),
                    _buildPdfDetailRow('Unit Layanan PLTD', report.unitName),
                    _buildPdfDetailRow('Mesin Pembangkit', report.machineName),
                    _buildPdfDetailRow('Tanggal & Jam Slot', '${report.date} (Pukul ${report.timeSlot})'),
                    _buildPdfDetailRow('Teknisi Pelaksana', report.technicianName),
                    _buildPdfDetailRow('Tipe / Prioritas', '${report.maintenanceType.toUpperCase()} / Prioritas ${report.priority}'),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              // Parameter Operasi WACB
              pw.Text('Parameter Operasional Pembangkit (WACB):', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
                cellStyle: const pw.TextStyle(fontSize: 8),
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

              pw.SizedBox(height: 12),

              // Checklist Items Table
              pw.Text('Daftar Periksa Fisik & Komponen Mesin (Checklist):', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                cellStyle: const pw.TextStyle(fontSize: 8),
                headers: ['Kategori', 'Item Pemeriksaan', 'Kondisi Fisik', 'Catatan Teknisi'],
                data: report.checklists.map((c) {
                  return [
                    c.category,
                    c.title,
                    c.condition.toUpperCase(),
                    c.notes.isNotEmpty ? c.notes : '-',
                  ];
                }).toList(),
              ),

              pw.SizedBox(height: 12),

              // Temuan & Tindakan
              pw.Text('Temuan & Rekomendasi Tindakan:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Temuan: ${report.findingDescription}', style: const pw.TextStyle(fontSize: 8.5)),
                    pw.SizedBox(height: 3),
                    pw.Text('Tindakan Dilakukan: ${report.actionTaken}', style: const pw.TextStyle(fontSize: 8.5)),
                    pw.SizedBox(height: 3),
                    pw.Text('Hasil Akhir: ${report.finalResult}', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                  ],
                ),
              ),

              pw.Spacer(),

              // Tanda Tangan
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Pelaksana Pemeliharaan,', style: const pw.TextStyle(fontSize: 8.5)),
                      pw.SizedBox(height: 34),
                      pw.Text(report.technicianName, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Teknisi PLTD', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Supervisor Keandalan (SPV),', style: const pw.TextStyle(fontSize: 8.5)),
                      pw.SizedBox(height: 34),
                      pw.Text('Super Admin K3', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Status: ${report.status.toUpperCase()}', style: pw.TextStyle(fontSize: 7.5, color: PdfColors.green800)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final fileName = 'BERITA_ACARA_${report.harNumber}.pdf';
    downloadFile(bytes, fileName, mimeType: 'application/pdf');
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

    // Header Row
    sheet.appendRow([
      TextCellValue('NO'),
      TextCellValue('NO TIKET HAR'),
      TextCellValue('TANGGAL'),
      TextCellValue('JAM SLOT'),
      TextCellValue('KODE UNIT'),
      TextCellValue('UNIT PLTD'),
      TextCellValue('ID MESIN'),
      TextCellValue('NAMA MESIN'),
      TextCellValue('TIPE HAR'),
      TextCellValue('PRIORITAS'),
      TextCellValue('TEKNISI'),
      TextCellValue('STATUS'),
      TextCellValue('HASIL AKHIR'),
      TextCellValue('DAYA MAMPU (kW)'),
      TextCellValue('BEBAN (kW)'),
      TextCellValue('STAND KWH'),
      TextCellValue('STAND BBM'),
      TextCellValue('TEKANAN OLI'),
      TextCellValue('TEMUAN'),
      TextCellValue('TINDAKAN PERBAIKAN'),
    ]);

    // Data Rows
    for (int i = 0; i < reports.length; i++) {
      final r = reports[i];
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(r.harNumber),
        TextCellValue(r.date),
        TextCellValue(r.timeSlot),
        TextCellValue(r.kdUnit),
        TextCellValue(r.unitName),
        TextCellValue(r.idMesin),
        TextCellValue(r.machineName),
        TextCellValue(r.maintenanceType),
        TextCellValue(r.priority),
        TextCellValue(r.technicianName),
        TextCellValue(r.status.toUpperCase()),
        TextCellValue(r.finalResult),
        DoubleCellValue(r.dayaMampu),
        DoubleCellValue(r.beban),
        DoubleCellValue(r.standKwh),
        DoubleCellValue(r.standBbm),
        DoubleCellValue(r.tekananOli),
        TextCellValue(r.findingDescription),
        TextCellValue(r.actionTaken),
      ]);
    }

    // Sheet 2: Summary KPI
    final summarySheet = excel['Ringkasan_KPI'];
    summarySheet.appendRow([TextCellValue('INDIKATOR'), TextCellValue('NILAI')]);
    summarySheet.appendRow([TextCellValue('Total Laporan'), IntCellValue(reports.length)]);
    summarySheet.appendRow([TextCellValue('Approved (Disetujui SPV)'), IntCellValue(reports.where((r) => r.status == 'approved').length)]);
    summarySheet.appendRow([TextCellValue('Menunggu Approval SPV'), IntCellValue(reports.where((r) => r.status == 'submitted').length)]);
    summarySheet.appendRow([TextCellValue('Draft Belum Disubmit'), IntCellValue(reports.where((r) => r.status == 'draft').length)]);
    summarySheet.appendRow([TextCellValue('Tanggal Ekspor'), TextCellValue(DateTime.now().toString())]);

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final unitClean = (unitName ?? 'PLTD').replaceAll(' ', '_');
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
    final sheet = excel['Daftar_Mesin'];
    excel.delete('Sheet1');

    sheet.appendRow([
      TextCellValue('NO'),
      TextCellValue('ID MESIN'),
      TextCellValue('NAMA MESIN GENERATOR'),
      TextCellValue('KODE SILM'),
      TextCellValue('SERIAL NUMBER'),
      TextCellValue('DAYA TERPASANG (kW)'),
      TextCellValue('TIPE MESIN'),
      TextCellValue('STATUS OPERASI'),
      TextCellValue('KODE UNIT'),
    ]);

    for (int i = 0; i < machines.length; i++) {
      final m = machines[i];
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(m.idMesin),
        TextCellValue(m.namaMesin),
        TextCellValue(m.kodeMesinSilm),
        TextCellValue(m.sn),
        DoubleCellValue(m.dt),
        TextCellValue(m.tipeMesin),
        TextCellValue(m.status),
        TextCellValue(m.kdUnit),
      ]);
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
    final sheet = excel['Template_HAR'];
    excel.delete('Sheet1');

    sheet.appendRow([
      TextCellValue('NO'),
      TextCellValue('NO TIKET HAR'),
      TextCellValue('TANGGAL (YYYY-MM-DD)'),
      TextCellValue('JAM SLOT (HH:MM)'),
      TextCellValue('KODE UNIT'),
      TextCellValue('UNIT PLTD'),
      TextCellValue('ID MESIN'),
      TextCellValue('NAMA MESIN'),
      TextCellValue('TIPE HAR'),
      TextCellValue('PRIORITAS'),
      TextCellValue('TEKNISI'),
      TextCellValue('STATUS'),
      TextCellValue('HASIL AKHIR'),
      TextCellValue('TEMUAN'),
      TextCellValue('TINDAKAN'),
    ]);

    // Example dummy row
    sheet.appendRow([
      IntCellValue(1),
      TextCellValue('HAR-2026-00099'),
      TextCellValue('2026-08-05'),
      TextCellValue('08:00'),
      TextCellValue('0283'),
      TextCellValue('ULD MUARA PAHU'),
      TextCellValue('000581'),
      TextCellValue('PLTD MUARA PAHU #01 (CATERPILLAR 3512B)'),
      TextCellValue('preventive'),
      TextCellValue('NORMAL'),
      TextCellValue('Ahmad Teknisi'),
      TextCellValue('submitted'),
      TextCellValue('Normal Andal'),
      TextCellValue('Tekanan oli stabil pada 4.2 Bar.'),
      TextCellValue('Pemeriksaan berkala level oli dan filter solar.'),
    ]);

    final fileBytes = excel.save();
    if (fileBytes != null) {
      downloadFile(fileBytes, 'TEMPLATE_IMPORT_HAR_PLTD.xlsx', mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    }
  }
}
