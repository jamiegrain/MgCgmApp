import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import 'package:mycgmapp/services/constants_service.dart';
import 'package:mycgmapp/models/current_glucose_status.dart';
import 'package:mycgmapp/screens/chat/chat_screen.dart';
import 'package:mycgmapp/main.dart' show startCallback;

import 'widgets/activity_status_badge.dart';
import 'widgets/glucose_display_card.dart';
import 'widgets/recent_history_card.dart';
import 'widgets/monitoring_status_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initForegroundTask();
    _checkTaskStatus();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    
    // Initial attempt to start
    _startForegroundTask();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check and attempt to start when returning from permission/settings screens
      _checkTaskStatus();
      _startForegroundTask();
    }
  }

  void _onReceiveTaskData(Object data) {
    if (data is Map<String, dynamic>) {
      context.read<CurrentGlucoseStatus>().updateFromBackground(data);
    }
  }

  Future<void> _initForegroundTask() async {
    final constants = ConstantsService();
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'glucose_monitor_channel_v2',
        channelName: 'Glucose Monitoring',
        channelDescription: 'Monitors glucose levels in the background',
        channelImportance: NotificationChannelImportance.MAX,
        priority: NotificationPriority.HIGH,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(
          constants.pollingIntervalMinutes * 60 * 1000,
        ),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<void> _checkTaskStatus() async {
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (mounted) {
      setState(() {
        _isRunning = isRunning;
      });
    }
  }

  Future<void> _startForegroundTask() async {
    // If already running, don't try to start again
    if (await FlutterForegroundTask.isRunningService) return;

    // 1. Check/Request Notification Permission
    NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      notificationPermission = await FlutterForegroundTask.requestNotificationPermission();
    }
    
    if (notificationPermission != NotificationPermission.granted) return;

    // 2. Check/Request Battery Optimization Exemption
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      // This opens a system dialog/settings page. 
      // The lifecycle observer will trigger this function again when the user returns.
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      return;
    }

    // 3. Start the service
    await Future.delayed(const Duration(milliseconds: 500));

    final constants = ConstantsService();
    final result = await FlutterForegroundTask.startService(
      notificationTitle: 'Glucose Monitoring Active',
      notificationText:
          'Checking glucose levels every ${constants.pollingIntervalMinutes} minutes',
      callback: startCallback,
    );

    if (result is ServiceRequestSuccess) {
      _checkTaskStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<CurrentGlucoseStatus>();
    final lastUpdate = status.lastUpdateTime ?? 'Awaiting first reading';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology, color: Colors.blue),
            tooltip: 'Ask AI Assistant',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(),
                  fullscreenDialog: true,
                ),
              );
            },
          ),
          if (status.isSnoozed)
            IconButton(
              icon: const Icon(Icons.notifications_off, color: Colors.orange),
              onPressed: () => status.resetSnooze(),
              tooltip: 'Reset Snooze',
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ActivityStatusBadge(
                isActivity: status.isActivityInProgress,
                error: status.error,
              ),
              const GlucoseDisplayCard(),
              const SizedBox(height: 24),
              const RecentHistoryCard(),
              const SizedBox(height: 24),
              MonitoringStatusCard(
                isRunning: _isRunning,
                lastUpdate: lastUpdate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
