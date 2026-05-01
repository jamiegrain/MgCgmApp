import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mycgmapp/Models/graph_response.dart';
import 'package:mycgmapp/services/cloud_api_service.dart';

class ApiService {
  Future<GraphResponse> fetchData() async {
    final response = await http.get(Uri.parse(CloudRunService.baseUrl));

    if (response.statusCode == 200) {
      return GraphResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data from backend API: ${response.body}');
    }
  }
}
