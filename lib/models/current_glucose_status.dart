import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import 'graph_response.dart';

class CurrentGlucoseStatus extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  double? _currentGlucose;
  List<GraphPoint> _graphPoints = [];
  DateTime? _snoozeUntil;
  String? _error;
  String? _lastUpdateTime;
  bool _isActivityInProgress = false;

  CurrentGlucoseStatus() {
    _loadSnoozeSettings();
    // Listen for snooze actions from notifications
    _notificationService.snoozeStream.stream.listen((minutes) {
      _loadSnoozeSettings();
    });
  }

  Future<void> _loadSnoozeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final snoozeStr = prefs.getString('snooze_until');
    if (snoozeStr != null) {
      _snoozeUntil = DateTime.parse(snoozeStr);
      if (_snoozeUntil!.isBefore(DateTime.now())) {
        _snoozeUntil = null;
      }
    } else {
      _snoozeUntil = null;
    }
    notifyListeners();
  }

  double? get currentGlucose => _currentGlucose;
  List<GraphPoint> get graphPoints => _graphPoints;
  String? get error => _error;
  String? get lastUpdateTime => _lastUpdateTime;
  bool get isActivityInProgress => _isActivityInProgress;
  
  bool get isSnoozed =>
      _snoozeUntil != null && _snoozeUntil!.isAfter(DateTime.now());

  Future<void> updateSnoozeUntil(DateTime snoozeUntil) async {
    _snoozeUntil = snoozeUntil;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('snooze_until', snoozeUntil.toIso8601String());
    notifyListeners();
  }

  Future<void> resetSnooze() async {
    _snoozeUntil = null;
    await _notificationService.clearSnooze();
    notifyListeners();
  }

  /// Called by the main app when receiving updates from the background service
  void updateFromBackground(Map<String, dynamic> data) {
    _currentGlucose = data['value']?.toDouble();
    _error = data['error'];
    _isActivityInProgress = data['isActivityInProgress'] ?? false;
    
    if (data['graphData'] != null) {
      final List<dynamic> rawPoints = data['graphData'];
      _graphPoints = rawPoints.map((p) => GraphPoint.fromJson(p)).toList();
    }

    if (data['timestamp'] != null) {
      _lastUpdateTime = _formatTimestamp(data['timestamp']);
    }

    notifyListeners();
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
