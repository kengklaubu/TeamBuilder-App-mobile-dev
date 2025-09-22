import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AIService _aiService = AIService();
  final TextEditingController _ctrl = TextEditingController();

  // UI จะถือสำเนา messages ไว้โชว์ แล้ว sync กลับไปยัง service ด้วย saveMessages()
  final List<Map<String, String>> _messages = <Map<String, String>>[];

  @override
  void initState() {
    super.initState();
    // ถ้าต้องการ preload จาก service
    _messages.addAll(_aiService.messages);
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    // อัปเดต UI ทันที
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _ctrl.clear();
    });

    // sync ไป service
    await _aiService.saveMessages(_messages);

    try {
      final reply = await _aiService.sendMessage(text);
      setState(() {
        _messages.add({'role': 'assistant', 'content': reply});
      });
      // sync กลับอีกครั้งให้แน่ใจว่า service กับ UI ตรงกัน
      await _aiService.saveMessages(_messages);
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': 'เกิดข้อผิดพลาด: $e',
        });
      });
    }
  }

  Future<void> _clear() async {
    await _aiService.clearMessages();
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        actions: [
          IconButton(
            onPressed: _clear,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear',
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isUser = m['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.blue.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(m['content'] ?? ''),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: TextField(
                      controller: _ctrl,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'พิมพ์ข้อความ...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
