import 'package:flutter/material.dart';
import '../data/result_data.dart';
import '../model/result_model.dart';

class ResultWidget extends StatefulWidget {
  const ResultWidget({super.key});

  @override
  State<ResultWidget> createState() => _ResultWidgetState();
}

class _ResultWidgetState extends State<ResultWidget> {
  List<ResultModel>? fishData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFishData();
  }

  Future<void> fetchFishData() async {
    final data = await ResultData.fetchFishData();
    setState(() {
      fishData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : fishData == null || fishData!.isEmpty
          ? const Center(child: Text("Erreur lors du chargement des données"))
          : ListView.builder(
        itemCount: fishData!.length,
        itemBuilder: (context, index) {
          var fish = fishData![index];
          return ListTile(
            title: Text(fish.codeOperation ?? 'Nom inconnu'),
            subtitle: Text('Valeur : ${fish.codeOperation ?? 'N/A'}'),
          );
        },
      ),
    );
  }
}
