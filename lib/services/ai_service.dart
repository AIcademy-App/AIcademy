import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert'; // For JSON decoding

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

  /// Generates a quiz in JSON format based on the provided text content
  Future<List<Map<String, dynamic>>> generateQuiz({required String content}) async {
    try {
      final prompt = '''
You are a teacher. Create a quiz with 5 multiple-choice questions based on the following text.
Return the result as a raw JSON list of objects. Do not include markdown formatting (like ```json).

JSON Structure:
[
  {
    "questionText": "The question string",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctAnswerIndex": 0 // Integer index of the correct option (0-3)
  }
]

Text to base quiz on:
$content
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText == null) throw Exception('No response from AI');

      // Clean up potential markdown code blocks if the AI adds them despite instructions
      final cleanJson = responseText.replaceAll('```json', '').replaceAll('```', '').trim();

      final List<dynamic> decoded = jsonDecode(cleanJson);
      return List<Map<String, dynamic>>.from(decoded);
    } catch (e) {
      print("Quiz Generation Error: $e");
      throw Exception('Failed to generate quiz. Try again.');
    }
  }

  /// Starts a chat session with the provided context
  ChatSession startChat({required String context}) {
    return _model.startChat(
      history: [
        Content.text('''You are a helpful AI assistant for a student. 
Answer questions based strictly on the provided context below. 
If the answer cannot be found in the context, politely state that you don't know based on the available information.

CONTEXT:
$context'''),
        Content.model([TextPart('Understood. I am ready to answer questions based on the provided context.')]),
      ],
    );
  }
}