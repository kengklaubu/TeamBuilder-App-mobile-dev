import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// โครงสร้างข้อความที่ API ต้องการ: role = user/assistant/system, content = ข้อความ
typedef ChatMsg = Map<String, String>;

class AIService {
  AIService();

  // เลือกผู้ให้บริการหลัก–สำรองจาก .env
  final String _primary =
      dotenv.env['AI_PROVIDER_PRIMARY'] ?? dotenv.env['AI_PROVIDER'] ?? 'openai';
  final String _secondary = dotenv.env['AI_PROVIDER_SECONDARY'] ?? 'groq';

  // เก็บเฉพาะบทสนทนา user/assistant (system จะใส่ขณะเรียก API)
  final List<ChatMsg> _messages = <ChatMsg>[];

  /// อ่านประวัติ (สำหรับ UI)
  List<ChatMsg> get messages => List.unmodifiable(_messages);

  /// บันทึกข้อความจากภายนอก (เช่น จาก UI ที่ถือสถานะเอง)
  Future<void> saveMessages(List<dynamic> messages) async {
    _messages
      ..clear()
      ..addAll(
        messages
            .map((e) => {
                  'role': (e['role'] ?? '').toString(),
                  'content': (e['content'] ?? '').toString(),
                })
            .cast<ChatMsg>(),
      );
  }

  /// ล้างประวัติ (สำหรับปุ่ม Clear/Reset)
  Future<void> clearMessages() async {
    _messages.clear();
  }

  /// ส่งข้อความและได้คำตอบกลับ พร้อมบันทึกทั้งคำถาม/คำตอบในประวัติ
  Future<String> sendMessage(String userMessage) async {
    // บันทึกข้อความผู้ใช้ลงประวัติทันที
    _messages.add({'role': 'user', 'content': userMessage});

    // ลำดับผู้ให้บริการที่จะลองเรียก (fallback อัตโนมัติ)
    final providers = <String>[_primary, if (_secondary != _primary) _secondary];

    // สร้าง payload messages = [system?, ...history...]
    final systemPrompt =
        dotenv.env['SYSTEM_PROMPT'] ?? 'You are a helpful assistant.';
    List<ChatMsg> buildPayload() => [
          if (systemPrompt.trim().isNotEmpty)
            {'role': 'system', 'content': systemPrompt},
          ..._messages,
        ];

    // วนลองเรียกตามลำดับ
    for (final p in providers) {
      try {
        String reply;
        if (p.toLowerCase() == 'openai') {
          reply = await _sendOpenAI(buildPayload());
        } else if (p.toLowerCase() == 'groq') {
          reply = await _sendGroq(buildPayload());
        } else {
          // เผื่ออนาคตเพิ่ม provider อื่น
          throw Exception('Unknown provider: $p');
        }

        // สำเร็จ: บันทึกคำตอบและคืนค่า
        _messages.add({'role': 'assistant', 'content': reply});
        return reply;
      } catch (e) {
        // ถ้าเจ้าแรกพัง ให้ลองเจ้าถัดไป
        if (kDebugMode) {
          // พิมพ์ไว้ช่วยดีบักตอนพัฒนา
          print('[AIService] provider $p failed: $e');
        }
      }
    }

    // ถ้าทุกเจ้าล้มเหลว ให้ลบข้อความ user ล่าสุดทิ้ง (ไม่งั้น history จะติดคา)
    if (_messages.isNotEmpty && _messages.last['role'] == 'user') {
      _messages.removeLast();
    }
    throw Exception('All AI providers failed.');
  }

  // -------------------- Providers --------------------

  Future<String> _sendOpenAI(List<ChatMsg> payload) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final model = dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini';
    final base =
        dotenv.env['OPENAI_BASE_URL']?.trim().isNotEmpty == true
            ? dotenv.env['OPENAI_BASE_URL']!.trim().replaceAll(RegExp(r'/$'), '')
            : 'https://api.openai.com';
    final uri = Uri.parse('$base/v1/chat/completions');

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'messages': payload,
        'temperature': _readNum(dotenv.env['TEMPERATURE']) ?? 0.7,
        'max_tokens': _readInt(dotenv.env['MAX_TOKENS']) ?? 1024,
      }),
    );

    return _handleResponse(res, providerName: 'OpenAI');
  }

  Future<String> _sendGroq(List<ChatMsg> payload) async {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    final model = dotenv.env['GROQ_MODEL'] ?? 'llama-3.1-70b-versatile';
    // Groq: OpenAI-compatible endpoint
    final base =
        dotenv.env['GROQ_BASE_URL']?.trim().isNotEmpty == true
            ? dotenv.env['GROQ_BASE_URL']!.trim().replaceAll(RegExp(r'/$'), '')
            : 'https://api.groq.com/openai';
    final uri = Uri.parse('$base/v1/chat/completions');

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'messages': payload,
        'temperature': _readNum(dotenv.env['TEMPERATURE']) ?? 0.7,
        'max_tokens': _readInt(dotenv.env['MAX_TOKENS']) ?? 1024,
      }),
    );

    return _handleResponse(res, providerName: 'Groq');
  }

  // -------------------- Helpers --------------------

  String _handleResponse(http.Response res, {required String providerName}) {
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      // โครงสร้าง OpenAI-compatible
      final content = data['choices']?[0]?['message']?['content'];
      if (content is String && content.isNotEmpty) {
        return content;
      }
      throw Exception('$providerName: empty content');
    }

    // สถานะที่สมเหตุสมผลต่อการ fallback
    if (<int>{401, 403, 429, 500, 502, 503, 504}.contains(res.statusCode)) {
      throw Exception('$providerName temporary/unusable: ${res.statusCode}');
    }

    // สถานะอื่น ๆ โยนรายละเอียดเพื่อให้เห็นปัญหา
    throw Exception('$providerName error ${res.statusCode}: ${res.body}');
  }

  int? _readInt(String? s) {
    if (s == null) return null;
    return int.tryParse(s.trim());
    }

  num? _readNum(String? s) {
    if (s == null) return null;
    return num.tryParse(s.trim());
  }
}
