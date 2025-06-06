import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../graph/grapheFranceIPR.dart';

class LegendeGraphFrance extends StatelessWidget {
  const LegendeGraphFrance({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Dégradation de l'Indice Poisson Rivière (IPR) au niveau National ",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          Flexible(
            flex: 3, // Ajoutez un flex pour donner plus d’espace au graphique
            child: GraphIprFrance(),
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
