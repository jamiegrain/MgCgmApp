import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/graph_response.dart';
import '../constants.dart';

class GlucoseChart extends StatelessWidget {
  final List<GraphPoint> points;

  const GlucoseChart({Key? key, required this.points}) : super(key: key);

  DateTime _parseTimestamp(String timestamp) {
    try {
      return DateTime.parse(timestamp);
    } catch (_) {
      try {
        // Handle format like "4/28/2026 2:12:34 AM"
        return DateFormat('M/d/yyyy h:mm:ss a').parse(timestamp);
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final constants = context.watch<AppConstants>();

    if (points.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No graph data available')),
      );
    }

    // Convert GraphPoints to FlSpots
    // We'll use the timestamp as X (milliseconds since epoch)
    final spots = points.map((p) {
      final time = _parseTimestamp(p.timestamp).millisecondsSinceEpoch.toDouble();
      return FlSpot(time, p.value);
    }).toList();

    // Sort spots by time just in case
    spots.sort((a, b) => a.x.compareTo(b.x));

    final minX = spots.first.x;
    final maxX = spots.last.x;

    return Container(
      height: 250,
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: (maxX - minX) / 4,
                getTitlesWidget: (value, meta) {
                  final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      DateFormat('HH:mm').format(date),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 4,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: minX,
          maxX: maxX,
          minY: 0,
          maxY: 20, // Adjust based on expected range
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withValues(alpha: 0.1),
              ),
            ),
            // High limit line
            LineChartBarData(
              spots: [FlSpot(minX, constants.highLimit), FlSpot(maxX, constants.highLimit)],
              dashArray: [5, 5],
              color: Colors.orange.withValues(alpha: 0.5),
              barWidth: 1,
              dotData: const FlDotData(show: false),
            ),
            // Low limit line
            LineChartBarData(
              spots: [FlSpot(minX, constants.lowLimit), FlSpot(maxX, constants.lowLimit)],
              dashArray: [5, 5],
              color: Colors.red.withValues(alpha: 0.5),
              barWidth: 1,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
