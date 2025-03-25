import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/result_data.dart';
import '../model/result_model.dart';



final searchProvider = StateProvider<String>((ref) => '');

final fishDataProvider = StateNotifierProvider<FishDataNotifier, List<ResultModel>>((ref) {
  final searchQuery = ref.watch(searchProvider);
  return FishDataNotifier(searchQuery);
});

class FishDataNotifier extends StateNotifier<List<ResultModel>> {
  FishDataNotifier(this._searchQuery) : super([]) {
    fetchMoreData();
  }

  int _page = 1;
  bool _hasMoreData = true;
  bool _isLoading = false;
  String _searchQuery;

  bool get hasMoreData => _hasMoreData;

  Future<void> fetchMoreData() async {
    if (_isLoading || !_hasMoreData) return;

    _isLoading = true;
    final newData = await ResultData.fetchFishData(page: _page, libelle_station: _searchQuery);

    if (newData.isEmpty) {
      _hasMoreData = false;
    } else {
      state = [...state, ...newData];
      _page++;
    }

    _isLoading = false;
  }


  Future<void> fetchStationData(String stationName) async {
    if (_isLoading) return;

    _isLoading = true;
    final newData = await ResultData.fetchFishData(libelle_station: stationName);

    if (newData.isNotEmpty) {
      final existingCodes = state.map((e) => e.codeOperation).toSet();
      final filteredData = newData.where((e) => !existingCodes.contains(e.codeOperation)).toList();

      if (filteredData.isNotEmpty) {
        state = [...state, ...filteredData];
      }
    }

    _isLoading = false;
  }

  void resetData(String newSearchQuery) {
    state = [];
    _page = 1;
    _hasMoreData = true;
    _searchQuery = newSearchQuery;
    fetchMoreData();
  }
}



