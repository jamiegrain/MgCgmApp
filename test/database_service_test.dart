import 'package:flutter_test/flutter_test.dart';
import 'package:mycgmapp/services/database_service.dart';

void main() {
  test('DatabaseService connection and query test', () async {
    print('Testing DatabaseService.checkActivityStatus()...');

    final dbService = DatabaseService();

    try {
      final result = await dbService.checkActivityStatus();
      print('Query completed. Activity in progress: $result');
      expect(result, isA<bool>());
    } catch (e) {
      print('Caught an error during MongoDB test: $e');
      rethrow;
    }
  });
}
