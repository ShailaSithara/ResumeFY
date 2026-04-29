import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/profile_provider.dart';
import '../../data/models/user_model.dart';
import '../../data/models/experience_model.dart';
import '../../data/models/education_model.dart';
import '../../widgets/common/gradient_button.dart';

class ResumePreviewScreen extends ConsumerStatefulWidget {
  const ResumePreviewScreen({super.key});

  @override
  ConsumerState<ResumePreviewScreen> createState() =>
      _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends ConsumerState<ResumePreviewScreen> {
  bool _isDownloading = false;
  bool _isSharing = false;
  String _template = 'modern';

  // ───────────────── COLORS ─────────────────
  static const _primary = PdfColor.fromInt(0xFF7C3AED);
  static const _secondary = PdfColor.fromInt(0xFFEC4899);
  static const _muted = PdfColors.grey600;

  // ───────────────── PDF BUILDER ─────────────────
  Future<pw.Document> _buildPdf(UserProfile profile) async {
    final doc = pw.Document();

    final page = switch (_template) {
      'minimal' => _minimal(profile),
      'classic' => _classic(profile),
      _ => _modern(profile),
    };

    doc.addPage(page);
    return doc;
  }

  // ───────────────── MODERN ─────────────────
  pw.Page _modern(UserProfile p) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _header(p),
          pw.SizedBox(height: 20),
          if (p.goals.bio.isNotEmpty) _section("About", p.goals.bio),
          if (p.skills.isNotEmpty) ...[
            _title("Skills"),
            pw.Wrap(
              spacing: 6,
              children: p.skills.map((s) => _chip(s)).toList(),
            ),
          ],
          if (p.experience.isNotEmpty) ...[
            _title("Experience"),
            ...p.experience.map(_expItem),
          ],
          if (p.education.isNotEmpty) ...[
            _title("Education"),
            ...p.education.map(_eduItem),
          ],
          if (p.goals.careerGoal.isNotEmpty)
            _section("Career Goal", p.goals.careerGoal),
        ],
      ),
    );
  }

  // ───────────────── HEADER ─────────────────
  pw.Widget _header(UserProfile p) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(colors: [_primary, _secondary]),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            p.personal.name,
            style: pw.TextStyle(
              fontSize: 26,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(p.personal.headline,
              style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
          pw.SizedBox(height: 8),
          pw.Text(
            "${p.personal.email} • ${p.personal.phone}",
            style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ───────────────── SECTION HELPERS ─────────────────
  pw.Widget _title(String t) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 12, bottom: 6),
        child: pw.Text(
          t,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
      );

  pw.Widget _section(String title, String content) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _title(title),
          pw.Text(content, style: const pw.TextStyle(fontSize: 11)),
        ],
      );

  pw.Widget _chip(String text) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(20),
          color: const PdfColor.fromInt(0x1A7C3AED),
        ),
        child: pw.Text(text,
            style: const pw.TextStyle(fontSize: 9, color: _primary)),
      );

  // ───────────────── EXPERIENCE ─────────────────
  pw.Widget _expItem(ExperienceModel e) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "${e.role} - ${e.company}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              "${e.startDate} - ${e.isCurrent ? "Present" : e.endDate ?? ""}",
              style: const pw.TextStyle(fontSize: 10, color: _muted),
            ),
            if (e.description.isNotEmpty)
              pw.Text(e.description, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      );

  // ───────────────── EDUCATION ─────────────────
  pw.Widget _eduItem(EducationModel e) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "${e.degree} in ${e.field}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              "${e.institution} • ${e.startYear}-${e.endYear}",
              style: const pw.TextStyle(fontSize: 10, color: _muted),
            ),
          ],
        ),
      );

  // ───────────────── MINIMAL ─────────────────
  pw.Page _minimal(UserProfile p) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(p.personal.name,
              style:
                  pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
          pw.Text(p.personal.headline),
          pw.SizedBox(height: 10),
          _section("Summary", p.goals.bio),
        ],
      ),
    );
  }

  // ───────────────── CLASSIC ─────────────────
  pw.Page _classic(UserProfile p) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(p.personal.name,
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text(p.personal.headline),
              ],
            ),
          ),
          pw.Divider(color: _primary),
          if (p.experience.isNotEmpty) ...[
            _title("Experience"),
            ...p.experience.map(_expItem),
          ],
          if (p.education.isNotEmpty) ...[
            _title("Education"),
            ...p.education.map(_eduItem),
          ],
        ],
      ),
    );
  }

  // ───────────────── SNACKBAR HELPER ─────────────────
  void _showSnack(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ───────────────── GET SAVE FILE ─────────────────
  /// Returns a unique file path for the PDF on any platform.
  Future<File> _getPdfFile() async {
    final String fileName =
        'resume_${DateTime.now().millisecondsSinceEpoch}.pdf';

    if (Platform.isAndroid) {
      // Try the public Downloads folder first (visible in Files app)
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (await downloadsDir.exists()) {
        return File('${downloadsDir.path}/$fileName');
      }
      // Fallback to app external files dir (no permission needed on Android 10+)
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        return File('${extDir.path}/$fileName');
      }
    }

    // iOS + fallback: temp directory, then share
    final tmpDir = await getTemporaryDirectory();
    return File('${tmpDir.path}/$fileName');
  }

  // ───────────────── DOWNLOAD ─────────────────
  Future<void> _download(UserProfile profile) async {
    setState(() => _isDownloading = true);

    try {
      // 1. Permission (safe for Android < 13)
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted && !status.isLimited) {
          _showSnack("Storage permission denied", isError: true);
          return;
        }
      }

      // 2. Build PDF
      final doc = await _buildPdf(profile);
      final bytes = await doc.save();

      // 3. Safe directory (NO hardcoded Download path)
      Directory dir;

      if (Platform.isAndroid) {
        // Public downloads folder via external dir fallback
        dir = (await getExternalStorageDirectory())!;
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final fileName =
          "Resume_${profile.personal.name.replaceAll(' ', '_')}.pdf";

      final file = File("${dir.path}/$fileName");

      // 4. Write file
      await file.writeAsBytes(bytes, flush: true);

      // 5. Show success + open file
      _showSnack("PDF saved successfully!", isError: false);

      await OpenFilex.open(file.path);
    } catch (e) {
      _showSnack("Download failed: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  // ───────────────── SHARE ─────────────────
  Future<void> _share(UserProfile profile) async {
    setState(() => _isSharing = true);

    try {
      final doc = await _buildPdf(profile);
      final bytes = await doc.save();

      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/resume.pdf");

      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: "My Resume - ${profile.personal.name}",
      );
    } catch (e) {
      _showSnack("Share failed: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  // ───────────────── UI ─────────────────
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileStreamProvider);

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) {
          if (profile == null) return const Text("No profile");

          return Column(
            children: [
              Expanded(
                child: PdfPreview(
                  build: (_) async {
                    final doc = await _buildPdf(profile);
                    return doc.save();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: _isSharing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.share),
                      onPressed: _isSharing ? null : () => _share(profile),
                    ),
                    Expanded(
                      child: GradientButton(
                        label: "Download",
                        onPressed:
                            _isDownloading ? null : () => _download(profile),
                        isLoading: _isDownloading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
