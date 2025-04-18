import 'package:dashboard/const/constant.dart';
import 'package:flutter/material.dart';
import '../model/station_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/Data_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/region_provider.dart';
import '../calcul/couleur_graph.dart';

class GraphIprRegion extends ConsumerWidget {
  const GraphIprRegion({super.key});

  Map<String, Map<int, double>> calculerEvolutionIPRParRegion(List<StationModel> stations) {
    Map<String, Map<int, List<double>>> iprParRegionEtAnnee = {};

    for (var station in stations) {
      String codeReg = station.code_region;
      String? region = correspondanceRegions[codeReg];

      if (region != null) {
        for (var prelevement in station.prelevements) {
          int annee = prelevement.date_operation.year;
          double ipr = double.tryParse(prelevement.ipr_code_classe) ?? 0.0;

          if (ipr > 0) {
            iprParRegionEtAnnee.putIfAbsent(region, () => {});
            iprParRegionEtAnnee[region]!.putIfAbsent(annee, () => []);
            iprParRegionEtAnnee[region]![annee]!.add(ipr);
          }
        }
      }
    }

    Map<String, Map<int, double>> moyennesParRegionEtAnnee = {};
    iprParRegionEtAnnee.forEach((region, dataParAnnee) {
      moyennesParRegionEtAnnee[region] = dataParAnnee.map((annee, valeurs) =>
          MapEntry(annee, valeurs.reduce((a, b) => a + b) / valeurs.length));
    });

    return moyennesParRegionEtAnnee;
  }

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
        final regionSelectionnee = ref.watch(selectedRegionProvider);
        if (regionSelectionnee == null) {
          return const Center(child: Text("Erreur, devrait afficher graphe France IPR"));
        }

        final regionCode = regionSelectionnee['code'];
        final regionName = regionSelectionnee['name'];

        final filteredStations = stations.where(
                (station) => station.code_region == regionCode
        ).toList();

        final evolutionIPR = ref.watch(evolutionIprProviderRegion);


        final donneesGraphique = evolutionIPR[regionName] ?? {};

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
        if (points.isEmpty) {
          return const Center(
            child: Text(
              "Aucune donnée disponible pour cette région. (Normalement, la Corse)",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          );
        }
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

