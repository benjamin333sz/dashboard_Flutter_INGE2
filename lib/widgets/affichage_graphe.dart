import 'package:flutter/material.dart';
import '../legend_graph/legende_graph_france.dart';
import '../legend_graph/legende_graph_station.dart';
import '../legend_graph/legende_graph_region.dart';

class AffichageGraphe extends StatelessWidget {
  const AffichageGraphe({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                children: [
                  ///Flexible(flex: 4, child: LegendeGraphFrance()), // Adjusted flex value
                  Flexible(flex: 4, child: LegendeGraphRegion()),
                  Flexible(flex: 4, child: LegendeGraphStation()), // Adjusted flex value

                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
