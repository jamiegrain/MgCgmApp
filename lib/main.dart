import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import 'package:mycgmapp/constants.dart';

import 'models/current_glucose_status.dart';
import 'services/notification_service.dart';
import 'services/background_glucose_service.dart';
import 'widgets/glucose_chart.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(GlucoseMonitorTaskHandler());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  FlutterForegroundTask.initCommunicationPort();

  runApp(
    ChangeNotifierProvider(
      create: (context) => CurrentGlucoseStatus(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glucose Alerts',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MyHomePage(title: 'Glucose Alerts'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _initForegroundTask();
    _checkTaskStatus();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }

  void _onReceiveTaskData(Object data) {
    if (data is Map<String, dynamic>) {
      context.read<CurrentGlucoseStatus>().updateFromBackground(data);
    }
  }

  Future<void> _initForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'glucose_monitor_channel',
        channelName: 'Glucose Monitoring',
        channelDescription: 'Monitors glucose levels in the background',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(
          AppConstants.pollingIntervalMinutes * 60 * 1000,
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
    setState(() {
      _isRunning = isRunning;
    });
  }

  Future<void> _startForegroundTask() async {
    final notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    final result = await FlutterForegroundTask.startService(
      notificationTitle: 'Glucose Monitoring Active',
      notificationText:
          'Checking glucose levels every ${AppConstants.pollingIntervalMinutes} minutes',
      callback: startCallback,
    );

    if (result is ServiceRequestSuccess) {
      setState(() {
        _isRunning = true;
      });
    }
  }

  Future<void> _stopForegroundTask() async {
    final result = await FlutterForegroundTask.stopService();
    if (result is ServiceRequestSuccess) {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Color _getGlucoseColor(double? value) {
    if (value == null) return Colors.grey;
    if (value > AppConstants.highLimit) return Colors.orange;
    if (value < AppConstants.lowLimit) return Colors.red;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<CurrentGlucoseStatus>();
    final glucoseValue = status.currentGlucose;
    final lastUpdate = status.lastUpdateTime ?? 'Awaiting first reading';
    final error = status.error;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
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
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Glucose value display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _getGlucoseColor(glucoseValue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getGlucoseColor(glucoseValue),
                    width: 3,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Current Glucose',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      glucoseValue != null
                          ? glucoseValue.toStringAsFixed(1)
                          : '--',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: _getGlucoseColor(glucoseValue),
                      ),
                    ),
                    const Text(
                      'mmol/L',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    if (glucoseValue != null &&
                        (glucoseValue > AppConstants.highLimit ||
                            glucoseValue < AppConstants.lowLimit)) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: glucoseValue > AppConstants.highLimit
                              ? Colors.orange
                              : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          glucoseValue > AppConstants.highLimit
                              ? '⚠️ HIGH'
                              : '⚠️ LOW',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          status.updateSnoozeUntil(
                            DateTime.now().add(const Duration(minutes: 30)),
                          );
                        },
                        child: const Text('Snooze alerts (30m)'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Glucose Chart
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlucoseChart(points: status.graphPoints),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Monitoring status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isRunning
                      ? Colors.green.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isRunning
                          ? Icons.monitor_heart
                          : Icons.monitor_heart_outlined,
                      color: _isRunning ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isRunning
                              ? 'Monitoring Active'
                              : 'Monitoring Stopped',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isRunning
                                ? Colors.green.shade700
                                : Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          'Last update: $lastUpdate',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Start/Stop button
              ElevatedButton.icon(
                onPressed: _isRunning
                    ? _stopForegroundTask
                    : _startForegroundTask,
                icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                label: Text(
                  _isRunning ? 'Stop Monitoring' : 'Start Monitoring',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Auto-checks every ${AppConstants.pollingIntervalMinutes} minutes',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
