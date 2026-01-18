import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  late final GenerativeModel _model;

  AIService() {
    _initializeModel();
  }

  void _initializeModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is missing from .env');
    }
    
    // Using the stable model identifier
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview' ,
      apiKey: apiKey,
    );
  }

  Future<String> answerQuestion({required String question}) async {
    try {
      final content = [Content.text(question)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response generated.';
    } catch (e) {
      // Log the ACTUAL error to the console so you can see if it's 403 (Auth) or 429 (Quota)
      print("CRITICAL Gemini Error: $e");
      throw Exception('AI Connection Failed. Check console for details.');
    }
  }
}