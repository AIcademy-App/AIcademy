import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  /// Extracts text in the background to prevent UI freezing
  Future<String> extractTextFromPdf(File pdfFile) async {
    try {
      // 'compute' runs the function in a separate isolate
      return await compute(_extractLogic, pdfFile);
    } catch (e) {
      throw Exception('Error extracting text: $e');
    }
  }

  // Internal logic used by compute
  static Future<String> _extractLogic(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    final PdfTextExtractor extractor = PdfTextExtractor(document);
    
    String text = extractor.extractText();
    document.dispose();
    return text.trim();
  }

  /// Metadata helper
  Future<Map<String, dynamic>> getPdfMetadata(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    final metadata = {
      'pageCount': document.pages.count,
      'fileSize': await pdfFile.length(),
      'fileName': pdfFile.path.split('/').last, 
    };

    document.dispose();
    return metadata;
  }
}