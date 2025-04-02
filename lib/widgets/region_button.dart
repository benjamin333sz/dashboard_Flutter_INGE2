//créer un widget, avec bouttons, un qui permettrait d'afficher toutes les staions, et plusieurs
//autres permettant de trier par régions
//biens séparer le gtros boutton France, de la partie avec les bouttons région


import 'package:flutter/material.dart';

class FilterWidget extends StatelessWidget {
  final List<String> regions = [
    "Île-de-France", "Auvergne-Rhône-Alpes", "Bretagne",
    "Normandie", "Occitanie", "Provence-Alpes-Côte d'Azur",
    "Hauts-de-France", "Grand Est", "Pays de la Loire",
    "Centre-Val de Loire", "Bourgogne-Franche-Comté", "Nouvelle-Aquitaine",
    "Corse"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () {},
            child: Text("France"),
          ),
          SizedBox(height: 10),
          ...regions.map((region) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ElevatedButton(
              onPressed: () {},
              child: Text(region),
            ),
          ))
        ],
      ),
    );
  }
}
