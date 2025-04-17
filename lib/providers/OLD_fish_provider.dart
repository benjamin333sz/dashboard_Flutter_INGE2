import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/OLD_result_data.dart';
import '../model/OLD_prelevement_model.dart';
import '../model/station_model.dart';
import '../data/station_data.dart';


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







class StationNotifier extends StateNotifier<AsyncValue<List<StationModel>>> {
  final StationData _stationData;

  StationNotifier(this._stationData) : super(const AsyncValue.loading()) {
    fetchStations();
  }

  Future<void> fetchStations() async {
    try {
      final stations = await _stationData.fetchStations();
      state = AsyncValue.data(stations);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Provider global
final stationProvider = StateNotifierProvider<StationNotifier, AsyncValue<List<StationModel>>>(
      (ref) => StationNotifier(StationData()),
);








