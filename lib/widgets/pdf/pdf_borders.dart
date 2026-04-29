import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class PdfBorders {
  PdfBorders._();

  /// Primary brand border
  static pw.Border primary = pw.Border.all(
    color: const PdfColor.fromInt(0xFF7C3AED),
    width: 1,
  );

  /// Soft transparent border (glass style)
  static pw.Border glass = pw.Border.all(
    color: const PdfColor.fromInt(0x33FFFFFF),
    width: 1,
  );

  /// Light grey border (minimal design)
  static pw.Border light = pw.Border.all(
    color: PdfColors.grey300,
    width: 1,
  );

  /// Thick accent border (for section highlights)
  static pw.Border accent = pw.Border.all(
    color: const PdfColor.fromInt(0xFFEC4899),
    width: 2,
  );

  /// No border helper
  static pw.Border none = pw.Border.all(
    width: 0,
    color: PdfColors.white,
  );
}
