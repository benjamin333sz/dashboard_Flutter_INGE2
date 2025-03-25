import "package:dio/dio.dart" as dio_http;
import '../model/station_model.dart';

class StationData {
  final String stationUrl = 'https://hubeau.eaufrance.fr/api/v1/etat_piscicole/stations';
  final dio_http.Dio dio = dio_http.Dio();

  Future<List<StationModel>> fetchStations() async {
    try {
      dio_http.Response response = await dio.get(stationUrl); //'$stationUrl?code_departement=59'

      if (response.statusCode == 200 || response.statusCode == 206) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => StationModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Erreur lors de la récupération des stations : $e');
      return [];
    }
  }
}
