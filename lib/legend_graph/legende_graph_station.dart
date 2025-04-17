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

    if (selectedRegion == null || selectedRegion['nom'] == 'France') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedStationProvider.notifier).state = null;
      });


      return const SizedBox.shrink(); // Widget vide
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
          const Flexible(
            flex: 3,
            child: GraphIprStation(), // affichera la bonne station
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
