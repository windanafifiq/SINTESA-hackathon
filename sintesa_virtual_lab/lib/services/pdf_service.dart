import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/lab_report_model.dart';

class PdfService {
  static Future<void> generateAndDownloadPdf(LabReportModel report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.only(bottom: 20),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(width: 2, color: PdfColors.blue900)),
                ),
                child: pw.Column(
                  children: [
                    pw.Text('LAPORAN PRAKTIKUM DIGITAL',
                        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.SizedBox(height: 5),
                    pw.Text('SINTESA Virtual Lab - Kimia',
                        style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Content Section
              _buildSectionTitle('Hasil Pengamatan:'),
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Text(report.generatedReport ?? 'Tidak ada data laporan.',
                    style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5)),
              ),
              
              pw.SizedBox(height: 40),
              
              // Footer
              pw.Divider(color: PdfColors.grey300),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Dicetak pada: ${DateTime.now().toString()}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Trigger download in browser
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_Praktikum_SINTESA.pdf',
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
      ),
    );
  }
}
