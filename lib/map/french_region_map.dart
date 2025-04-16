import 'package:dashboard/widgets/region_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/region_provider.dart';
import './point_region.dart';

class FrenchRegionMaps extends ConsumerStatefulWidget {
  const FrenchRegionMaps({super.key});

  @override
  _FrenchRegionMapsState createState() => _FrenchRegionMapsState();
}

class _FrenchRegionMapsState extends ConsumerState<FrenchRegionMaps> {
  final MapController _mapController = MapController();

  final List<Map<String, dynamic>> _regions = [
    {'name': 'Île-de-France', 'points': IledeFrancePoint, 'color': Colors.blue},
    {'name': 'Centre-Val de Loire', 'points': CentreValdeLoirePoint, 'color': Colors.red},
    {'name': 'Bourgogne-Franche-Comté', 'points': BourgogneFrancheComtePoint, 'color': Colors.green},
    {'name': 'Normandie', 'points': NormandiePoint, 'color': Colors.orange},
    {'name': 'Hauts-de-France', 'points': HautsdeFrancePoint, 'color': Colors.purple},
    {'name': 'Grand Est', 'points': GrandEstPoint, 'color': Colors.teal},
    {'name': 'Pays de la Loire', 'points': PaysdelaLoirePoint, 'color': Colors.pink},
    {'name': 'Bretagne', 'points': BretagnePoint, 'color': Colors.indigo},
    {'name': 'Nouvelle-Aquitaine', 'points': NouvelleAquitainePoint, 'color': Colors.amber},
    {'name': 'Occitanie', 'points': OccitaniePoint, 'color': Colors.cyan},
    {'name': 'Auvergne-Rhône-Alpes', 'points': AuvergneRhoneAlpesPoint, 'color': Colors.lime},
    {'name': "Provence-Alpes-Côte d'Azur", 'points': ProvenceAlpesCotedAzurPoint, 'color': Colors.deepOrange},
    {'name': 'Corse', 'points': CorsePoint, 'color': Colors.brown},
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
    ref.read(selectedRegionProvider.notifier).state = regionName;
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
        ref.read(selectedRegionProvider.notifier).state = region['name'];
        return;
      }
    }
    ref.read(selectedRegionProvider.notifier).state = null;
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

  @override
  Widget build(BuildContext context) {
    final selectedRegion = ref.watch(selectedRegionProvider);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(46.603354, 1.888334),
            initialZoom: 5.5,
            onTap: (_, LatLng point) => _handleMapTap(point),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            PolygonLayer(
              polygons: _regions.map((region) {
                final bool isSelected = selectedRegion == region['name'];
                return Polygon(
                  points: region['points'],
                  color: region['color'].withOpacity(isSelected ? 0.7 : 0.3),
                  borderColor: region['color'],
                  borderStrokeWidth: 2,
                );
              }).toList(),
            ),
          ],
        ),
        if (false)
          (Positioned(
            top: 20,
            left: 20,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: FilterWidget(
                onRegionSelected: _zoomToRegion,
              ),
            ),
          )),
      ],
    );

  }
}



