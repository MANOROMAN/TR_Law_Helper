import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/config_service.dart';
import '../constants/app_colors.dart';

class AIChatScreen extends StatefulWidget {
  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late final GeminiService _geminiService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    final apiKey = await ConfigService.getApiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      _geminiService = GeminiService(apiKey: apiKey);
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                "Merhaba! Ben Türk hukuk sistemi konusunda uzmanlaşmış yapay zeka danışmanınızım. Size nasıl yardımcı olabilirim?",
            isUser: false,
          ),
        );
      });
    } else {
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                "API anahtarı bulunamadı. Lütfen ayarlardan API anahtarınızı girin.",
            isUser: false,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI'ye Sor"),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.primaryYellow),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(width: 60),
                  CircularProgressIndicator(),
                  SizedBox(width: 10),
                  Text("AI düşünüyor..."),
                ],
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.smart_toy, color: AppColors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.primaryBlue
                    : AppColors.surfaceBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? AppColors.white : AppColors.darkGrey,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primaryYellow,
              child: const Icon(Icons.person, color: AppColors.primaryBlue),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Hukuki sorunuzu yazın...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surfaceBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            backgroundColor: AppColors.primaryYellow,
            mini: true,
            child: const Icon(Icons.send, color: AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isLoading) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    try {
      final response = await _geminiService.sendMessage(userMessage);

      // İstatistikleri güncelle
      await ConfigService.incrementChatCount();
      await ConfigService.updateLastChatDate();

      // Eğer mesaj engellendiyse istatistiği güncelle
      if (response.contains('Bu tür sorulara cevap veremiyorum')) {
        await ConfigService.incrementBlockedMessages();
      }

      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Üzgünüm, şu anda bir hata oluştu. Lütfen tekrar deneyin.",
            isUser: false,
          ),
        );
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
