import 'package:dashboard/const/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fish_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';


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


// Data class for gradient data
// Linear interpolation: https://en.wikipedia.org/wiki/Linear_interpolation
double lerp(num a, num b, double t) {
  return a.toDouble() * (1.0 - t) + b.toDouble() * t;
}

// Inverse lerp: https://www.gamedev.net/articles/programming/general-and-gameplay-programming/inverse-lerp-a-super-useful-yet-often-overlooked-function-r5230/
double invlerp(num a, num b, num x) {
  return (x - a.toDouble()) / (b.toDouble() - a.toDouble());
}

// For interpolating between colors
Color lerpColor(Color a, Color b, double t) {
  return Color.lerp(a, b, t)!;
}


// Data class for gradient data
class GradientData {
  final List<double> stops;
  final List<Color> colors;

  GradientData(this.stops, this.colors)
      : assert(stops.length == colors.length);

  // Get the color value at any point in a gradient
  Color getColor(double t) {
    assert(stops.length == colors.length);
    if (t <= 0) return colors.first;
    if (t >= 1) return colors.last;

    for (int i = 0; i < stops.length - 1; i++) {
      final stop = stops[i];
      final nextStop = stops[i + 1];
      final color = colors[i];
      final nextColor = colors[i + 1];
      if (t >= stop && t < nextStop) {
        final lerpT = invlerp(stop, nextStop, t);
        return lerpColor(color, nextColor, lerpT);
      }
    }

    return colors.last;
  }

  // Calculate a new gradient for a subset of this gradient
  GradientData getConstrainedGradient(
      double dataYMin, // Min y-value of the data set
      double dataYMax, // Max y-value of the data set
      double graphYMin, // Min value of the y-axis
      double graphYMax, // Max value of the y-axis
      )
  {
    // The "new" beginning and end stop positions for the gradient
    final tMin = invlerp(graphYMin, graphYMax, dataYMin);
    final tMax = invlerp(graphYMin, graphYMax, dataYMax);

    final newStops = <double>[];
    final newColors = <Color>[];

    newStops.add(0);
    newColors.add(getColor(tMin));

    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final color = colors[i];
      if (stop <= tMin || stop >= tMax) continue;
      final stopT = invlerp(tMin, tMax, stop);
      newStops.add(stopT);
      newColors.add(color);
    }

    newStops.add(1);
    newColors.add(getColor(tMax));

    return GradientData(newStops, newColors);
  }
}