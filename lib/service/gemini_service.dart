import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiService {
  static const String _apiKey = 'AIzaSyCGcIvaWcAHhJKYbLj8YmJzmKct1rjHkbk'; 
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  Future<String> sendMessage(String message) async {
    final url = Uri.parse('$_baseUrl?key=$_apiKey');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': message}
              ]
            }
          ]
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Lỗi: Không thể kết nối với Gemini API. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }
}