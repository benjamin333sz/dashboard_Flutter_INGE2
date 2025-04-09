import 'package:dashboard/const/constant.dart';
import 'package:flutter/material.dart';
import '../model/station_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fish_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphIprFrance extends ConsumerWidget {
  const GraphIprFrance({super.key});

  Map<int, double> calculerEvolutionIPRFrance(List<StationModel> stations) {
    Map<int, List<double>> iprParAnnee = {};

    for (var station in stations) {
      for (var prelevement in station.prelevements) {
        int annee = prelevement.date_operation.year;
        double ipr = double.tryParse(prelevement.ipr_code_classe) ?? 0.0;

        if (ipr > 0) {
          iprParAnnee.putIfAbsent(annee, () => []);
          iprParAnnee[annee]!.add(ipr);
        }
      }
    }

    return iprParAnnee.map((annee, valeurs) =>
        MapEntry(annee, valeurs.reduce((a, b) => a + b) / valeurs.length));
  }




  double calculerMoyenneIPRParAnnee(List<Prelevement> prelevements, List<int> annees) {
    List<double> valeursIPR = prelevements
        .where((p) => annees.contains(p.date_operation.year))
        .map((p) => double.tryParse(p.ipr_code_classe) ?? 0.0)
        .where((ipr) => ipr > 0)
        .toList();

    if (valeursIPR.isEmpty) return 0.0;

    return valeursIPR.reduce((a, b) => a + b) / valeursIPR.length;
  }


  LineChartBarData createLineBarData({
    required List<FlSpot> points,
    required double minY,
    required double maxY,
    required GradientData baseGradient,
  }) {
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
      isCurved: true,
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
        final donneesGraphique = calculerEvolutionIPRFrance(stations);


        Map<int, List<double>> valeursParAnnee = {};
        donneesGraphique.forEach((annee, ipr) {
          valeursParAnnee.putIfAbsent(annee, () => []).add(ipr);
        });

        final donneesFiltrees = valeursParAnnee.map((annee, valeurs) =>
            MapEntry(annee, valeurs.reduce((a, b) => a + b) / valeurs.length));

        final sortedData = donneesFiltrees.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        List<FlSpot> points = sortedData.map((entry)
        {
          return FlSpot(entry.key.toDouble(), double.parse((entry.value).toStringAsFixed(3)));
        }).toList();

        final gradient = GradientData(
          [0.0, 0.25, 0.5, 0.75, 1],
          [
            iprTresBon,
            iprBon,
            iprMoyen,
            iprMauvais,
            iprTresMauvais,
          ],
        );

        return Expanded(
          child: LineChart(
            LineChartData(
              minY: 1,
              maxY: 5,
              backgroundColor: backgroundGraph,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30, // ✅ Espace pour éviter le chevauchement
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5, // ✅ Afficher les années tous les 5 ans
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(), // ✅ Affichage correct des années
                        style: TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // ✅ Supprime les "2K"
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
                getTouchedSpotIndicator:
                    (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((index) {
                    final spot = barData.spots[index];
                    final color = gradient.getColor(invlerp(1, 5, spot.y));

                    return TouchedSpotIndicatorData(
                      FlLine(
                        color: color, // ligne vers point
                        strokeWidth: 5,
                      ),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6, // point
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

    for (int i=0 ;i < 0; i < stops.length, i++) {
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