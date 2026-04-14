import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:programming_learn_app/data/models/certificate_model.dart';
import 'package:share_plus/share_plus.dart';

class CertificatePdfService {
  Future<Uint8List> generatePdf(CertificateModel cert) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#58CC02'), width: 3),
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Text(
                    'CodeQuest Academy',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#58CC02')),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 2, color: PdfColor.fromHex('#58CC02')),
                  pw.Spacer(),
                  pw.Text(
                    'CERTIFICATE OF COMPLETION',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, letterSpacing: 4, color: PdfColor.fromHex('#666666')),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text('This is to certify that', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 12)),
                  pw.SizedBox(height: 8),
                  pw.Text(cert.recipientName, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text('has successfully completed the course', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 12)),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    cert.title,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#58CC02')),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Level: ${cert.level} · Score: ${cert.score}%',
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text('Skills Demonstrated:', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text(cert.skills.join(' · '), textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 13)),
                  pw.Spacer(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Date Issued', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(DateFormat('dd MMM yyyy').format(cert.issuedAt), style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Container(width: 140, height: 1, color: PdfColors.grey),
                          pw.SizedBox(height: 4),
                          pw.Text('CodeQuest Academy', style: const pw.TextStyle(fontSize: 11)),
                          pw.Text('Authorised Instructor', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Verification Code', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(cert.verificationCode, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                          pw.Text('codequest.app/verify', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  Future<File> savePdfToDevice(Uint8List pdfBytes, String filename) async {
    final sanitized = filename.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');

    Directory? baseDir = await getDownloadsDirectory();
    baseDir ??= await getApplicationDocumentsDirectory();

    final file = File('${baseDir.path}/CodeQuest_${sanitized}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
    await file.writeAsBytes(pdfBytes, flush: true);
    return file;
  }

  Future<void> sharePdf(Uint8List pdfBytes, String filename, {String? title}) async {
    final file = await savePdfToDevice(pdfBytes, filename);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: 'My CodeQuest Certificate — ${title ?? filename}',
      text: 'Sharing my CodeQuest certificate.',
    );
  }
}
