import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mycgmapp/models/current_glucose_status.dart';
import 'package:mycgmapp/widgets/glucose_chart.dart';

class RecentHistoryCard extends StatelessWidget {
  const RecentHistoryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = context.watch<CurrentGlucoseStatus>();

    return Card(
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
    );
  }
}
