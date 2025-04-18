import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/OLD_result_data.dart';
import '../model/OLD_prelevement_model.dart';

import '../model/station_model.dart';
import '../data/station_data.dart';





class StationNotifier extends StateNotifier<AsyncValue<List<StationModel>>> {
  final StationData _stationData;

  StationNotifier(this._stationData) : super(const AsyncValue.loading()) {
    fetchStationsAndPrelevements();
  }

  Future<void> fetchStationsAndPrelevements() async {
    try {
      // ⚡ Appels parallèles
      final results = await Future.wait([
        _stationData.fetchStationsOnly(),  // Utilise _stationData pour appeler la méthode
        _stationData.fetchPrelevementsWithCache(),  // Utilise _stationData ici aussi
      ]);

      final nofiltrestations = results[0] as List<StationModel>;
      final prelevements = results[1] as List<Prelevement>;

      // 🚫 Filtrage des stations fantômes
      final stations = nofiltrestations.where((station) =>
      station.code_station != null &&
          station.code_station!.trim().isNotEmpty &&
          station.libelle_station != null &&
          station.libelle_station!.trim().isNotEmpty
      ).toList();


      // 🔁 Association des prélèvements avec les stations
      final prelevementsParStation = <String, List<Prelevement>>{};
      for (var prelevement in prelevements) {
        prelevementsParStation.putIfAbsent(prelevement.code_station, () => []).add(prelevement);
      }

      for (var station in stations) {
        station.prelevements = prelevementsParStation[station.code_station] ?? [];
      }

      state = AsyncValue.data(stations);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Provider global
final stationProvider = StateNotifierProvider<StationNotifier, AsyncValue<List<StationModel>>>(
      (ref) => StationNotifier(StationData()),
);








