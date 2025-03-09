import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/result_model.dart';

class ResultData {
  static const String baseUrl = 'https://hubeau.eaufrance.fr/api/v1/etat_piscicole/indicateurs';

  static Future<List<ResultModel>> fetchFishData({int page = 1}) async {
    final url = Uri.parse('$baseUrl?page=$page&size=10');
    final response = await http.get(url);

    if (response.statusCode == 200 || response.statusCode == 206) {
      final utf8Response = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = jsonDecode(utf8Response);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((json) => ResultModel.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}