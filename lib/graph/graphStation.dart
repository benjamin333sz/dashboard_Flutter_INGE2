import 'package:dashboard/const/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fish_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../calcul/couleur_graph.dart';

class GraphIprStation extends ConsumerWidget {
  const GraphIprStation({super.key});

  LineChartBarData createLineBarData({
    required List<FlSpot> points,
    required double minY,
    required double maxY,
    required GradientData baseGradient,
  })
  {
    final dataYMin = points.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final dataYMax = points.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final constrainedGradient = baseGradient.getConstrainedGradient(
      dataYMin,
      dataYMax,
      minY,
      maxY,
    );

    return LineChartBarData(
      spots: points,
      isCurved: false,
      barWidth: 3,
      gradient: LinearGradient(
        begin: Alignment(0, 1),
        end: Alignment(0, -1),
        colors: constrainedGradient.colors,
        stops: constrainedGradient.stops,
      ),
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final color = baseGradient.getColor(invlerp(minY, maxY, spot.y));
          return FlDotCirclePainter(
            radius: 5,
            color: color,
            strokeWidth: 1,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(show: false),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsState = ref.watch(stationProvider);

    return stationsState.when(
      data: (stations) {
        if (stations.isEmpty) {
          return Center(child: Text("Aucune station disponible"));
        }

        final station = stations.firstWhere((station) => station.code_station == "03254370");
        final prelevements = station.prelevements;
        /*for (var prelevement in prelevements) {
          print("Ipr ${prelevement.ipr_code_classe}, date ${prelevement.date_operation}");
        }
        if (prelevements.isEmpty) {
          return Center(child: Text("Aucun prélèvement disponible pour cette station"));
        }*/

        prelevements.sort((a, b) => a.date_operation.compareTo(b.date_operation));

        List<FlSpot> points = prelevements.map((prelevement) {
          double x = prelevement.date_operation.millisecondsSinceEpoch.toDouble();
          double y = double.parse((prelevement.ipr_code_classe));
          return FlSpot(x, y);
        }).toList();

        final gradient = GradientData(
          [0.0, 0.25, 0.50, 0.75, 1],
          [iprTresBon, iprBon, iprMoyen, iprMauvais, iprTresMauvais],
        );

        final singlePoint = points.length == 1;

        final minX = singlePoint
            ? points.first.x - Duration(days: 1).inMilliseconds
            : points.map((e) => e.x).reduce((a, b) => a < b ? a : b);

        final maxX = singlePoint
            ? points.first.x + Duration(days: 1).inMilliseconds
            : points.map((e) => e.x).reduce((a, b) => a > b ? a : b);

        return Expanded(
          child: LineChart(
            LineChartData(
              minY: 1,
              maxY: 5,
              minX: minX,
              maxX: maxX,
              backgroundColor: backgroundGraph,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: true,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.shade300,
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (value) => FlLine(
                  color: Colors.grey.shade300,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: null,
                    getTitlesWidget: (value, meta) {
                      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      final formatted = DateFormat('yyyy-MM-dd').format(date);
                      return Padding(
                        padding: const EdgeInsets.only(top: 6.0),

                        child: RotationTransition( // Rotation du Texte
                          turns: AlwaysStoppedAnimation(-15 / 360),
                          child: Text(
                            formatted,
                            style: TextStyle(fontSize: 8),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                createLineBarData(
                  points: points,
                  minY: 1,
                  maxY: 5,
                  baseGradient: gradient,
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                getTouchedSpotIndicator: (barData, spotIndexes) {
                  return spotIndexes.map((index) {
                    final spot = barData.spots[index];
                    final color = gradient.getColor(invlerp(1, 5, spot.y));
                    return TouchedSpotIndicatorData(
                      FlLine(color: color, strokeWidth: 5),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 15, // point
                            color: color,
                            strokeWidth: 5,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((barSpot) {
                      final y = barSpot.y;
                      final color = gradient.getColor(invlerp(1, 5, y));
                      return LineTooltipItem(
                        y.toStringAsFixed(3),
                        TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Erreur: $err")),
    );
  }
}


