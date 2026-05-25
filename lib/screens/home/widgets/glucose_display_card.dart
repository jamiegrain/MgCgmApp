import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mycgmapp/constants.dart';
import 'package:mycgmapp/models/current_glucose_status.dart';

class GlucoseDisplayCard extends StatelessWidget {
  const GlucoseDisplayCard({Key? key}) : super(key: key);

  Color _getGlucoseColor(double? value, AppConstants constants, bool isActivityInProgress) {
    if (value == null) return Colors.grey;
    final highLimit = constants.getHighLimit(isActivityInProgress);
    final lowLimit = constants.getLowLimit(isActivityInProgress);

    if (value > highLimit) return Colors.orange;
    if (value < lowLimit) return Colors.red;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<CurrentGlucoseStatus>();
    final constants = context.watch<AppConstants>();
    final glucoseValue = status.currentGlucose;
    final isActivity = status.isActivityInProgress;
    final color = _getGlucoseColor(glucoseValue, constants, isActivity);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color,
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
            glucoseValue != null ? glucoseValue.toStringAsFixed(1) : '--',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Text(
            'mmol/L',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          if (glucoseValue != null &&
              (glucoseValue > constants.getHighLimit(isActivity) ||
                  glucoseValue < constants.getLowLimit(isActivity))) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: glucoseValue > constants.getHighLimit(isActivity)
                    ? Colors.orange
                    : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                glucoseValue > constants.getHighLimit(isActivity) ? '⚠️ HIGH' : '⚠️ LOW',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            PopupMenuButton<int>(
              onSelected: (minutes) {
                status.updateSnoozeUntil(
                  DateTime.now().add(Duration(minutes: minutes)),
                );
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 30, child: Text('Snooze 30 mins')),
                const PopupMenuItem(value: 60, child: Text('Snooze 60 mins')),
                const PopupMenuItem(value: 120, child: Text('Snooze 120 mins')),
              ],
              child: TextButton.icon(
                onPressed: null,
                style: TextButton.styleFrom(
                  disabledForegroundColor: Colors.blue,
                ),
                icon: const Icon(Icons.snooze),
                label: const Text('Snooze alerts...'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
