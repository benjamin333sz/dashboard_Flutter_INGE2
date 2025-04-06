import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'grapheIPR.dart';

class LegendeGraphRegion extends StatelessWidget{
  const LegendeGraphRegion({super.key});

  @override
  Widget build(BuildContext context){
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Text(
              "Dégradation de l'Indice Poisson Rivière (IPR) ",
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,

            ),
          ),
          GraphIprRegion(),
          SizedBox(height: 50),
          Expanded(
            child: Text("Légende : 1 : Très bon état, 2 : Bon état, 3 : moyen état, 4 : mauvais état, 5 : Très mauvais état"),)

        ],
      ),
    );
  }
}