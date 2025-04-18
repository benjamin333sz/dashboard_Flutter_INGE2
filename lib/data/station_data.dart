import 'package:dio/dio.dart' as dio_http;
import 'package:hive_flutter/hive_flutter.dart';
import '../model/station_model.dart';
import '../model/OLD_prelevement_model.dart';

class StationData {
  final String stationUrl = 'https://hubeau.eaufrance.fr/api/v1/etat_piscicole/stations';
  final String prelevementUrl = 'https://hubeau.eaufrance.fr/api/v1/etat_piscicole/indicateurs';
  final dio_http.Dio dio = dio_http.Dio();

  static const Duration _cacheTTL = Duration(hours: 1);

  /// 🔄 Récupère uniquement les stations (sans prélèvements)
  Future<List<StationModel>> fetchStationsOnly() async {
    final cached = await getCachedStations();
    if (cached != null) return cached;

    print('🔍 Début de la récupération des stations depuis l’API...');
    List<StationModel> allStations = [];
    int page = 1;
    int limit = 16000;
    bool hasMore = true;

    while (hasMore) {
      try {
        print('📡 Requête API stations - Page $page');
        final response = await dio.get('$stationUrl?page=$page&size=$limit');

        if (response.statusCode != 200 && response.statusCode != 206) break;

        List<dynamic> data = response.data['data'];
        if (data.isEmpty) {
          hasMore = false;
        } else {
          allStations.addAll(data.map((json) => StationModel.fromJson(json)));
          page++;
        }
      } catch (e) {
        print('❌ Erreur récupération stations : $e');
        break;
      }
    }

    print('🎯 Total stations récupérées : ${allStations.length}');
    await cacheStations(allStations);
    return allStations;
  }

  Future<List<Prelevement>> fetchAllPrelevementsSimple({int limit = 10000}) async {
    List<Prelevement> all = [];
    int page = 1;
    bool hasMore = true;

    while (hasMore) {
      try {
        final response = await dio.get('$prelevementUrl?page=$page&size=$limit');
        if (response.statusCode != 200 && response.statusCode != 206) break;

        final List<dynamic> data = response.data['data'];
        if (data.isEmpty) {
          hasMore = false;
        } else {
          all.addAll(data.map((e) => Prelevement.fromJson(e)));
          page++;
        }
      } catch (e) {
        print('❌ Erreur page $page: $e');
        break;
      }
    }

    print('🎯 Total prélèvements récupérés : ${all.length}');
    return all;
  }

  /// 💾 Caching des stations avec Hive
  Future<void> cacheStations(List<StationModel> stations) async {
    final box = Hive.box('stationsBox');
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await box.put('data', stations.map((s) => s.toJson()).toList());
    await box.put('timestamp', timestamp);
    print('📦 Stations mises en cache via Hive.');
  }

  Future<List<StationModel>?> getCachedStations() async {
    final box = Hive.box('stationsBox');
    final jsonList = box.get('data');
    final timestamp = box.get('timestamp');

    if (jsonList == null || timestamp == null) return null;

    final cacheAge = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
    if (cacheAge > _cacheTTL) return null;

    return (jsonList as List)
        .map((e) => StationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

  }

  /// 💾 Caching des prélèvements avec Hive
  Future<void> cachePrelevements(List<Prelevement> prelevements) async {
    final box = Hive.box('prelevementsBox');
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await box.put('data', prelevements.map((p) => p.toJson()).toList());
    await box.put('timestamp', timestamp);
    print('📦 Prélèvements mis en cache via Hive.');
  }

  Future<List<Prelevement>?> getCachedPrelevements() async {
    final box = Hive.box('prelevementsBox');
    final jsonList = box.get('data');
    final timestamp = box.get('timestamp');

    if (jsonList == null || timestamp == null) return null;

    final cacheAge = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
    if (cacheAge > _cacheTTL) return null;

    return (jsonList as List)
        .map((e) => Prelevement.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Prelevement>> fetchPrelevementsWithCache() async {
    final cached = await getCachedPrelevements();
    if (cached != null) return cached;

    final prelevements = await fetchAllPrelevementsSimple();
    await cachePrelevements(prelevements);
    return prelevements;
  }
}
