import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/project.dart';
import '../services/file_service.dart';
import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  final Project project;
  const ChatScreen({super.key, required this.project});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FileService _fileService = FileService();
  final AIService _aiService = AIService();
  
  ChatSession? _chatSession;
  final List<Map<String, String>> _messages = []; // {'role': 'user'|'ai', 'text': '...'}
  bool _isLoadingContext = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 1. Fetch all files
      final files = await _fileService
          .getProjectFilesStream(uid: user.uid, projectId: widget.project.id)
          .first;

      if (files.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoadingContext = false;
            _messages.add({
              'role': 'ai',
              'text': 'No files found in this project. Please upload a PDF to start chatting.'
            });
          });
        }
        return;
      }

      // 2. Combine content
      String combinedContent = files.map((f) => f.content).join('\n\n');
      // Truncate if too long (basic safety, though 1.5 Flash has large context)
      if (combinedContent.length > 100000) {
        combinedContent = combinedContent.substring(0, 100000);
      }

      // 3. Start Session
      _chatSession = _aiService.startChat(context: combinedContent);

      if (mounted) {
        setState(() {
          _isLoadingContext = false;
          _messages.add({
            'role': 'ai',
            'text': 'Hello! I have read your files. Ask me anything about "${widget.project.name}".'
          });
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingContext = false;
          _messages.add({'role': 'ai', 'text': 'Error loading context: $e'});
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _chatSession == null) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isSending = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final response = await _chatSession!.sendMessage(Content.text(text));
      final aiText = response.text ?? "I couldn't generate a response.";

      if (mounted) {
        setState(() {
          _messages.add({'role': 'ai', 'text': aiText});
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({'role': 'ai', 'text': 'Error: $e'});
        });
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text('Chat with PDF', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingContext
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5BC)))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                          decoration: BoxDecoration(
                            color: isUser ? null : const Color(0xFF1E1E1E),
                            gradient: isUser
                                ? const LinearGradient(colors: [Color(0xFF23C174), Color(0xFF00C9E0)])
                                : null,
                            borderRadius: BorderRadius.circular(16).copyWith(
                              bottomRight: isUser ? const Radius.circular(0) : null,
                              bottomLeft: !isUser ? const Radius.circular(0) : null,
                            ),
                          ),
                          child: Text(
                            msg['text']!,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_isSending) const LinearProgressIndicator(color: Color(0xFF00E5BC), backgroundColor: Colors.transparent),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ask a question...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _isSending ? null : _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Color(0xFF23C174), Color(0xFF00C9E0)]),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}