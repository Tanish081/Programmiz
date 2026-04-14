import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:programming_learn_app/core/services/certificate_pdf_service.dart';
import 'package:programming_learn_app/core/utils/hive_boxes.dart';
import 'package:programming_learn_app/data/models/certificate_model.dart';
import 'package:programming_learn_app/ui/components/app_card.dart';
import 'package:programming_learn_app/ui/components/duo_button.dart';
import 'package:programming_learn_app/ui/components/section_header.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  final CertificatePdfService _pdfService = CertificatePdfService();

  List<CertificateModel> _certificates() {
    try {
      final box = Hive.box<CertificateModel>(HiveBoxes.certificate);
      final list = box.values.toList();
      list.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
      return list;
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final earned = _certificates();

    const locked = <Map<String, String>>[
      {
        'title': 'Python Fundamentals — Beginner',
        'condition': 'Complete all 5 absolute beginner lessons with avg score ≥ 70%',
      },
      {
        'title': 'Python Developer — Intermediate',
        'condition': 'Complete all 10 lessons with avg score ≥ 70%',
      },
      {
        'title': 'Python Expert',
        'condition': 'Complete 15 lessons + 5 challenges with avg score ≥ 80%',
      },
      {
        'title': 'Full Stack Explorer',
        'condition': 'Complete Full Stack domain roadmap',
      },
      {
        'title': 'Data Analyst Foundations',
        'condition': 'Complete Data Analyst domain roadmap',
      },
      {
        'title': 'Interview Ready — Python',
        'condition': 'Complete 3 interview sessions with avg score ≥ 70%',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('My Certificates')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          const SectionHeader(
            title: 'Certificates',
            subtitle: 'Earn these by finishing lessons, roadmaps, and interview practice.',
          ),
          const SizedBox(height: 6),
          Text('${earned.length}/${locked.length} earned', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
          const SizedBox(height: 14),
          if (earned.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(16),
              child: const Text('Complete courses to earn certificates'),
            )
          else
            ...earned.map((cert) => _certificateCard(cert)),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Earn these next', subtitle: 'Locked by progress milestones and completion goals.', compact: true),
          const SizedBox(height: 10),
          ...locked.where((entry) => !earned.any((cert) => cert.title == entry['title'])).map(
                (entry) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Text('🏆', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 3),
                            Text(entry['condition'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _certificateCard(CertificateModel cert) {
    return AppCard(
      padding: EdgeInsets.zero,
      radius: 24,
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF58CC02), Color(0xFF46A302)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🏆', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 4),
                  Text(
                    'CERTIFICATE OF COMPLETION',
                    style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('This certifies that', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(cert.recipientName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('has successfully completed', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(cert.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF58CC02))),
                const SizedBox(height: 10),
                Divider(color: Colors.grey.shade200),
                Row(
                  children: [
                    Text('📅 ${DateFormat('dd MMM yyyy').format(cert.issuedAt)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    const Spacer(),
                    Text('✅ ${cert.level}', style: const TextStyle(fontSize: 11, color: Color(0xFF58CC02))),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: cert.skills
                      .map((skill) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(999)),
                            child: Text(skill, style: const TextStyle(fontSize: 11)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Text('🔐 Verify: ${cert.verificationCode}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontFamily: 'monospace')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DuoButton(
                        label: 'View PDF 📄',
                        isPrimary: false,
                        onPressed: () async {
                          final pdf = await _pdfService.generatePdf(cert);
                          await Printing.layoutPdf(onLayout: (_) async => pdf);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DuoButton(
                        label: 'Share 🔗',
                        onPressed: () async {
                          final pdf = await _pdfService.generatePdf(cert);
                          await _pdfService.sharePdf(pdf, cert.title, title: cert.title);
                        },
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
}
