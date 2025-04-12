import 'package:flutter/material.dart';

// Mettez à jour FranceButtonWidget
class FranceButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const FranceButtonWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 34)),
      child: Text("France"),
    );
  }
}

class RegionsButtonWidget extends StatelessWidget {
  // 1. Déclarez la liste comme `static const` (constante à la compilation)
  static const List<String> regions = [
    "Île-de-France", "Auvergne-Rhône-Alpes", "Bretagne",
    "Normandie", "Occitanie", "Provence-Alpes-Côte d'Azur",
    "Hauts-de-France", "Grand Est", "Pays de la Loire",
    "Centre-Val de Loire", "Bourgogne-Franche-Comté",
    "Nouvelle-Aquitaine", "Corse"
  ];

  final Function(String?) onRegionSelected;

  // 2. Gardez le constructeur `const` (maintenant valide)
  const RegionsButtonWidget({
    super.key,
    required this.onRegionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Tri par région", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        ...RegionsButtonWidget.regions.map((region) => Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: ElevatedButton(
            onPressed: () => onRegionSelected(region),
            style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 34)),
            child: Text(region),
          ),
        )).toList(),
      ],
    );
  }
}

class FilterWidget extends StatelessWidget {
  final Function(String?) onRegionSelected; // Callback pour la sélection

  const FilterWidget({super.key, required this.onRegionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      color: Colors.white,
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FranceButtonWidget(onPressed: () => onRegionSelected("France")),
          SizedBox(height: 8),
          Divider(),
          SizedBox(height: 8),
          RegionsButtonWidget(onRegionSelected: onRegionSelected),
        ],
      ),
    );
  }
}