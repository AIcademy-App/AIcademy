import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For compute
import 'package:syncfusion_flutter_pdf/pdf.dart'; // PDF extraction
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screens/navigation.dart';
import 'screens/check_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF00E5BC),
        fontFamily: 'Urbanist',
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // User is logged in → Show app
          if (snapshot.hasData) {
            return const MainNavigationScreen();
          }

          // User is NOT logged in → Show auth screen
          return const CheckScreen();
        },
      ),
    );
  }
}

// --- ADDED PDF SERVICE LOGIC ---
// You can keep this here or move it to lib/services/pdf_service.dart
class PdfService {
  /// Extracts text from PDF using a background isolate to prevent UI lag
  Future<String> extractTextFromPdf(File pdfFile) async {
    try {
      // Runs extraction logic on a separate thread
      return await compute(_extractLogic, pdfFile);
    } catch (e) {
      throw Exception('Error extracting text from PDF: $e');
    }
  }

  // This static method runs in the background isolate
  static Future<String> _extractLogic(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    final PdfTextExtractor extractor = PdfTextExtractor(document);
    
    String extractedText = extractor.extractText();
    document.dispose(); // Free up memory immediately
    
    return extractedText.trim();
  }

  /// Helper for metadata
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