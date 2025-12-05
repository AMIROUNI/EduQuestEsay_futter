import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class GeminiChatProvider extends ChangeNotifier {
  final String apiKey;
  late final GenerativeModel _model;
  late final ChatSession _chat;
  
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  GeminiChatProvider({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: apiKey,
    );
    _chat = _model.startChat();
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(text: text, isUser: true));
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      final responseText = response.text ?? 'No response';

      _messages.add(ChatMessage(text: responseText, isUser: false));
    } catch (e) {
      _messages.add(ChatMessage(
        text: 'Error: ${e.toString()}',
        isUser: false,
        isError: true,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _chat = _model.startChat();
    notifyListeners();
  }

  @override
  void dispose() {
    _messages.clear();
    super.dispose();
  }
}