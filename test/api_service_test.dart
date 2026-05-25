import 'package:flutter_test/flutter_test.dart';
import 'package:mycgmapp/services/api_service.dart';
import 'package:mycgmapp/services/cloud_api_service.dart';

void main() {
  test('ApiService fetchData debug test', () async {
    print('Testing ApiService.fetchData()...');
    print('Base URL from environment: ${CloudRunService.baseUrl}');
    
    final apiService = ApiService();
    
    try {
      final result = await apiService.fetchData();
      print('Success!');
      print('Response Status: ${result.status}');
      print('Connection ID: ${result.data.connection.id}');
      print('Number of graph points: ${result.data.graphData.length}');
      
      if (result.data.graphData.isNotEmpty) {
        print('First data point: ${result.data.graphData.first.value} at ${result.data.graphData.first.timestamp}');
      }
      
      expect(result, isNotNull);
    } catch (e) {
      print('Caught an error: $e');
      rethrow;
    }
  });
}
