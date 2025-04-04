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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsState = ref.watch(stationProvider);


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
