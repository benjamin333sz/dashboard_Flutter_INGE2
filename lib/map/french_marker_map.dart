import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fish_provider.dart';

const LatLng currentLocation = LatLng(48.859651, 2.341497);


class FrenchMarkerMap extends ConsumerWidget {


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsState = ref.watch(stationProvider);
    return

      Scaffold(
        body: stationsState.when(
          data: (stations) {
            return FlutterMap(
              options: MapOptions(
                initialCenter: currentLocation, // Coordonnées de Paris
                initialZoom: 13.0,
                onTap: (_, __) => Navigator.pop(context),
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",

                ),
                MarkerLayer(
                  markers: stations.map((station) => Marker(

                      width: 80.0,
                      height: 80.0,
                      point: LatLng(station.latitude, station.longitude),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(station.libelleStation),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("📍 Région : ${station.libelleRegion}"),
                                Text("📌 Coordonnées : ${station.latitude}, ${station.longitude}"),
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
                      child: Icon(Icons.location_pin, color: Colors.green, size: 40),
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
