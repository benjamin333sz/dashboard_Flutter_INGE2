import 'package:dashboard/map/french_marker_map.dart';
import 'package:dashboard/data/coordonees_data.dart';
import 'package:dashboard/widgets/result_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../map/french_marker_map.dart';
import '../widgets/research_widget.dart';
import '../widgets/title_widget.dart';



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
                  Expanded(flex: 10, child: FrenchRegionsMap()),
                ],
              ),
            );
          },
        ),
      ),
    );

  }
}