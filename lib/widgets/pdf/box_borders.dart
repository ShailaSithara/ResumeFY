import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class PdfBoxBorders {
  PdfBoxBorders._();

  /// Primary brand border (violet theme)
  static final pw.Border primary = pw.Border.all(
    color: const PdfColor.fromInt(0xFF7C3AED),
    width: 1,
  );

  /// Secondary pink border
  static final pw.Border secondary = pw.Border.all(
    color: const PdfColor.fromInt(0xFFEC4899),
    width: 1,
  );

  /// Accent cyan border
  static final pw.Border accent = pw.Border.all(
    color: const PdfColor.fromInt(0xFF06B6D4),
    width: 1,
  );

  /// Soft glass-style border (modern UI look)
  static final pw.Border glass = pw.Border.all(
    color: const PdfColor.fromInt(0x33FFFFFF),
    width: 1,
  );

  /// Light grey minimal border
  static final pw.Border light = pw.Border.all(
    color: PdfColors.grey300,
    width: 1,
  );

  /// Dark subtle border (for dark resume themes)
  static final pw.Border dark = pw.Border.all(
    color: PdfColors.grey800,
    width: 1,
  );

  /// Thick highlight border (section emphasis)
  static final pw.Border highlight = pw.Border.all(
    color: const PdfColor.fromInt(0xFF7C3AED),
    width: 2,
  );

  /// No border (utility)
  static final pw.Border none = pw.Border.all(
    color: PdfColors.white,
    width: 0,
  );
}
