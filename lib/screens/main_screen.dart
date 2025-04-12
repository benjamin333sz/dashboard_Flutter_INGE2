import 'package:flutter/material.dart';
import '../widgets/affichage_graphe.dart';
import '../map/french_marker_map.dart';
import '../map/french_region_map.dart';
class MainScreen extends StatelessWidget{
  const MainScreen({super.key});


  @override
  Widget build(BuildContext context){

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double horizontalPadding = constraints.maxWidth * 0.05;
            double verticalPadding = constraints.maxHeight * 0.02;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Row(
                children: [
                  //Expanded(flex: 1, child: TitleWidget()),
                  //Expanded(flex: 2, child: ResearchWidget()),
                  Expanded(child: FrenchRegionMaps()),
                  //Expanded( child: LegendeGraphRegion()),
                  Expanded( child: AffichageGraphe()),
                ],
              ),
            );
          },
        ),
      ),
    );

  }
}