import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ResultWidget extends StatefulWidget {
  const ResultWidget({super.key});
  @override
  State<ResultWidget> createState() => _ResultWidgetState();

}




class _ResultWidgetState extends State<ResultWidget> {
  List<dynamic>? fishData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFishData();
  }

//  MediaQuery.of(context).size.height * .20 // 20% de la hauteur de l'écran
//  MediaQuery.of(context).size.width * .40 // 40% de la longueur de l'écran


  Future<void> fetchFishData() async {
    final url = Uri.parse('https://hubeau.eaufrance.fr/api/v1/etat_piscicole/indicateurs?code_commune=01249');
    //https://hubeau.eaufrance.fr/api/v1/etat_piscicole/observations?code_operation=93411
    final response = await http.get(url);

    if (response.statusCode == 200 || response.statusCode==206) {
      setState(() {
        fishData = jsonDecode(response.body)['data']; // Vérifie la structure JSON exacte
        isLoading = false;
      });
    } else {
      setState(() {
        fishData = null;
        isLoading = false;
      });
      print('Erreur : ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Indicateur de chargement
          : fishData == null
          ? const Center(child: Text("Erreur lors du chargement des données"))
          : ListView.builder(
        itemCount: fishData!.length,
        itemBuilder: (context, index) {
          var fish = fishData![index];
          print("Fish data = ${fishData}");
          return ListTile(
            title: Text(fish['code_operation'] ?? 'Nom inconnu'),
            subtitle: Text('Valeur : ${fish['code_operation'] ?? 'N/A'}'),
          );
        },
      ),
    );
  }
}