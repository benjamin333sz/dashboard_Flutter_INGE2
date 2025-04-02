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
      List<int> annees) {
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

  Map<String, List<Prelevement>> regrouperPrelevementsParRegion(
      List<StationModel> stations) {
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

  Map<String, double> calculerMoyenneParRegionAvecFiltre(
      List<StationModel> stations, List<int> annees) {
    Map<String,
        List<
            Prelevement>> prelevementsParRegion = regrouperPrelevementsParRegion(
        stations);

    return prelevementsParRegion.map((region, prelevements) =>
        MapEntry(region, calculerMoyenneIPRParAnnee(prelevements, annees))
    );
  }

  Map<String, Map<int, double>> calculerEvolutionIPRParRegion(
      List<StationModel> stations) {
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


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsState = ref.watch(stationProvider);

    return stationsState.when(
      data: (stations) {
        List<int> anneesFiltre = [2022, 2023];
        List<int> anneeBase = [2024];

        final moyennesParRegion = calculerMoyenneParRegionAvecFiltre(stations, anneeBase);
        moyennesParRegion.forEach((region, moyenneIPR) {
          //print("Région: $region - Moyenne IPR: ${moyenneIPR.toStringAsFixed(5)}");
        });

        Map<String, Map<int, double>> evolutionIPR = calculerEvolutionIPRParRegion(stations);

        String regionSelectionnee = "Grand Est";
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
        List<FlSpot> points = sortedData.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value);
        }).toList();

        return Scaffold(
          appBar: AppBar(title: Text("Évolution de l'IPR")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Évolution de l'IPR pour $regionSelectionnee",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // ✅ Rend le graphe responsive
                Expanded(
                  child: LineChart(
                    LineChartData(
                      minY: 1, // ✅ Fixe l'axe Y entre 1 et 5
                      maxY: 5,

                      gridData: FlGridData(show: false),
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
                        LineChartBarData(
                          spots: points,
                          isCurved: true, // ✅ Courbe plus fluide
                          barWidth: 3,
                          color: Colors.blue,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: Colors.blue,
                                strokeWidth: 1,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(show: false),

                          // ✅ Arrondir les valeurs affichées
                          showingIndicators: List.generate(points.length, (i) => i),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      },
      loading: () => Center(child: CircularProgressIndicator()), // Indicateur de chargement
      error: (err, stack) => Center(child: Text("Erreur: $err")), // Gestion d'erreur
    );

  }
}