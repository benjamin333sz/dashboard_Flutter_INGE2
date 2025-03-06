import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// RECUPERER CODE SUR GITHUB: git pull

void main() {
  runApp(const MyApp());
  // test de push
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Données Poissons',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'État piscicole des rivières'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic>? fishData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFishData();
  }

  Future<void> fetchFishData() async {
    final url = Uri.parse('https://hubeau.eaufrance.fr/api/v1/etat_piscicole/indicateurs?code_operation=92843');
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
      appBar: AppBar(title: Text(widget.title)),
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
