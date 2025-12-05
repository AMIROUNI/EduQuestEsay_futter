import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final GenerativeModel model;

  GeminiService(String apiKey)
      : model = GenerativeModel(
          model: "gemini-2.5-flash",
          apiKey: apiKey,
        );

  Future<String> sendMessage(String message) async {
    final response = await model.generateContent([
      Content.text(message),
    ]);

    return response.text ?? "No response";
  }
}
