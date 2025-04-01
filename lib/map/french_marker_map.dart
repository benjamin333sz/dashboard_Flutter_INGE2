import 'package:dashboard/const/constant.dart';
import 'package:flutter/material.dart';
import '../model/station_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fish_provider.dart';
import 'package:intl/intl.dart';

const LatLng currentLocation = LatLng(48.859651, 2.341497);


class FrenchMarkerMap extends ConsumerWidget {

  double calculerMoyenneIPRParAnnee(List<Prelevement> prelevements, List<int> annees) {
    List<double> valeursIPR = prelevements
        .where((p) => annees.contains(p.date_operation.year)) // Filtre par année
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
  Map<String, double> calculerMoyenneParRegionAvecFiltre(List<StationModel> stations, List<int> annees) {
    Map<String, List<Prelevement>> prelevementsParRegion = regrouperPrelevementsParRegion(stations);

    return prelevementsParRegion.map((region, prelevements) =>
        MapEntry(region, calculerMoyenneIPRParAnnee(prelevements, annees))
    );
  }





  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsState = ref.watch(stationProvider);
    List<int> anneesFiltre = [2022, 2023];
    List<int> anneeBase=[2024];

    stationsState.when(
      data: (stations) {
        final moyennesParRegion = calculerMoyenneParRegionAvecFiltre(stations,anneeBase);

        moyennesParRegion.forEach((region, moyenneIPR) {
          print("Région: $region - Moyenne IPR: ${moyenneIPR.toStringAsFixed(5)}");
        });
      },
      loading: () => print("Chargement des données..."),
      error: (err, stack) => print("Erreur: $err"),
    );


    Color getMarkerColor(String iprCodeClasse) {
      switch (iprCodeClasse) {
        case '1':
          return iprTresBon; // Très bon état
        case '2':
          return iprBon; // Bon état
        case '3':
          return iprMoyen; // Moyen état
        case '4':
          return iprMauvais; // Mauvais état
        case '5':
          return iprTresMauvais; // Très mauvais état
        default:
          return iprDefault; // Inconnu
      }
    }


    return

      Scaffold(
        body: stationsState.when(
          data: (stations) {
            return FlutterMap(
              options: MapOptions(
                initialCenter: currentLocation, // Coordonnées de Paris
                initialZoom: 13.0,
                onTap: (_, __) => {},
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",

                ),



                MarkerLayer(
                  markers: stations
                      .where((station) =>
                        station.prelevements.isNotEmpty &&
                        station.libelle_station.trim().isNotEmpty)

                      .map((station) => Marker(

                      width: 80.0,
                      height: 80.0,
                      point: LatLng(station.latitude, station.longitude),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(station.libelle_station),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Card(
                                      child: ExpansionTile(
                                      title: Text(station.libelle_station),
                                      subtitle: Text('Prélèvements: ${station.prelevements.length}'),
                                      children: station.prelevements.map((prelevement) {
                                        return ListTile(
                                          title: Text('📅 Date: ${prelevement.date_operation.toString()}'),
                                          subtitle: Text('📊 Classe: ${prelevement.ipr_code_classe} - ${prelevement.ipr_libelle_classe}'),
                                        );
                                      }).toList(),
                                    ),
                                  )
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Fermer"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Icon(Icons.location_pin, color: getMarkerColor(station.prelevements.first.ipr_code_classe), size: 40),
                    ),
                )).toList(),

                ),


                 ]

                );
          }, loading: () => Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text("Erreur : $err")),
        ),
      );
  }
}
