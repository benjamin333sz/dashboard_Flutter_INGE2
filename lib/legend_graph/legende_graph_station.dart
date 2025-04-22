import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../graph/graphStation.dart';
import '../providers/region_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/station_provider.dart';

class LegendeGraphStation extends ConsumerWidget {
  const LegendeGraphStation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRegion = ref.watch(selectedRegionProvider);
    final selectedStation = ref.watch(selectedStationProvider);

    // Si aucune région ou région France → reset et cacher
    if (selectedRegion == null || selectedRegion['nom'] == 'France') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedStationProvider.notifier).state = null;
      });
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Dégradation de l'IPR de la station",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),

          // 🌟 Affichage du libellé si dispo
          if (selectedStation != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "Station : ${selectedStation.libelle_station}",
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),

          const Flexible(
            flex: 3,
            child: GraphIprStation(),
          ),

          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Légende : 1 : Très bon état, 2 : Bon état, 3 : moyen état, 4 : mauvais état, 5 : Très mauvais état",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
