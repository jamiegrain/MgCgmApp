import 'package:flutter/foundation.dart';
import 'package:mycgmapp/constants.dart';
import '../services/notification_service.dart';
import 'graph_response.dart';

class CurrentGlucoseStatus extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  double? _currentGlucose;
  List<GraphPoint> _graphPoints = [];
  DateTime? _snoozeUntil;
  String? _error;
  String? _lastUpdateTime;

  double? get currentGlucose => _currentGlucose;
  List<GraphPoint> get graphPoints => _graphPoints;
  String? get error => _error;
  String? get lastUpdateTime => _lastUpdateTime;
  
  bool get isSnoozed =>
      _snoozeUntil != null && _snoozeUntil!.isAfter(DateTime.now());

  void updateSnoozeUntil(DateTime snoozeUntil) {
    _snoozeUntil = snoozeUntil;
    notifyListeners();
  }

  void resetSnooze() {
    _snoozeUntil = null;
    notifyListeners();
  }

  /// Called by the main app when receiving updates from the background service
  void updateFromBackground(Map<String, dynamic> data) {
    _currentGlucose = data['value']?.toDouble();
    _error = data['error'];
    
    if (data['graphData'] != null) {
      final List<dynamic> rawPoints = data['graphData'];
      _graphPoints = rawPoints.map((p) => GraphPoint.fromJson(p)).toList();
    }

    if (data['timestamp'] != null) {
      _lastUpdateTime = _formatTimestamp(data['timestamp']);
    }

    if (_currentGlucose != null && !isSnoozed) {
      _checkForAlerts(_currentGlucose!);
    }
    
    notifyListeners();
  }

  void _checkForAlerts(double glucoseValue) {
    if (glucoseValue > AppConstants.highLimit) {
      _notificationService.showNotification(
        0,
        'High Glucose Alert',
        'Your glucose level is high: $glucoseValue',
      );
    } else if (glucoseValue < AppConstants.lowLimit) {
      _notificationService.showNotification(
        1,
        'Low Glucose Alert',
        'Your glucose level is low: $glucoseValue',
      );
    }
  }

  String _formatTimestamp(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }
}
