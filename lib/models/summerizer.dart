import 'package:aicademy/services/ai_service.dart'; // Ensure you import your AI service

class Summarizer {
  String inputText;
  String? summary;
  final AIService _aiService = AIService();

  Summarizer({required this.inputText});

  /// Real AI Summary generation
  Future<void> generateSummary() async {
    // Specifically asking Gemini for 2 paragraphs as requested
    String prompt = "Please summarize the following text into exactly two clear paragraphs: $inputText";
    
    try {
      // Calling the Gemini model via the service you built
      summary = await _aiService.answerQuestion(question: prompt);
      print("Summary generated: $summary");
    } catch (e) {
      summary = "Error generating summary: $e";
    }
  }

  Future<void> summarizePDF(String pdfContent) async {
    inputText = pdfContent;
    await generateSummary();
  }
}