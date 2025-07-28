import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/gemini_service.dart';

class ChatBottomSheet extends StatefulWidget {
  final GeminiService geminiService;

  const ChatBottomSheet({super.key, required this.geminiService});

  @override
  State<ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends State<ChatBottomSheet> {
  final TextEditingController _chatController = TextEditingController();
  List<Map<String, String>> _chatMessages = [];
  bool _isSending = false;
  
  // Khóa lưu trữ cho SharedPreferences
  static const String _storageKey = 'gemini_chat_history';

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  // Lưu lịch sử chat vào bộ nhớ cục bộ
  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatHistoryJson = jsonEncode(_chatMessages);
      await prefs.setString(_storageKey, chatHistoryJson);
    } catch (e) {
      print('Lỗi khi lưu lịch sử chat: $e');
    }
  }

  // Tải lịch sử chat từ bộ nhớ cục bộ khi widget được khởi tạo
  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatHistoryJson = prefs.getString(_storageKey);
      
      if (chatHistoryJson != null) {
        final List<dynamic> decodedList = jsonDecode(chatHistoryJson);
        setState(() {
          _chatMessages = decodedList
              .map((item) => {
                'role': item['role'] as String,
                'text': item['text'] as String,
              })
              .toList();
        });
      }
    } catch (e) {
      print('Lỗi khi tải lịch sử chat: $e');
    }
  }

  // Xóa lịch sử chat
  Future<void> _clearChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      setState(() {
        _chatMessages = [];
      });
    } catch (e) {
      print('Lỗi khi xóa lịch sử chat: $e');
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _chatMessages.add({'role': 'user', 'text': text});
      _chatMessages.add({'role': 'bot', 'text': 'Responding...'});
      _chatController.clear();
      _isSending = true;
    });

    try {
      final reply = await widget.geminiService.sendMessage(text);
      setState(() {
        _chatMessages.removeLast(); 
        _chatMessages.add({'role': 'bot', 'text': reply});
      });
      // Lưu lịch sử trò chuyện sau khi nhận được phản hồi
      await _saveChatHistory();
    } catch (e) {
      setState(() {
        _chatMessages.removeLast();
        _chatMessages.add({'role': 'bot', 'text': '❌ Error responding.'});
      });
      // Vẫn lưu trữ kể cả khi có lỗi
      await _saveChatHistory();
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        top: 12,
        left: 16,
        right: 16,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF4F2FA),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Chat Bot',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete conversation'),
                        content: Text('Are you sure you want to delete the entire chat history?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              _clearChatHistory();
                              Navigator.of(context).pop();
                            },
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Nội dung chat
            Expanded(
              child: _chatMessages.isEmpty
                  ? Center(
                      child: Text(
                        "Let's start a conversation",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _chatMessages.length,
                      itemBuilder: (context, index) {
                        final msg = _chatMessages[index];
                        final isUser = msg['role'] == 'user';
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: isUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isUser)
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.grey[400],
                                  child: Icon(Icons.android, size: 16, color: Colors.white),
                                ),
                              if (!isUser) SizedBox(width: 6),
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isUser ? Colors.red[100] : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(msg['text'] ?? '', style: TextStyle(fontSize: 14)),
                                ),
                              ),
                              if (isUser) SizedBox(width: 6),
                              if (isUser)
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.red[400],
                                  child: Icon(Icons.person, size: 16, color: Colors.white),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            // Ô nhập tin nhắn + nút gửi
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Enter message...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                _isSending
                    ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
                    : IconButton(
                        icon: Icon(Icons.send, color: Colors.red),
                        onPressed: _sendMessage,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}