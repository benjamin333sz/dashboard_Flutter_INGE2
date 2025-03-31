import "package:dio/dio.dart" as dio_http;
import '../model/station_model.dart';

class StationData {
  final String stationUrl = 'https://hubeau.eaufrance.fr/api/v1/etat_piscicole/stations';
  final String prelevementUrl = 'https://hubeau.eaufrance.fr/api/v1/etat_piscicole/indicateurs';

  final dio_http.Dio dio = dio_http.Dio();

  Future<List<Prelevement>> fetchAllPrelevements() async {
    print('🔍 Début de la récupération des prélèvements...allPrelevement');
    List<Prelevement> allPrelevements = [];
    int page = 1;
    int limit = 10000; // Adapte cette valeur selon la doc de l'API
    bool hasMore = true;

    while (hasMore) {
      try {
        print('📡 Requête API allPrelevement- Page $page');
        final response = await dio.get('$prelevementUrl?page=$page&size=$limit');//&date_operation_min=2024-01-01

        if (response.statusCode != 200 && response.statusCode != 206) {
          print('❌ Erreur API allPrelevement - Code : ${response.statusCode}');
          break;
        }

        List<dynamic> data = response.data['data'];
        print('✅ ${data.length} prélèvements récupérés sur la page $page');
        if (data.isEmpty) {
          hasMore = false; // On arrête si plus de résultats
        } else {
          allPrelevements.addAll(data.map((json) => Prelevement.fromJson(json)));
          page++; // On passe à la page suivante
        }
      } catch (e) {

        print('❌ allPrelevement Exception lors de la récupération des prélèvements : $e');

        break;
      }
    }

    print('Total prélèvements récupérés : ${allPrelevements.length}');
    return allPrelevements;
  }












  Future<List<StationModel>> fetchStations() async {
    print('🔍 Début de la récupération des stations...');

    List<StationModel> allStations = [];
    int page = 1;
    int limit = 16000;
    bool hasMore = true;

    while (hasMore) {
      try {
        print('📡 Requête API stations - Page $page');
        final response = await dio.get('$stationUrl?page=$page&size=$limit');

        if (response.statusCode != 200 && response.statusCode != 206) {
          print('❌ Erreur API stations - Code : ${response.statusCode}');
          break;
        }

        List<dynamic> data = response.data['data'];
        print('✅ ${data.length} stations récupérées sur la page $page');

        if (data.isEmpty) {
          hasMore = false;
        } else {
          allStations.addAll(data.map((json) => StationModel.fromJson(json)));
          page++;
        }
      } catch (e) {
        print('❌ Exception lors de la récupération des stations : $e');
        break;
      }
    }

    print('🎯 Total stations récupérées : ${allStations.length}');


    print('📡 Lancement de la récupération des prélèvements...');
    List<Prelevement> prelevements = await fetchAllPrelevements();

    Map<String, List<Prelevement>> prelevementsParStation = {};
    for (var prelevement in prelevements) {
      String stationCode = prelevement.code_station;
      prelevementsParStation.putIfAbsent(stationCode, () => []).add(prelevement);
      //print('📌 Prélevement: Station=${prelevement.libelle_station}, Code=${prelevement.code_station}');

    }


    print('🛠️ Association des prélèvements aux stations...');
    for (var station in allStations) {
      //print(prelevementsParStation[station.code_station]);
      station.prelevements = (prelevementsParStation[station.code_station] ?? []).toList();
      //print("station.prelevements: ${station.prelevements}, station.code_station: ${station.code_station}, ");
    }
    /*for (var station in allStations.take(10)) { // Vérifier seulement 10 stations pour éviter trop de logs
      print('📍 Station: ${station.libelle_station} (Code: ${station.code_station})');
      print('   🔍 Nombre de prélèvements: ${station.prelevements.length}');

      for (var prelevement in station.prelevements.take(3)) { // Affiche 3 prélèvements max par station
        print('   ✅ ${prelevement.date_operation} | Classe: ${prelevement.ipr_code_classe}');
      }
    }*/



    print('🎯 Finalisation : ${allStations.length} stations avec prélèvements');

    for (var station in allStations) {
      station.prelevements = prelevementsParStation[station.code_station] ?? [];
      //print('📍 Station: ${station.libelle_station} (Code: ${station.code_station}) Nombre de prélèvements associés: ${station.prelevements.length}');

    }

    return allStations;
  }



}
