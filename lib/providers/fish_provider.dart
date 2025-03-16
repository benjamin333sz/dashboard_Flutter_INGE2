import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/result_data.dart';
import '../model/result_model.dart';



final searchProvider = StateProvider<String>((ref) => '');

final fishDataProvider = FutureProvider<List<ResultModel>>((ref) async {
  final searchQuery = ref.watch(searchProvider);
  return ResultData.fetchFishData(libelle_station: searchQuery);
});

