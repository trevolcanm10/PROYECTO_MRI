import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProbabilityChart extends StatelessWidget {
  final Map<String, double> probabilidades;

  const ProbabilityChart({super.key, required this.probabilidades});

  static const Map<String, Color> _colores = {
    'glioma':     Color(0xFFE74C3C),
    'meningioma': Color(0xFFF39C12),
    'notumor':    Color(0xFF27AE60),
    'pituitary':  Color(0xFF9B59B6),
  };

  @override
  Widget build(BuildContext context) {
    final entries = probabilidades.entries.toList();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1.0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1E3C72),
              getTooltipItem: (group, _, rod, __) {
                final clase = entries[group.x].key;
                final pct = (rod.toY * 100).toStringAsFixed(1);
                return BarTooltipItem(
                  '$clase\n$pct%',
                  const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      entries[idx].key,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                getTitlesWidget: (v, _) => Text(
                  '${(v * 100).toInt()}%',
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 9),
                ),
              ),
            ),
            topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.25,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Colors.white10, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(entries.length, (i) {
            final color = _colores[entries[i].key] ?? const Color(0xFF3498DB);
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: entries[i].value,
                  color: color,
                  width: 28,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 1.0,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
