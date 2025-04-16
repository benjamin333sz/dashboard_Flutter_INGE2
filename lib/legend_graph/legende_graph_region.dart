import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/region_provider.dart';
import '../graph/grapheRegionIPR.dart';
import '../graph/grapheFranceIPR.dart';

class LegendeGraphRegion extends ConsumerStatefulWidget{
  const LegendeGraphRegion({super.key});

  @override
  ConsumerState<LegendeGraphRegion> createState() => _LegendeGraphRegionState();


}

class _LegendeGraphRegionState extends ConsumerState<LegendeGraphRegion> {



  @override
  Widget build(BuildContext context) {

    final selectedRegion = ref.watch(selectedRegionProvider);
    final isFrance = selectedRegion == null || selectedRegion == "France";
    final regionLabel = selectedRegion ?? "France";

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(

              "Dégradation de l'IPR en ${isFrance ? "France" : regionLabel}",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),//l'Indice Poisson Rivière


          ),
          Flexible(
            flex: 3,
            child: isFrance
                  ? GraphIprFrance()
                  : GraphIprRegion(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
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
