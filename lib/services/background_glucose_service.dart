import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:mycgmapp/services/cloud_api_service.dart';
import 'package:mycgmapp/services/notification_service.dart';
import 'package:mycgmapp/services/database_service.dart';

/// Background service for glucose monitoring
class BackgroundGlucoseService {
  final DatabaseService _dbService = DatabaseService();

  Future<GlucoseResult> fetchAndCheckGlucose() async {
    try {
      final response = await http.get(Uri.parse(CloudRunService.baseUrl));
      
      // Fetch activity status from database
      final bool isActivityInProgress = await _dbService.checkActivityStatus();

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'] as Map<String, dynamic>;

        return GlucoseResult(
          value: (data['connection']['glucoseMeasurement']['Value'] as num)
              .toDouble(),
          graphData: data['graphData'] as List<dynamic>,
          timestamp: DateTime.now(),
          isActivityInProgress: isActivityInProgress,
        );
      } else {
        throw Exception(
          'Failed to fetch glucose data from backend: ${response.body}',
        );
      }
    } catch (e) {
      print('Error in background glucose fetch: $e');
      return GlucoseResult(
        value: null,
        graphData: null,
        timestamp: DateTime.now(),
        isActivityInProgress: false, // Default state
        error: e.toString(),
      );
    }
  }
}

class GlucoseResult {
  final double? value;
  final List<dynamic>? graphData;
  final DateTime timestamp;
  final bool isActivityInProgress;
  final String? error;

  GlucoseResult({
    required this.value,
    this.graphData,
    required this.timestamp,
    this.isActivityInProgress = false,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'value': value,
    'graphData': graphData,
    'timestamp': timestamp.toIso8601String(),
    'isActivityInProgress': isActivityInProgress,
    'error': error,
  };
}

class GlucoseMonitorTaskHandler extends TaskHandler {
  final BackgroundGlucoseService _service = BackgroundGlucoseService();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('Glucose monitoring started at: $timestamp');
    // Initialize NotificationService in this isolate
    await NotificationService().init();
    await _performUpdate();
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    await _performUpdate();
  }

  Future<void> _performUpdate() async {
    final result = await _service.fetchAndCheckGlucose();

    if (result.value != null) {
      // Pass activity status to notification check
      await NotificationService().checkAndNotify(
        result.value!, 
        isActivityInProgress: result.isActivityInProgress,
      );
    }

    FlutterForegroundTask.sendDataToMain(result.toJson());
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print('Glucose monitoring stopped.');
  }
}
