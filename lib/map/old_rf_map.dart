import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class FrenchRegionsMap extends StatelessWidget {
  const FrenchRegionsMap({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(46.603354, 1.888334), // Centre de la France
          initialZoom: 6.0,
        ),
        children: [
          // Ajouter la couche de tuiles
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",

          ),


          PolygonLayer(
            polygons: [
              Polygon(
                  points: [
                    LatLng(48.8566, 2.3522), // Paris
                    LatLng(48.7, 2.1), // Point approximatif sud-ouest IDF
                    LatLng(49.0, 2.5), // Point approximatif nord IDF
                    LatLng(48.9, 3.1), // Point approximatif est IDF
                  ],
                  color: Colors.blue.withOpacity(0.4), // Couleur bleue remplie
                  borderColor: Colors.blue,
                  borderStrokeWidth: 2.0,


              ),
              Polygon(
                points: [
                  LatLng(50.9, 1.6), // Paris
                  LatLng(45.7, 1.1), // Point approximatif sud-ouest IDF
                  LatLng(44.0, 2.5), // Point approximatif nord IDF
                  LatLng(44.9, 3.1), // Point approximatif est IDF
                ],
                color: Colors.yellow.withOpacity(0.4), // Couleur bleue remplie
                borderColor: Colors.yellow,
                borderStrokeWidth: 2.0,


              ),


            ],
          ),
        ],

    );
  }
}
