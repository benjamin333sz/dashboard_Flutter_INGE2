import 'package:dashboard/const/constant.dart';
import 'package:flutter/material.dart';
import '../model/station_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fish_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';




class GraphIprRegion extends ConsumerWidget {


  double calculerMoyenneIPRParAnnee(List<Prelevement> prelevements,
      List<int> annees)
  {
    List<double> valeursIPR = prelevements
        .where((p) =>
        annees.contains(p.date_operation.year)) // Filtre par année
        .map((p) => double.tryParse(p.ipr_code_classe) ?? 0.0)
        .where((ipr) => ipr > 0) // Évite les valeurs nulles ou invalides
        .toList();

    if (valeursIPR.isEmpty) return 0.0;

    return valeursIPR.reduce((a, b) => a + b) / valeursIPR.length;
  }


  Map<String, String> correspondanceRegions = {
    "11": "Île-de-France",
    "24": "Centre-Val de Loire",
    "27": "Bourgogne-Franche-Comté",
    "28": "Normandie",
    "32": "Hauts-de-France",
    "44": "Grand Est",
    "52": "Pays de ma Loire",
    "53": "Bretagne",
    "75": "Nouvelle-Aquitaine",
    "76": "Occitanie",
    "84": "Auvergne-Rhône-Alpes",
    "93": "Provences-Alpes-Côte d'Azur",
    "94": "Corse"
  };

  Map<String, List<Prelevement>> regrouperPrelevementsParRegion(List<StationModel> stations) {
    Map<String, List<Prelevement>> prelevementsParRegion = {};

    for (var station in stations) {
      String codeReg = station.code_region;
      String? region = correspondanceRegions[codeReg];

      if (region != null) {
        prelevementsParRegion.putIfAbsent(region, () => []);
        prelevementsParRegion[region]!.addAll(station.prelevements);
      }
    }

    return prelevementsParRegion;
  }



  Map<String, Map<int, double>> calculerEvolutionIPRParRegion(List<StationModel> stations)
  {
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

    // Calcul de la moyenne par région et par année
    Map<String, Map<int, double>> moyennesParRegionEtAnnee = {};

    iprParRegionEtAnnee.forEach((region, dataParAnnee) {
      moyennesParRegionEtAnnee[region] = dataParAnnee.map((annee, valeurs) =>
          MapEntry(annee, valeurs.reduce((a, b) => a + b) / valeurs.length));
    });

    return moyennesParRegionEtAnnee;
  }











  Color getColorForValue(double value) {
    if (value == 1) return iprTresBon;
    if (value <= 2) return iprBon;
    if (value <= 3) return iprMoyen;
    if (value <= 4) return iprMauvais;
    return iprTresMauvais;
  }

  List<LineChartBarData> generateGradientLineBars(List<FlSpot> points) {
    List<LineChartBarData> lineBars = [];
    Set<FlSpot> drawnPoints = {}; // Ensemble pour suivre les points déjà dessinés

    // Initialiser la première paire de points pour commencer le tracé.
    if (points.isNotEmpty) {
      // On va parcourir les points successivement
      FlSpot previousPoint = points[0];
      drawnPoints.add(previousPoint); // Ajouter le premier point comme déjà dessiné

      for (int i = 1; i < points.length; i++) {
        FlSpot currentPoint = points[i];

        // Vérifier si le point courant a déjà été dessiné
        if (drawnPoints.contains(currentPoint)) {
          // Si le point existe déjà, ne pas ajouter de segment supplémentaire
          continue;
        }

        Color startColor = getColorForValue(previousPoint.y);
        Color endColor = getColorForValue(currentPoint.y);

        // Ajouter un segment entre le point précédent et le point courant
        lineBars.add(
          LineChartBarData(
            spots: [previousPoint, currentPoint], // Segment entre le point précédent et le point courant
            isCurved: true,
            barWidth: 4,
            gradient: LinearGradient(
              colors: [startColor, endColor], // Dégradé entre les couleurs
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: getColorForValue(spot.y),
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        );

        // Ajouter le point courant à l'ensemble des points dessinés
        drawnPoints.add(currentPoint);

        // Mettre à jour le point précédent pour la prochaine itération
        previousPoint = currentPoint;
      }
    }

    return lineBars;
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsState = ref.watch(stationProvider);

    return stationsState.when(
      data: (stations) {



        Map<String, Map<int, double>> evolutionIPR = calculerEvolutionIPRParRegion(stations);

        String regionSelectionnee = "Normandie";
        Map<int, double> donneesGraphique = evolutionIPR[regionSelectionnee] ?? {};

        // 📌 Étape 1: Filtrer les valeurs et moyenner si plusieurs mesures par an
        Map<int, List<double>> valeursParAnnee = {};
        donneesGraphique.forEach((annee, ipr) {
          valeursParAnnee.putIfAbsent(annee, () => []).add(ipr);
        });

        Map<int, double> donneesFiltrees = valeursParAnnee.map((annee, valeurs) =>
            MapEntry(annee, valeurs.reduce((a, b) => a + b) / valeurs.length));

        // 📌 Étape 2: Trier les données par année
        var sortedData = donneesFiltrees.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        // 📌 Étape 3: Transformer en points pour la courbe
        List<FlSpot> points = sortedData.map((entry)
        {
          return FlSpot(entry.key.toDouble(), double.parse((entry.value).toStringAsFixed(5)));
        }).toList();

        return Expanded(// ✅ Rend le graphe responsive
          child: LineChart(
            LineChartData(
              minY: 0.8, // ✅ Fixe l'axe Y entre 1 et 5
              maxY: 5.2,
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
              titlesData: FlTitlesData
                (
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

              lineBarsData: generateGradientLineBars(points),
              lineTouchData: LineTouchData(
                enabled: true,  // Active les interactions avec la ligne
                handleBuiltInTouches: true,  // Active la gestion des touches par défaut
                touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                  if (response == null || response.lineBarSpots == null) {
                    return;
                  }
                  if (event is FlTapUpEvent) {
                    // Gérer l'événement de tap si nécessaire
                  }
                },

              ),



            ),
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator()), // Indicateur de chargement
      error: (err, stack) => Center(child: Text("Erreur: $err")), // Gestion d'erreur
    );

  }
}