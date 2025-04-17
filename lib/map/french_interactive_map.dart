import 'package:dashboard/const/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/Data_provider.dart';
import '../providers/region_provider.dart';
import '../providers/station_provider.dart';
import '../calcul/point_region.dart';

class FrenchInteractiveMap extends ConsumerStatefulWidget {
  const FrenchInteractiveMap({super.key});

  @override
  _FrenchInteractiveMapState createState() => _FrenchInteractiveMapState();
}

class _FrenchInteractiveMapState extends ConsumerState<FrenchInteractiveMap> {
  final MapController _mapController = MapController();

  final List<Map<String, dynamic>> _regions = [
    {'name': 'Île-de-France','code':"11", 'points': IledeFrancePoint, 'color': Colors.blue},
    {'name': 'Centre-Val de Loire','code':"24", 'points': CentreValdeLoirePoint, 'color': Colors.red},
    {'name': 'Bourgogne-Franche-Comté','code':"27", 'points': BourgogneFrancheComtePoint, 'color': Colors.green},
    {'name': 'Normandie','code':"28", 'points': NormandiePoint, 'color': Colors.orange},
    {'name': 'Hauts-de-France','code':"32", 'points': HautsdeFrancePoint, 'color': Colors.purple},
    {'name': 'Grand Est','code':"44", 'points': GrandEstPoint, 'color': Colors.teal},
    {'name': 'Pays de la Loire','code':"52", 'points': PaysdelaLoirePoint, 'color': Colors.pink},
    {'name': 'Bretagne','code':"53", 'points': BretagnePoint, 'color': Colors.indigo},
    {'name': 'Nouvelle-Aquitaine','code':"75", 'points': NouvelleAquitainePoint, 'color': Colors.amber},
    {'name': 'Occitanie','code':"76", 'points': OccitaniePoint, 'color': Colors.cyan},
    {'name': 'Auvergne-Rhône-Alpes','code':"84", 'points': AuvergneRhoneAlpesPoint, 'color': Colors.lime},
    {'name': "Provence-Alpes-Côte d'Azur",'code':"93", 'points': ProvenceAlpesCotedAzurPoint, 'color': Colors.deepOrange},
    {'name': 'Corse','code':"94", 'points': CorsePoint, 'color': Colors.brown},
  ];

  void _zoomToRegion(String? regionName) {
    if (regionName == null || regionName == "France") {
      _mapController.move(const LatLng(46.603354, 1.888334), 5.0);
      ref.read(selectedRegionProvider.notifier).state = null;
      return;
    }
    final region = _regions.firstWhere((r) => r['name'] == regionName);
    final points = region['points'] as List<LatLng>;
    final center = _computePolygonCenter(points);

    _mapController.move(center, 7);
    ref.read(selectedRegionProvider.notifier).state = {
      'name': region['name'],
      'code': region['code']
    };

  }

  LatLng _computePolygonCenter(List<LatLng> points) {
    double lat = 0, lng = 0;
    for (var point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

  void _handleMapTap(LatLng point) {
    for (var region in _regions) {
      if (_isPointInPolygon(point, region['points'])) {
        _zoomToRegion(region['name']);
        return;
      }
    }
    _zoomToRegion(null);
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    double x = point.latitude;
    double y = point.longitude;

    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      double xi = polygon[i].latitude, yi = polygon[i].longitude;
      double xj = polygon[j].latitude, yj = polygon[j].longitude;

      bool intersect = ((yi > y) != (yj > y)) &&
          (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  Color getMarkerColor(String iprCodeClasse) {
    switch (iprCodeClasse) {
      case '1':
        return iprTresBon;
      case '2':
        return iprBon;
      case '3':
        return iprMoyen;
      case '4':
        return iprMauvais;
      case '5':
        return iprTresMauvais;
      default:
        return iprDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedRegion = ref.watch(selectedRegionProvider);
    final stationsState = ref.watch(stationProvider);

    return stationsState.when(
      data: (stations) {
        // FILTRE
        final filteredStations = stations.where((station) {
          final selected = selectedRegion;

          final hasValidIpr = station.prelevements.any(
                (prelevement) => prelevement.ipr_code_classe.trim().isNotEmpty,
          );
          /*print('Selected region code: ${selectedRegion?['code']}');
          print('Station region code: ${station.code_region}');
          print('Station latitude: ${station.latitude},${station.longitude}');*/
          return station.prelevements.isNotEmpty &&
              station.libelle_station.trim().isNotEmpty &&
              selected != null &&
              selected['code'] != null &&
              station.code_region == selected['code']&&
              hasValidIpr;
        }).toList();



        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(46.603354, 1.888334),
            initialZoom: 5.5,
            onTap: (_, point) => _handleMapTap(point),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),

            if (selectedRegion == null || selectedRegion == "France")
              PolygonLayer(
                polygons: _regions.map((region) {
                  final isSelected = selectedRegion == region['name'];
                  return Polygon(
                    points: region['points'],
                    color: region['color'].withOpacity(isSelected ? 0.7 : 0.2), // plus clair si pas sélectionné
                    borderColor: region['color'],
                    borderStrokeWidth: isSelected ? 3 : 1, // plus épais si sélectionné
                  );
                }).toList(),
              ),


            if (selectedRegion != null && selectedRegion != "France")
              MarkerLayer(
                markers: filteredStations.map((station) =>
                    Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(station.latitude, station.longitude),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(selectedStationProvider.notifier).state = station;
                    },
                    child: Icon(
                      Icons.location_pin,
                      color: getMarkerColor(station.prelevements.first.ipr_code_classe),
                      size: 40,
                    ),
                  ),
                )).toList(),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Erreur : $err")),
    );
  }
}
