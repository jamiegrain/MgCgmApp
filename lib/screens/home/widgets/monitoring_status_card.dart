import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mycgmapp/constants.dart';

class MonitoringStatusCard extends StatelessWidget {
  final bool isRunning;
  final String lastUpdate;

  const MonitoringStatusCard({
    Key? key,
    required this.isRunning,
    required this.lastUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final constants = context.watch<AppConstants>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRunning ? Colors.green.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isRunning ? Icons.monitor_heart : Icons.monitor_heart_outlined,
                color: isRunning ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRunning ? 'Monitoring Active' : 'Monitoring Stopped',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isRunning ? Colors.green.shade700 : Colors.grey.shade700,
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
        const SizedBox(height: 16),
        Text(
          'Auto-checks every ${constants.pollingIntervalMinutes} minutes',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}
