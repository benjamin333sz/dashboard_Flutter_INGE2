import 'package:dashboard/graph/grapheFranceIPR.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/station_model.dart';
import '../providers/fish_provider.dart';
import '../graph/grapheRegionIPR.dart'; // Pour accéder aux fonctions
import '../calcul/France.dart';
import '../calcul/region.dart';


final selectedRegionProvider = StateProvider<String?>((ref) => null);



final evolutionIprProviderRegion = Provider<Map<String, Map<int, double>>>((ref) {
  final stationsAsync = ref.watch(stationProvider);

  final stations = stationsAsync.maybeWhen(
    data: (data) => data is List<StationModel> ? data : <StationModel>[],
    orElse: () => <StationModel>[],
  );


  final graphe = GraphIprRegion();
  final rawData = graphe.calculerEvolutionIPRParRegion(stations);

  final evolution = <String, Map<int, double>>{};
  rawData.forEach((region, values) {
    evolution[region] = values.map((annee, ipr) =>
        MapEntry(annee, ipr));
  });

  return evolution;
});





final evolutionIprFranceProvider = Provider<Map<int, double>>((ref) {
  final stationsAsync = ref.watch(stationProvider);

  final stations = stationsAsync.maybeWhen(
    data: (data) => data is List<StationModel> ? data : <StationModel>[],
    orElse: () => <StationModel>[],
  );

  return calculerEvolutionIPRFrance(stations);
});

