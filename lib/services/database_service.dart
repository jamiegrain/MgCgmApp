import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cloud_api_service.dart';

class DatabaseService {
  Future<bool> checkActivityStatus() async {
    try {
      final baseUrl = CloudRunService.baseUrl.endsWith('/')
          ? CloudRunService.baseUrl.substring(
              0,
              CloudRunService.baseUrl.length - 1,
            )
          : CloudRunService.baseUrl;
      final url = '$baseUrl/settings/activity';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isActivityInProgress'] == true;
      }

      print(
        'Failed to fetch activity status: ${response.statusCode} - ${response.body}',
      );
      return false;
    } catch (e) {
      print('Error fetching activity status: $e');
      return false;
    }
  }
}
