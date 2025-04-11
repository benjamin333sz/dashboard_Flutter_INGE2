import 'package:flutter/material.dart';

class FranceButtonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 40), // Hauteur réduite
      ),
      child: Text("France"),
    );
  }
}

class RegionsButtonWidget extends StatelessWidget {
  final List<String> regions = [
    "Île-de-France", "Auvergne-Rhône-Alpes", "Bretagne",
    "Normandie", "Occitanie", "Provence-Alpes-Côte d'Azur",
    "Hauts-de-France", "Grand Est", "Pays de la Loire",
    "Centre-Val de Loire", "Bourgogne-Franche-Comté", "Nouvelle-Aquitaine",
    "Corse"
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Tri par région",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4), // Espacement réduit
        ...regions.map((region) => Padding(
          padding: const EdgeInsets.only(bottom: 4.0), // Moins d'espace entre les boutons
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 40), // Hauteur réduite
            ),
            child: Text(region),
          ),
        )).toList(),
      ],
    );
  }
}

class FilterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      color: Colors.white,
      padding: EdgeInsets.all(8), // Moins de padding global
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FranceButtonWidget(),
          SizedBox(height: 8),
          Divider(),
          SizedBox(height: 8),
          RegionsButtonWidget(),
        ],
      ),
    );
  }
}
