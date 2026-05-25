import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mycgmapp/services/cloud_api_service.dart';

class ChatService {
  Future<Map<String, String>> queryVertex(String text, String? sessionId) async {
    try {
      final baseUrl = CloudRunService.baseUrl.endsWith('/')
          ? CloudRunService.baseUrl.substring(
              0,
              CloudRunService.baseUrl.length - 1,
            )
          : CloudRunService.baseUrl;
      final url = Uri.parse('$baseUrl/vertex/query');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          if (sessionId != null) 'sessionId': sessionId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'response': data['response'] ?? 'No response received from assistant.',
          'sessionId': data['sessionId'] ?? '',
        };
      } else {
        return {
          'response': 'Backend Error: ${response.statusCode} - ${response.body}',
          'sessionId': sessionId ?? '',
        };
      }
    } catch (e) {
      return {
        'response': 'Network connection error: $e',
        'sessionId': sessionId ?? '',
      };
    }
  }
}
