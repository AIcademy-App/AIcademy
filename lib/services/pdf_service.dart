import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  /// Extract text from a PDF file
  /// Returns the extracted text content
  Future<String> extractTextFromPdf(File pdfFile) async {
    try {
      // Read the PDF file
      final bytes = await pdfFile.readAsBytes();

      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // Extract text from all pages
      String extractedText = '';
      for (int i = 0; i < document.pages.count; i++) {
        // Get text from each page
        final PdfPageLayer pageLayer = document.pages[i];
        final String pageText = _extractPageText(pageLayer);
        extractedText += pageText + '\n\n';
      }

      document.dispose();

      return extractedText.trim();
    } catch (e) {
      throw Exception('Error extracting text from PDF: $e');
    }
  }

  /// Helper method to extract text from a single page
  String _extractPageText(PdfPageLayer page) {
    try {
      final PdfTextExtractor extractor = PdfTextExtractor(page);
      final String text = extractor.extractText();
      return text;
    } catch (e) {
      // If extraction fails, return empty string for that page
      return '';
    }
  }

  /// Get PDF file metadata (page count, size)
  Future<Map<String, dynamic>> getPdfMetadata(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      final metadata = {
        'pageCount': document.pages.count,
        'fileSize': pdfFile.lengthSync(),
        'fileName': pdfFile.path.split('/').last,
      };

      document.dispose();

      return metadata;
    } catch (e) {
      throw Exception('Error getting PDF metadata: $e');
    }
  }
}
