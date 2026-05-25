import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import 'package:mycgmapp/constants.dart';
import 'package:mycgmapp/services/constants_service.dart';

import 'models/current_glucose_status.dart';
import 'services/notification_service.dart';
import 'services/background_glucose_service.dart';
import 'screens/home/home_screen.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(GlucoseMonitorTaskHandler());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  FlutterForegroundTask.initCommunicationPort();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppConstants>(create: (_) => ConstantsService()),
        ChangeNotifierProvider(create: (context) => CurrentGlucoseStatus()),
      ],
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
      home: const HomeScreen(title: 'Glucose Alerts'),
    );
  }
}
