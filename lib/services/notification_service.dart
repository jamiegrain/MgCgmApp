import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'constants_service.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final AppConstants _constants = ConstantsService();

  // Stream to listen for notification actions (like Snooze)
  final StreamController<String> snoozeStream = StreamController<String>.broadcast();

  static const String _snoozeKey = 'snooze_until';

  @pragma('vm:entry-point')
  static Future<void> notificationTapBackground(NotificationResponse notificationResponse) async {
    if (notificationResponse.actionId == 'snooze_30') {
      final prefs = await SharedPreferences.getInstance();
      final snoozeUntil = DateTime.now().add(const Duration(minutes: 30));
      await prefs.setString(_snoozeKey, snoozeUntil.toIso8601String());
    }
  }

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.actionId == 'snooze_30') {
          await snooze(30);
          snoozeStream.add('30');
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> snooze(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    final snoozeUntil = DateTime.now().add(Duration(minutes: minutes));
    await prefs.setString(_snoozeKey, snoozeUntil.toIso8601String());
  }

  Future<bool> isSnoozed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final snoozeStr = prefs.getString(_snoozeKey);
    if (snoozeStr == null) return false;
    final snoozeUntil = DateTime.tryParse(snoozeStr);
    if (snoozeUntil == null) return false;
    return snoozeUntil.isAfter(DateTime.now());
  }

  Future<void> clearSnooze() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_snoozeKey);
  }

  Future<void> checkAndNotify(double glucoseValue, {bool isActivityInProgress = false}) async {
    if (await isSnoozed()) return;

    final lowLimit = _constants.getLowLimit(isActivityInProgress);
    final highLimit = _constants.getHighLimit(isActivityInProgress);

    if (glucoseValue > highLimit) {
      await showNotification(
        0,
        'High Glucose Alert',
        'Your glucose level is high: ${glucoseValue.toStringAsFixed(1)} mmol/L',
      );
    } else if (glucoseValue < lowLimit) {
      await showNotification(
        1,
        'Low Glucose Alert',
        'Your glucose level is low: ${glucoseValue.toStringAsFixed(1)} mmol/L',
      );
    }
  }

  Future<void> showNotification(int id, String title, String body) async {
    final Int64List vibrationPattern = Int64List.fromList([
      0, 1000, 200, 300, 100, 300, 100, 300, 200, 1000
    ]);

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'glucose_alerts_channel_v3',
      'Glucose Alerts',
      channelDescription: 'Aggressive channel for glucose level alerts',
      importance: Importance.max,
      priority: Priority.high,
      vibrationPattern: vibrationPattern,
      enableVibration: true,
      showWhen: false,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'snooze_30',
          'Snooze 30 mins',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }
}
