import 'package:dashboard/map/OLD_french_marker_map.dart';
import 'package:flutter/material.dart';
import '../widgets/affichage_graphe.dart';
import '../map/french_interactive_map.dart';
import '../const/constant.dart';

class MainScreen extends StatelessWidget{
  const MainScreen({super.key});


  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(
        title: Text("Évolution de l'Indice Poisson Rivière en France Métropolitaine", style: TextStyle(fontSize: 32),),
        centerTitle: true,
        backgroundColor: backgroundColor,
      ),
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
                  Expanded(child: FrenchInteractiveMap()),
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