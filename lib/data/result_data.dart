import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/result_model.dart';

class ResultData {
  static Future<List<ResultModel>> fetchFishData() async {
    final url = Uri.parse('https://hubeau.eaufrance.fr/api/v1/etat_piscicole/indicateurs?code_commune=01249');
    final response = await http.get(url);

    if (response.statusCode == 200 || response.statusCode == 206) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => ResultModel.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}
